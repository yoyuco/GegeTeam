import { ref, computed, onMounted, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabase'

export interface CurrencyBalance {
  currency_code: string
  purchase_balance: number
  sales_balance: number
}

export function useWalletBalance() {
  const loading = ref(false)
  const accounts = ref<any[]>([])
  const realtimeChannel = ref<any | null>(null)

  // Group balances by currency
  const balancesByCurrency = computed<CurrencyBalance[]>(() => {
    const currencyMap = new Map<string, CurrencyBalance>()

    accounts.value.forEach(account => {
      const currency = account.currency_code
      if (!currencyMap.has(currency)) {
        currencyMap.set(currency, {
          currency_code: currency,
          purchase_balance: 0,
          sales_balance: 0
        })
      }
      const balance = currencyMap.get(currency)!
      if (account.account_type === 'purchase') {
        balance.purchase_balance = account.current_balance || 0
      } else if (account.account_type === 'sales') {
        balance.sales_balance = account.current_balance || 0
      }
    })

    return Array.from(currencyMap.values()).sort((a, b) => a.currency_code.localeCompare(b.currency_code))
  })

  // Filter to only show currencies with non-zero balance
  const activeBalances = computed<CurrencyBalance[]>(() => {
    return balancesByCurrency.value.filter(b => b.purchase_balance !== 0 || b.sales_balance !== 0)
  })

  // Fetch wallet data
  async function fetchWallet() {
    loading.value = true
    try {
      const { data: profileId } = await supabase.rpc('get_current_profile_id')
      if (!profileId) {
        accounts.value = []
        return
      }

      const { data } = await supabase
        .from('employee_trading_accounts_view')
        .select('*')
        .eq('employee_id', profileId)

      accounts.value = data || []
    } catch (error) {
      console.error('[useWalletBalance] Error fetching wallet:', error)
      accounts.value = []
    } finally {
      loading.value = false
    }
  }

  // Setup realtime subscription
  async function setupRealtime() {
    try {
      const { data: profileId } = await supabase.rpc('get_current_profile_id')
      if (!profileId) return

      // Create a unique channel name with timestamp to avoid conflicts
      const channelName = `wallet-balance-changes-${profileId}-${Date.now()}`

      // Subscribe to both employee_fund_accounts AND employee_fund_transactions
      const channel = supabase
        .channel(channelName)
        .on(
          'postgres_changes',
          {
            event: '*', // Listen to INSERT, UPDATE, DELETE
            schema: 'public',
            table: 'employee_fund_accounts',
            filter: `employee_id=eq.${profileId}`
          },
          (payload) => {
            console.log('[useWalletBalance] Accounts changed:', payload)
            // Refresh wallet data when changes occur
            fetchWallet()
          }
        )
        .on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table: 'employee_fund_transactions',
            filter: `employee_id=eq.${profileId}`
          },
          (payload) => {
            console.log('[useWalletBalance] New transaction:', payload)
            // Also refresh when new transactions are created (affects balance)
            fetchWallet()
          }
        )
        .subscribe((status) => {
          if (status === 'SUBSCRIBED') {
            console.log('[useWalletBalance] Realtime subscription active for', profileId)
          } else if (status === 'CHANNEL_ERROR') {
            console.error('[useWalletBalance] Realtime subscription error')
          }
        })

      realtimeChannel.value = channel
    } catch (error) {
      console.error('[useWalletBalance] Error setting up realtime:', error)
    }
  }

  // Cleanup
  function cleanup() {
    if (realtimeChannel.value) {
      supabase.removeChannel(realtimeChannel.value)
      realtimeChannel.value = null
    }
  }

  // Initialize
  onMounted(async () => {
    await fetchWallet()
    await setupRealtime()
  })

  onUnmounted(() => {
    cleanup()
  })

  return {
    loading,
    accounts,
    balancesByCurrency,
    activeBalances,
    fetchWallet,
    refresh: fetchWallet
  }
}
