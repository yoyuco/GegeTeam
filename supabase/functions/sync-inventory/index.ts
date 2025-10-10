import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface SyncResult {
  gameId: string
  leagueId: string
  currencyId: string
  calculatedQuantity: number
  currentQuantity: number
  difference: number
  updated: boolean
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Get request body for specific sync parameters
    const { gameCode, leagueId, currencyId, forceSync = false } = await req.json().catch(() => ({}))

    console.log('Starting inventory sync:', { gameCode, leagueId, currencyId, forceSync })

    // Build query to get transactions for calculating expected inventory
    let transactionsQuery = supabase
      .from('currency_transactions')
      .select(
        `
        game_code,
        league_attribute_id,
        currency_attribute_id,
        quantity,
        game_account_id
      `
      )
      .order('created_at', { ascending: true })

    // Apply filters if provided
    if (gameCode) {
      transactionsQuery = transactionsQuery.eq('game_code', gameCode)
    }
    if (leagueId) {
      transactionsQuery = transactionsQuery.eq('league_attribute_id', leagueId)
    }
    if (currencyId) {
      transactionsQuery = transactionsQuery.eq('currency_attribute_id', currencyId)
    }

    const { data: transactions, error: transactionError } = await transactionsQuery

    if (transactionError) {
      throw new Error(`Failed to fetch transactions: ${transactionError.message}`)
    }

    // Calculate expected inventory for each account/currency combination
    const calculatedInventory = new Map<string, number>()

    transactions?.forEach((transaction) => {
      const key = `${transaction.game_account_id}-${transaction.currency_attribute_id}`
      const current = calculatedInventory.get(key) || 0
      calculatedInventory.set(key, current + transaction.quantity)
    })

    // Get current inventory from database
    let inventoryQuery = supabase.from('currency_inventory').select(`
        game_account_id,
        currency_attribute_id,
        quantity,
        reserved_quantity
      `)

    if (gameCode) {
      // Join with game_accounts to filter by game
      inventoryQuery = supabase.from('currency_inventory').select(`
          game_account_id,
          currency_attribute_id,
          quantity,
          reserved_quantity,
          game_accounts!inner(game_code, league_attribute_id)
        `)
    }

    const { data: currentInventory, error: inventoryError } = await inventoryQuery

    if (inventoryError) {
      throw new Error(`Failed to fetch current inventory: ${inventoryError.message}`)
    }

    // Compare and synchronize
    const syncResults: SyncResult[] = []
    let totalUpdates = 0
    let totalCorrections = 0

    for (const [key, calculatedQuantity] of calculatedInventory.entries()) {
      const [gameAccountId, currencyAttributeId] = key.split('-')

      const currentRecord = currentInventory?.find(
        (inv) =>
          inv.game_account_id === gameAccountId && inv.currency_attribute_id === currencyAttributeId
      )

      const difference = calculatedQuantity - (currentRecord?.quantity || 0)

      // Only update if there's a significant difference or force sync is enabled
      if (Math.abs(difference) > 0.01 || (forceSync && difference !== 0)) {
        const updateData = {
          quantity: Math.max(0, calculatedQuantity), // Ensure non-negative
          updated_at: new Date().toISOString(),
        }

        const { error: updateError } = await supabase.from('currency_inventory').upsert(
          {
            game_account_id: gameAccountId,
            currency_attribute_id: currencyAttributeId,
            ...updateData,
            reserved_quantity: currentRecord?.reserved_quantity || 0,
            avg_buy_price_vnd: currentRecord?.avg_buy_price_vnd || 0,
            avg_buy_price_usd: currentRecord?.avg_buy_price_usd || 0,
            last_updated_at: new Date().toISOString(),
          },
          {
            onConflict: 'game_account_id,currency_attribute_id',
            ignoreDuplicates: false,
          }
        )

        if (updateError) {
          console.error(`Failed to update inventory for ${key}:`, updateError)
        } else {
          totalUpdates++
          if (difference !== 0) {
            totalCorrections++
          }
        }

        syncResults.push({
          gameId: gameAccountId,
          leagueId: 'unknown', // Would need to join to get this
          currencyId: currencyAttributeId,
          calculatedQuantity,
          currentQuantity: currentRecord?.quantity || 0,
          difference,
          updated: !updateError,
        })
      }
    }

    // Check for inventory records that should be zero (no transactions but have inventory)
    const activeKeys = new Set(calculatedInventory.keys())

    for (const record of currentInventory || []) {
      const key = `${record.game_account_id}-${record.currency_attribute_id}`

      if (!activeKeys.has(key) && record.quantity > 0) {
        // This inventory has no supporting transactions, set to zero
        const { error: zeroUpdateError } = await supabase
          .from('currency_inventory')
          .update({
            quantity: 0,
            updated_at: new Date().toISOString(),
          })
          .eq('game_account_id', record.game_account_id)
          .eq('currency_attribute_id', record.currency_attribute_id)

        if (!zeroUpdateError) {
          totalUpdates++
          totalCorrections++
        }

        syncResults.push({
          gameId: record.game_account_id,
          leagueId: 'unknown',
          currencyId: record.currency_attribute_id,
          calculatedQuantity: 0,
          currentQuantity: record.quantity,
          difference: -record.quantity,
          updated: !zeroUpdateError,
        })
      }
    }

    // Log the synchronization
    await supabase.from('system_logs').insert({
      action: 'inventory_sync',
      status: 'success',
      details: {
        totalRecords: calculatedInventory.size,
        totalUpdates,
        totalCorrections,
        filters: { gameCode, leagueId, currencyId, forceSync },
      },
      created_at: new Date().toISOString(),
    })

    return new Response(
      JSON.stringify({
        success: true,
        message: `Inventory synchronization completed. ${totalUpdates} records processed, ${totalCorrections} corrections made.`,
        data: {
          totalRecords: calculatedInventory.size,
          totalUpdates,
          totalCorrections,
          syncResults: syncResults.slice(0, 10), // Return first 10 results as sample
        },
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Error during inventory synchronization:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})
