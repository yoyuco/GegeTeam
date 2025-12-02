// Global Order Manager
// Singleton pattern to prevent multiple instances of order fetching
import { reactive, onUnmounted } from 'vue'
import { useCurrencyOrders } from '@/composables/useCurrencyOrders.js'

class OrderManager {
  constructor() {
    this.instance = null
    this.isInitialized = false
    this.subscribers = new Set()
    this.globalStats = reactive({
      totalFetches: 0,
      successfulFetches: 0,
      failedFetches: 0,
      lastFetchTime: null,
      currentLoaders: 0,
      activeInstances: 0,
    })
  }

  getInstance() {
    if (!this.instance) {
      this.instance = useCurrencyOrders()
      this.isInitialized = true
      console.log('🏭 OrderManager: Created singleton instance')
    }
    this.globalStats.activeInstances++
    return this.instance
  }

  releaseInstance() {
    this.globalStats.activeInstances--
    if (this.globalStats.activeInstances === 0) {
      console.log('🏭 OrderManager: No active instances, cleaning up')
      this.instance?.stopAutoRefresh?.()
    }
  }

  subscribe(callback) {
    this.subscribers.add(callback)
    return () => this.subscribers.delete(callback)
  }

  notifySubscribers(event, data) {
    this.subscribers.forEach((callback) => {
      try {
        callback(event, data)
      } catch (error) {
        console.error('OrderManager subscriber error:', error)
      }
    })
  }

  getStats() {
    return {
      ...this.globalStats,
      subscribersCount: this.subscribers.size,
      isInitialized: this.isInitialized,
    }
  }
}

// Export singleton instance
export const orderManager = new OrderManager()

// Export composable that uses the singleton
export function useOrderManager() {
  const ordersInstance = orderManager.getInstance()

  // Wrap fetchOrders with global tracking
  const trackedFetchOrders = async (filters = {}) => {
    orderManager.globalStats.totalFetches++
    orderManager.globalStats.currentLoaders++
    orderManager.globalStats.lastFetchTime = new Date().toISOString()

    try {
      await ordersInstance.fetchOrders(filters)
      orderManager.globalStats.successfulFetches++
      orderManager.notifySubscribers('fetch-success', {
        filters,
        count: ordersInstance.orders.value?.length || 0,
      })
    } catch (error) {
      orderManager.globalStats.failedFetches++
      orderManager.notifySubscribers('fetch-error', { filters, error: error.message })
      throw error
    } finally {
      orderManager.globalStats.currentLoaders--
    }
  }

  // Auto-cleanup on component unmount
  onUnmounted(() => {
    orderManager.releaseInstance()
  })

  return {
    ...ordersInstance,
    fetchOrders: trackedFetchOrders,
    globalStats: orderManager.globalStats,
    subscribe: orderManager.subscribe.bind(orderManager),
    getManagerStats: orderManager.getStats.bind(orderManager),
  }
}
