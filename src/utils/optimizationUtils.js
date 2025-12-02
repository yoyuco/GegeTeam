// Optimization utilities for reducing network requests and egress
import { ref, onUnmounted } from 'vue'

// Global state for tracking background operations
const backgroundOperations = ref({
  activePolls: new Map(),
  lastRequests: new Map(),
  requestCounts: new Map(),
})

/**
 * Optimized polling with intelligent frequency adjustment
 */
export function useOptimizedPolling() {
  const createSmartPoll = (name, callback, options = {}) => {
    const {
      baseInterval = 30000, // 30 seconds base
      maxInterval = 300000, // 5 minutes max
      inactivityThreshold = 60000, // 1 minute of inactivity
      backoffMultiplier = 1.5,
      maxBackoffAttempts = 5,
    } = options

    let pollInterval = baseInterval
    let pollTimer = null
    let lastActivity = Date.now()
    let consecutiveEmptyResults = 0
    let backoffAttempts = 0

    const poll = async () => {
      try {
        const result = await callback()

        if (result && result.length > 0) {
          // Reset on successful data
          consecutiveEmptyResults = 0
          backoffAttempts = 0
          pollInterval = baseInterval
          lastActivity = Date.now()
        } else {
          // Back off on empty results
          consecutiveEmptyResults++
          if (consecutiveEmptyResults >= 3 && backoffAttempts < maxBackoffAttempts) {
            pollInterval = Math.min(pollInterval * backoffMultiplier, maxInterval)
            backoffAttempts++
            console.log(
              `📉 Polling ${name}: backing off to ${pollInterval / 1000}s (empty results: ${consecutiveEmptyResults})`
            )
          }
        }

        // Check for user inactivity
        const timeSinceActivity = Date.now() - lastActivity
        if (timeSinceActivity > inactivityThreshold) {
          pollInterval = Math.min(pollInterval * 2, maxInterval)
          console.log(
            `😴 Polling ${name}: inactive user, extending interval to ${pollInterval / 1000}s`
          )
        }
      } catch (error) {
        console.error(`❌ Polling ${name} error:`, error)
        // Back off on errors
        pollInterval = Math.min(pollInterval * 2, maxInterval)
      }

      // Schedule next poll
      scheduleNextPoll()
    }

    const scheduleNextPoll = () => {
      if (pollTimer) clearTimeout(pollTimer)
      pollTimer = setTimeout(poll, pollInterval)
    }

    const start = () => {
      console.log(`🚀 Starting optimized polling: ${name} (${pollInterval / 1000}s interval)`)
      backgroundOperations.value.activePolls.set(name, {
        interval: pollInterval,
        started: new Date(),
        callback,
      })
      scheduleNextPoll()
    }

    const stop = () => {
      if (pollTimer) {
        clearTimeout(pollTimer)
        pollTimer = null
      }
      backgroundOperations.value.activePolls.delete(name)
      console.log(`🛑 Stopped polling: ${name}`)
    }

    const updateActivity = () => {
      lastActivity = Date.now()
      // Reset interval if user becomes active
      if (pollInterval > baseInterval) {
        pollInterval = baseInterval
        console.log(`👤 User activity detected for ${name}, resetting to ${pollInterval / 1000}s`)
      }
    }

    const getStatus = () => ({
      name,
      interval: pollInterval,
      consecutiveEmptyResults,
      backoffAttempts,
      timeSinceActivity: Date.now() - lastActivity,
    })

    return {
      start,
      stop,
      updateActivity,
      getStatus,
    }
  }

  /**
   * Batch multiple requests into single calls
   */
  const createBatchRequester = (name, requestFn, options = {}) => {
    const {
      batchSize = 10,
      batchTimeout = 1000, // 1 second
      maxBatchDelay = 5000, // 5 seconds max wait
    } = options

    let pendingRequests = []
    let batchTimer = null

    const processBatch = async () => {
      if (pendingRequests.length === 0) return

      const batch = pendingRequests.splice(0, batchSize)
      console.log(`📦 Processing batch for ${name}: ${batch.length} requests`)

      try {
        const results = await requestFn(batch)

        // Resolve individual promises
        batch.forEach((request, index) => {
          if (request.resolve) {
            request.resolve(results[index] || results)
          }
        })
      } catch (error) {
        // Reject all promises in batch
        batch.forEach((request) => {
          if (request.reject) {
            request.reject(error)
          }
        })
      }

      // Schedule next batch if there are more requests
      if (pendingRequests.length > 0) {
        scheduleBatch()
      }
    }

    const scheduleBatch = () => {
      if (batchTimer) clearTimeout(batchTimer)
      batchTimer = setTimeout(processBatch, batchTimeout)
    }

    const addRequest = (requestData) => {
      return new Promise((resolve, reject) => {
        pendingRequests.push({
          data: requestData,
          resolve,
          reject,
          timestamp: Date.now(),
        })

        // Process immediately if batch is full or max delay reached
        if (
          pendingRequests.length >= batchSize ||
          (pendingRequests.length > 0 && Date.now() - pendingRequests[0].timestamp > maxBatchDelay)
        ) {
          processBatch()
        } else if (!batchTimer) {
          scheduleBatch()
        }
      })
    }

    const flush = () => {
      if (batchTimer) {
        clearTimeout(batchTimer)
        batchTimer = null
      }
      return processBatch()
    }

    onUnmounted(() => {
      flush()
    })

    return {
      add: addRequest,
      flush,
    }
  }

  /**
   * Request deduplication - cache identical requests
   */
  const createDeduplicator = (name, requestFn, options = {}) => {
    const {
      cacheTimeout = 5000, // 5 seconds
      maxCacheSize = 100,
    } = options

    const cache = new Map()
    const pendingRequests = new Map()

    const getCacheKey = (params) => {
      return JSON.stringify(params)
    }

    const cleanExpiredCache = () => {
      const now = Date.now()
      for (const [key, entry] of cache.entries()) {
        if (now - entry.timestamp > cacheTimeout) {
          cache.delete(key)
        }
      }

      // Remove oldest entries if cache is too large
      if (cache.size > maxCacheSize) {
        const entries = Array.from(cache.entries()).sort((a, b) => a[1].timestamp - b[1].timestamp)
        entries.slice(0, entries.length - maxCacheSize).forEach(([key]) => {
          cache.delete(key)
        })
      }
    }

    const request = async (params) => {
      const cacheKey = getCacheKey(params)

      // Check cache first
      const cached = cache.get(cacheKey)
      if (cached && Date.now() - cached.timestamp < cacheTimeout) {
        console.log(`💾 Cache hit for ${name}: ${cacheKey}`)
        return cached.data
      }

      // Check if same request is already pending
      if (pendingRequests.has(cacheKey)) {
        console.log(`⏳ Request deduplicated for ${name}: ${cacheKey}`)
        return pendingRequests.get(cacheKey)
      }

      // Make new request
      const promise = requestFn(params)
      pendingRequests.set(cacheKey, promise)

      try {
        const result = await promise

        // Cache result
        cache.set(cacheKey, {
          data: result,
          timestamp: Date.now(),
        })

        console.log(`🆕 New request for ${name}: ${cacheKey}`)
        return result
      } finally {
        pendingRequests.delete(cacheKey)
        cleanExpiredCache()
      }
    }

    return {
      request,
    }
  }

  return {
    backgroundOperations,
    createSmartPoll,
    createBatchRequester,
    createDeduplicator,
  }
}

// Export singleton instance
export const optimizationUtils = useOptimizedPolling()
