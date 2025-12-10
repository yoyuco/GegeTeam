<!-- path: src/components/currency/CurrencyInventoryPanel.vue -->
<!-- Enhanced Currency Inventory Panel with 2 tabs - Push Style -->
<template>
  <!-- Slide-out panel - no overlay, pure push style -->
  <div v-if="isOpen" class="inventory-panel">
    <div class="bg-white h-full flex flex-col">
      <!-- Header -->
      <div class="bg-gradient-to-r from-indigo-600 to-purple-600 text-white p-4 rounded-t-lg">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                />
              </svg>
            </div>
            <div>
              <h3 class="font-bold text-lg">Quản lý Kho Currency</h3>
              <p class="text-indigo-100 text-sm">{{ displayInventoryData.length }} loại currency</p>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="flex items-center gap-2">
            <!-- Inventory Overview Button -->
            <button
              @click="showInventoryOverview = true"
              class="w-8 h-8 bg-white/20 hover:bg-white/30 text-white rounded-lg flex items-center justify-center transition-all duration-200 border border-white/10"
              title="Xem tổng quan toàn bộ inventory"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                />
              </svg>
            </button>
          </div>
          <button
            class="w-8 h-8 bg-white/20 hover:bg-white/30 rounded-lg flex items-center justify-center transition-colors"
            @click="$emit('close')"
          >
            <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>
      </div>

      <!-- Game Server Info Display (No Selector - Panel is too small) -->
      <div v-if="activeGame" class="bg-gray-50 border-b border-gray-200 p-3">
        <div class="flex items-center gap-2 text-sm">
          <span class="font-medium text-gray-700">Bối cảnh:</span>
          <n-tag type="info" size="small">{{ getGameDisplayName(activeGame) }}</n-tag>
          <span v-if="activeServer" class="text-gray-400">•</span>
          <n-tag v-if="activeServer" type="default" size="small">{{ getServerDisplayName(activeServer) }}</n-tag>
        </div>
      </div>
      <div v-else class="bg-yellow-50 border-b border-yellow-200 p-3">
        <div class="flex items-center gap-2 text-sm text-yellow-800">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
          <span>Vui lòng chọn game và server trong trang chính</span>
        </div>
      </div>

      <!-- Tabs Navigation -->
      <div class="bg-white border-b border-gray-200">
        <div class="flex">
          <button
            @click="activeTab = 'inventory'"
            :class="[
              'flex-1 py-3 px-4 text-center font-medium text-sm transition-colors',
              activeTab === 'inventory'
                ? 'text-indigo-600 border-b-2 border-indigo-600 bg-indigo-50'
                : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50'
            ]"
          >
            <div class="flex items-center justify-center gap-2">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                />
              </svg>
              Inventory
            </div>
          </button>
          <button
            @click="activeTab = 'transfer'"
            :class="[
              'flex-1 py-3 px-4 text-center font-medium text-sm transition-colors',
              activeTab === 'transfer'
                ? 'text-indigo-600 border-b-2 border-indigo-600 bg-indigo-50'
                : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50'
            ]"
          >
            <div class="flex items-center justify-center gap-2">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"
                />
              </svg>
              Chuyển Currency
            </div>
          </button>
        </div>
      </div>

      <!-- Tab Content -->
      <div class="flex-1 overflow-hidden">
        <n-scrollbar style="max-height: calc(100vh - 180px)">
          <!-- Inventory Tab -->
          <div v-if="activeTab === 'inventory'" class="p-4">
            <!-- Summary Stats -->
            <div class="grid grid-cols-2 gap-3 mb-6">
              <div class="bg-blue-50 border border-blue-200 rounded-lg p-3">
                <div class="flex items-center gap-2">
                  <div class="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center">
                    <svg
                      class="w-3 h-3 text-blue-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                      />
                    </svg>
                  </div>
                  <div>
                    <p class="text-xs text-blue-600 font-medium">Tổng giá trị</p>
                    <p class="text-sm font-bold text-blue-900">{{ formatCurrency(totalValue) }} ₫</p>
                  </div>
                </div>
              </div>
              <div class="bg-green-50 border border-green-200 rounded-lg p-3">
                <div class="flex items-center gap-2">
                  <div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center">
                    <svg
                      class="w-3 h-3 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                      />
                    </svg>
                  </div>
                  <div>
                    <p class="text-xs text-green-600 font-medium">Đang giữ</p>
                    <p class="text-sm font-bold text-green-900">
                      {{ formatQuantity(totalReserved) }}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Currency Items -->
            <div v-if="displayInventoryData.length === 0" class="text-center py-8">
              <div
                class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4"
              >
                <svg
                  class="w-8 h-8 text-gray-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                  />
                </svg>
              </div>
              <h3 class="text-gray-900 font-medium mb-1">Chưa có dữ liệu</h3>
              <p class="text-gray-500 text-sm">Chưa có currency trong kho</p>
            </div>

            <div v-else class="space-y-3">
              <!-- Group data by currency (unique currency names) -->
              <template v-for="currency in groupedCurrencies" :key="(currency as any).currency_name">
              <div
                v-if="currency && currency.currency_name"
                class="bg-white border border-gray-200 rounded-xl overflow-hidden hover:shadow-lg transition-all duration-200"
              >
                <!-- Currency Header (Clickable) -->
                <div
                  :class="getCurrencyColorClass((currency as any).currency_name)"
                  class="p-4 text-white cursor-pointer hover:opacity-90 transition-opacity"
                  @click="toggleCurrencyExpanded((currency as any).currency_name)"
                >
                  <div class="flex items-center justify-between">
                    <div class="flex items-center gap-3">
                      <div class="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center backdrop-blur">
                        <span class="text-white font-bold text-lg">{{ ((currency as any).currency_name || '').charAt(0) }}</span>
                      </div>
                      <div>
                        <h4 class="font-bold text-lg">{{ (currency as any).currency_name || 'Unknown Currency' }}</h4>
                        <!-- Average Price Display -->
                        <div v-if="currencyAveragePrices[(currency as any).currency_name]?.hasPoolData && currencyAveragePrices[(currency as any).currency_name]?.averagePriceVND > 0"
                             class="text-xs font-bold text-white mt-1">
                          Giá TB: {{ formatCurrency(currencyAveragePrices[(currency as any).currency_name]?.averagePriceVND) }} VND
                        </div>
                      </div>
                    </div>
                    <div class="flex items-center gap-4">
                      <div class="text-right">
                        <div class="bg-blue-100 text-blue-700 text-sm px-2 py-1 rounded-full font-medium inline-block mb-1">
                          {{ formatQuantity((currency as any).totalQuantity) }}
                        </div>
                        <p v-if="(currency as any).totalReserved > 0" class="text-indigo-200 text-xs">
                          Ordered: {{ formatQuantity((currency as any).totalReserved) }}
                        </p>
                      </div>
                      <!-- Expand/Collapse Icon -->
                      <div class="transition-transform duration-200" :class="{ 'rotate-180': isCurrencyExpanded((currency as any).currency_name) }">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                        </svg>
                      </div>
                    </div>
                  </div>
                  <!-- Total Value Bar -->
                  <div class="mt-3 pt-3 border-t border-white/20">
                    <div class="flex justify-between items-center">
                      <span class="text-indigo-100 text-xs">Tổng giá trị</span>
                      <span class="text-white font-bold">{{ formatCurrency((currency as any).totalValueVND) }} ₫</span>
                    </div>
                  </div>
                </div>

                <!-- Cost Currency Sections (Kho VND/CNY) - Only show when expanded -->
                <div v-show="isCurrencyExpanded((currency as any).currency_name)" class="p-4 space-y-3">
                  <div
                    v-for="costCurrency in ['VND', 'CNY']"
                    :key="costCurrency"
                    v-show="(currency as any).costCurrencies[costCurrency]?.accounts?.length > 0"
                  >
                    <!-- Cost Currency Header -->
                    <div class="flex items-center gap-2 mb-3">
                      <div class="w-6 h-6 bg-gradient-to-br from-green-500 to-emerald-600 rounded flex items-center justify-center">
                        <span class="text-white font-bold text-xs">{{ costCurrency }}</span>
                      </div>
                      <div>
                        <h5 class="font-semibold text-gray-900 text-sm">Kho {{ costCurrency }}</h5>
                        <p class="text-xs text-gray-500">
                          Giá TB: {{ formatCurrency((currency as any).costCurrencies[costCurrency]?.avgCost || 0, costCurrency) }} {{ costCurrency }}
                        </p>
                      </div>
                      <div class="ml-auto text-right">
                        <p class="font-bold text-sm text-gray-900">{{ formatQuantity((currency as any).costCurrencies[costCurrency]?.totalQuantity || 0) }}</p>
                        <p v-if="(currency as any).costCurrencies[costCurrency]?.totalReserved > 0" class="text-xs text-orange-600">
                          +{{ formatQuantity((currency as any).costCurrencies[costCurrency]?.totalReserved || 0) }}
                        </p>
                      </div>
                    </div>

                    <!-- Accounts List -->
                    <div class="ml-4 space-y-2">
                      <div
                        v-for="account in ((currency as any).costCurrencies[costCurrency]?.accounts || [])"
                        :key="(account as any).name"
                        v-show="((account as any).quantity || 0) > 0 || ((account as any).reserved || 0) > 0"
                        class="flex items-center justify-between bg-gray-50 rounded-lg p-2 hover:bg-gray-100 transition-colors"
                      >
                        <div class="flex items-center gap-2 min-w-0 flex-1">
                          <div class="w-5 h-5 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                            <svg class="w-2.5 h-2.5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                            </svg>
                          </div>
                          <div class="min-w-0 flex-1">
                            <p class="text-xs font-medium text-gray-900 truncate">{{ (account as any).name || 'Unknown Account' }}</p>
                            <p class="text-xs text-gray-500">{{ formatCurrency((account as any).avgCost || 0, costCurrency) }} {{ costCurrency }}</p>
                            <!-- Removed channel display from account level -->
                          </div>
                        </div>
                        <div class="text-right ml-2">
                          <p class="font-bold text-xs text-gray-900">{{ formatQuantity((account as any).quantity || 0) }}</p>
                          <p v-if="(account as any).reserved > 0" class="text-xs text-orange-600">+{{ formatQuantity((account as any).reserved || 0) }}</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              </template>
            </div>
          </div>

          <!-- Transfer Tab -->
          <div v-if="activeTab === 'transfer'" class="p-0">
            <TransferCurrencyTab
              :game-code="activeGame"
              :server-code="activeServer"
              @transfer-completed="handleTransferCompleted"
            />
          </div>
        </n-scrollbar>
      </div>
    </div>
  </div>

  
  <!-- Inventory Overview Modal -->
  <InventoryOverviewModal
    v-if="showInventoryOverview"
    :is-open="showInventoryOverview"
    @close="showInventoryOverview = false"
  />
