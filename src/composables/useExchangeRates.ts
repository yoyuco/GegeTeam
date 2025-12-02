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

      // First, collect all direct rates to VND (e.g., USD->VND, CNY->VND)
      data.forEach((rate: any) => {
        if (rate.to_currency === 'VND') {
          rates[rate.from_currency] = parseFloat(rate.rate)
        }
      })


      // Also collect reverse rates from VND (e.g., VND->USD) and convert them
      data.forEach((rate: any) => {
        if (rate.from_currency === 'VND' && !rates[rate.to_currency]) {
          rates[rate.to_currency] = 1 / parseFloat(rate.rate)
        }
      })

      // If still no direct rates found, try to build from any available rates using USD as base
      if (Object.keys(rates).length === 0) {
        // Find USD as base currency
        const usdRates: { [key: string]: number } = {}
        data.forEach((rate: any) => {
          if (rate.from_currency === 'USD') {
            usdRates[rate.to_currency] = parseFloat(rate.rate)
          } else if (rate.to_currency === 'USD') {
            usdRates[rate.from_currency] = 1 / parseFloat(rate.rate)
          }
        })

        // If we have USD->VND rate, use it to build other rates
        if (usdRates['VND']) {
          rates['USD'] = usdRates['VND']
          rates['VND'] = 1

          // Build other currency rates through USD
          Object.keys(usdRates).forEach(currency => {
            if (currency !== 'VND' && currency !== 'USD') {
              rates[currency] = usdRates[currency] * usdRates['VND']
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

      console.error('Failed to load exchange rates from database:', err)

      // Don't use fallback - return empty rates to indicate error
      exchangeRates.value = {}
      throw new Error(`Không thể tải tỷ giá hối đoái từ database. Lỗi: ${err instanceof Error ? err.message : 'Unknown error'}`)
    } finally {
      loading.value = false
    }
  }

  // Convert amount from cost currency to VND
  const convertToVND = (amount: number, costCurrency: string): number => {
    if (costCurrency === 'VND') {
      return amount
    }

    const rate = exchangeRates.value[costCurrency]
    if (!rate || rate === 0) {
      throw new Error(`Không tìm thấy tỷ giá hối đoái cho ${costCurrency} -> VND. Vui lòng kiểm tra lại dữ liệu exchange rates.`)
    }

    return amount * rate
  }

  // Convert amount from VND to target currency
  const convertFromVND = (amount: number, targetCurrency: string): number => {
    if (targetCurrency === 'VND') {
      return amount
    }

    const rate = exchangeRates.value[targetCurrency]
    if (!rate || rate === 0) {
      throw new Error(`Không tìm thấy tỷ giá hối đoái cho VND -> ${targetCurrency}. Vui lòng kiểm tra lại dữ liệu exchange rates.`)
    }

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
    const rate = exchangeRates.value[currency]
    if (!rate || rate === 0) {
      throw new Error(`Không tìm thấy tỷ giá hối đoái cho ${currency}. Vui lòng kiểm tra lại dữ liệu exchange rates.`)
    }
    return rate
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