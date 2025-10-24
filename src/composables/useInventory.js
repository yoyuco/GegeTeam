import { ref, computed, watch, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabase'
import { useGameContext } from '@/composables/useGameContext.js'
import { usePermissions } from '@/composables/usePermissions.js'
// import { useCurrency } from '@/composables/useCurrency.js' // Unused for now

export function useInventory() {
  const { currentGame, currentLeague, loadGameAccounts } = useGameContext()
  const { canViewInventory, canManageGameAccounts } = usePermissions()
  // const { getCurrencyByCode, formatCurrencyAmount } = useCurrency() // Unused for now

  // Reactive state
  const inventory = ref([])
  const gameAccounts = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Real-time subscription
  let inventorySubscription = null

  // Computed properties
  const totalInventoryValue = computed(() => {
    return inventory.value.reduce((total, item) => {
      return total + item.quantity * item.avg_buy_price_vnd
    }, 0)
  })

  const inventoryByCurrency = computed(() => {
    const map = {}
    inventory.value.forEach((item) => {
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
      group.totalQuantity += item.quantity
      group.totalReserved += item.reserved_quantity
      group.totalValueVnd += item.quantity * item.avg_buy_price_vnd
      group.accounts.push(item)
    })

    // Calculate weighted average prices
    Object.values(map).forEach((group) => {
      if (group.totalQuantity > 0) {
        group.avgPriceVnd = group.totalValueVnd / group.totalQuantity
      }
    })

    return Object.values(map)
  })

  const availableInventory = computed(() => {
    return inventoryByCurrency.value.filter((item) => item.totalQuantity > 0)
  })

  const lowStockItems = computed(() => {
    return inventoryByCurrency.value.filter(
      (item) => item.totalQuantity <= 10 && item.totalQuantity > 0
    )
  })

  const emptyInventory = computed(() => {
    return inventoryByCurrency.value.filter((item) => item.totalQuantity === 0)
  })

  // Load game accounts
  const loadAccounts = async () => {
    if (!currentGame.value || !currentLeague.value) {
      gameAccounts.value = []
      return
    }

    try {
      gameAccounts.value = await loadGameAccounts('INVENTORY')
    } catch (err) {
      console.error('Error loading game accounts:', err)
      error.value = err.message
    }
  }

  // Load inventory data
  const loadInventory = async (accountId = null) => {
    console.log('Loading inventory...', {
      accountId,
      game: currentGame.value,
      league: currentLeague.value,
    })
    if (!currentGame.value || !currentLeague.value) {
      console.log('No game context, returning empty inventory')
      inventory.value = []
      return
    }

    if (!canViewInventory(currentGame.value)) {
      console.warn('No permission to view inventory')
      return
    }

    loading.value = true
    error.value = null

    try {
      const accountIds = accountId ? [accountId] : gameAccounts.value.map((acc) => acc.id)
      console.log('Loading inventory for accounts:', accountIds)

      let query = supabase
        .from('currency_inventory')
        .select(
          `
          *,
          game_account:game_accounts(id, account_name, purpose, manager_profile_id)
        `
        )
        .in('game_account_id', accountIds)

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      inventory.value = data || []
      console.log('Inventory loaded:', inventory.value.length, inventory.value)
    } catch (err) {
      console.error('Error loading inventory:', err)
      error.value = err.message
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
          league_attribute_id: currentLeague.value,
          account_name: accountData.accountName,
          purpose: accountData.purpose || 'INVENTORY',
          manager_profile_id: accountData.managerId || null,
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
      console.error('Error creating game account:', err)
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
      console.error('Error updating game account:', err)
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
      console.error('Error adjusting inventory:', err)
      throw err
    }
  }

  // Set up real-time subscription
  const setupRealtimeSubscription = () => {
    if (inventorySubscription) {
      inventorySubscription.unsubscribe()
    }

    if (!currentGame.value || !currentLeague.value) return

    // Subscribe to inventory changes
    inventorySubscription = supabase
      .channel('inventory_changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'currency_inventory',
          filter: `game_account_id=in.(${gameAccounts.value.map((acc) => acc.id).join(',')})`,
        },
        (payload) => {
          console.log('Inventory change:', payload)

          if (payload.eventType === 'INSERT') {
            inventory.value.push(payload.new)
          } else if (payload.eventType === 'UPDATE') {
            const index = inventory.value.findIndex((item) => item.id === payload.new.id)
            if (index !== -1) {
              inventory.value[index] = payload.new
            }
          } else if (payload.eventType === 'DELETE') {
            const index = inventory.value.findIndex((item) => item.id === payload.old.id)
            if (index !== -1) {
              inventory.value.splice(index, 1)
            }
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
      await Promise.all([loadAccounts(), loadInventory()])

      // Setup real-time subscription
      setupRealtimeSubscription()
    } catch (err) {
      console.error('Error initializing inventory composable:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Watch for game changes
  watch(
    [currentGame, currentLeague],
    () => {
      if (currentGame.value && currentLeague.value) {
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
  }
}