</template>

<script setup lang="ts">
import { computed, ref, watch, onUnmounted, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { NScrollbar, NTag } from 'naive-ui'
import { supabase } from '@/lib/supabase'
import { useInventory } from '@/composables/useInventory.js'
import { useGameContext } from '@/composables/useGameContext.js'
import { useExchangeRates } from '@/composables/useExchangeRates'
import TransferCurrencyTab from './TransferCurrencyTab.vue'
import InventoryOverviewModal from './InventoryOverviewModal.vue'

// Props để nhận trạng thái từ component cha
const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  // Optional: có thể nhận game và server từ bên ngoài để override
  gameCode: {
    type: String,
    default: undefined
  },
  serverCode: {
    type: String,
    default: undefined
  }
})

// Emits
defineEmits<{
  close: []
}>()

// Router and route for URL state management
const router = useRouter()
const route = useRoute()

// Tab state
const activeTab = ref('inventory')

// Modal state with URL persistence
const showInventoryOverview = ref(false)

// Initialize modal state from URL
const initializeModalState = () => {
  const urlParams = new URLSearchParams(window.location.search)
  const overviewModal = urlParams.get('overviewModal')
  showInventoryOverview.value = overviewModal === 'true'
}

// Update URL when modal state changes
const updateModalStateInUrl = (isOpen: boolean) => {
  const url = new URL(window.location.href)
  if (isOpen) {
    url.searchParams.set('overviewModal', 'true')
  } else {
    url.searchParams.delete('overviewModal')
  }

  // Update URL without page reload
  window.history.replaceState({}, '', url.toString())
}

