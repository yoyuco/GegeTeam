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
      costCurrency, // Optional cost currency to filter pools
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
      console.log('Starting transfer:', { sourceAccountId, targetAccountId, currencyId, quantity, costCurrency })

      // Get all source currency pools ordered by last_updated_at (FIFO: oldest first)
      // Filter by cost currency if specified
      const poolsQuery = supabase
        .from('inventory_pools')
        .select('*')
        .eq('game_account_id', sourceAccountId)
        .eq('currency_attribute_id', currencyId)
        .eq('game_code', gameCode)
        .eq('server_attribute_code', serverCode)
        .gt('quantity', 0)
        .order('last_updated_at', { ascending: true })

      // Add cost currency filter if specified
      if (costCurrency) {
        poolsQuery.eq('cost_currency', costCurrency)
      }

      const { data: sourcePools, error: sourceError } = await poolsQuery

      if (sourceError) {
        console.error('Error fetching source pools:', sourceError)
        throw sourceError
      }
      
      if (!sourcePools || sourcePools.length === 0) {
        throw new Error('Source currency not found')
      }

      // Debug: Log all returned pools
      console.log('All source pools returned:', sourcePools.map(pool => ({
        id: pool.id,
        quantity: pool.quantity,
        cost_currency: pool.cost_currency,
        last_updated_at: pool.last_updated_at
      })))

      // Filter out pools with zero quantity
      const activePools = sourcePools.filter(pool => {
        const qty = parseFloat(pool.quantity) || 0
        return qty > 0
      })

      // Debug: Log active pools after filtering
      console.log('Active pools after filtering:', activePools.map(pool => ({
        id: pool.id,
        quantity: pool.quantity,
        cost_currency: pool.cost_currency
      })))

      // Only check for mixed cost currencies if no specific cost currency was requested
      if (!costCurrency) {
        const uniqueCostCurrencies = [...new Set(activePools.map(pool => pool.cost_currency))]
        console.log('Unique cost currencies found:', uniqueCostCurrencies)

        if (uniqueCostCurrencies.length > 1) {
          throw new Error(`Cannot transfer from mixed cost currencies: ${uniqueCostCurrencies.join(', ')}`)
        }
      }

      if (activePools.length === 0) {
        throw new Error('No active currency pools found for transfer')
      }

      // Check total quantity across all active pools
      const totalAvailableQuantity = activePools.reduce((sum, pool) => {
        const qty = parseFloat(pool.quantity) || 0
        return sum + qty
      }, 0)

      if (totalAvailableQuantity < quantity) {
        throw new Error(`Insufficient quantity. Available: ${totalAvailableQuantity}, Requested: ${quantity}`)
      }

      // Get source pool cost currency from active pools
      const sourceCostCurrency = activePools[0]?.cost_currency || 'VND'

      console.log('Using source cost currency:', sourceCostCurrency)

      // Get target currency pools with same cost currency (can be multiple)
      const { data: targetPools, error: targetError } = await supabase
        .from('inventory_pools')
        .select('*')
        .eq('game_account_id', targetAccountId)
        .eq('currency_attribute_id', currencyId)
        .eq('game_code', gameCode)
        .eq('server_attribute_code', serverCode)
        .eq('cost_currency', sourceCostCurrency) // Only match same cost currency
        .order('last_updated_at', { ascending: true }) // Get oldest pool first

      if (targetError) {
        console.error('Error fetching target pools:', targetError)
        throw targetError
      }

      console.log('Target pools found:', targetPools || [])

      let targetPool = null
      let remainingQuantity = quantity
      let transferValue = 0
      const poolsUsed = []

      console.log('Starting FIFO pool allocation for quantity:', quantity)

      // FIFO: Take from oldest active pools first
      for (const sourcePool of activePools) {
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

          console.log(`Taking ${quantityToTake} from pool ${sourcePool.id}, remaining: ${remainingQuantity}`)
        }
      }

      console.log('Pools used:', poolsUsed)
      console.log('Total transfer value:', transferValue)

      // Get profile ID once at the beginning
      const { data: profileId, error: profileError } = await supabase.rpc('get_current_profile_id')
      if (profileError || !profileId) {
        console.error('Error getting profile ID:', profileError)
        throw new Error('Failed to get current user profile')
      }

      // Handle target pools (multiple pools possible)
      if (targetPools && targetPools.length > 0) {
        // Use the oldest target pool (FIFO) for transfers
        targetPool = targetPools[0]
        console.log('Using existing target pool:', targetPool.id)
        
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
            last_updated_by: profileId
          })
          .eq('id', targetPool.id)
          .select()
          .single()

        if (updateError) {
          console.error('Error updating target pool:', updateError)
          throw updateError
        }
        
        console.log('Updated target pool:', updatedTargetData)
        targetPool = updatedTargetData
      } else {
        // Create new target pool if none exists
        console.log('Creating new target pool...')
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
            last_updated_by: profileId
          })
          .select()
          .single()

        if (createError) {
          console.error('Error creating target pool:', createError)
          throw createError
        }
        
        console.log('Created new target pool:', newTargetData)
        targetPool = newTargetData
      }

      // Update source pools (multiple pools - FIFO)
      console.log('Updating source pools...')
      for (const poolUsed of poolsUsed) {
        const { data: sourcePoolData, error: fetchError } = await supabase
          .from('inventory_pools')
          .select('quantity')
          .eq('id', poolUsed.poolId)
          .single()

        if (fetchError) {
          console.error('Error fetching source pool for update:', fetchError)
          throw fetchError
        }

        if (sourcePoolData) {
          const newQuantity = parseFloat(sourcePoolData.quantity) - poolUsed.quantityTaken
          console.log(`Updating pool ${poolUsed.poolId}: ${sourcePoolData.quantity} -> ${newQuantity}`)
          
          const { error: sourceUpdateError } = await supabase
            .from('inventory_pools')
            .update({
              quantity: newQuantity,
              last_updated_by: profileId
            })
            .eq('id', poolUsed.poolId)

          if (sourceUpdateError) {
            console.error('Error updating source pool:', sourceUpdateError)
            throw sourceUpdateError
          }
        }
      }

      console.log('All source pools updated successfully')

      // Log the transfer with pool information using currency_transactions
      console.log('Creating currency transactions...')

      const transactionData = {
        sourceAccountId,
        targetAccountId,
        currencyId,
        quantity, // This should be the requested quantity (e.g., 50)
        transferValue,
        sourceCostCurrency,
        poolsUsed,
        notes,
        profileId
      }

      console.log('Transaction data:', transactionData)

      // Create transfer_out transaction for source account
      const { error: sourceTransactionError } = await supabase
        .from('currency_transactions')
        .insert({
          game_account_id: sourceAccountId,
          game_code: gameCode,
          server_attribute_code: serverCode,
          transaction_type: 'transfer_out',
          currency_attribute_id: currencyId,
          quantity: quantity, // This should be exactly what user requested (e.g., 50)
          unit_price: transferValue / quantity, // Weighted average cost
          currency_code: sourceCostCurrency,
          notes: notes || `Transfer out to account ${targetAccountId} using ${poolsUsed.length} pool(s)`,
          created_by: profileId,
          proofs: JSON.stringify({
            target_account_id: targetAccountId,
            pools_used: poolsUsed.map(pool => ({
              pool_id: pool.poolId,
              quantity_taken: pool.quantityTaken,
              average_cost: pool.averageCost,
              cost_currency: pool.costCurrency
            }))
          })
        })

      if (sourceTransactionError) {
        console.error('Error creating source transaction:', sourceTransactionError)
        throw sourceTransactionError
      }

      console.log('Source transaction created successfully')

      // Create transfer_in transaction for target account
      const { error: targetTransactionError } = await supabase
        .from('currency_transactions')
        .insert({
          game_account_id: targetAccountId,
          game_code: gameCode,
          server_attribute_code: serverCode,
          transaction_type: 'transfer_in',
          currency_attribute_id: currencyId,
          quantity: quantity, // This should be exactly what user requested (e.g., 50)
          unit_price: parseFloat(targetPool.average_cost),
          currency_code: sourceCostCurrency,
          notes: notes || `Transfer in from account ${sourceAccountId} using ${poolsUsed.length} pool(s)`,
          created_by: profileId,
          proofs: JSON.stringify({
            source_account_id: sourceAccountId,
            pools_used: poolsUsed.map(pool => ({
              pool_id: pool.poolId,
              quantity_taken: pool.quantityTaken,
              average_cost: pool.averageCost,
              cost_currency: pool.costCurrency
            }))
          })
        })

      if (targetTransactionError) {
        console.error('Error creating target transaction:', targetTransactionError)
        throw targetTransactionError
      }

      console.log('Target transaction created successfully')
      console.log('Transfer completed successfully!')

      return {
        target: targetPool,
        transferredQuantity: quantity, // This should be exactly what user requested (e.g., 50)
        transferredValue: transferValue,
        poolsUsed: poolsUsed,
        weightedAverageCost: transferValue / quantity
      }
    } catch (err) {
      console.error('Transfer error:', err)
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
        .from('currency_transactions')
        .select(`
          *,
          game_account:game_accounts!game_account_id (account_name),
          currency:attributes!currency_attribute_id (name, code),
          created_by_user:profiles(id, display_name)
        `)
        .in('transaction_type', ['transfer_out', 'transfer_in']) // Only transfer transactions
        .order('created_at', { ascending: false })

      // Apply filters
      if (filters.gameCode) {
        query = query.eq('game_code', filters.gameCode)
      }
      if (filters.serverCode) {
        query = query.eq('server_attribute_code', filters.serverCode)
      }
      if (filters.sourceAccountId) {
        query = query.eq('game_account_id', filters.sourceAccountId)
      }
      if (filters.targetAccountId) {
        query = query.eq('game_account_id', filters.targetAccountId)
      }
      if (filters.currencyId) {
        query = query.eq('currency_attribute_id', filters.currencyId)
      }
      if (filters.transactionType) {
        query = query.eq('transaction_type', filters.transactionType)
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