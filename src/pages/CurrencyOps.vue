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
              <p v-if="activeTab === 'exchange'" class="text-green-100 text-sm mt-1">{{ contextString }}</p>
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
          <span
            v-if="assignedOrdersCount > 0"
            class="ml-2 px-2 py-1 text-xs font-bold text-white bg-red-500 rounded-full"
          >
            {{ assignedOrdersCount }}
          </span>
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
              description="Xử lý các đơn hàng đã được hệ thống phân công cho nhân viên vận hành"
              :data="deliveryOrders"
              :loading="loadingDelivery"
              @export="handleDeliveryExport"
              @view-detail="handleDeliveryViewDetail"
              @update-status="handleDeliveryUpdateStatus"
              @finalize-order="handleDeliveryFinalizeOrder"
              @proof-uploaded="handleProofUploaded"
              @process-inventory="handleProcessInventory"
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
              @export="handleHistoryExport"
              @view-detail="handleHistoryViewDetail"
              @refresh-data="loadTransactionHistory"
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
    :game-code="currentGame"
    :server-code="currentServer"
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
import { useDataCache, useDebounce } from '@/composables/useDataCache'
import type { Currency, GameAccount, Channel } from '@/types/composables'
import { supabase } from '@/lib/supabase'

// Type definitions for currency orders
interface CurrencyOrder {
  id: string
  order_number?: string
  order_type?: string
  status?: string
  currency_attribute_id?: string
  channel_id?: string
  party_id?: string
  assigned_to?: string
  game_code?: string
  server_attribute_code?: string
  currency_attribute?: {
    id: string
    code: string
    name: string
    type?: string
  } | null
  channel?: {
    id: string
    code: string
    name: string
  } | null
  party?: {
    id: string
    name?: string
    type?: string
  } | null
  assigned_employee?: {
    id: string
    display_name?: string
  } | null
  game_account?: {
    id: string
    account_name?: string
  } | null
  [key: string]: any // Allow additional properties
}

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

const { inventoryByCurrency, gameAccounts, loadAccounts, loadInventory, getAvailableQuantity } = useInventory()

// Initialize data cache
const {
  getCachedCurrencies,
  getCachedChannels,
  getCachedProfiles,
  getCachedGameAccounts,
  getCachedGameNames,
  getCachedServerNames,
  setCachedCurrencies,
  setCachedChannels,
  setCachedProfiles,
  setCachedGameAccounts,
  setCachedGameNames,
  setCachedServerNames,
  preloadCommonData,
  clearAllCaches
} = useDataCache()

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
      throw relationshipError
    }

    // Get the currency attribute IDs
    const currencyIds = relationshipData?.map(rel => rel.child_attribute_id) || []

    if (currencyIds.length === 0) {
      // No currencies found for game - this is normal for some games
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
      // Fallback to previous method
      const gameInfo = currentGame.value === 'POE_2' ? { currencyPrefix: 'CURRENCY_POE2' } :
                       currentGame.value === 'POE_1' ? { currencyPrefix: 'CURRENCY_POE1' } :
                       currentGame.value === 'DIABLO_4' ? { currencyPrefix: 'CURRENCY_D4' } : null
      if (!gameInfo) {
        return
      }

      const { error: fallbackError } = await supabase
        .from('attributes')
        .select('*')
        .eq('type', gameInfo.currencyPrefix)
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      if (fallbackError) {
        throw fallbackError
      }
    }

    // The currencies are already loaded into useCurrency.allCurrencies via initializeCurrency
    // We need to ensure they're properly loaded

  } catch (err) {
    throw err
  }
}

// --- TRẠNG THÁI (STATE) ---
const isInventoryOpen = ref(false)
const activeTab = ref('delivery')
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
    const filtered = (gameAccounts.value || [])
      .filter((acc: GameAccount) => acc && acc.account_name && acc.id)

    return filtered.map((acc: GameAccount) => ({
      label: acc.account_name,
      value: acc.id
    }))
  } catch (error) {
    return []
  }
})



// Assigned orders count for notification badge
const assignedOrdersCount = computed(() => {
  return deliveryOrders.value.filter(order => order.status === 'assigned').length
})

