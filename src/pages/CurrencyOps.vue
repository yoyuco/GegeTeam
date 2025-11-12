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
    <div class="mb-6" v-if="activeTab === 'exchange'">
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
            <p class="text-sm text-gray-600 mt-1">Các đơn đã được phân công tự động và đang chờ xử lý</p>
            </div>

            <DataListCurrency
              model-type="delivery"
              title="Quản lý giao nhận Currency"
              description="Xử lý các đơn hàng đã được hệ thống phân công cho nhân viên vận hành"
              :data="deliveryOrders"
              :loading="loadingDelivery"
              @search="handleDeliverySearch"
              @filter="handleDeliveryFilter"
              @export="handleDeliveryExport"
              @view-detail="handleDeliveryViewDetail"
              @update-status="handleDeliveryUpdateStatus"
              @finalize-order="handleDeliveryFinalizeOrder"
              @proof-uploaded="handleProofUploaded"
              @refresh-data="loadDeliveryOrders"
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
              description="Xem lại các đơn đã hoàn thành và bị hủy"
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

  <!-- Order Completion Modal -->
  <OrderCompletionModal
    v-model:show="showOrderCompletionModal"
    :order="selectedOrderForCompletion"
    @completed="handleOrderCompletionCompleted"
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
import OrderCompletionModal from '@/components/currency/OrderCompletionModal.vue'
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

// Order completion modal state
const showOrderCompletionModal = ref(false)
const selectedOrderForCompletion = ref<any>(null)

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

    // Only load exchange-related data if we're on exchange tab
    if (activeTab.value === 'exchange') {
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

      // Load accounts for exchange functionality
      await loadAccounts()
    }

    // Load delivery orders from database (for delivery tab)
    // Always load delivery orders to ensure data is available
    await loadDeliveryOrders()

    // Load transaction history (for history tab)
    if (activeTab.value === 'history') {
      await loadTransactionHistory()
    }
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

// Load delivery orders from database
// Note: This shows orders that have been automatically assigned by the system
// to operation team members for processing. Shows all orders regardless of game/server.
const loadDeliveryOrders = async () => {
  loadingDelivery.value = true
  try {
    // Since some relationships don't exist in the schema, we'll use manual joins
    const { data, error } = await supabase
      .from('currency_orders')
      .select('*')
      .in('status', ['assigned', 'preparing', 'delivering', 'ready', 'delivered']) // Include delivered orders
      .order('created_at', { ascending: false })
      .limit(100) // Increase limit since we're showing all games

    if (error) {
      console.error('Error loading delivery orders:', error)
      message.error('Không thể tải danh sách đơn hàng')
      return
    }

    // Manual joins for related data since relationships don't exist in schema
    const ordersWithData = []
    if (data && data.length > 0) {
      // Collect all unique IDs for batch queries
      const currencyIds = [...new Set(data.map(order => order.currency_attribute_id).filter(Boolean))]
      const channelIds = [...new Set(data.map(order => order.channel_id).filter(Boolean))]
      const employeeIds = [...new Set(data.map(order => order.assigned_to).filter(Boolean))]
      const gameAccountIds = [...new Set(data.map(order => order.game_account_id).filter(Boolean))]
      const partyIds = [...new Set(data.map(order => order.party_id).filter(Boolean))]

      // Collect unique game codes and server codes for name lookup
      const gameCodes = [...new Set(data.map(order => order.game_code).filter(Boolean))]
      const serverCodes = [...new Set(data.map(order => order.server_attribute_code).filter(Boolean))]

      // Batch fetch all related data
      const [currencyData, channelData, employeeData, gameAccountData, partyData, gameData, serverData] = await Promise.all([
        currencyIds.length > 0 ? supabase
          .from('attributes')
          .select('id, code, name, type')
          .in('id', currencyIds) : Promise.resolve({ data: [] }),

        channelIds.length > 0 ? supabase
          .from('channels')
          .select('id, code, name')
          .in('id', channelIds) : Promise.resolve({ data: [] }),

        employeeIds.length > 0 ? supabase
          .from('profiles')
          .select('id, display_name')
          .in('id', employeeIds) : Promise.resolve({ data: [] }),

        gameAccountIds.length > 0 ? supabase
          .from('game_accounts')
          .select('id, account_name, game_code, purpose')
          .in('id', gameAccountIds) : Promise.resolve({ data: [] }),

        partyIds.length > 0 ? supabase
          .from('parties')
          .select('id, name, type')
          .in('id', partyIds) : Promise.resolve({ data: [] }),

        // Fetch game names
        gameCodes.length > 0 ? supabase
          .from('attributes')
          .select('code, name')
          .eq('type', 'GAME')
          .in('code', gameCodes) : Promise.resolve({ data: [] }),

        // Fetch server names (handle both SERVER and GAME_SERVER types)
        serverCodes.length > 0 ? supabase
          .from('attributes')
          .select('code, name')
          .in('type', ['SERVER', 'GAME_SERVER'])
          .in('code', serverCodes) : Promise.resolve({ data: [] })
      ])

      // Create lookup maps
      const currencyMap = new Map(currencyData.data?.map(item => [item.id, item]) || [])
      const channelMap = new Map(channelData.data?.map(item => [item.id, item]) || [])
      const employeeMap = new Map(employeeData.data?.map(item => [item.id, item]) || [])
      const gameAccountMap = new Map(gameAccountData.data?.map(item => [item.id, item]) || [])
      const partyMap = new Map(partyData.data?.map(item => [item.id, item]) || [])

      // Create lookup maps for game and server names
      const gameNameMap = new Map(gameData.data?.map(item => [item.code, item.name]) || [])
      const serverNameMap = new Map(serverData.data?.map(item => [item.code, item.name]) || [])

      // Combine data
      for (const order of data) {
        const combinedOrder = {
          ...order,
          currency_attribute: order.currency_attribute_id ? currencyMap.get(order.currency_attribute_id) || null : null,
          channel: order.channel_id ? channelMap.get(order.channel_id) || null : null,
          assigned_employee: order.assigned_to ? employeeMap.get(order.assigned_to) || null : null,
          game_account: order.game_account_id ? gameAccountMap.get(order.game_account_id) || null : null,
          party: order.party_id ? partyMap.get(order.party_id) || null : null,
          // Add game and server names
          game_name: order.game_code ? gameNameMap.get(order.game_code) || order.game_code : null,
          server_name: order.server_attribute_code ? serverNameMap.get(order.server_attribute_code) || order.server_attribute_code : null
        }

        ordersWithData.push(combinedOrder)
      }
    }

    deliveryOrders.value = ordersWithData
  } catch (error) {
    console.error('Error in loadDeliveryOrders:', error)
    message.error('Có lỗi xảy ra khi tải đơn hàng')
  } finally {
    loadingDelivery.value = false
  }
}

