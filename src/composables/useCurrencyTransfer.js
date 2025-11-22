import { ref } from 'vue'
import { supabase } from '@/lib/supabase'

export function useCurrencyTransfer() {
  const loading = ref(false)
  const error = ref(null)

  // Transfer currency between accounts
  const transferCurrency = async (transferData) => {
    const {
      sourceAccountId,
      targetAccountId,
      currencyId,
      quantity,
      gameCode,
      serverCode,
      notes = ''
    } = transferData

    if (!sourceAccountId || !targetAccountId || !currencyId || quantity <= 0) {
      throw new Error('Invalid transfer data')
    }

    if (sourceAccountId === targetAccountId) {
      throw new Error('Source and target accounts cannot be the same')
    }

    loading.value = true
    error.value = null

    try {
      // Get all source currency pools ordered by last_updated_at (FIFO: oldest first)
      const { data: sourcePools, error: sourceError } = await supabase
        .from('inventory_pools')
        .select('*')
        .eq('game_account_id', sourceAccountId)
        .eq('currency_attribute_id', currencyId)
        .eq('game_code', gameCode)
        .eq('server_attribute_code', serverCode)
        .gt('quantity', 0)
        .order('last_updated_at', { ascending: true })

      if (sourceError) throw sourceError
      if (!sourcePools || sourcePools.length === 0) {
        throw new Error('Source currency not found')
      }

      // Validate all source pools have same cost currency
      const uniqueCostCurrencies = [...new Set(sourcePools.map(pool => pool.cost_currency))]
      if (uniqueCostCurrencies.length > 1) {
        throw new Error(`Cannot transfer from mixed cost currencies: ${uniqueCostCurrencies.join(', ')}`)
      }

      // Check total quantity across all pools
      const totalAvailableQuantity = sourcePools.reduce((sum, pool) => {
        const qty = parseFloat(pool.quantity) || 0
        return sum + Math.max(0, qty)
      }, 0)

      if (totalAvailableQuantity < quantity) {
        throw new Error(`Insufficient quantity. Available: ${totalAvailableQuantity}, Requested: ${quantity}`)
      }

      // Get source pool cost currency to ensure transfer only within same cost currency
      const sourceCostCurrency = sourcePools[0]?.cost_currency || 'VND'

      // Get or create target currency pool with same cost currency
      const { data: targetData, error: targetError } = await supabase
        .from('inventory_pools')
        .select('*')
        .eq('game_account_id', targetAccountId)
        .eq('currency_attribute_id', currencyId)
        .eq('game_code', gameCode)
        .eq('server_attribute_code', serverCode)
        .eq('cost_currency', sourceCostCurrency) // Only match same cost currency
        .single()

      if (targetError && targetError.code !== 'PGRST116') {
        throw targetError
      }

      let targetPool = targetData
      let remainingQuantity = quantity
      let transferValue = 0
      const poolsUsed = []

      // FIFO: Take from oldest pools first
      for (const sourcePool of sourcePools) {
        if (remainingQuantity <= 0) break

        const currentQuantity = parseFloat(sourcePool.quantity) || 0
        const quantityToTake = Math.min(remainingQuantity, currentQuantity)

        if (quantityToTake > 0) {
          poolsUsed.push({
            poolId: sourcePool.id,
            quantityTaken: quantityToTake,
            averageCost: parseFloat(sourcePool.average_cost),
            costCurrency: sourcePool.cost_currency,
            channelId: sourcePool.channel_id // Add channel ID
          })

          transferValue += quantityToTake * parseFloat(sourcePool.average_cost)
          remainingQuantity -= quantityToTake
        }
      }

      // If target pool doesn't exist, create it with weighted average cost
      if (!targetPool) {
        // Use weighted average cost from all used pools
        const averageCost = transferValue / quantity
        // Use the same cost currency as source pools
        const costCurrency = sourceCostCurrency
        // Use channel_id from the first pool (FIFO order)
        const channelId = poolsUsed[0]?.channelId

        const { data: newTargetData, error: createError } = await supabase
          .from('inventory_pools')
          .insert({
            game_code: gameCode,
            server_attribute_code: serverCode,
            currency_attribute_id: currencyId,
            game_account_id: targetAccountId,
            quantity: quantity,
            average_cost: averageCost.toFixed(6),
            cost_currency: costCurrency, // Ensure same cost currency as source
            channel_id: channelId, // Use channel from first source pool
            last_updated_by: (await supabase.rpc('get_current_profile_id')).data
          })
          .select()
          .single()

        if (createError) throw createError
        targetPool = newTargetData
      } else {
        // Validate target pool has same cost currency
        if (targetPool.cost_currency !== sourceCostCurrency) {
          throw new Error(`Cannot transfer to different cost currency. Source: ${sourceCostCurrency}, Target: ${targetPool.cost_currency}`)
        }

        // Calculate new average cost for target pool with weighted average
        const existingValue = parseFloat(targetPool.quantity) * parseFloat(targetPool.average_cost)
        const totalNewQuantity = parseFloat(targetPool.quantity) + quantity
        const newAverageCost = (existingValue + transferValue) / totalNewQuantity

        // Update target pool
        const { data: updatedTargetData, error: updateError } = await supabase
          .from('inventory_pools')
          .update({
            quantity: totalNewQuantity,
            average_cost: newAverageCost.toFixed(6),
            last_updated_by: (await supabase.rpc('get_current_profile_id')).data
          })
          .eq('id', targetPool.id)
          .select()
          .single()

        if (updateError) throw updateError
        targetPool = updatedTargetData
      }

      // Update source pools (multiple pools - FIFO)
      for (const poolUsed of poolsUsed) {
        const { data: sourcePoolData } = await supabase
          .from('inventory_pools')
          .select('quantity')
          .eq('id', poolUsed.poolId)
          .single()

        if (sourcePoolData) {
          const newQuantity = parseFloat(sourcePoolData.quantity) - poolUsed.quantityTaken
          const { error: sourceUpdateError } = await supabase
            .from('inventory_pools')
            .update({
              quantity: newQuantity,
              last_updated_by: (await supabase.rpc('get_current_profile_id')).data
            })
            .eq('id', poolUsed.poolId)

          if (sourceUpdateError) throw sourceUpdateError
        }
      }

      // Log the transfer with pool information
      await supabase
        .from('currency_transfers')
        .insert({
          game_code: gameCode,
          server_attribute_code: serverCode,
          source_account_id: sourceAccountId,
          target_account_id: targetAccountId,
          currency_attribute_id: currencyId,
          quantity: quantity,
          transfer_value: transferValue,
          source_avg_cost: transferValue / quantity, // Weighted average cost
          target_new_avg_cost: targetPool.average_cost,
          notes: notes || `FIFO transfer using ${poolsUsed.length} pool(s)`,
          transferred_by: (await supabase.rpc('get_current_profile_id')).data
        })

      return {
        target: targetPool,
        transferredQuantity: quantity,
        transferredValue: transferValue,
        poolsUsed: poolsUsed,
        weightedAverageCost: transferValue / quantity
      }
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Get transfer history
  const getTransferHistory = async (filters = {}) => {
    try {
      let query = supabase
        .from('currency_transfers')
        .select(`
          *,
          source_account:game_accounts!source_account_id (account_name),
          target_account:game_accounts!target_account_id (account_name),
          currency:attributes!currency_attribute_id (name, code),
          transferred_by_user:profiles(id, display_name)
        `)
        .order('created_at', { ascending: false })

      // Apply filters
      if (filters.gameCode) {
        query = query.eq('game_code', filters.gameCode)
      }
      if (filters.serverCode) {
        query = query.eq('server_attribute_code', filters.serverCode)
      }
      if (filters.sourceAccountId) {
        query = query.eq('source_account_id', filters.sourceAccountId)
      }
      if (filters.targetAccountId) {
        query = query.eq('target_account_id', filters.targetAccountId)
      }
      if (filters.currencyId) {
        query = query.eq('currency_attribute_id', filters.currencyId)
      }
      if (filters.limit) {
        query = query.limit(filters.limit)
      }

      const { data, error } = await query
      if (error) throw error

      return data || []
    } catch (err) {
      error.value = err.message
      return []
    }
  }

  // Validate transfer possibility
  const validateTransfer = async (sourceAccountId, currencyId, quantity) => {
    try {
      const { data, error } = await supabase
        .from('inventory_pools')
        .select('quantity')
        .eq('game_account_id', sourceAccountId)
        .eq('currency_attribute_id', currencyId)
        .single()

      if (error) {
        if (error.code === 'PGRST116') {
          return { valid: false, reason: 'Currency not found in source account' }
        }
        throw error
      }

      const currentQuantity = parseFloat(data.quantity) || 0

      if (currentQuantity < quantity) {
        return {
          valid: false,
          reason: `Insufficient quantity. Available: ${currentQuantity}, Requested: ${quantity}`
        }
      }

      return { valid: true, availableQuantity: currentQuantity }
    } catch (err) {
      return { valid: false, reason: 'Validation failed' }
    }
  }

  return {
    loading,
    error,
    transferCurrency,
    getTransferHistory,
    validateTransfer
  }
}