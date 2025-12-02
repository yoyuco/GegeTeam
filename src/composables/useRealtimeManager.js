// Realtime Manager Composable
// Centralized management of Supabase realtime subscriptions to optimize egress
import { ref, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabase'

// Global subscription registry
const activeSubscriptions = new Map()
const subscriptionStats = ref({
  totalSubscriptions: 0,
  activeConnections: 0,
  lastActivity: null,
})

export function useRealtimeManager() {
  /**
   * Create a managed realtime subscription with proper cleanup
   * @param {string} name - Unique subscription name
   * @param {string} table - Table name to subscribe to
   * @param {Function} callback - Callback function for events
   * @param {Object} options - Additional options (filter, schema, etc.)
   * @returns {Object} - Subscription control object
   */
  const createSubscription = (name, table, callback, options = {}) => {
    // Clean up existing subscription if it exists
    if (activeSubscriptions.has(name)) {
      removeSubscription(name)
    }

    const { filter = '', schema = 'public', event = '*' } = options

    console.log(`🔄 Creating realtime subscription: ${name} -> ${table}`)

    const channel = supabase
      .channel(`managed-${name}-${Date.now()}`)
      .on(
        'postgres_changes',
        {
          event,
          schema,
          table,
          ...(filter && { filter }),
        },
        (payload) => {
          console.log(`📨 Realtime event [${name}]:`, payload.eventType, payload.table)
          subscriptionStats.value.lastActivity = new Date().toISOString()
          callback(payload)
        }
      )
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          console.log(`✅ Realtime subscription active: ${name}`)
        } else if (status === 'CHANNEL_ERROR') {
          console.error(`❌ Realtime subscription error: ${name}`)
          removeSubscription(name)
        }
      })

    const subscription = {
      name,
      table,
      channel,
      callback,
      options,
      createdAt: new Date(),
      lastEvent: null,
      eventCount: 0,
    }

    activeSubscriptions.set(name, subscription)
    updateStats()

    return {
      name,
      isActive: true,
      unsubscribe: () => removeSubscription(name),
      getStats: () => ({
        ...subscription,
        activeTime: Date.now() - subscription.createdAt.getTime(),
        eventCount: subscription.eventCount,
      }),
    }
  }

  /**
   * Remove a subscription by name
   */
  const removeSubscription = (name) => {
    const subscription = activeSubscriptions.get(name)
    if (subscription) {
      console.log(`🗑️ Removing realtime subscription: ${name}`)
      supabase.removeChannel(subscription.channel)
      activeSubscriptions.delete(name)
      updateStats()
    }
  }

  /**
   * Remove all subscriptions
   */
  const removeAllSubscriptions = () => {
    console.log(`🧹 Removing all ${activeSubscriptions.size} realtime subscriptions`)
    activeSubscriptions.forEach((subscription) => {
      supabase.removeChannel(subscription.channel)
    })
    activeSubscriptions.clear()
    updateStats()
  }

  /**
   * Get subscription by name
   */
  const getSubscription = (name) => {
    return activeSubscriptions.get(name)
  }

  /**
   * Check if subscription exists
   */
  const hasSubscription = (name) => {
    return activeSubscriptions.has(name)
  }

  /**
   * Get all active subscriptions
   */
  const getAllSubscriptions = () => {
    return Array.from(activeSubscriptions.values()).map((sub) => ({
      name: sub.name,
      table: sub.table,
      createdAt: sub.createdAt,
      eventCount: sub.eventCount,
      activeTime: Date.now() - sub.createdAt.getTime(),
    }))
  }

  /**
   * Update subscription statistics
   */
  const updateStats = () => {
    subscriptionStats.value = {
      totalSubscriptions: activeSubscriptions.size,
      activeConnections: activeSubscriptions.size,
      lastActivity: subscriptionStats.value.lastActivity,
      subscriptions: getAllSubscriptions(),
    }
  }

  /**
   * Debounced subscription creator to prevent rapid reconnections
   */
  const debouncedSubscription = (() => {
    const timeouts = new Map()

    return (name, table, callback, options = {}, delay = 1000) => {
      // Clear existing timeout for this name
      if (timeouts.has(name)) {
        clearTimeout(timeouts.get(name))
      }

      // Set new timeout
      const timeoutId = setTimeout(() => {
        createSubscription(name, table, callback, options)
        timeouts.delete(name)
      }, delay)

      timeouts.set(name, timeoutId)
    }
  })()

  /**
   * Auto-cleanup on component unmount
   */
  const autoCleanup = (subscriptionNames) => {
    onUnmounted(() => {
      subscriptionNames.forEach((name) => {
        removeSubscription(name)
      })
    })
  }

  /**
   * Health check for subscriptions
   */
  const healthCheck = () => {
    const staleThreshold = 5 * 60 * 1000 // 5 minutes
    const now = Date.now()
    const staleSubscriptions = []

    activeSubscriptions.forEach((subscription, name) => {
      const activeTime = now - subscription.createdAt.getTime()
      if (activeTime > staleThreshold && subscription.eventCount === 0) {
        staleSubscriptions.push(name)
      }
    })

    if (staleSubscriptions.length > 0) {
      console.warn(`⚠️ Found ${staleSubscriptions.length} stale subscriptions:`, staleSubscriptions)
      staleSubscriptions.forEach((name) => removeSubscription(name))
    }

    return {
      healthy: activeSubscriptions.size > 0,
      staleCount: staleSubscriptions.length,
      activeCount: activeSubscriptions.size,
    }
  }

  // Set up periodic health check
  const healthCheckInterval = setInterval(healthCheck, 60000) // Check every minute

  // Cleanup interval on composable cleanup
  onUnmounted(() => {
    clearInterval(healthCheckInterval)
  })

  return {
    // State
    subscriptionStats,

    // Methods
    createSubscription,
    removeSubscription,
    removeAllSubscriptions,
    getSubscription,
    hasSubscription,
    getAllSubscriptions,
    debouncedSubscription,
    autoCleanup,
    healthCheck,

    // Utilities
    updateStats,
  }
}

// Export singleton instance for global management
export const realtimeManager = useRealtimeManager()