// --- METHODS ---
// Load all necessary data
const loadData = async () => {
  try {
    isDataLoading.value = true
    areCurrenciesLoading.value = true // Start currency loading

    // Only load exchange-related data if we're on exchange tab
    if (activeTab.value === 'exchange') {
      // Initialize and wait for game context
      await initializeFromStorage()
      let retries = 0
      while ((!currentGame.value || !currentServer.value) && retries < 10) {
        await new Promise(resolve => setTimeout(resolve, 500))
        retries++
      }
      if (!currentGame.value || !currentServer.value) {
        throw new Error('Game context not available')
      }

      // Now initialize currency composable properly (same pattern as GameLeagueSelector)
      await initializeCurrency()
      // Load currencies and accounts for exchange
      await loadCurrenciesForCurrentGame()
      await new Promise(resolve => setTimeout(resolve, 100)) // Allow reactive updates
      await loadAccounts()
    }

    // Load delivery orders (always loaded for data availability)
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
  }
}

// Exchange handlers
const handleExchangeSubmit = async (data: any) => {
  submittingExchange.value = true
  try {
    // Validate game context first
    if (!currentGame.value) {
      throw new Error('Vui lòng chọn game trước khi thực hiện đổi currency')
    }

    // Get current profile ID first (rule from memory.md)
    const { data: profileData, error: profileError } = await supabase.rpc('get_current_profile_id')

    if (profileError) {
      throw new Error(`Không thể lấy thông tin người dùng: ${profileError.message}`)
    }

  
    // Validate inventory quantity before creating order
    const availableQuantity = getAvailableQuantity(
      data.sourceCurrency?.id,
      data.sourceCurrency?.accountId
    )

    if (availableQuantity < data.sourceCurrency?.amount) {
      throw new Error(`Không đủ số lượng currency nguồn. Có sẵn: ${availableQuantity}, Yêu cầu: ${data.sourceCurrency?.amount}`)
    }

    // Prepare parameters for the exchange function (match new function signature)
    const params = {
      p_user_id: profileData,  // profiles.id as per memory.md rule
      p_game_account_id: data.sourceCurrency?.accountId,
      p_source_currency_id: data.sourceCurrency?.id,
      p_source_quantity: Number(data.sourceCurrency?.amount || 0),
      p_target_currency_id: data.destCurrency?.id,
      p_target_quantity: Number(data.destCurrency?.amount || 0),
      p_server_attribute_code: currentServer.value  // Server from GameServerSelector
    }

    
    // Call step 1 exchange function with reduced parameters
    const { data: exchangeOrderData, error: exchangeError } = await supabase.rpc('create_exchange_currency_order', params)

    if (exchangeError) {
      throw new Error(`Không thể tạo đơn đổi currency: ${exchangeError.message}`)
    }

    // Handle both array and object responses
    const orderResult = Array.isArray(exchangeOrderData) ? exchangeOrderData[0] : exchangeOrderData
    if (!orderResult || !orderResult.order_id) {
      throw new Error((orderResult as any)?.message || 'Tạo đơn đổi currency thất bại')
    }
    const orderId = orderResult.order_id
    const orderNumber = orderResult.order_number

    message.success(`✅ Tạo đơn draft thành công: ${orderNumber}`)

    // Step 2: Upload proofs if any
    let proofsData = null
    if (data.proofFiles && data.proofFiles.length > 0) {
      proofsData = await uploadExchangeProofs(orderId, orderNumber, data.proofFiles)
    }

    // Step 3: Complete the exchange order
    message.info(`Đang hoàn thành đơn exchange ${orderNumber}...`)
    const { data: completeData, error: completeError } = await supabase.rpc('complete_exchange_currency_order', {
      p_order_id: orderId,
      p_proofs: proofsData,
      p_completed_by_id: profileData  // Pass profile ID following memory.md pattern
    })

    if (completeError) {
      throw new Error(`Không thể hoàn thành đơn exchange: ${completeError.message}`)
    }

    if (!completeData || !completeData[0]?.success) {
      throw new Error(completeData?.[0]?.message || 'Hoàn thành exchange thất bại')
    }

    message.success(`✅ Exchange currency hoàn thành: ${orderNumber}`)

    // Reset the form
    handleExchangeReset()
    return

  } catch (error: any) {
    message.error(error.message || 'Có lỗi xảy ra khi đổi currency')
  } finally {
    submittingExchange.value = false
  }
}

