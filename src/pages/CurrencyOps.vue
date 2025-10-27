<template>
  <div class="min-h-0 bg-gray-50 p-6" :style="{ marginRight: isInventoryOpen ? '380px' : '0' }">
    <!-- Header -->
    <div class="mb-6">
      <div class="bg-gradient-to-r from-green-600 to-emerald-600 text-white p-6 rounded-xl shadow-lg">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4">
            <div
              class="w-14 h-14 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm"
            >
              <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
              </svg>
            </div>
            <div>
              <h1 class="text-2xl font-bold">Vận hành Currency</h1>
              <p class="text-green-100 text-sm mt-1">{{ contextString }}</p>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <n-button
              type="primary"
              size="medium"
              class="bg-white/20 hover:bg-white/30 text-white border-white/30 backdrop-blur-sm"
              @click="isInventoryOpen = !isInventoryOpen"
            >
              <template #icon>
                <svg
                  v-if="!isInventoryOpen"
                  class="w-5 h-5"
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
                <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </template>
              {{ isInventoryOpen ? 'Đóng Inventory' : 'Xem Inventory' }}
            </n-button>
          </div>
        </div>
      </div>
    </div>

    <!-- Inventory Summary -->
    <div class="mb-6">
      <GameServerSelector
        ref="gameServerSelectorRef"
        :key="`game-server-${currentGame?.value}-${currentServer?.value}`"
        @game-changed="onGameChanged"
        @server-changed="onServerChanged"
        @context-changed="onContextChanged"
      />
    </div>

    <!-- Main Tabs -->
    <div class="bg-white border border-gray-200 rounded-xl">
      <div class="flex">
        <button
          :class="[
            'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
            activeTab === 'exchange'
              ? 'tab-active text-blue-600'
              : 'tab-inactive text-gray-500 hover:text-gray-700',
          ]"
          @click="activeTab = 'exchange'"
        >
          <svg class="w-4 h-4 tab-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          Đổi Currency
        </button>
        <button
          :class="[
            'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
            activeTab === 'delivery'
              ? 'tab-active text-green-600'
              : 'tab-inactive text-gray-500 hover:text-gray-700',
          ]"
          @click="activeTab = 'delivery'"
        >
          <svg class="w-4 h-4 tab-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          Giao nhận Currency
        </button>
        <button
          :class="[
            'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
            activeTab === 'history'
              ? 'tab-active text-purple-600'
              : 'tab-inactive text-gray-500 hover:text-gray-700',
          ]"
          @click="activeTab = 'history'"
        >
          <svg class="w-4 h-4 tab-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          Lịch Sử Giao Dịch
        </button>
      </div>
    </div>

    <!-- Tab Content -->
    <div class="flex-1">
      <!-- Tab Đổi Currency -->
      <div v-if="activeTab === 'exchange'" class="tab-pane">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div class="p-6">
            <div class="flex items-center gap-2 mb-6">
              <svg
                class="w-6 h-6 text-green-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"
                />
              </svg>
              <h2 class="text-lg font-semibold text-gray-800">Đổi currency</h2>
            </div>

            
            <!-- Render form directly - useCurrency handles loading automatically -->
            <ExchangeCurrencyForm
              ref="exchangeFormRef"
              :key="`exchange-form-${currentGame?.value}-${currentServer?.value}`"
              :currencies="filteredCurrencies"
              :account-options="accountOptions"
              :loading="areCurrenciesLoading"
              :loading-accounts="loadingAccounts"
              :submitting="submittingExchange"
              @submit="handleExchangeSubmit"
              @reset="handleExchangeReset"
            />
          </div>
        </div>
      </div>

      <!-- Tab Giao nhận Currency -->
      <div v-if="activeTab === 'delivery'" class="tab-pane">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div class="p-6">
            <div class="flex items-center gap-2 mb-6">
              <svg
                class="w-6 h-6 text-blue-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 7l5 5m0 0l-5 5m5-5H6"
                />
              </svg>
              <h2 class="text-lg font-semibold text-gray-800">Giao nhận Currency</h2>
            </div>

            <DataListCurrency
              model-type="delivery"
              title="Quản lý giao nhận Currency"
              description="Xử lý các đơn hàng mua/bán currency đang được giao"
              :data="deliveryOrders"
              :loading="loadingDelivery"
              @search="handleDeliverySearch"
              @filter="handleDeliveryFilter"
              @export="handleDeliveryExport"
              @view-detail="handleDeliveryViewDetail"
              @update-status="handleDeliveryUpdateStatus"
            />
          </div>
        </div>
      </div>

      <!-- Tab Lịch Sử Giao Dịch -->
      <div v-if="activeTab === 'history'" class="tab-pane">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div class="p-6">
            <div class="flex items-center gap-2 mb-6">
              <svg
                class="w-6 h-6 text-purple-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <h2 class="text-lg font-semibold text-gray-800">Lịch sử giao dịch</h2>
            </div>

            <DataListCurrency
              model-type="history"
              title="Lịch sử giao dịch Currency"
              description="Xem lại các giao dịch đã hoàn thành"
              :data="transactionHistory"
              :loading="loadingHistory"
              @search="handleHistorySearch"
              @filter="handleHistoryFilter"
              @export="handleHistoryExport"
              @view-detail="handleHistoryViewDetail"
            />
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Inventory Panel as true sidebar -->
  <CurrencyInventoryPanel
    v-if="isInventoryOpen"
    :is-open="isInventoryOpen"
    :inventory-data="inventoryByCurrency"
    @close="isInventoryOpen = false"
  />
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import {
  NButton,
  useMessage,
} from 'naive-ui'