// Watch for modal state changes and update URL
watch(showInventoryOverview, (newValue) => {
  updateModalStateInUrl(newValue)
})

// Track expanded state for currencies
const expandedCurrencies = ref<Set<string>>(new Set())

// Average prices for currencies (cached)
const currencyAveragePrices = ref<{ [key: string]: { averagePriceVND: number; hasPoolData: boolean } }>({})


// Use composables
const { currentGame, currentServer } = useGameContext()
const { loadExchangeRates, convertToVND } = useExchangeRates()
const {
  loadInventoryForGameServer,
  formatCurrency,
  formatQuantity,
  getGameDisplayName,
  getServerDisplayName
} = useInventory()

// Computed game và server để sử dụng
const activeGame = computed(() => props.gameCode || currentGame.value)
const activeServer = computed(() => props.serverCode || currentServer.value)

// Local state để xử lý game/server thay đổi
const localGameData = ref<any[]>([])

// Computed totals based on grouped currencies data
const totalValue = computed(() => {
  return groupedCurrencies.value.reduce((total: number, currency: any) => {
    return total + (currency.totalValueVND || 0)
  }, 0)
})

const totalReserved = computed(() => {
  return groupedCurrencies.value.reduce((total: number, currency: any) => {
    return total + (currency.totalReserved || 0)
  }, 0)
})

