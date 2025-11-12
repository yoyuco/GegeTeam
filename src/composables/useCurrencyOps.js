import { ref, computed, reactive } from 'vue'
import { supabase } from '@/lib/supabase'
import { useInventory } from '@/composables/useInventory.js'
import { useCurrency } from '@/composables/useCurrency.js'
import { useGameContext } from '@/composables/useGameContext.js'
import { usePermissions } from '@/composables/usePermissions.js'

export function useCurrencyOps() {
  // Compose existing composables
  const {
    inventory,
    gameAccounts,
    inventoryByCurrency,
    transferStock,
    transitionLeague,
    detectDiscrepancies,
    getTransferableAccounts,
    getExchangeSummary,
    validateTransfer,
    createDiscrepancyReport,
  } = useInventory()

  const { currencies, loadAllCurrencies, salesChannels } = useCurrency()
  const { currentGame, currentServer } = useGameContext()
  const { user } = usePermissions()

  // Reactive state for operations
  const loading = ref(false)
  const error = ref(null)

  // Orders state
  const sellOrders = ref([])
  const purchaseOrders = ref([])
  const exchangeOrders = ref([])
  const selectedOrder = ref(null)

  // Discrepancies state
  const discrepancies = ref([])

  // Exchange calculation state
  const exchangeCalculation = reactive({
    fromCurrency: null,
    toCurrency: null,
    fromQuantity: 0,
    toQuantity: 0,
    fromAvgCost: 0,
    toAvgCost: 0,
    profit: 0,
  })

  // Computed properties
  const hasManagementRole = computed(() => {
    if (!user.value) return false
    // Check if user has admin, manager, or mod role
    return ['admin', 'manager', 'mod'].some(
      (role) => user.value.user_roles?.includes(role) || user.value.roles?.includes(role)
    )
  })

  const opsStats = computed(() => {
    return {
      totalAccounts: gameAccounts.value.length,
      totalCurrencies: currencies.value.length,
      totalInventoryValue: inventory.value.reduce(
        (sum, item) => sum + item.quantity * item.avg_buy_price_vnd,
        0
      ),
      lowStockItems: inventory.value.filter((item) => item.quantity < 10 && item.quantity >= 0)
        .length,
      pendingDiscrepancies: discrepancies.value.length,
    }
  })

  const availableStockForExchange = computed(() => {
    if (!currentGame.value) return []

    return gameAccounts.value
      .filter((account) => account.purpose === 'INVENTORY')
      .map((account) => ({
        account,
        summary: getExchangeSummary(account.id),
      }))
      .filter(({ summary }) => summary.length > 0)
  })

  // Purchase Order Functions
  const createPurchaseOrder = async (orderData) => {
    loading.value = true
    error.value = null

    try {
      // Handle dual currency input from frontend
      let unitPrice = null

      if (orderData.unitPriceVnd && orderData.unitPriceVnd > 0) {
        unitPrice = orderData.unitPriceVnd
        // Find a channel with VND fee currency
        const { data: channelData, error: channelError } = await supabase
          .from('channels')
          .select('id, fee_currency')
          .eq('fee_currency', 'VND')
          .limit(1)
          .single()

        if (channelError) throw channelError

        // Use new API with single currency price
        const { data, error: rpcError } = await supabase.rpc('create_currency_order', {
          p_customer_id: orderData.customerId,
          p_channel_id: channelData.id,
          p_currency_code: orderData.currencyCode || orderData.currencyId,
          p_order_type: 'BUY',
          p_quantity: orderData.quantity,
          p_unit_price: unitPrice,
          p_notes: orderData.notes,
          p_expires_at: orderData.expiresAt || null,
        })

        if (rpcError) throw rpcError

        // Refresh data
        await loadAllCurrencies()
        await detectDiscrepancies()

        return data
      } else if (orderData.unitPriceUsd && orderData.unitPriceUsd > 0) {
        unitPrice = orderData.unitPriceUsd
        // Find a channel with USD fee currency
        const { data: channelData, error: channelError } = await supabase
          .from('channels')
          .select('id, fee_currency')
          .eq('fee_currency', 'USD')
          .limit(1)
          .single()

        if (channelError) throw channelError

        // Use new API with single currency price
        const { data, error: rpcError } = await supabase.rpc('create_currency_order', {
          p_customer_id: orderData.customerId,
          p_channel_id: channelData.id,
          p_currency_code: orderData.currencyCode || orderData.currencyId,
          p_order_type: 'BUY',
          p_quantity: orderData.quantity,
          p_unit_price: unitPrice,
          p_notes: orderData.notes,
          p_expires_at: orderData.expiresAt || null,
        })

        if (rpcError) throw rpcError

        // Refresh data
        await loadAllCurrencies()
        await detectDiscrepancies()

        return data
      } else {
        throw new Error('Either unitPriceVnd or unitPriceUsd must be provided')
      }
    } catch (err) {
      console.error('Error creating purchase order:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  const loadPurchaseOrders = async () => {
    try {
      const { data, error: rpcError } = await supabase.rpc('get_currency_orders', {
        p_customer_id: null,
        p_channel_id: null,
        p_status: null,
        p_limit: 50,
        p_offset: 0,
      })

      if (rpcError) throw rpcError
      purchaseOrders.value = data || []
    } catch (err) {
      console.error('Error loading purchase orders:', err)
      error.value = err.message
    }
  }

  // Exchange Functions
  const performExchange = async (exchangeData) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: rpcError } = await supabase.rpc('perform_currency_exchange_v1', {
        p_from_game_account_id: exchangeData.fromAccountId,
        p_to_game_account_id: exchangeData.toAccountId,
        p_from_currency_id: exchangeData.fromCurrencyId,
        p_to_currency_id: exchangeData.toCurrencyId,
        p_from_quantity: exchangeData.fromQuantity,
        p_to_quantity: exchangeData.toQuantity,
        p_exchange_rate: exchangeData.exchangeRate,
        p_game_code: currentGame.value,
        p_server_attribute_code: currentServer.value,
        p_notes: exchangeData.notes,
      })

      if (rpcError) throw rpcError

      // Refresh inventory
      await detectDiscrepancies()

      return data
    } catch (err) {
      console.error('Error performing exchange:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  const calculateExchangeProfit = (fromCurrency, toCurrency, fromQuantity, toQuantity) => {
    const fromAvgCost =
      inventory.value
        .filter((item) => item.currency_attribute_id === fromCurrency)
        .reduce((sum, item) => sum + item.avg_buy_price_vnd, 0) /
        inventory.value.filter((item) => item.currency_attribute_id === fromCurrency).length || 0

    const toAvgCost =
      inventory.value
        .filter((item) => item.currency_attribute_id === toCurrency)
        .reduce((sum, item) => sum + item.avg_buy_price_vnd, 0) /
        inventory.value.filter((item) => item.currency_attribute_id === toCurrency).length || 0

    exchangeCalculation.fromCurrency = fromCurrency
    exchangeCalculation.toCurrency = toCurrency
    exchangeCalculation.fromQuantity = fromQuantity
    exchangeCalculation.toQuantity = toQuantity
    exchangeCalculation.fromAvgCost = fromAvgCost
    exchangeCalculation.toAvgCost = toAvgCost
    exchangeCalculation.profit = toQuantity * toAvgCost - fromQuantity * fromAvgCost

    return exchangeCalculation.profit
  }

  // Stock Transfer Functions
  const validateAndTransfer = async (transferData) => {
    // Validate first
    const validation = validateTransfer(
      transferData.fromAccountId,
      transferData.currencyId,
      transferData.quantity
    )

    if (!validation.valid) {
      throw new Error(`Transfer validation failed: ${validation.error}`)
    }

    // Perform transfer
    return await transferStock(
      transferData.fromAccountId,
      transferData.toAccountId,
      transferData.currencyId,
      transferData.quantity,
      transferData.reason
    )
  }

  // League Transition Functions
  const getAvailableLeagues = (gameCode) => {
    // Get available currencies for exchange (server-based system)
    return currencies.value.filter(
      (curr) =>
        curr && curr.type === `CURRENCY_${gameCode.replace('_', '')}`
    )
  }

  // League transition functionality - DEPRECATED in server-based system
  const performLeagueTransition = async (transitionData) => {
    console.warn('League transition is deprecated in server-based system')
    throw new Error('League transitions are not supported in server-based architecture')
  }

  // Discrepancy Management Functions
  const loadDiscrepancies = async () => {
    try {
      discrepancies.value = await detectDiscrepancies()
    } catch (err) {
      console.error('Error loading discrepancies:', err)
      error.value = err.message
    }
  }

  const submitDiscrepancyReport = async (reportData) => {
    try {
      const result = await createDiscrepancyReport(reportData)

      // Refresh discrepancies
      await loadDiscrepancies()

      return result
    } catch (err) {
      console.error('Error submitting discrepancy report:', err)
      error.value = err.message
      throw err
    }
  }

  // Order Processing Functions (for Sell Orders tab)
  const loadSellOrders = async () => {
    try {
      const { data, error: rpcError } = await supabase.rpc('get_currency_orders_v1', {
        p_order_type: 'SALE',
        p_status: 'pending',
        p_game_code: currentGame.value,
        p_limit: 100,
      })

      if (rpcError) throw rpcError
      sellOrders.value = data || []
    } catch (err) {
      console.error('Error loading sell orders:', err)
      error.value = err.message
    }
  }

  const processSellOrder = async (orderId, processingData) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('process_currency_order_v1', {
        p_order_id: orderId,
        p_processing_notes: processingData.notes,
        p_game_account_id: processingData.accountId,
      })

      if (rpcError) throw rpcError

      // Refresh orders
      await loadSellOrders()

      return data
    } catch (err) {
      console.error('Error processing sell order:', err)
      error.value = err.message
      throw err
    }
  }

  const completeSellOrder = async (orderId, completionData) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('complete_currency_order_v1', {
        p_order_id: orderId,
        p_completion_notes: completionData.notes,
        p_proof_urls: completionData.proofUrls,
        p_actual_quantity: completionData.actualQuantity,
        p_actual_unit_price_vnd: completionData.actualUnitPriceVnd,
      })

      if (rpcError) throw rpcError

      // Refresh orders and inventory
      await Promise.all([loadSellOrders(), detectDiscrepancies()])

      return data
    } catch (err) {
      console.error('Error completing sell order:', err)
      error.value = err.message
      throw err
    }
  }

  // Initialize
  const initialize = async () => {
    loading.value = true
    error.value = null

    try {
      await Promise.all([
        loadAllCurrencies(),
        loadDiscrepancies(),
        loadSellOrders(),
        loadPurchaseOrders(),
      ])
    } catch (err) {
      console.error('Error initializing currency ops composable:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  return {
    // State
    loading,
    error,
    sellOrders,
    purchaseOrders,
    exchangeOrders,
    selectedOrder,
    discrepancies,
    exchangeCalculation,

    // Computed
    hasManagementRole,
    opsStats,
    availableStockForExchange,

    // Existing inventory functions (delegated)
    transferStock,
    transitionLeague,
    detectDiscrepancies,
    getTransferableAccounts,
    getExchangeSummary,
    validateTransfer,
    createDiscrepancyReport,

    // Purchase Order Functions
    createPurchaseOrder,
    loadPurchaseOrders,

    // Exchange Functions
    performExchange,
    calculateExchangeProfit,

    // Stock Transfer Functions
    validateAndTransfer,

    // League Transition Functions
    getAvailableLeagues,
    performLeagueTransition,

    // Discrepancy Management
    loadDiscrepancies,
    submitDiscrepancyReport,

    // Sell Order Processing
    loadSellOrders,
    processSellOrder,
    completeSellOrder,

    // Initialization
    initialize,

    // Compose existing
    inventory,
    gameAccounts,
    inventoryByCurrency,
    currencies,
    salesChannels,
    currentGame,
    currentServer,
    user,
  }
}