// Import components
import GameServerSelector from '@/components/currency/GameServerSelector.vue'
import CurrencyInventoryPanel from '@/components/currency/CurrencyInventoryPanel.vue'
import ExchangeCurrencyForm from '@/components/currency/ExchangeCurrencyForm.vue'
import DataListCurrency from '@/components/currency/DataListCurrency.vue'

// Import composables
import { useGameContext } from '@/composables/useGameContext.js'
import { useCurrency } from '@/composables/useCurrency.js'
import { useInventory } from '@/composables/useInventory.js'
import type { Currency, GameAccount } from '@/types/composables'
import { supabase } from '@/lib/supabase'

// --- KHỞI TẠO ---
const message = useMessage()

// --- COMPOSABLES ---
const {
  currentGame,
  currentServer,
  contextString,
  initializeFromStorage,
} = useGameContext()

const {
  allCurrencies,
  initialize: initializeCurrency,
} = useCurrency()

const { inventoryByCurrency, gameAccounts, loadAccounts } = useInventory()

// Manual currency loading function using attribute_relationships
const loadCurrenciesForCurrentGame = async () => {
  if (!currentGame.value) {
    // No current game, cannot load currencies
    return
  }
  try {
    // First get the game attribute ID
    const { data: gameData, error: gameError } = await supabase
      .from('attributes')
      .select('id')
      .eq('code', currentGame.value)
      .eq('type', 'GAME')
      .single()

    if (gameError || !gameData) {
      console.error('❌ Game not found:', gameError)
      throw new Error(`Game ${currentGame.value} not found`)
    }

    // Then load GAME_CURRENCY type currencies linked to this game via attribute_relationships
    // Use a different approach - query from attribute_relationships directly
    const { data: relationshipData, error: relationshipError } = await supabase
      .from('attribute_relationships')
      .select(`
        child_attribute_id
      `)
      .eq('parent_attribute_id', gameData.id)

    if (relationshipError) {
      console.error('❌ Error loading attribute relationships:', relationshipError)
      throw relationshipError
    }

    // Get the currency attribute IDs
    const currencyIds = relationshipData?.map(rel => rel.child_attribute_id) || []

    if (currencyIds.length === 0) {
      console.log('ℹ️ No currencies found for game:', currentGame.value)
      console.log('✅ No currencies to load - this is normal for some games')
      return
    }

    // Now load the actual currency attributes
    const { data, error } = await supabase
      .from('attributes')
      .select('*')
      .in('id', currencyIds)
      .eq('type', 'GAME_CURRENCY')
      .eq('is_active', true)
      .order('sort_order', { ascending: true })

    if (error) {
      console.error('❌ Error loading currencies via attribute_relationships:', error)

      // Fallback to previous method
      const gameInfo = currentGame.value === 'POE_2' ? { currencyPrefix: 'CURRENCY_POE2' } :
                       currentGame.value === 'POE_1' ? { currencyPrefix: 'CURRENCY_POE1' } :
                       currentGame.value === 'DIABLO_4' ? { currencyPrefix: 'CURRENCY_D4' } : null
      if (!gameInfo) {
        console.error('❌ Unknown game, cannot load currencies')
        return
      }

      const { error: fallbackError } = await supabase
        .from('attributes')
        .select('*')
        .eq('type', gameInfo.currencyPrefix)
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      if (fallbackError) {
        console.error('❌ Error in fallback currency loading:', fallbackError)
        throw fallbackError
      }
    }

    // The currencies are already loaded into useCurrency.allCurrencies via initializeCurrency
    // We need to ensure they're properly loaded

  } catch (err) {
    console.error('❌ Error in manual currency loading:', err)
    throw err
  }
}

