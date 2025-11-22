import { ref, computed, watch, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabase'
import { useGameContext } from '@/composables/useGameContext.js'
import { usePermissions } from '@/composables/usePermissions.js'
import { useCurrency } from '@/composables/useCurrency.js'
import { useExchangeRates } from '@/composables/useExchangeRates.js'

export function useInventory() {
  const { currentGame, currentServer, loadGameAccounts } = useGameContext()
  const { canViewInventory, canManageGameAccounts } = usePermissions()
  const { getExchangeRate, initialize: initializeCurrency } = useCurrency()
  const { loadExchangeRates, convertToVND } = useExchangeRates()

  // Reactive state
  const inventory = ref([])
  const gameAccounts = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Real-time subscription
  let inventorySubscription = null

  // Cache for attributes
  const gameAttributes = ref(new Map())
  const serverAttributes = ref(new Map())

  // Load attributes from database
  const loadAttributes = async () => {
    try {
      // Load game attributes
      const { data: gameData, error: gameError } = await supabase
        .from('attributes')
        .select('code, name')
        .eq('type', 'GAME')
        .eq('is_active', true)

      if (!gameError && gameData) {
        gameData.forEach(item => {
          gameAttributes.value.set(item.code, item.name || item.code)
        })
      }

      // Load server attributes
      const { data: serverData, error: serverError } = await supabase
        .from('attributes')
        .select('code, name')
        .eq('type', 'GAME_SERVER')
        .eq('is_active', true)

      if (!serverError && serverData) {
        serverData.forEach(item => {
          serverAttributes.value.set(item.code, item.name || item.code)
        })
      }
    } catch (error) {
      console.error('Failed to load attributes:', error)
    }
  }

  // Computed properties
  const totalInventoryValue = computed(() => {
    try {
      return (inventory.value || []).reduce((total, item) => {
        if (item && item.quantity && item.avg_buy_price_vnd) {
          return total + item.quantity * item.avg_buy_price_vnd
        }
        return total
      }, 0)
    } catch (error) {
      return 0
    }
  })

  const inventoryByCurrency = computed(() => {
    try {
      const map = {}
      ;(inventory.value || []).forEach((item) => {
        if (!item || !item.currency_attribute_id) return

        const currencyKey = item.currency_attribute_id
        if (!map[currencyKey]) {
          map[currencyKey] = {
            currencyId: item.currency_attribute_id,
            currency: item.currency,
            totalQuantity: 0,
            totalReserved: 0,
            avgPriceVnd: 0,
            avgPriceUsd: 0,
            totalValueVnd: 0,
            accounts: [],
          }
        }

        const group = map[currencyKey]
        group.totalQuantity += item.quantity || 0
        group.totalReserved += item.reserved_quantity || 0
        group.totalValueVnd += (item.quantity || 0) * (item.avg_buy_price_vnd || 0)
        group.accounts.push(item)
      })

    // Calculate weighted average prices
    Object.values(map).forEach((group) => {
      if (group.totalQuantity > 0) {
        group.avgPriceVnd = group.totalValueVnd / group.totalQuantity
      }
    })

    return Object.values(map)
    } catch (error) {
      return []
    }
  })

  const availableInventory = computed(() => {
    try {
      return (inventoryByCurrency.value || []).filter((item) => item && item.totalQuantity > 0)
    } catch (error) {
      return []
    }
  })

  const lowStockItems = computed(() => {
    try {
      return (inventoryByCurrency.value || []).filter(
        (item) => item && item.totalQuantity <= 10 && item.totalQuantity > 0
      )
    } catch (error) {
      return []
    }
  })

  const emptyInventory = computed(() => {
    try {
      return (inventoryByCurrency.value || []).filter((item) => item && item.totalQuantity === 0)
    } catch (error) {
      return []
    }
  })

  // Load game accounts
  const loadAccounts = async () => {
    if (!currentGame.value || !currentServer.value) {
      gameAccounts.value = []
      return
    }

    try {
      gameAccounts.value = await loadGameAccounts('INVENTORY')
    } catch (err) {
      error.value = err.message
    }
  }

  // Load inventory data from inventory_pools table
  const loadInventory = async (accountId = null) => {
    if (!currentGame.value || !currentServer.value) {
      inventory.value = []
      return
    }

    if (!canViewInventory(currentGame.value)) {
      return
    }

    loading.value = true
    error.value = null

    try {
      let query = supabase
        .from('inventory_pools')
        .select(`
          game_code,
          server_attribute_code,
          currency_attribute_id,
          quantity,
          reserved_quantity,
          average_cost,
          cost_currency,
          last_updated_at,
          last_updated_by,
          game_accounts!game_account_id!left (
            id,
            account_name,
            purpose
          ),
          channels!channel_id!left (
            id,
            name
          ),
          attributes!inventory_pools_currency_attribute_id_fkey!left (
            id,
            name,
            code
          )
        `)
        .eq('game_code', currentGame.value)
        .eq('server_attribute_code', currentServer.value)

      // Filter by specific account if provided
      if (accountId) {
        query = query.eq('game_account_id', accountId)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      // Transform the data to match the expected structure
      const transformedData = (data || []).map(item => {
        const avgCost = parseFloat(item.average_cost) || 0

        // Use real exchange rates for conversions
        let avgPriceVnd = avgCost
        let avgPriceUsd = avgCost

        if (item.cost_currency === 'VND') {
          avgPriceVnd = avgCost
          const vndToUsdRate = getExchangeRate('VND', 'USD')
          avgPriceUsd = vndToUsdRate ? avgCost * vndToUsdRate : avgCost / 25700 // Fallback
        } else if (item.cost_currency === 'USD') {
          avgPriceUsd = avgCost
          const usdToVndRate = getExchangeRate('USD', 'VND')
          avgPriceVnd = usdToVndRate ? avgCost * usdToVndRate : avgCost * 25700 // Fallback
        } else if (item.cost_currency === 'CNY') {
          avgPriceVnd = avgCost
          const cnyToVndRate = getExchangeRate('CNY', 'VND')
          avgPriceVnd = cnyToVndRate ? avgCost * cnyToVndRate : avgCost * 3500 // Fallback

          const cnyToUsdRate = getExchangeRate('CNY', 'USD')
          avgPriceUsd = cnyToUsdRate ? avgCost * cnyToUsdRate : avgCost / 3500 // Fallback
        }

        return {
          id: item.currency_attribute_id, // Use currency_attribute_id as id for compatibility
          currency_attribute_id: item.currency_attribute_id,
          currency: item.attributes?.name || 'Unknown Currency', // Map to expected field names
          quantity: parseFloat(item.quantity) || 0,
          reserved_quantity: parseFloat(item.reserved_quantity) || 0,
          avg_buy_price_vnd: avgPriceVnd,
          avg_buy_price_usd: avgPriceUsd,
          cost_currency: item.cost_currency,
          game_account_id: item.game_accounts?.id,
          game_account: {
            id: item.game_accounts?.id,
            account_name: item.game_accounts?.account_name,
            purpose: item.game_accounts?.purpose
          },
          channel_name: item.channels?.name || 'Unknown Channel',
          last_updated_at: item.last_updated_at,
          last_updated_by: item.last_updated_by,
          // Additional fields for new UI structure
          currency_name: item.attributes?.name || 'Unknown Currency',
          currency_code: item.attributes?.code || 'UNKNOWN',
          average_cost: parseFloat(item.average_cost) || 0
        }
      })

      inventory.value = transformedData
    } catch (err) {
      error.value = err.message
      inventory.value = []
    } finally {
      loading.value = false
    }
  }

  // Get inventory summary for dashboard
  const getInventorySummary = computed(() => {
    return {
      totalItems: inventoryByCurrency.value.length,
      itemsWithStock: availableInventory.value.length,
      lowStockCount: lowStockItems.value.length,
      emptyCount: emptyInventory.value.length,
      totalValueVnd: totalInventoryValue.value,
      totalValueUsd: totalInventoryValue.value / 25700, // Approximate USD value
      lastUpdated:
        inventory.value.length > 0
          ? new Date(Math.max(...inventory.value.map((item) => new Date(item.last_updated_at))))
          : null,
    }
  })

  // Get inventory by account
  const getInventoryByAccount = (accountId) => {
    return inventory.value.filter((item) => item.game_account_id === accountId)
  }

  // Get available quantity for currency
  const getAvailableQuantity = (currencyId, accountId = null) => {
    const items = accountId
      ? inventory.value.filter(
          (item) => item.currency_attribute_id === currencyId && item.game_account_id === accountId
        )
      : inventory.value.filter((item) => item.currency_attribute_id === currencyId)

    return items.reduce((total, item) => total + item.quantity, 0)
  }

  // Get reserved quantity for currency
  const getReservedQuantity = (currencyId, accountId = null) => {
    const items = accountId
      ? inventory.value.filter(
          (item) => item.currency_attribute_id === currencyId && item.game_account_id === accountId
        )
      : inventory.value.filter((item) => item.currency_attribute_id === currencyId)

    return items.reduce((total, item) => total + item.reserved_quantity, 0)
  }

  // Check if sufficient inventory exists
  const hasSufficientInventory = (currencyId, quantity, accountId = null) => {
    const available = getAvailableQuantity(currencyId, accountId)
    return available >= quantity
  }

  // Create game account
  const createGameAccount = async (accountData) => {
    if (!canManageGameAccounts(currentGame.value)) {
      throw new Error('You do not have permission to manage game accounts')
    }

    try {
      const { data, error: insertError } = await supabase
        .from('game_accounts')
        .insert({
          game_code: currentGame.value,
          account_name: accountData.accountName,
          purpose: accountData.purpose || 'INVENTORY',
          is_active: true,
        })
        .select()
        .single()

      if (insertError) throw insertError

      // Reload accounts and inventory
      await loadAccounts()
      await loadInventory()

      return data
    } catch (err) {
      throw err
    }
  }

  // Update game account
  const updateGameAccount = async (accountId, updates) => {
    if (!canManageGameAccounts(currentGame.value)) {
      throw new Error('You do not have permission to manage game accounts')
    }

    try {
      const { data, error: updateError } = await supabase
        .from('game_accounts')
        .update(updates)
        .eq('id', accountId)
        .select()
        .single()

      if (updateError) throw updateError

      // Reload data
      await loadAccounts()
      await loadInventory()

      return data
    } catch (err) {
      throw err
    }
  }

  // Manual inventory adjustment
  const adjustInventory = async (adjustmentData) => {
    if (!canManageGameAccounts(currentGame.value)) {
      throw new Error('You do not have permission to adjust inventory')
    }

    try {
      const { data, error: transactionError } = await supabase.rpc('create_currency_transaction', {
        p_game_account_id: adjustmentData.gameAccountId,
        p_transaction_type: 'manual_adjustment',
        p_currency_attribute_id: adjustmentData.currencyId,
        p_quantity: adjustmentData.quantity,
        p_unit_price_vnd: adjustmentData.unitPriceVnd || 0,
        p_unit_price_usd: adjustmentData.unitPriceUsd || 0,
        p_notes: adjustmentData.notes || '',
      })

      if (transactionError) throw transactionError

      // Reload inventory
      await loadInventory(adjustmentData.gameAccountId)

      return data
    } catch (err) {
      throw err
    }
  }

  // Set up real-time subscription for inventory_pools
  const setupRealtimeSubscription = () => {
    if (inventorySubscription) {
      inventorySubscription.unsubscribe()
    }

    if (!currentGame.value || !currentServer.value) return

    // Subscribe to inventory_pools changes
    inventorySubscription = supabase
      .channel('inventory_pools_changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'inventory_pools',
          filter: `game_code=eq.${currentGame.value}&server_attribute_code=eq.${currentServer.value}`,
        },
        async (payload) => {
          
          // Reload inventory when changes occur to maintain data consistency
          try {
            await loadInventory()
          } catch (err) {
          }
        }
      )
      .subscribe()
  }

  // Cleanup subscription
  const cleanupSubscription = () => {
    if (inventorySubscription) {
      inventorySubscription.unsubscribe()
      inventorySubscription = null
    }
  }

  // Initialize
  const initialize = async () => {
    loading.value = true

    try {
      // Load exchange rates first
      await loadExchangeRates()

      // Initialize currency system to load exchange rates
      await initializeCurrency()

      // Load attributes for display names
      await loadAttributes()

      await Promise.all([loadAccounts(), loadInventory()])

      // Setup real-time subscription
      setupRealtimeSubscription()
    } catch (err) {
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Watch for game changes
  watch(
    [currentGame, currentServer],
    () => {
      if (currentGame.value && currentServer.value) {
        cleanupSubscription()
        initialize()
      }
    },
    { immediate: true }
  )

  // Cleanup on unmount
  onUnmounted(() => {
    cleanupSubscription()
  })

  // Format functions for the new UI
  const formatCurrency = (amount, currencyCode = 'VND') => {
    if (!amount && amount !== 0) return '0'

    // Format based on currency type
    if (currencyCode === 'VND') {
      // VND: No decimal places, round to whole number
      return new Intl.NumberFormat('vi-VN', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      }).format(Math.round(amount))
    } else {
      // CNY, USD: Show up to 5 decimal places for precision, but don't force trailing zeros
      return new Intl.NumberFormat('vi-VN', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 5
      }).format(amount)
    }
  }

  const formatQuantity = (amount) => {
    return new Intl.NumberFormat('vi-VN').format(amount)
  }

  // Get display names for games and servers
  const getGameDisplayName = (gameCode) => {
    return gameAttributes.value.get(gameCode) || gameCode
  }

  const getServerDisplayName = (serverCode) => {
    if (!serverCode || serverCode === 'NULL') return 'No Server'
    return serverAttributes.value.get(serverCode) || serverCode
  }

  // Load inventory data for specific game and server (for external use) - NEW VERSION for CurrencyInventoryPanel
  const loadInventoryForGameServer = async (gameCode, serverCode) => {
    if (!gameCode || !serverCode) {
      return []
    }

    loading.value = true
    error.value = null

    try {
      // Ensure exchange rates are loaded for accurate conversion
      await loadExchangeRates()
      await initializeCurrency()
      let query = supabase
        .from('inventory_pools')
        .select(`
          game_code,
          server_attribute_code,
          currency_attribute_id,
          quantity,
          reserved_quantity,
          average_cost,
          cost_currency,
          last_updated_at,
          last_updated_by,
          game_accounts!game_account_id!left (
            id,
            account_name,
            purpose
          ),
          channels!channel_id!left (
            id,
            name
          ),
          attributes!inventory_pools_currency_attribute_id_fkey!left (
            id,
            name,
            code
          )
        `)
        .eq('game_code', gameCode)
        .eq('server_attribute_code', serverCode)

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      // Group data by currency and cost currency
      const groupedData = {}

      ;(data || []).forEach(item => {
        const key = `${item.attributes?.code || 'UNKNOWN'}`

        if (!groupedData[key]) {
          groupedData[key] = {
            game_code: item.game_code,
            server_attribute_code: item.server_attribute_code,
            currency_name: item.attributes?.name || 'Unknown Currency',
            currency_code: item.attributes?.code || 'UNKNOWN',
            costCurrencies: {},
            totalQuantity: 0,
            totalReserved: 0,
            totalValueVND: 0
          }
        }

        const costKey = item.cost_currency
        const accountName = item.game_accounts?.account_name || 'Unknown Account'

        if (!groupedData[key].costCurrencies[costKey]) {
          groupedData[key].costCurrencies[costKey] = {}
        }

        if (!groupedData[key].costCurrencies[costKey][accountName]) {
          groupedData[key].costCurrencies[costKey][accountName] = {
            totalQuantity: 0,
            totalReserved: 0,
            totalCost: 0,
            totalValue: 0
          }
        }

        // Update account totals (aggregate by cost currency and account)
        const quantity = parseFloat(item.quantity) || 0
        const reserved = parseFloat(item.reserved_quantity) || 0
        const avgCost = parseFloat(item.average_cost) || 0
        const cost = quantity * avgCost

        // Use real exchange rates to convert to VND
        const vndValue = convertToVND(cost, item.cost_currency || 'VND')

        const accountData = groupedData[key].costCurrencies[costKey][accountName]
        accountData.totalQuantity += quantity
        accountData.totalReserved += reserved
        accountData.totalCost += cost
        accountData.totalValue += vndValue

        // Update currency totals
        groupedData[key].totalQuantity += quantity
        groupedData[key].totalReserved += reserved
        groupedData[key].totalValueVND += vndValue
      })

      // Transform to expected structure with calculated average costs
      Object.keys(groupedData).forEach(key => {
        const currencyData = groupedData[key]
        Object.keys(currencyData.costCurrencies).forEach(costKey => {
          const accounts = Object.entries(currencyData.costCurrencies[costKey]).map(([accountName, data]) => ({
            name: accountName,
            quantity: data.totalQuantity,
            reserved: data.totalReserved,
            avgCost: data.totalQuantity > 0 ? data.totalCost / data.totalQuantity : 0,
            totalValue: data.totalValue
          }))
          currencyData.costCurrencies[costKey] = {
            avgCost: accounts.reduce((sum, acc) => sum + acc.avgCost * acc.quantity, 0) / accounts.reduce((sum, acc) => sum + acc.quantity, 0) || 0,
            totalQuantity: accounts.reduce((sum, acc) => sum + acc.quantity, 0),
            totalReserved: accounts.reduce((sum, acc) => sum + acc.reserved, 0),
            accounts: accounts
          }
        })
      })

      return Object.values(groupedData)
    } catch (err) {
      error.value = err.message
      return []
    } finally {
      loading.value = false
    }
  }

  return {
    // State
    inventory,
    gameAccounts,
    loading,
    error,

    // Computed
    totalInventoryValue,
    inventoryByCurrency,
    availableInventory,
    lowStockItems,
    emptyInventory,
    getInventorySummary,

    // Methods
    loadAccounts,
    loadInventory,
    loadInventoryForGameServer, // NEW: For external use (CurrencyInventoryPanel)
    getInventoryByAccount,
    getAvailableQuantity,
    getReservedQuantity,
    hasSufficientInventory,
    createGameAccount,
    updateGameAccount,
    adjustInventory,
    setupRealtimeSubscription,
    cleanupSubscription,
    initialize,

    // NEW: Utility functions for new UI
    formatCurrency,
    formatQuantity,
    getGameDisplayName,
    getServerDisplayName,
    loadAttributes
  }
}
