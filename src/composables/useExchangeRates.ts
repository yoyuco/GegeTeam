import { ref, readonly } from 'vue'
import { supabase } from '@/lib/supabase'

export interface ExchangeRates {
  [currency: string]: number
}

export function useExchangeRates() {
  const exchangeRates = ref<ExchangeRates>({})
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Load exchange rates from database
  const loadExchangeRates = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('exchange_rates')
        .select('from_currency, to_currency, rate')
        .eq('is_active', true)
        .or('expires_at.is.null,expires_at.gt.now()')

      if (fetchError) throw fetchError

      // Build exchange rate map for conversion to VND
      const rates: ExchangeRates = {}

      // First, collect all direct rates to VND
      data.forEach((rate: any) => {
        if (rate.to_currency === 'VND') {
          rates[rate.from_currency] = parseFloat(rate.rate)
        }
      })

      // If no direct rates found, try to build from any available rates
      if (Object.keys(rates).length === 0) {
        // Find a base currency to convert through
        const allCurrencies = new Set<string>()
        data.forEach((rate: any) => {
          allCurrencies.add(rate.from_currency)
          allCurrencies.add(rate.to_currency)
        })

        // Try to use VND as base if available, otherwise use first currency
        const baseCurrency = allCurrencies.has('VND') ? 'VND' : Array.from(allCurrencies)[0]

        if (baseCurrency === 'VND') {
          // Build VND rates from reverse conversions
          data.forEach((rate: any) => {
            if (rate.from_currency === 'VND') {
              rates[rate.to_currency] = 1 / parseFloat(rate.rate)
            }
          })
        }
      }

      // Default VND to VND rate
      rates['VND'] = rates['VND'] || 1

      exchangeRates.value = rates

      return rates
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to load exchange rates'

      // Fallback rates
      const fallbackRates: ExchangeRates = {
        'VND': 1,
        'USD': 25000,
        'CNY': 3500,
        'EUR': 27000
      }

      exchangeRates.value = fallbackRates
      return fallbackRates
    } finally {
      loading.value = false
    }
  }

  // Convert amount from cost currency to VND
  const convertToVND = (amount: number, costCurrency: string): number => {
    const rate = exchangeRates.value[costCurrency] || 1
    return amount * rate
  }

  // Convert amount from VND to target currency
  const convertFromVND = (amount: number, targetCurrency: string): number => {
    const rate = exchangeRates.value[targetCurrency] || 1
    return amount / rate
  }

  // Convert between any two currencies (VND as intermediate)
  const convertCurrency = (amount: number, fromCurrency: string, toCurrency: string): number => {
    if (fromCurrency === toCurrency) return amount

    // Convert to VND first, then to target
    const amountInVND = convertToVND(amount, fromCurrency)
    return convertFromVND(amountInVND, toCurrency)
  }

  // Get current exchange rate for a currency
  const getExchangeRate = (currency: string): number => {
    return exchangeRates.value[currency] || 1
  }

  // Format amount with currency conversion
  const formatCurrencyWithConversion = (
    amount: number,
    originalCurrency: string,
    targetCurrency: string = 'VND'
  ): { amount: number; originalCurrency: string; targetCurrency: string; converted: boolean } => {
    if (originalCurrency === targetCurrency) {
      return { amount, originalCurrency, targetCurrency, converted: false }
    }

    const convertedAmount = convertCurrency(amount, originalCurrency, targetCurrency)
    return { amount: convertedAmount, originalCurrency, targetCurrency, converted: true }
  }

  return {
    exchangeRates: readonly(exchangeRates),
    loading: readonly(loading),
    error: readonly(error),
    loadExchangeRates,
    convertToVND,
    convertFromVND,
    convertCurrency,
    getExchangeRate,
    formatCurrencyWithConversion
  }
}