const uploadExchangeProofs = async (orderId: string, orderNumber: string, files: (File | { file: File })[]) => {
  try {
    message.info(`Đang upload ${files.length} file proof cho đơn ${orderNumber}...`)

    // Create folder path for exchange order proofs (use correct exchange folder)
    const folderPath = `currency/exchange/${orderNumber}/exchange`
    const proofsArray: any[] = []

    for (const file of files) {
      // Extract actual File object from SimpleProofUpload structure
      let actualFile: File

      // Type guard to check if file has .file property (SimpleProofUpload structure)
      if ('file' in file && file.file instanceof File) {
        actualFile = file.file
      } else if (file instanceof File) {
        // Direct File object
        actualFile = file
      } else {
        continue // Skip invalid files
      }

      if (!actualFile) {
        continue // Skip invalid files
      }

      // Use original filename to avoid corruption
      const fileName = actualFile.name
      const filePath = `${folderPath}/${fileName}`

      // Upload file using the same utility as purchase upload
      const { uploadFile } = await import('@/lib/supabase')
      const uploadResult = await uploadFile(actualFile, filePath, 'work-proofs')

      if (!uploadResult.success) {
        throw new Error(`Không thể upload file ${actualFile.name}: ${uploadResult.error}`)
      }

      // Use original Supabase storage URL (no file processing corruption)
      proofsArray.push({
        url: uploadResult.publicUrl,
        path: uploadResult.path,
        type: 'exchange',
        filename: actualFile.name,
        uploaded_at: new Date().toISOString()
      })
    }

    message.success(`✅ Upload thành công ${files.length} file proof`)

    // Return proofs data for step 3
    return proofsArray

  } catch (error: any) {
    message.error(`Upload proof thất bại: ${error.message}`)
    throw error
  }
}

const handleExchangeReset = () => {
  // Call the onReset method from ExchangeCurrencyForm component
  if (exchangeFormRef.value && exchangeFormRef.value.onReset) {
    exchangeFormRef.value.onReset()
  }
  message.info('Form đã được reset.')
}