const handleTransferCompleted = async () => {
  await loadInventoryData()
}

// Toggle expanded state for a currency
const toggleCurrencyExpanded = (currencyName: string) => {
  const newSet = new Set(expandedCurrencies.value)
  if (newSet.has(currencyName)) {
    newSet.delete(currencyName)
  } else {
    newSet.add(currencyName)
  }
  expandedCurrencies.value = newSet
}

// Check if a currency is expanded
const isCurrencyExpanded = (currencyName: string) => {
  return expandedCurrencies.value.has(currencyName)
}

// Calculate average price for a specific currency across all pools
const calculateCurrencyAveragePrice = async (currencyName: string) => {
  if (!activeGame.value || !activeServer.value || !currencyName) {
    return
  }
  try {
    // First, find the currency attribute ID for the given currency name
    const { data: currencyData, error: currencyError } = await supabase
      .from('attributes')
      .select('id')
      .eq('name', currencyName)
      .eq('is_active', true)
      .limit(1)

    if (currencyError) throw currencyError
    if (!currencyData || currencyData.length === 0) {
      return
    }

    const currencyAttributeId = currencyData[0].id

    // Query all pools for this currency
    const { data, error } = await supabase
      .from('inventory_pools')
      .select('average_cost, cost_currency, quantity')
      .eq('game_code', activeGame.value)
      .eq('server_attribute_code', activeServer.value || '')
      .eq('currency_attribute_id', currencyAttributeId)
      .gt('quantity', 0)

    if (error) throw error

    if (data && data.length > 0) {
      // Calculate weighted average price in VND
      let totalValueVND = 0
      let totalQuantity = 0

      for (const pool of data) {
        const quantity = parseFloat(pool.quantity) || 0
        const avgCost = parseFloat(pool.average_cost) || 0
        const costCurrency = pool.cost_currency || 'VND'

        try {
          const valueInVND = convertToVND(avgCost * quantity, costCurrency)
          totalValueVND += valueInVND
          totalQuantity += quantity
        } catch (conversionError) {
          console.error('Currency conversion error in calculateCurrencyAveragePrice:', conversionError)
        }
      }

      const averagePriceVND = totalQuantity > 0 ? totalValueVND / totalQuantity : 0

      currencyAveragePrices.value[currencyName] = {
        averagePriceVND,
        hasPoolData: true
      }
    } else {
      // No pool data found
      currencyAveragePrices.value[currencyName] = {
        averagePriceVND: 0,
        hasPoolData: false
      }
    }
  } catch (err) {
    console.error('Error calculating currency average price:', err)
    currencyAveragePrices.value[currencyName] = {
      averagePriceVND: 0,
      hasPoolData: false
    }
  }
}

// Realtime subscription for currency inventory
let currencyInventorySubscription: any = null

// Setup realtime subscription for currency inventory changes
const setupInventoryRealtimeSubscription = () => {
  // Clean up existing subscription
  if (currencyInventorySubscription) {
    currencyInventorySubscription.unsubscribe()
  }

  // Subscribe to currency inventory changes
  currencyInventorySubscription = supabase
    .channel('currency-inventory-panel-changes')
    .on(
      'postgres_changes',
      {
        event: '*', // Listen to all changes (INSERT, UPDATE, DELETE)
        schema: 'public',
        table: 'currency_inventory'
      },
      async (payload) => {
        console.log('Currency inventory panel change detected:', payload)

        // Reload inventory data when panel is open
        if (props.isOpen) {
          await loadInventoryData()
        }
      }
    )
    .subscribe((status) => {
      if (status === 'SUBSCRIBED') {
        console.log('Realtime subscription established for currency inventory panel')
      } else if (status === 'CHANNEL_ERROR') {
        console.error('Realtime subscription error for currency inventory panel')
      }
    })
}

