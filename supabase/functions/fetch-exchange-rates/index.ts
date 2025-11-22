import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// API Configuration
const API_CONFIG = {
  primary: {
    name: 'fawazahmed0',
    url: 'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json',
    parser: 'parseFawazahmed0'
  },
  fallback: {
    name: 'exchangerate-api',
    url: 'https://v6.exchangerate-api.com/v6/latest/USD',
    parser: 'parseExchangeRateAPI'
  }
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Parse Fawazahmed0 API response
function parseFawazahmed0(data: any) {
  if (!data?.date || !data?.usd) {
    throw new Error('Invalid Fawazahmed0 API response format')
  }

  const rates = []
  const timestamp = new Date().toISOString()
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24 hours

  // Get USD base rates
  const usdRates = data.usd
  const baseCurrency = 'USD'

  // Process all currencies from USD base
  for (const [toCurrency, rate] of Object.entries(usdRates)) {
    if (typeof rate === 'number' && rate > 0) {
      // Direct pair: USD -> XXX
      rates.push({
        from_currency: baseCurrency,
        to_currency: toCurrency.toUpperCase(),
        rate: rate,
        effective_date: timestamp,
        expires_at: expiresAt
      })

      // Reverse pair: XXX -> USD
      rates.push({
        from_currency: toCurrency.toUpperCase(),
        to_currency: baseCurrency,
        rate: 1 / rate,
        effective_date: timestamp,
        expires_at: expiresAt
      })
    }
  }

  console.log(`Parsed ${rates.length} rates from Fawazahmed0 API`)
  return rates
}

// Parse ExchangeRate-API.com response
function parseExchangeRateAPI(data: any) {
  if (!data?.conversion_rates) {
    throw new Error('Invalid ExchangeRate-API response format')
  }

  const rates = []
  const baseCurrency = data.base || 'USD'
  const timestamp = new Date().toISOString()
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24 hours

  for (const [toCurrency, rate] of Object.entries(data.conversion_rates)) {
    if (typeof rate === 'number') {
      // Direct pair: Base -> XXX
      rates.push({
        from_currency: baseCurrency,
        to_currency: toCurrency.toUpperCase(),
        rate: rate,
        effective_date: timestamp,
        expires_at: expiresAt
      })

      // Reverse pair: XXX -> Base
      if (rate !== 0) {
        rates.push({
          from_currency: toCurrency.toUpperCase(),
          to_currency: baseCurrency,
          rate: 1 / rate,
          effective_date: timestamp,
          expires_at: expiresAt
        })
      }
    }
  }

  return rates
}

// Fetch rates from API with timeout
async function fetchRatesFromAPI(config: any, supabase: any) {
  const controller = new AbortController()
  const timeoutId = setTimeout(() => controller.abort(), 10000) // 10 second timeout

  try {
    const startTime = Date.now()

    const response = await fetch(config.url, {
      signal: controller.signal,
      headers: {
        'User-Agent': 'Supabase-Edge-Function/1.0'
      }
    })

    clearTimeout(timeoutId)

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    const data = await response.json()
    const responseTime = Date.now() - startTime

    // Parse based on API type
    const parser = config.name === 'fawazahmed0' ? parseFawazahmed0 : parseExchangeRateAPI
    const rates = parser(data)

    // Log successful fetch
    await supabase.from('exchange_rate_api_log').insert({
      api_provider: config.name,
      endpoint_url: config.url,
      success: true,
      response_time_ms: responseTime,
      currencies_fetched: rates.length
    })

    return rates

  } catch (error) {
    clearTimeout(timeoutId)

    // Log failed fetch
    await supabase.from('exchange_rate_api_log').insert({
      api_provider: config.name,
      endpoint_url: config.url,
      success: false,
      error_message: error.message
    })

    throw error
  }
}

// Get active currencies from database
async function getActiveCurrencies(supabase: any) {
  const { data, error } = await supabase
    .from('currencies')
    .select('code')
    .eq('is_active', true)

  if (error) throw error
  return data?.map(c => c.code) || ['USD', 'VND', 'CNY'] // fallback
}

// Filter rates for active currencies only and add cross rates
function filterRatesForActiveCurrencies(rates: any[], activeCurrencies: string[]) {
  const currencySet = new Set(activeCurrencies.map(c => c.toUpperCase()))
  console.log(`Active currencies: ${Array.from(currencySet).join(', ')}`)
  console.log(`Total rates received: ${rates.length}`)

  // Filter direct rates
  const directRates = rates.filter(rate =>
    currencySet.has(rate.from_currency) &&
    currencySet.has(rate.to_currency) &&
    rate.from_currency !== rate.to_currency
  )

  console.log(`Direct rates after filtering: ${directRates.length}`)

  // Calculate cross rates (e.g., VND/CNY using USD as base)
  const crossRates = []
  const usdRateMap = new Map()

  // Build USD rate map
  for (const rate of directRates) {
    if (rate.from_currency === 'USD') {
      usdRateMap.set(rate.to_currency, rate.rate)
    } else if (rate.to_currency === 'USD') {
      usdRateMap.set(rate.from_currency, 1 / rate.rate)
    }
  }

  console.log(`USD rate map entries: ${usdRateMap.size}`)

  // Calculate cross rates for all combinations
  const currencies = Array.from(currencySet)
  for (let i = 0; i < currencies.length; i++) {
    for (let j = 0; j < currencies.length; j++) {
      const from = currencies[i]
      const to = currencies[j]

      if (from !== to &&
          !directRates.some(r => r.from_currency === from && r.to_currency === to) &&
          usdRateMap.has(from) && usdRateMap.has(to)) {

        // Calculate cross rate: from/to = (from/USD) / (to/USD)
        const fromToUSD = usdRateMap.get(from)
        const toToUSD = usdRateMap.get(to)
        const crossRate = fromToUSD / toToUSD

        crossRates.push({
          from_currency: from,
          to_currency: to,
          rate: crossRate,
          effective_date: new Date().toISOString(),
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
        })
      }
    }
  }

  const totalRates = [...directRates, ...crossRates]
  console.log(`Final rates after cross rate calculation: ${totalRates.length}`)

  return totalRates
}

// Update exchange rates in database
async function updateExchangeRates(supabase: any, rates: any[]) {
  if (rates.length === 0) return

  // Deactivate old rates
  await supabase
    .from('exchange_rates')
    .update({ is_active: false })
    .eq('is_active', true)
    .lt('effective_date', new Date().toISOString())

  // Insert new rates
  const { error } = await supabase
    .from('exchange_rates')
    .upsert(rates, {
      onConflict: 'from_currency,to_currency,effective_date',
      ignoreDuplicates: false
    })

  if (error) throw error
}

// Update API configuration
async function updateAPIConfig(supabase: any, apiUsed: string, failures: number = 0) {
  const updateData: any = {
    last_api_used: apiUsed,
    last_successful_fetch: apiUsed === 'primary' || apiUsed === 'fallback' ? new Date().toISOString() : null,
    updated_at: new Date().toISOString()
  }

  if (failures >= 0) {
    updateData.api_failures = failures
  }

  const { error } = await supabase
    .from('exchange_rate_config')
    .update(updateData)
    .eq('is_active', true)

  if (error) throw error
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get active configuration
    const { data: config, error: configError } = await supabase
      .from('exchange_rate_config')
      .select('*')
      .eq('is_active', true)
      .single()

    if (configError || !config) {
      throw new Error('Configuration not found')
    }

    // Get active currencies
    const activeCurrencies = await getActiveCurrencies(supabase)
    console.log(`Active currencies: ${activeCurrencies.join(', ')}`)

    let rates = []
    let apiUsed = null

    // Try primary API first
    try {
      console.log(`Trying primary API: ${API_CONFIG.primary.name}`)
      const allRates = await fetchRatesFromAPI(API_CONFIG.primary, supabase)
      rates = filterRatesForActiveCurrencies(allRates, activeCurrencies)
      apiUsed = 'primary'

      // Reset failure count on success
      await updateAPIConfig(supabase, apiUsed, 0)
      console.log(`Primary API success: ${rates.length} rates fetched`)

    } catch (primaryError) {
      console.warn(`Primary API failed:`, primaryError.message)

      // Try fallback API
      try {
        console.log(`Trying fallback API: ${API_CONFIG.fallback.name}`)
        const allRates = await fetchRatesFromAPI(API_CONFIG.fallback, supabase)
        rates = filterRatesForActiveCurrencies(allRates, activeCurrencies)
        apiUsed = 'fallback'

        // Increment failure count
        await updateAPIConfig(supabase, apiUsed, config.api_failures + 1)
        console.log(`Fallback API success: ${rates.length} rates fetched`)

      } catch (fallbackError) {
        console.error(`Both APIs failed`)
        await updateAPIConfig(supabase, 'none', config.api_failures + 1)

        return new Response(
          JSON.stringify({
            error: 'All APIs failed',
            primary_error: primaryError.message,
            fallback_error: fallbackError.message
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        )
      }
    }

    // Update database with new rates
    if (rates.length > 0) {
      await updateExchangeRates(supabase, rates)
      console.log(`Updated ${rates.length} exchange rates in database`)
    }

    // Return success response
    const responseData = {
      success: true,
      api_used: apiUsed,
      total_rates_fetched: rates.length,
      active_currencies: activeCurrencies,
      timestamp: new Date().toISOString(),
      sample_rates: rates.slice(0, 5) // Show first 5 rates as sample
    }

    return new Response(
      JSON.stringify(responseData),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Edge function error:', error)

    return new Response(
      JSON.stringify({
        error: 'Internal server error',
        message: error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})