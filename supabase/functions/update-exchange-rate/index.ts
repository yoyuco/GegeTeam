import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ExchangeRateResponse {
  rates: Record<string, number>
  base: string
  date: string
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

    // Fetch current exchange rates from external API
    // Using exchangerate-api.com as example (you can replace with your preferred API)
    const apiResponse = await fetch('https://api.exchangerate-api.com/v4/latest/USD')

    if (!apiResponse.ok) {
      throw new Error(`Failed to fetch exchange rates: ${apiResponse.statusText}`)
    }

    const data: ExchangeRateResponse = await apiResponse.json()

    // Get current USD/VND rate (fallback to default if not available)
    const usdToVnd = data.rates.VND || 25700

    // Update exchange rates in database
    const updates = [
      // USD to VND
      supabase.from('exchange_rates').upsert(
        {
          source_currency: 'USD',
          target_currency: 'VND',
          rate: usdToVnd,
          last_updated_at: new Date().toISOString(),
        },
        { onConflict: 'source_currency,target_currency' }
      ),

      // VND to USD (inverse)
      supabase.from('exchange_rates').upsert(
        {
          source_currency: 'VND',
          target_currency: 'USD',
          rate: 1 / usdToVnd,
          last_updated_at: new Date().toISOString(),
        },
        { onConflict: 'source_currency,target_currency' }
      ),
    ]

    // Add other major currency pairs if available
    const majorCurrencies = ['EUR', 'GBP', 'JPY', 'CNY']
    for (const currency of majorCurrencies) {
      if (data.rates[currency]) {
        updates.push(
          supabase.from('exchange_rates').upsert(
            {
              source_currency: 'USD',
              target_currency: currency,
              rate: data.rates[currency],
              last_updated_at: new Date().toISOString(),
            },
            { onConflict: 'source_currency,target_currency' }
          )
        )

        updates.push(
          supabase.from('exchange_rates').upsert(
            {
              source_currency: currency,
              target_currency: 'USD',
              rate: 1 / data.rates[currency],
              last_updated_at: new Date().toISOString(),
            },
            { onConflict: 'source_currency,target_currency' }
          )
        )
      }
    }

    // Execute all updates
    const results = await Promise.allSettled(updates)

    // Count successful updates
    const successful = results.filter((r) => r.status === 'fulfilled').length
    const failed = results.length - successful

    // Log the update
    await supabase.from('system_logs').insert({
      action: 'exchange_rates_update',
      status: failed === 0 ? 'success' : 'partial',
      details: {
        total_rates: results.length,
        successful,
        failed,
        usd_to_vnd: usdToVnd,
        api_date: data.date,
      },
      created_at: new Date().toISOString(),
    })

    return new Response(
      JSON.stringify({
        success: true,
        message: `Updated ${successful} exchange rates${failed > 0 ? ` (${failed} failed)` : ''}`,
        data: {
          usdToVnd,
          totalUpdated: successful,
          failed,
          apiDate: data.date,
        },
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Error updating exchange rates:', error)

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