// --- TRẠNG THÁI (STATE) ---
const isInventoryOpen = ref(false)
const activeTab = ref('exchange')
const loadingAccounts = ref(false)
const areCurrenciesLoading = ref(false)
const isDataLoading = ref(false)

// Exchange form state
const submittingExchange = ref(false)

// Delivery orders state
const deliveryOrders = ref<any[]>([])
const loadingDelivery = ref(false)

// Transaction history state
const transactionHistory = ref<any[]>([])
const loadingHistory = ref(false)

// Exchange form reference
const exchangeFormRef = ref()

// --- COMPUTED ---
const filteredCurrencies = computed(() => {
  // Don't show any options if currencies are still loading
  if (areCurrenciesLoading.value || !allCurrencies.value || !currentGame?.value) {
    return []
  }

  
  const filtered = allCurrencies.value.filter((currency: Currency) => {
    // All currencies should now be GAME_CURRENCY type loaded via attribute_relationships
    return currency.type === 'GAME_CURRENCY' && currency.is_active !== false
  })

  const result = filtered.map((currency: Currency) => ({
    // Use safe property access with fallbacks to prevent undefined/null values
    label: currency.name || currency.code || `Currency ${currency.id.slice(0, 8)}...`,
    value: currency.id,
    data: currency, // ← Thêm data property như trong CurrencyCreateOrders
  }))

  
  return result
})


const accountOptions = computed(() => {
  try {
    return (gameAccounts.value || [])
      .filter((acc: GameAccount) => acc && acc.name && acc.id)
      .map((acc: GameAccount) => ({ label: acc.name, value: acc.id }))
  } catch (error) {
    console.error('Error in accountOptions computed:', error)
    return []
  }
})



// --- METHODS ---
// Load all necessary data
const loadData = async () => {
  try {
    isDataLoading.value = true
    areCurrenciesLoading.value = true // Start currency loading

    // First ensure game context is initialized

    await initializeFromStorage()
    // Wait for game context to be available
    let retries = 0
    while ((!currentGame.value || !currentServer.value) && retries < 10) {

      await new Promise(resolve => setTimeout(resolve, 500))
      retries++
    }
    if (!currentGame.value || !currentServer.value) {
      console.error('❌ Game context not available after retries')
      throw new Error('Game context not available')
    }

    // Now initialize currency composable properly (same pattern as GameLeagueSelector)

    await initializeCurrency()
    // Manual currency loading to ensure currencies are loaded

    await loadCurrenciesForCurrentGame()
    // Give a moment for reactive updates to propagate
    await new Promise(resolve => setTimeout(resolve, 100))

    // Load accounts
    await loadAccounts()

    // Load mock data for demo
    loadMockData()
  } catch {
    message.error('Không thể tải dữ liệu')
  } finally {
    isDataLoading.value = false
    areCurrenciesLoading.value = false // Currency loading complete
  }
}


const initializeComponent = async () => {
  try {
    // Use the same loading pattern as CurrencyCreateOrders
    await loadData()
  } catch (error) {
    message.error('Không thể khởi tạo dữ liệu')
    console.error(error)
  }
}

// Exchange handlers
const handleExchangeSubmit = async (data: any) => {
  submittingExchange.value = true
  try {
    // TODO: Implement exchange API call
    message.success('Đổi currency thành công!')
  } catch (error) {
    message.error('Lỗi khi đổi currency.')
    console.error(error)
  } finally {
    submittingExchange.value = false
  }
}