// Load delivery orders from database using RPC function with role-based access
const loadDeliveryOrders = async () => {
  loadingDelivery.value = true
  try {
    // Get current user profile first - REQUIRED for security
    const { data: profileData, error: profileError } = await supabase.rpc('get_current_profile_id')

    if (profileError || !profileData) {

      message.error('Bạn cần đăng nhập để xem danh sách đơn hàng')
      return  // Dừng lại - không gọi RPC nếu không có auth
    }

    // Use the optimized RPC function with server-side filtering and caching
    const { data, error } = await supabase
      .rpc('get_currency_orders_optimized', {
        p_current_profile_id: profileData,  // REQUIRED: Valid profile ID for access control (FIRST PARAM!)
        p_for_delivery: true,              // Filter for delivery-relevant statuses
        p_limit: 100,                      // Get more orders for comprehensive view
        p_offset: 0,
        p_search_query: null,             // Can be used for future search functionality
        p_status_filter: null,             // Use built-in delivery filtering
        p_order_type_filter: null,
        p_game_code_filter: null
      })

    if (error) {

      message.error('Không thể tải danh sách đơn hàng: ' + error.message)
      return
    }

    

    // Collect unique game and server codes for name lookup
    const gameCodes = [...new Set(data.map((order: any) => order.game_code).filter(Boolean))]
    const serverCodes = [...new Set(data.map((order: any) => order.server_attribute_code).filter(Boolean))]

    // Fetch game and server names
    const [gameData, serverData] = await Promise.all([
      gameCodes.length > 0 ? supabase
        .from('attributes')
        .select('code, name')
        .eq('type', 'GAME')
        .in('code', gameCodes) : Promise.resolve({ data: [] }),

      serverCodes.length > 0 ? supabase
        .from('attributes')
        .select('code, name')
        .in('type', ['SERVER', 'GAME_SERVER'])
        .in('code', serverCodes) : Promise.resolve({ data: [] })
    ])

    // Create lookup maps
    const gameNameMap = new Map(gameData.data?.map(item => [item.code, item.name]) || [])
    const serverNameMap = new Map(serverData.data?.map(item => [item.code, item.name]) || [])

    // The RPC function returns pre-joined data, so we just need to format it
    const formattedOrders = (data || []).map((order: CurrencyOrder) => ({
      ...order,
      // Add compatibility fields for existing component logic
      currencyName: order.currency_attribute?.name || 'Unknown Currency',
      currencyCode: order.currency_attribute?.code || 'Unknown',
      channelName: order.channel?.name || 'Unknown Channel',
      channelCode: order.channel?.code || 'Other',
      customerName: order.party?.name || 'Direct Customer',
      customer: order.party?.name || 'Direct Customer', // Added for table column mapping
      employeeName: order.assigned_employee?.display_name || 'Unassigned',
      // Add resolved names
      game_name: order.game_code ? gameNameMap.get(order.game_code) || order.game_code : null,
      server_name: order.server_attribute_code ? serverNameMap.get(order.server_attribute_code) || order.server_attribute_code : null,
      // Flatten nested objects for templates
      currency_attribute: order.currency_attribute,
      channel: order.channel,
      assigned_employee: order.assigned_employee,
      game_account: order.game_account,
      party: order.party
    }))

    deliveryOrders.value = formattedOrders

  } catch (error) {

    message.error('Có lỗi xảy ra khi tải đơn hàng')
  } finally {
    loadingDelivery.value = false
  }
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
          preparation_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .eq('id', order.id)

      if (error) {

        message.warning(`Xem chi tiết đơn #${order.order_number} nhưng không thể cập nhật trạng thái`)
      } else {
        message.success(`✅ Đã xem chi tiết và chuyển đơn #${order.order_number} sang trạng thái "Đang chuẩn bị"`)
        // Reload data to reflect the status change
        await loadDeliveryOrders()
      }
    } else {
      message.info(`Xem chi tiết đơn #${order.order_number} (trạng thái: ${getStatusLabel(order.status, order.order_type)})`)
    }

    // View order detail
    // TODO: Implement view detail modal here

  } catch (error) {

    message.error(`Có lỗi xảy ra khi xem chi tiết đơn #${order.order_number}`)
  }
}