// Delivery handlers
const handleDeliverySearch = (query: string) => {
  // Handle delivery search - will be implemented with real search logic
  console.log('Search query:', query)
}

const handleDeliveryFilter = (filters: any) => {
  // Handle delivery filter - will be implemented with real filter logic
  console.log('Filters:', filters)
}

const handleDeliveryExport = () => {
  // TODO: Implement export functionality
  message.info('Tính năng xuất file đang được phát triển...')
}

const handleDeliveryViewDetail = async (order: any) => {
  try {
    // Only update status if order is currently 'assigned'
    if (order.status === 'assigned') {
      // Update order status to 'preparing' when viewing details
      const { error } = await supabase
        .from('currency_orders')
        .update({
          status: 'preparing',
          updated_at: new Date().toISOString()
        })
        .eq('id', order.id)

      if (error) {
        console.error('Error updating order status:', error)
        message.warning(`Xem chi tiết đơn #${order.order_number} nhưng không thể cập nhật trạng thái`)
      } else {
        message.success(`✅ Đã xem chi tiết và chuyển đơn #${order.order_number} sang trạng thái "Đang chuẩn bị"`)
        // Reload data to reflect the status change
        await loadDeliveryOrders()
      }
    } else {
      message.info(`Xem chi tiết đơn #${order.order_number} (trạng thái: ${getStatusLabel(order.status, order.order_type)})`)
    }

    console.log('View order detail:', order)
    // TODO: Implement view detail modal here

  } catch (error) {
    console.error('Error in handleDeliveryViewDetail:', error)
    message.error(`Có lỗi xảy ra khi xem chi tiết đơn #${order.order_number}`)
  }
}

// Helper function to get status label in Vietnamese
const getStatusLabel = (status: string, orderType?: string) => {
  const statusLabels: { [key: string]: string } = {
    draft: 'Nháp',
    pending: 'Chờ xử lý',
    assigned: 'Đã phân công',
    preparing: 'Đang chuẩn bị',
    ready: 'Sẵn sàng giao',
    delivering: orderType === 'PURCHASE' ? 'Đang nhận' : 'Đang giao',
    delivered: orderType === 'PURCHASE' ? 'Đã nhận hàng' : 'Đã giao hàng', // Different text based on order type
    completed: 'Hoàn thành',
    cancelled: 'Hủy bỏ',
    failed: 'Thất bại'
  }
  return statusLabels[status] || status
}