const handleExchangeReset = () => {
  message.info('Form đã được reset.')
}

// Delivery handlers
const handleDeliverySearch = () => {
  // Handle delivery search
}

const handleDeliveryFilter = () => {
  // Handle delivery filter
}

const handleDeliveryExport = () => {
  message.info('Xuất file danh sách giao nhận...')
}

const handleDeliveryViewDetail = () => {
  // Handle delivery view detail
}

const handleDeliveryUpdateStatus = () => {
  message.success('Cập nhật trạng thái thành công')
}

// History handlers
const handleHistorySearch = () => {
  // Handle history search
}

const handleHistoryFilter = () => {
  // Handle history filter
}

const handleHistoryExport = () => {
  message.info('Xuất file lịch sử giao dịch...')
}

const handleHistoryViewDetail = () => {
  // Handle history view detail
}

// Game context handlers
const onGameChanged = async (gameCode: string) => {
  // Update useGameContext state
  currentGame.value = gameCode
  currentServer.value = null // Reset server when game changes

  // Reset all forms when game changes
  resetAllForms()
  // Data will be reloaded automatically by useGameContext
}

const onServerChanged = async (serverCode: string) => {
  // Update useGameContext state
  currentServer.value = serverCode

  // Reset all forms when server changes
  resetAllForms()
  // Data will be reloaded automatically by useGameContext
}

const onContextChanged = async (context: { hasContext: boolean }) => {
  if (context.hasContext) {
    await loadData()
  } else {
    // Reset forms when no context
    resetAllForms()
  }
}

// Reset all forms when game/league changes
const resetAllForms = () => {
  // ExchangeCurrencyForm doesn't have resetForm method, it has internal reset logic
  // The form will be reset automatically via key prop change when game changes
  // No additional reset logic needed for ExchangeCurrencyForm
}

// Mock data for demo
const loadMockData = () => {
  // Mock delivery orders
  deliveryOrders.value = [
    {
      id: 'DEL001',
      type: 'purchase',
      customerName: 'Nguyễn Văn A',
      currencyName: 'Chaos Orb',
      amount: 100,
      status: 'pending',
      channelName: 'Facebook',
      deliveryInfo: 'Giao tại khu vực quận 1',
      notes: 'Khách hàng yêu cầu giao nhanh',
      createdAt: new Date().toISOString()
    },
    {
      id: 'DEL002',
      type: 'sell',
      customerName: 'Trần Thị B',
      currencyName: 'Exalted Orb',
      amount: 50,
      status: 'delivering',
      channelName: 'Zalo',
      deliveryInfo: 'Giao tại khu vực quận 3',
      notes: 'Đã xác nhận với khách hàng',
      createdAt: new Date().toISOString()
    }
  ]

  // Mock transaction history
  transactionHistory.value = [
    {
      id: 'HIS001',
      type: 'purchase',
      customerName: 'Lê Văn C',
      currencyName: 'Divine Orb',
      amount: 25,
      status: 'completed',
      totalPrice: 25000000,
      paymentMethod: 'Chuyển khoản',
      notes: 'Giao dịch thành công',
      createdAt: new Date(Date.now() - 86400000).toISOString()
    },
    {
      id: 'HIS002',
      type: 'exchange',
      customerName: 'Phạm Thị D',
      currencyName: 'Chaos Orb',
      amount: 200,
      status: 'completed',
      totalPrice: 0,
      paymentMethod: 'Đổi currency',
      notes: 'Đổi 200 Chaos Orb lấy 10 Divine Orb',
      createdAt: new Date(Date.now() - 172800000).toISOString()
    }
  ]
}

// Watch for game/server changes to reload inventory
watch([currentGame, currentServer], async () => {
  // Only proceed if we have both game and server
  if (!currentGame.value || !currentServer.value) return
    // Reset forms - this will set currencyId to null briefly
  resetAllForms()
  // Immediately load new data to minimize flicker
  await loadData()
})

// --- LIFECYCLE ---
onMounted(async () => {
  await initializeComponent()
})

</script>

<style scoped>
.tab-pane {
  animation: fadeInUp 0.3s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

</style>