// Cleanup realtime subscription
const cleanupInventoryRealtimeSubscription = () => {
  if (currencyInventorySubscription) {
    supabase.removeChannel(currencyInventorySubscription)
    currencyInventorySubscription = null
    console.log('Currency inventory panel realtime subscription cleaned up')
  }
}

// Ensure exchange rates are loaded on mount
onMounted(async () => {
  try {
    // Initialize modal state from URL
    initializeModalState()

    await loadExchangeRates()

    // Setup realtime subscription when panel opens
    if (props.isOpen) {
      setupInventoryRealtimeSubscription()
    }
  } catch (error) {
    console.error('CurrencyInventoryPanel: Failed to load exchange rates:', error)
  }
})

// Watch for panel open/close
watch(() => props.isOpen, (isOpen) => {
  if (isOpen) {
    // Setup realtime subscription when panel opens
    setupInventoryRealtimeSubscription()
  } else {
    // Cleanup when panel closes
    cleanupInventoryRealtimeSubscription()
  }
})

// Cleanup on component unmount
onUnmounted(() => {
  cleanupInventoryRealtimeSubscription()
})

// Generate different colors for different currencies
const getCurrencyColorClass = (currencyName: string) => {
  const colorMap: { [key: string]: string } = {
    'Chaos Orb': 'bg-gradient-to-r from-red-500 to-orange-600',
    'Exalted Orb': 'bg-gradient-to-r from-yellow-500 to-amber-600',
    'Divine Orb': 'bg-gradient-to-r from-purple-500 to-pink-600',
    'Mirror of Kalandra': 'bg-gradient-to-r from-teal-500 to-cyan-600',
    'Lifeforce': 'bg-gradient-to-r from-green-500 to-emerald-600',
    'Primalist': 'bg-gradient-to-r from-indigo-500 to-blue-600',
    'Ritual': 'bg-gradient-to-r from-violet-500 to-purple-600',
    'Delirium': 'bg-gradient-to-r from-pink-500 to-rose-600',
    'Breach': 'bg-gradient-to-r from-orange-500 to-red-600',
    'Essence': 'bg-gradient-to-r from-blue-500 to-indigo-600',
    'Mapping': 'bg-gradient-to-r from-emerald-500 to-green-600',
    'Metamorph': 'bg-gradient-to-r from-cyan-500 to-teal-600'
  }

  // Return mapped color or generate one based on hash of name
  if (colorMap[currencyName]) {
    return colorMap[currencyName]
  }

  // Generate consistent color based on string hash
  let hash = 0
  for (let i = 0; i < currencyName.length; i++) {
    hash = currencyName.charCodeAt(i) + ((hash << 5) - hash)
  }

  const colorOptions = [
    'bg-gradient-to-r from-blue-500 to-indigo-600',
    'bg-gradient-to-r from-green-500 to-emerald-600',
    'bg-gradient-to-r from-purple-500 to-pink-600',
    'bg-gradient-to-r from-orange-500 to-red-600',
    'bg-gradient-to-r from-teal-500 to-cyan-600',
    'bg-gradient-to-r from-yellow-500 to-amber-600',
    'bg-gradient-to-r from-red-500 to-pink-600',
    'bg-gradient-to-r from-indigo-500 to-purple-600'
  ]

  return colorOptions[Math.abs(hash) % colorOptions.length]
}

const loadInventoryData = async () => {
  if (activeGame.value && activeServer.value) {
    try {
      // Load exchange rates first
      await loadExchangeRates()

      const data = await loadInventoryForGameServer(activeGame.value, activeServer.value)
      localGameData.value = data || []

      // Calculate average prices directly from inventory data
      for (const item of data || []) {
        if (item.currency_name && item.totalQuantity > 0) {
          const averagePriceVND = item.totalValueVND / item.totalQuantity

          currencyAveragePrices.value[item.currency_name] = {
            averagePriceVND,
            hasPoolData: true
          }
        }
      }
    } catch (err) {
      console.error('CurrencyInventoryPanel: Failed to load inventory data:', err)
      localGameData.value = []
    }
  } else {
    localGameData.value = []
  }
}


// Watch for game/server changes
watch(
  [activeGame, activeServer],
  () => {
    loadInventoryData()
  },
  { immediate: true }
)

const displayInventoryData = computed(() => {
  return localGameData.value
})

