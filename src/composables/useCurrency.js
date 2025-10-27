import { ref, computed, watch } from 'vue'
import { supabase } from '@/lib/supabase'
import { useGameContext } from '@/composables/useGameContext.js'
import { usePermissions } from '@/composables/usePermissions.js'

export function useCurrency() {
  const { currentGame, currentServer, loadCurrencies } = useGameContext()
  const { canCreateTransactions } = usePermissions()

  // Reactive state
  const currencies = ref([])
  const exchangeRates = ref({})
  const channels = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Computed properties
  const activeCurrencies = computed(() => {
    try {
      return (currencies.value || [])
        .filter((currency) => currency && currency.is_active !== false)
    } catch (error) {
      console.error('Error in activeCurrencies computed:', error)
      return []
    }
  })

  const currenciesByCode = computed(() => {
    try {
      const map = {}
      ;(currencies.value || []).forEach((currency) => {
        if (currency && currency.code) {
          map[currency.code] = currency
        }
      })
      return map
    } catch (error) {
      console.error('Error in currenciesByCode computed:', error)
      return {}
    }
  })

  const salesChannels = computed(() => {
    // Channels for selling: SELL || BOTH (using direction field), exclude DEFAULT
    try {
      return (channels.value || [])
        .filter((channel) => channel && channel.direction && channel.code)
        .filter((channel) =>
          (channel.direction === 'SELL' || channel.direction === 'BOTH') &&
          channel.code !== 'DEFAULT'
        )
    } catch (error) {
      console.error('Error in salesChannels computed:', error)
      return []
    }
  })

  const purchaseChannels = computed(() => {
    // Channels for purchasing: BUY || BOTH (using direction field), exclude DEFAULT
    try {
      return (channels.value || [])
        .filter((channel) => channel && channel.direction && channel.code)
        .filter((channel) =>
          (channel.direction === 'BUY' || channel.direction === 'BOTH') &&
          channel.code !== 'DEFAULT'
        )
    } catch (error) {
      console.error('Error in purchaseChannels computed:', error)
      return []
    }
  })

  const allCurrencies = computed(() => {
    try {
      return currencies.value || []
    } catch (error) {
      console.error('Error in allCurrencies computed:', error)
      return []
    }
  })

  const loadAllCurrencies = async () => {
    return await loadAvailableCurrencies()
  }

  // Get currency by code
  const getCurrencyByCode = (code) => {
    return currenciesByCode.value[code] || null
  }

  // Get exchange rate between two currencies
  const getExchangeRate = (fromCurrency, toCurrency) => {
    if (fromCurrency === toCurrency) return 1

    const key = `${fromCurrency}_${toCurrency}`
    return exchangeRates.value[key] || null
  }

  // Convert amount between currencies
  const convertCurrency = (amount, fromCurrency, toCurrency) => {
    const rate = getExchangeRate(fromCurrency, toCurrency)
    if (rate === null) return null

    return amount * rate
  }

  // Load currencies for current game using attribute_relationships
  const loadAvailableCurrencies = async () => {
    if (!currentGame.value) {
      currencies.value = []
      return
    }

    loading.value = true
    error.value = null

    try {
      // First get the game attribute ID
      const { data: gameData, error: gameError } = await supabase
        .from('attributes')
        .select('id')
        .eq('code', currentGame.value)
        .eq('type', 'GAME')
        .single()

      if (gameError) throw gameError
      if (!gameData) throw new Error(`Game ${currentGame.value} not found`)

      // Then load GAME_CURRENCY type currencies linked to this game via attribute_relationships
      // Use a different approach - query from attribute_relationships directly
      const { data, error: fetchError } = await supabase
        .from('attribute_relationships')
        .select(`
          child_attribute_id
        `)
        .eq('parent_attribute_id', gameData.id)

      if (fetchError) throw fetchError

      // Get the currency attribute IDs
      const currencyIds = data?.map(rel => rel.child_attribute_id) || []

      if (currencyIds.length === 0) {
        currencies.value = []
        return
      }

      // Now load the actual currency attributes
      const { data: currencyData, error: currencyError } = await supabase
        .from('attributes')
        .select('*')
        .in('id', currencyIds)
        .eq('type', 'GAME_CURRENCY')
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      if (currencyError) throw currencyError

      currencies.value = currencyData || []
    } catch (err) {
      console.error('Error loading currencies:', err)
      error.value = err.message

      // Fallback to previous method if attribute_relationships query fails
      try {
        // Try GAME_CURRENCY approach with game code matching instead of attribute_relationships
        const { data: fallbackData, error: fallbackError } = await supabase
          .from('attributes')
          .select('*')
          .eq('type', 'GAME_CURRENCY')
          .eq('is_active', true)
          .like('code', `%${currentGame.value.replace('_', '')}%`)
          .order('sort_order', { ascending: true })

        if (!fallbackError) {
          currencies.value = fallbackData || []
        } else {
          // Final fallback - try old currency types
          let currencyType = null
          if (currentGame.value === 'POE_2') {
            currencyType = 'CURRENCY_POE2'
          } else if (currentGame.value === 'POE_1') {
            currencyType = 'CURRENCY_POE1'
          } else if (currentGame.value === 'DIABLO_4') {
            currencyType = 'CURRENCY_D4'
          }

          if (currencyType) {
            const { data: oldTypeData, error: oldTypeError } = await supabase
              .from('attributes')
              .select('*')
              .eq('type', currencyType)
              .eq('is_active', true)
              .order('sort_order', { ascending: true })

            if (!oldTypeError) {
                            currencies.value = oldTypeData || []
            }
          }
        }
      } catch (fallbackErr) {
        console.error('Fallback currency loading also failed:', fallbackErr)
        currencies.value = []
      }
    } finally {
      loading.value = false
    }
  }

  // Load exchange rates
  const loadExchangeRates = async () => {
    try {
      const { data, error: fetchError } = await supabase.from('exchange_rates').select('*')

      if (fetchError) throw fetchError

      // Convert to key-value format
      const rates = {}
      data.forEach((rate) => {
        rates[`${rate.source_currency}_${rate.target_currency}`] = rate.rate
      })

      exchangeRates.value = rates
    } catch (err) {
      console.error('Error loading exchange rates:', err)
      error.value = err.message
    }
  }

  // Load channels (sources)
  const loadChannels = async () => {
        try {
      const { data, error: fetchError } = await supabase
        .from('channels')
        .select('*')
        .eq('is_active', true)
        .order('code')

      if (fetchError) throw fetchError

      channels.value = data || []
    } catch (err) {
      console.error('Error loading channels:', err)
      error.value = err.message
      channels.value = [] // Ensure channels is always an array
    }
  }

  // Get channels with fee chains
  const getChannelsWithFeeChains = computed(() => {
    try {
      return (channels.value || []).filter(
        (channel) => channel && channel.trading_fee_chain && channel.trading_fee_chain.is_active !== false
      )
    } catch (error) {
      console.error('Error in getChannelsWithFeeChains computed:', error)
      return []
    }
  })

  // Get channel by ID
  const getChannelById = (channelId) => {
    try {
      return (channels.value || []).find((channel) => channel && channel.id === channelId)
    } catch (error) {
      console.error('Error in getChannelById:', error)
      return null
    }
  }

  // Create currency transaction
  const createTransaction = async (transactionData) => {
    if (!canCreateTransactions(currentGame.value)) {
      throw new Error('You do not have permission to create currency transactions')
    }

    try {
      const { data, error: insertError } = await supabase
        .from('currency_transactions')
        .insert({
          game_account_id: transactionData.gameAccountId,
          game_code: currentGame.value,
          server_attribute_code: currentServer.value,
          transaction_type: transactionData.type,
          currency_attribute_id: transactionData.currencyId,
          quantity: transactionData.quantity,
          unit_price_vnd: transactionData.unitPriceVnd || 0,
          unit_price_usd: transactionData.unitPriceUsd || 0,
          exchange_rate_vnd_per_usd: transactionData.exchangeRate,
          order_line_id: transactionData.orderLineId || null,
          partner_id: transactionData.partnerId || null,
          farmer_profile_id: transactionData.farmerId || null,
          proof_urls: transactionData.proofUrls || [],
          notes: transactionData.notes || '',
          created_by: supabase.auth.user().id,
        })
        .select()
        .single()

      if (insertError) throw insertError

      return data
    } catch (err) {
      console.error('Error creating transaction:', err)
      throw err
    }
  }

  // Get transactions for current game/server
  const getTransactions = async (filters = {}) => {
    if (!currentGame.value || !currentServer.value) return []

    try {
      let query = supabase
        .from('currency_transactions')
        .select(
          `
          *,
          currency:attributes(id, code, name),
          game_account:game_accounts(id, account_name, purpose),
          creator:profiles(id, display_name)
        `
        )
        .eq('game_code', currentGame.value)
        .eq('server_attribute_code', currentServer.value)
        .order('created_at', { ascending: false })

      // Apply filters
      if (filters.transactionType) {
        query = query.eq('transaction_type', filters.transactionType)
      }

      if (filters.currencyId) {
        query = query.eq('currency_attribute_id', filters.currencyId)
      }

      if (filters.gameAccountId) {
        query = query.eq('game_account_id', filters.gameAccountId)
      }

      if (filters.startDate) {
        query = query.gte('created_at', filters.startDate)
      }

      if (filters.endDate) {
        query = query.lte('created_at', filters.endDate)
      }

      if (filters.limit) {
        query = query.limit(filters.limit)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      return data || []
    } catch (err) {
      console.error('Error fetching transactions:', err)
      error.value = err.message
      return []
    }
  }

  // Get currency inventory summary (Dashboard)
  const getInventorySummary = async (gameCode = null, serverCode = null) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('get_currency_inventory_summary_v1', {
        p_game_code: gameCode,
        p_server_attribute_code: serverCode,
      })

      if (rpcError) throw rpcError

      return data || []
    } catch (err) {
      console.error('Error getting inventory summary:', err)
      throw err
    }
  }

  // Record currency purchase
  const recordPurchase = async (purchaseData) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('record_currency_purchase_v1', {
        p_game_account_id: purchaseData.gameAccountId,
        p_currency_attribute_id: purchaseData.currencyId,
        p_quantity: purchaseData.quantity,
        p_unit_price_vnd: purchaseData.unitPriceVnd || 0,
        p_unit_price_usd: purchaseData.unitPriceUsd || 0,
        p_exchange_rate_vnd_per_usd: purchaseData.exchangeRate || 25700,
        p_partner_id: purchaseData.partnerId || null,
        p_proof_urls: purchaseData.proofUrls || [],
        p_notes: purchaseData.notes || '',
      })

      if (rpcError) throw rpcError

      return data
    } catch (err) {
      console.error('Error recording purchase:', err)
      throw err
    }
  }

  // Create currency sell order
  const createSellOrder = async (orderData) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('create_currency_sell_order_v1', {
        p_game_account_id: orderData.gameAccountId,
        p_currency_attribute_id: orderData.currencyId,
        p_quantity: orderData.quantity,
        p_unit_price_vnd: orderData.unitPriceVnd || 0,
        p_unit_price_usd: orderData.unitPriceUsd || 0,
        p_exchange_rate_vnd_per_usd: orderData.exchangeRate || 25700,
        p_customer_name: orderData.customerName || '',
        p_customer_contact: orderData.customerContact || '',
        p_notes: orderData.notes || '',
      })

      if (rpcError) throw rpcError

      return data
    } catch (err) {
      console.error('Error creating sell order:', err)
      throw err
    }
  }

  // Fulfill currency order
  const fulfillOrder = async (orderId, fulfillmentData) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('fulfill_currency_order_v1', {
        p_order_id: orderId,
        p_game_account_id: fulfillmentData.gameAccountId,
        p_proof_urls: fulfillmentData.proofUrls || [],
        p_notes: fulfillmentData.notes || '',
      })

      if (rpcError) throw rpcError

      return data
    } catch (err) {
      console.error('Error fulfilling order:', err)
      throw err
    }
  }

  // Exchange currency
  const exchangeCurrency = async (exchangeData) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('exchange_currency_v1', {
        p_from_account_id: exchangeData.fromAccountId,
        p_from_currency_id: exchangeData.fromCurrencyId,
        p_to_currency_id: exchangeData.toCurrencyId,
        p_from_quantity: exchangeData.fromQuantity,
        p_to_quantity: exchangeData.toQuantity,
        p_exchange_rate: exchangeData.exchangeRate,
        p_notes: exchangeData.notes || '',
      })

      if (rpcError) throw rpcError

      return data
    } catch (err) {
      console.error('Error exchanging currency:', err)
      throw err
    }
  }

  // Payout farmer
  const payoutFarmer = async (payoutData) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('payout_farmer_v1', {
        p_game_account_id: payoutData.gameAccountId,
        p_currency_attribute_id: payoutData.currencyId,
        p_quantity: payoutData.quantity,
        p_farmer_profile_id: payoutData.farmerId,
        p_payout_rate_vnd: payoutData.payoutRateVnd || 0,
        p_payout_rate_usd: payoutData.payoutRateUsd || 0,
        p_exchange_rate_vnd_per_usd: payoutData.exchangeRate || 25700,
        p_notes: payoutData.notes || '',
      })

      if (rpcError) throw rpcError

      return data
    } catch (err) {
      console.error('Error paying out farmer:', err)
      throw err
    }
  }

  // Calculate profit for order
  const calculateOrderProfit = async (orderLineId) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('calculate_profit_for_order_v1', {
        p_order_line_id: orderLineId,
      })

      if (rpcError) throw rpcError

      return data
    } catch (err) {
      console.error('Error calculating order profit:', err)
      throw err
    }
  }

  // Get currency summary for display
  const getCurrencySummary = (currencyId, quantity, avgPriceVnd = 0, avgPriceUsd = 0) => {
    const currency = getCurrencyByCode(currencyId)
    if (!currency) return null

    const totalValueVnd = quantity * avgPriceVnd
    const totalValueUsd = quantity * avgPriceUsd

    return {
      currency,
      quantity,
      avgPriceVnd,
      avgPriceUsd,
      totalValueVnd,
      totalValueUsd,
      displayValue:
        avgPriceVnd > 0
          ? `${avgPriceVnd.toLocaleString('vi-VN')} VND`
          : avgPriceUsd > 0
            ? `$${avgPriceUsd.toFixed(2)}`
            : 'N/A',
    }
  }

  // Format currency amount for display
  const formatCurrencyAmount = (amount, currencyCode) => {
    if (!amount && amount !== 0) return 'N/A'

    const currency = getCurrencyByCode(currencyCode)
    const name = currency?.name || currencyCode

    // Format based on currency type
    if (currencyCode.includes('GOLD')) {
      // For gold, show with commas
      return `${Math.floor(amount).toLocaleString()} ${name}`
    } else {
      // For other currencies, show decimal
      return `${parseFloat(amount).toLocaleString(undefined, {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
      })} ${name}`
    }
  }

  // Validate transaction data
  const validateTransaction = (transactionData) => {
    const errors = []

    if (!transactionData.gameAccountId) {
      errors.push('Game account is required')
    }

    if (!transactionData.currencyId) {
      errors.push('Currency is required')
    }

    if (!transactionData.quantity && transactionData.quantity !== 0) {
      errors.push('Quantity is required')
    }

    if (!transactionData.type) {
      errors.push('Transaction type is required')
    }

    const validTypes = [
      'purchase',
      'sale_delivery',
      'exchange_out',
      'exchange_in',
      'transfer',
      'manual_adjustment',
      'farm_in',
      'farm_payout',
      'league_archive',
    ]

    if (!validTypes.includes(transactionData.type)) {
      errors.push('Invalid transaction type')
    }

    if (
      transactionData.type === 'purchase' &&
      !transactionData.unitPriceVnd &&
      !transactionData.unitPriceUsd
    ) {
      errors.push('Purchase price is required for purchase transactions')
    }

    return errors
  }

  // Initialize all data
  const initialize = async () => {
    loading.value = true

    try {
      // Only load data that doesn't depend on game context
      await Promise.all([loadExchangeRates(), loadChannels()])

      // Load currencies if game context is already available
      if (currentGame.value) {
        await loadAvailableCurrencies()
      }
    } catch (err) {
      console.error('Error initializing currency composable:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Watch for game context changes
  watch(currentGame, async () => {
    if (currentGame.value) {
      await loadAvailableCurrencies()
    }
  })

  return {
    // State
    currencies,
    exchangeRates,
    channels,
    loading,
    error,

    // Computed
    activeCurrencies,
    currenciesByCode,
    salesChannels,
    purchaseChannels,
    allCurrencies,
    getChannelsWithFeeChains,

    // Methods
    getCurrencyByCode,
    getExchangeRate,
    convertCurrency,
    loadAvailableCurrencies,
    loadAllCurrencies,
    loadExchangeRates,
    loadChannels,
    getChannelById,
    createTransaction,
    getTransactions,

    // RPC Functions
    getInventorySummary,
    recordPurchase,
    createSellOrder,
    fulfillOrder,
    exchangeCurrency,
    payoutFarmer,
    calculateOrderProfit,

    // Utility Methods
    getCurrencySummary,
    formatCurrencyAmount,
    validateTransaction,
    initialize,
  }
}