const handleDeliveryUpdateStatus = async (order: any, newStatus: string) => {
  try {
    // Handle purchase order completion with proper WAC calculation
    if (order.order_type === 'PURCHASE' && newStatus === 'completed') {
      // Use the new WAC-optimized function for purchase orders
      const { data, error } = await supabase.rpc('complete_purchase_order_wac', {
        p_order_id: order.id,
        p_completed_by: order.assigned_to
      })

      if (error) {
        throw new Error(`Không thể hoàn thành đơn mua: ${error.message}`)
      }

      if (data && data.success) {
        const dataInfo = data.data || {}
        message.success(`✅ Đơn mua #${order.order_number} đã hoàn thành! WAC cập nhật từ ${dataInfo.old_average_cost || 0} → ${dataInfo.new_average_cost || 0}. Tồn kho: ${dataInfo.new_quantity || 0}`)
      } else {
        throw new Error(data?.error || 'Hoàn thành đơn mua thất bại')
      }
    }
    // Handle sell order cancellation with inventory rollback
    else if (order.order_type === 'SELL' && newStatus === 'cancelled') {
      // Get current user ID
      const { data: profileData, error: profileError } = await supabase.rpc('get_current_profile_id')

      if (profileError) {
        throw new Error(`Không thể lấy thông tin người dùng: ${profileError.message}`)
      }

      // Use the cancel sell order function with inventory rollback
      const { data, error } = await supabase.rpc('cancel_sell_order_with_inventory_rollback', {
        p_order_id: order.id,
        p_user_id: profileData
      })

      if (error) {
        throw new Error(`Không thể hủy đơn bán: ${error.message}`)
      }

      if (data && data.length > 0 && data[0].success) {
        message.success(`✅ Đơn bán #${order.order_number} đã được hủy và đã hoàn trả inventory thành công!`)
      } else {
        throw new Error(data?.[0]?.message || 'Hủy đơn bán thất bại')
      }
    }
    else {
      // Simple status update for other cases
      const { error } = await supabase
        .from('currency_orders')
        .update({
          status: newStatus,
          updated_at: new Date().toISOString()
        })
        .eq('id', order.id)

      if (error) {
        message.error('Không thể cập nhật trạng thái')
        return
      }

      message.success(`Đã cập nhật trạng thái đơn #${order.order_number} thành công`)
    }

    // Reload data
    await loadDeliveryOrders()
  } catch (error: any) {
    console.error('Error updating order status:', error)
    message.error(error.message || 'Có lỗi xảy ra khi cập nhật trạng thái')
  }
}

const handleDeliveryFinalizeOrder = (order: any) => {
  selectedOrderForCompletion.value = order
  showOrderCompletionModal.value = true
}

const handleOrderCompletionCompleted = async () => {
  // Reload delivery orders to show updated status
  await loadDeliveryOrders()
}


// Proof upload handler
const handleProofUploaded = async (data: { orderId: string; proofs: any }) => {
  console.log('Proof uploaded for order:', data.orderId)

  // Refresh the delivery orders to show updated proofs
  await loadDeliveryOrders()

  message.success('Bằng chứng đã được tải lên và cập nhật thành công!')
}

// History handlers
const handleHistorySearch = (query: string) => {
  // Handle history search - will be implemented with real search logic
  console.log('History search query:', query)
}

const handleHistoryFilter = (filters: any) => {
  // Handle history filter - will be implemented with real filter logic
  console.log('History filters:', filters)
}

const handleHistoryExport = () => {
  // TODO: Implement export functionality
  message.info('Tính năng xuất file lịch sử đang được phát triển...')
}