// Group data by unique currency names for the new structure
const groupedCurrencies = computed(() => {
  const currencyMap: Record<string, any> = {}

  displayInventoryData.value.forEach((item: any) => {
    if (!item || !item.currency_name) return

    const currencyName = item.currency_name

    if (!currencyMap[currencyName]) {
      currencyMap[currencyName] = {
        currency_name: currencyName,
        totalQuantity: 0,
        totalReserved: 0,
        totalValueVND: 0,
        costCurrencies: {}
      }
    }

    const currency = currencyMap[currencyName]
    currency.totalQuantity += item.totalQuantity || 0
    currency.totalReserved += item.totalReserved || 0
    currency.totalValueVND += item.totalValueVND || 0

    // Process cost currencies
    if (item.costCurrencies && typeof item.costCurrencies === 'object') {
      Object.entries(item.costCurrencies).forEach(([costCurrency, costData]: [string, any]) => {
        if (!costData || typeof costData !== 'object') return // Skip invalid costData

        if (!currency.costCurrencies[costCurrency]) {
          currency.costCurrencies[costCurrency] = {
            avgCost: 0,
            totalQuantity: 0,
            totalReserved: 0,
            accounts: []
          }
        }

        const costCurrencyGroup = currency.costCurrencies[costCurrency]
        costCurrencyGroup.totalQuantity += costData.totalQuantity || 0
        costCurrencyGroup.totalReserved += costData.totalReserved || 0

        // Weighted average cost calculation
        const oldQuantity = costCurrencyGroup.totalQuantity - (costData.totalQuantity || 0)
        const totalCost = costCurrencyGroup.avgCost * oldQuantity + (costData.avgCost || 0) * (costData.totalQuantity || 0)
        costCurrencyGroup.avgCost = costCurrencyGroup.totalQuantity > 0 ? totalCost / costCurrencyGroup.totalQuantity : (costData.avgCost || 0)

        if (Array.isArray(costData.accounts)) {
          costCurrencyGroup.accounts.push(...costData.accounts)
        }
      })
    }
  })

  return Object.values(currencyMap)
})

// Toggle body margin to push content when panel opens/closes
watch(
  () => props.isOpen,
  (isOpen: boolean) => {
    if (isOpen) {
      document.body.style.marginRight = '380px'
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.marginRight = '0'
      document.body.style.overflow = ''
    }
  }
)

onUnmounted(() => {
  // Clean up styles when component is unmounted
  document.body.style.marginRight = '0'
  document.body.style.overflow = ''
})
</script>

<style scoped>
.inventory-panel {
  position: fixed;
  right: 0;
  top: 0;
  bottom: 0;
  width: 380px;
  background: #ffffff;
  border-left: 1px solid #e5e7eb;
  z-index: 10;
  transform: translateX(0);
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: -2px 0 10px rgba(0, 0, 0, 0.05);
}

/* Panel animation */
.inventory-panel {
  animation: slideIn 0.3s ease-out;
  height: 100vh;
  overflow: hidden;
}

/* Body transition for smooth push effect */
:global(body) {
  transition: margin-right 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

/* Custom scrollbar styling */
:deep(.n-scrollbar-rail) {
  background-color: #f3f4f6;
  border-radius: 4px;
}

:deep(.n-scrollbar-bar) {
  background-color: #9ca3af;
  border-radius: 4px;
}

:deep(.n-scrollbar-bar:hover) {
  background-color: #6b7280;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .inventory-panel {
    width: 100vw;
  }
}

@media (max-width: 640px) {
  .inventory-panel {
    width: 100vw;
  }
}

/* Hover effects for interactive elements */
.inventory-panel .hover\:shadow-md:hover {
  box-shadow:
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Transition for all interactive elements */
.inventory-panel * {
  transition: all 0.2s ease-in-out;
}

/* Improve readability */
.inventory-panel {
  font-family:
    'Inter',
    -apple-system,
    BlinkMacSystemFont,
    'Segoe UI',
    Roboto,
    sans-serif;
}

/* Add subtle borders and shadows */
.inventory-panel .border-gray-200 {
  border-color: #e5e7eb;
}

.inventory-panel .shadow-md {
  box-shadow:
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Custom styles for inventory overview button */
.inventory-overview-button {
  /* Ensure button is always visible */
  pointer-events: auto !important;
}

.inventory-overview-button:hover {
  transform: scale(1.1);
}

.inventory-overview-tooltip {
  /* Ensure tooltip doesn't cause overflow issues */
  max-width: 200px;
}
</style>