// Get status label in Vietnamese
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
    // Note: Inventory processing is now handled by handleProcessInventory BEFORE status change
    // This function now only handles cases where inventory doesn't need processing or was already processed

    if (order.order_type === 'PURCHASE' && newStatus === 'delivered') {
      // Status change to delivered for purchase order

      // If order is already delivered, this might be a duplicate call
      if (order.status === 'delivered') {
        // Order is already delivered, no action needed
        message.info(`Đơn mua #${order.order_number} đã ở trạng thái đã giao`)
        return
      }

      // For purchase orders changing to delivered, inventory should have been processed already
      // Purchase order marked as delivered (inventory should have been processed separately)
      message.success(`✅ Đơn mua #${order.order_number} đã được giao hàng thành công!`)
      return
    }
    // Handle purchase order final completion when status changes to completed
    else if (order.order_type === 'PURCHASE' && newStatus === 'completed') {
      // Just update status to completed, inventory already handled at delivered stage
      const { error } = await supabase
        .from('currency_orders')
        .update({
          status: newStatus,
          updated_at: new Date().toISOString()
        })
        .eq('id', order.id)

      if (error) {
        message.error('Không thể cập nhật trạng thái hoàn thành')
        return
      }

      message.success(`✅ Đơn mua #${order.order_number} đã được hoàn thành!`)
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
    // Handle purchase order cancellation
    else if (order.order_type === 'PURCHASE' && newStatus === 'cancelled') {
      // Get current user ID
      const { data: profileData, error: profileError } = await supabase.rpc('get_current_profile_id')

      if (profileError) {
        throw new Error(`Không thể lấy thông tin người dùng: ${profileError.message}`)
      }

      // Use the cancel purchase order function
      const { data, error } = await supabase.rpc('cancel_purchase_order', {
        p_order_id: order.id,
        p_user_id: profileData
      })

      if (error) {
        throw new Error(`Không thể hủy đơn mua: ${error.message}`)
      }

      if (data && data.length > 0 && data[0].success) {
        message.success(`✅ Đơn mua #${order.order_number} đã được hủy thành công!`)
      } else {
        throw new Error(data?.[0]?.message || 'Hủy đơn mua thất bại')
      }
    }
    // Handle sell order delivery with inventory deduction
    else if (order.order_type === 'SELL' && newStatus === 'delivered') {
      // Get current user ID
      const { data: profileData, error: profileError } = await supabase.rpc('get_current_profile_id')

      if (profileError) {
        throw new Error(`Không thể lấy thông tin người dùng: ${profileError.message}`)
      }

      // Use the complete currency order function for sell orders when delivered
      const { data, error } = await supabase.rpc('complete_currency_order_v1', {
        p_order_id: order.id,
        p_completed_by: profileData,
        p_channel_id: order.channel_id
      })

      if (error) {
        throw new Error(`Không thể cập nhật inventory cho đơn bán: ${error.message}`)
      }

      if (data && data.length > 0 && data[0].success) {
        message.success(`✅ Đơn bán #${order.order_number} đã giao hàng! Inventory đã được cập nhật.`)
      } else {
        throw new Error(data?.[0]?.message || 'Cập nhật inventory cho đơn bán thất bại')
      }
    }
    // Handle sell order final completion when status changes to completed
    else if (order.order_type === 'SELL' && newStatus === 'completed') {
      // Just update status to completed, inventory already handled at delivered stage
      const { error } = await supabase
        .from('currency_orders')
        .update({
          status: newStatus,
          updated_at: new Date().toISOString()
        })
        .eq('id', order.id)

      if (error) {
        message.error('Không thể cập nhật trạng thái hoàn thành')
        return
      }

      message.success(`✅ Đơn bán #${order.order_number} đã được hoàn thành!`)
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

// Process inventory for purchase orders before status change
const handleProcessInventory = async (data: { order: any; targetStatus: string }) => {
  const { order, targetStatus } = data

  // Processing inventory for order

  try {
    // Only process inventory for purchase orders
    if (order.order_type !== 'PURCHASE') {
      // Not a purchase order, skipping inventory processing
      // Update status directly for non-purchase orders
      await updateOrderStatus(order.id, targetStatus)
      return
    }

    // Process inventory for purchase orders using RPC function

    // Get current user profile
    const { data: profileData, error: profileError } = await supabase.rpc('get_current_profile_id')
    if (profileError) {
      throw new Error(`Không thể lấy thông tin người dùng: ${profileError.message}`)
    }

    // Call confirm_purchase_order_receiving_v2 to create inventory pools (temporary fix for caching issue)
    const { data: rpcData, error: rpcError } = await supabase.rpc('confirm_purchase_order_receiving_v2', {
      p_order_id: order.id,
      p_completed_by: profileData
    })

    if (rpcError) {


      // Check for specific database schema errors
      if (rpcError.message && rpcError.message.includes('relation "channels" does not exist')) {

        throw new Error('Lỗi schema database: Bảng "channels" không tồn tại. Vui lòng liên hệ admin để fix cấu trúc database.')
      }

      throw new Error(`Không thể xử lý inventory: ${rpcError.message}`)
    }

    if (rpcData && rpcData.length > 0 && rpcData[0].success) {
      const dataInfo = rpcData[0].data || {}
      // Inventory processed successfully
      message.success(`✅ Xử lý inventory thành công! Chi phí trung bình: ${dataInfo.new_average_cost || 0}, Tồn kho: ${dataInfo.new_quantity || 0}`)
    } else {

      throw new Error(rpcData?.[0]?.message || 'Xử lý inventory thất bại')
    }

    // Update status to delivered after successful inventory processing
    await updateOrderStatus(order.id, targetStatus)

  } catch (error: any) {

    message.error(`Lỗi xử lý inventory: ${error.message}`)

    // Fallback: update status despite inventory processing error
    await updateOrderStatus(order.id, targetStatus)
  }
}

// Update order status
const updateOrderStatus = async (orderId: string, newStatus: string) => {
  const { error } = await supabase
    .from('currency_orders')
    .update({
      status: newStatus,
      updated_at: new Date().toISOString()
    })
    .eq('id', orderId)

  if (error) {
    throw new Error(`Không thể cập nhật trạng thái: ${error.message}`)
  }

  // Reload data to show updated status
  await loadDeliveryOrders()
}


// Handle proof upload
const handleProofUploaded = async (data: { orderId: string; proofs: any }) => {
  // Refresh delivery orders to show updated proofs
  await loadDeliveryOrders()

  message.success('Bằng chứng đã được tải lên và cập nhật thành công!')
}


const handleHistoryExport = () => {
  // TODO: Implement export functionality
  message.info('Tính năng xuất file lịch sử đang được phát triển...')
}

const handleHistoryViewDetail = (order: any) => {
  message.info(`Xem chi tiết đơn #${order.order_number}`)
}

const onGameChanged = async (gameCode: string) => {
  currentGame.value = gameCode
  currentServer.value = null
  resetAllForms()
}

const onServerChanged = async (serverCode: string) => {
  currentServer.value = serverCode
  resetAllForms()
}

const onContextChanged = async (context: { hasContext: boolean }) => {
  if (context.hasContext) {
    await loadData()
  } else {
    resetAllForms()
  }
}

// Reset all forms (forms reset automatically via key props)
const resetAllForms = () => {
  // Forms handle their own reset logic internally
}

// Load transaction history from database (completed and cancelled orders only)
const loadTransactionHistory = async () => {
  loadingHistory.value = true
  try {
    // Get current user profile first - REQUIRED for security
    const { data: profileData, error: profileError } = await supabase.rpc('get_current_profile_id')

    
    if (profileError || !profileData) {
      message.error('Bạn cần đăng nhập để xem lịch sử giao dịch')
      return
    }

    // Use the optimized RPC function with server-side filtering and caching
    // This function includes all necessary joins and filters server-side with indexes
    const { data, error } = await supabase
      .rpc('get_currency_orders_optimized', {
        p_current_profile_id: profileData,  // REQUIRED: Valid profile ID for access control
        p_for_delivery: false,             // History tab (not delivery)
        p_limit: 100,
        p_offset: 0,
        p_search_query: null,             // Can be used for future search functionality
        p_status_filter: null,             // Show all statuses, will filter client-side for history
        p_order_type_filter: null,
        p_game_code_filter: null
      })

    // Filter history data to only show completed and cancelled orders
    const historyData = data?.filter((order: any) =>
      ['completed', 'cancelled'].includes(order.status)
    ) || []

    if (error) {
      message.error('Không thể tải lịch sử giao dịch: ' + error.message)
      return
    }

    // Manual joins for related data (relationships don't exist in schema)
    const ordersWithData = []
    if (data && data.length > 0) {
      // Collect all unique IDs for batch queries
      const currencyIds = [...new Set(data.map((order: any) => order.currency_attribute_id).filter(Boolean))]
      const channelIds = [...new Set(data.map((order: any) => order.channel_id).filter(Boolean))]
      const employeeIds = [...new Set(data.map((order: any) => order.assigned_to).filter(Boolean))]
      const gameAccountIds = [...new Set(data.map((order: any) => order.game_account_id).filter(Boolean))]
      const partyIds = [...new Set(data.map((order: any) => order.party_id).filter(Boolean))]

      // Collect game and server codes for name lookup
      const gameCodes = [...new Set(data.map((order: any) => order.game_code).filter(Boolean))]
      const serverCodes = [...new Set(data.map((order: any) => order.server_attribute_code).filter(Boolean))]

      // Batch fetch related data
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
          // Add resolved names
          game_name: order.game_code ? gameNameMap.get(order.game_code) || order.game_code : null,
          server_name: order.server_attribute_code ? serverNameMap.get(order.server_attribute_code) || order.server_attribute_code : null
        }

        ordersWithData.push(combinedOrder)
      }
    }

    // Use filtered history data that only includes completed and cancelled orders
    transactionHistory.value = historyData
  } catch (error) {

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
      channelName: 'Zalo', // cspell:disable-line
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