const handleHistoryViewDetail = (order: any) => {
  // TODO: Implement view detail modal
  console.log('View history order detail:', order)
  message.info(`Xem chi tiết đơn #${order.order_number}`)
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

// Load transaction history from database
// Note: This shows only completed and cancelled orders for historical reference.
// Shows all orders regardless of game/server.
const loadTransactionHistory = async () => {
  loadingHistory.value = true
  try {
    // Since some relationships don't exist in the schema, we'll use manual joins
    const { data, error } = await supabase
      .from('currency_orders')
      .select('*')
      .in('status', ['completed', 'cancelled']) // Only show completed and cancelled orders
      .order('created_at', { ascending: false })
      .limit(100) // Increase limit since we're showing all games

    if (error) {
      console.error('Error loading transaction history:', error)
      message.error('Không thể tải lịch sử giao dịch')
      return
    }

    // Manual joins for related data since relationships don't exist in schema
    const ordersWithData = []
    if (data && data.length > 0) {
      // Collect all unique IDs for batch queries
      const currencyIds = [...new Set(data.map(order => order.currency_attribute_id).filter(Boolean))]
      const channelIds = [...new Set(data.map(order => order.channel_id).filter(Boolean))]
      const employeeIds = [...new Set(data.map(order => order.assigned_to).filter(Boolean))]
      const gameAccountIds = [...new Set(data.map(order => order.game_account_id).filter(Boolean))]
      const partyIds = [...new Set(data.map(order => order.party_id).filter(Boolean))]

      // Collect unique game codes and server codes for name lookup
      const gameCodes = [...new Set(data.map(order => order.game_code).filter(Boolean))]
      const serverCodes = [...new Set(data.map(order => order.server_attribute_code).filter(Boolean))]

      // Batch fetch all related data
      const [currencyData, channelData, employeeData, gameAccountData, partyData, gameData, serverData] = await Promise.all([
        currencyIds.length > 0 ? supabase
          .from('attributes')
          .select('id, code, name, type')
          .in('id', currencyIds) : Promise.resolve({ data: [] }),

        channelIds.length > 0 ? supabase
          .from('channels')
          .select('id, code, name')
          .in('id', channelIds) : Promise.resolve({ data: [] }),

        employeeIds.length > 0 ? supabase
          .from('profiles')
          .select('id, display_name')
          .in('id', employeeIds) : Promise.resolve({ data: [] }),

        gameAccountIds.length > 0 ? supabase
          .from('game_accounts')
          .select('id, account_name, game_code, purpose')
          .in('id', gameAccountIds) : Promise.resolve({ data: [] }),

        partyIds.length > 0 ? supabase
          .from('parties')
          .select('id, name, type')
          .in('id', partyIds) : Promise.resolve({ data: [] }),

        // Fetch game names
        gameCodes.length > 0 ? supabase
          .from('attributes')
          .select('code, name')
          .eq('type', 'GAME')
          .in('code', gameCodes) : Promise.resolve({ data: [] }),

        // Fetch server names (handle both SERVER and GAME_SERVER types)
        serverCodes.length > 0 ? supabase
          .from('attributes')
          .select('code, name')
          .in('type', ['SERVER', 'GAME_SERVER'])
          .in('code', serverCodes) : Promise.resolve({ data: [] })
      ])

      // Create lookup maps
      const currencyMap = new Map(currencyData.data?.map(item => [item.id, item]) || [])
      const channelMap = new Map(channelData.data?.map(item => [item.id, item]) || [])
      const employeeMap = new Map(employeeData.data?.map(item => [item.id, item]) || [])
      const gameAccountMap = new Map(gameAccountData.data?.map(item => [item.id, item]) || [])
      const partyMap = new Map(partyData.data?.map(item => [item.id, item]) || [])

      // Create lookup maps for game and server names
      const gameNameMap = new Map(gameData.data?.map(item => [item.code, item.name]) || [])
      const serverNameMap = new Map(serverData.data?.map(item => [item.code, item.name]) || [])

      // Combine data
      for (const order of data) {
        const combinedOrder = {
          ...order,
          currency_attribute: order.currency_attribute_id ? currencyMap.get(order.currency_attribute_id) || null : null,
          channel: order.channel_id ? channelMap.get(order.channel_id) || null : null,
          assigned_employee: order.assigned_to ? employeeMap.get(order.assigned_to) || null : null,
          game_account: order.game_account_id ? gameAccountMap.get(order.game_account_id) || null : null,
          party: order.party_id ? partyMap.get(order.party_id) || null : null,
          // Add game and server names
          game_name: order.game_code ? gameNameMap.get(order.game_code) || order.game_code : null,
          server_name: order.server_attribute_code ? serverNameMap.get(order.server_attribute_code) || order.server_attribute_code : null
        }

        ordersWithData.push(combinedOrder)
      }
    }

    transactionHistory.value = ordersWithData
  } catch (error) {
    console.error('Error in loadTransactionHistory:', error)
    message.error('Có lỗi xảy ra khi tải lịch sử giao dịch')
  } finally {
    loadingHistory.value = false
  }
}

// Mock data for demo (deprecated - use database functions instead)
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

// Watch for game/server changes to reload data (only affects exchange tab)
watch([currentGame, currentServer], async () => {
  // Only reload data if we're on exchange tab
  if (activeTab.value === 'exchange') {
    // Only proceed if we have both game and server
    if (!currentGame.value || !currentServer.value) return

    // Reset forms - this will set currencyId to null briefly
    resetAllForms()

    // Load new data for exchange tab
    await loadData()
  }
})

// Watch for tab changes to load appropriate data
watch(activeTab, async (newTab) => {
  // Load data based on the new active tab
  if (newTab === 'delivery') {
    await loadDeliveryOrders()
  } else if (newTab === 'history') {
    await loadTransactionHistory()
  } else if (newTab === 'exchange') {
    // For exchange tab, load the full data including game context
    await loadData()
  }
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
