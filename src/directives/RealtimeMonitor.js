// Realtime Monitor Directive
// Provides real-time monitoring and debugging for Supabase realtime usage
import { ref, onMounted, onUnmounted } from 'vue'
import { realtimeManager } from '@/composables/useRealtimeManager.js'

export function useRealtimeMonitor() {
  const isMonitoring = ref(false)
  const metrics = ref({
    totalEvents: 0,
    eventsPerSecond: 0,
    activeSubscriptions: 0,
    dataTransferred: 0, // Estimated
    connectionErrors: 0,
    lastEventTime: null,
  })

  let monitoringInterval = null
  let eventCount = 0
  let lastMetricsReset = Date.now()

  const startMonitoring = () => {
    if (isMonitoring.value) return

    isMonitoring.value = true
    console.log('🔍 Starting realtime monitoring...')

    // Monitor subscription statistics
    monitoringInterval = setInterval(() => {
      const stats = realtimeManager.subscriptionStats.value
      const now = Date.now()
      const timeDelta = (now - lastMetricsReset) / 1000 // seconds

      metrics.value = {
        totalEvents: eventCount,
        eventsPerSecond: eventCount / timeDelta,
        activeSubscriptions: stats.totalSubscriptions,
        dataTransferred: estimateDataTransferred(stats),
        connectionErrors: stats.connectionErrors || 0,
        lastEventTime: stats.lastActivity,
      }

      // Log warnings for high usage
      if (metrics.value.eventsPerSecond > 5) {
        console.warn(
          `⚠️ High realtime activity: ${metrics.value.eventsPerSecond.toFixed(2)} events/sec`
        )
      }

      if (metrics.value.activeSubscriptions > 10) {
        console.warn(
          `⚠️ High subscription count: ${metrics.value.activeSubscriptions} active subscriptions`
        )
      }

      // Reset counters every minute
      if (timeDelta > 60) {
        eventCount = 0
        lastMetricsReset = now
      }
    }, 5000) // Update every 5 seconds
  }

  const stopMonitoring = () => {
    if (!isMonitoring.value) return

    isMonitoring.value = false
    if (monitoringInterval) {
      clearInterval(monitoringInterval)
      monitoringInterval = null
    }
    console.log('🛑 Realtime monitoring stopped')
  }

  const estimateDataTransferred = (stats) => {
    // Rough estimation: each event ~1KB + subscription overhead
    const eventsData = eventCount * 1024 // bytes
    const subscriptionOverhead = stats.totalSubscriptions * 512 // bytes per subscription
    return (eventsData + subscriptionOverhead) / 1024 // KB
  }

  const logDetailedStats = () => {
    const subscriptions = realtimeManager.getAllSubscriptions()
    console.group('📊 Realtime Statistics')
    console.log('Active Subscriptions:', subscriptions.length)
    subscriptions.forEach((sub) => {
      console.log(
        `  - ${sub.name}: ${sub.table} (${sub.eventCount} events, ${(sub.activeTime / 1000).toFixed(1)}s active)`
      )
    })
    console.log('Metrics:', metrics.value)
    console.groupEnd()
  }

  const enforceLimits = () => {
    const subscriptions = realtimeManager.getAllSubscriptions()

    // Remove inactive subscriptions (no events for 5 minutes)
    const staleThreshold = 5 * 60 * 1000 // 5 minutes
    const now = Date.now()

    subscriptions.forEach((sub) => {
      const activeTime = now - sub.createdAt.getTime()
      if (activeTime > staleThreshold && sub.eventCount === 0) {
        console.warn(`🗑️ Removing stale subscription: ${sub.name}`)
        realtimeManager.removeSubscription(sub.name)
      }
    })

    // Limit total subscriptions
    if (subscriptions.length > 15) {
      console.warn(
        `⚠️ Too many subscriptions (${subscriptions.length}), removing oldest inactive ones`
      )
      const sortedByAge = subscriptions.sort((a, b) => a.createdAt - b.createdAt)
      const toRemove = sortedByAge.slice(0, subscriptions.length - 15)
      toRemove.forEach((sub) => realtimeManager.removeSubscription(sub.name))
    }
  }

  // Auto-enforce limits every 2 minutes
  const enforceInterval = setInterval(enforceLimits, 120000)

  onMounted(() => {
    startMonitoring()
  })

  onUnmounted(() => {
    stopMonitoring()
    clearInterval(enforceInterval)
  })

  // Global error monitoring
  const originalError = console.error
  console.error = (...args) => {
    if (args[0] && typeof args[0] === 'string' && args[0].includes('realtime')) {
      metrics.value.connectionErrors++
    }
    originalError.apply(console, args)
  }

  return {
    isMonitoring,
    metrics,
    startMonitoring,
    stopMonitoring,
    logDetailedStats,
    enforceLimits,
  }
}

// Export for use in components
export const realtimeMonitor = useRealtimeMonitor()
