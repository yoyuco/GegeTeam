// path: src/composables/usePoeCurrencies.js
import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'

export function usePoeCurrencies() {
  // Reactive state
  const attributes = ref([])
  const currencyInventory = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Computed properties
  const poeCurrencies = computed(() => {
    return attributes.value
      .filter((attr) => {
        // Filter for currency types across different POE versions
        return (
          attr.type === 'CURRENCY_POE1' ||
          attr.type === 'CURRENCY_POE2' ||
          attr.type === 'CURRENCY_D4'
        )
      })
      .map((attr) => ({
        id: attr.id,
        code: attr.code,
        name: attr.name,
        type: attr.type,
        sort_order: attr.sort_order,
        description: attr.description,
        // Create a display name with type info
        displayName: `${attr.name} (${attr.type})`,
        // Extract game version from type
        gameVersion: attr.type.includes('POE1')
          ? 'POE1'
          : attr.type.includes('POE2')
            ? 'POE2'
            : attr.type.includes('D4')
              ? 'D4'
              : 'Unknown',
      }))
      .sort((a, b) => a.sort_order - b.sort_order)
  })

  // Get POE currencies for specific game version
  const getPoeCurrenciesByGame = (gameVersion) => {
    return poeCurrencies.value.filter((currency) => {
      switch (gameVersion) {
        case 'POE_2':
          return currency.type === 'CURRENCY_POE2'
        case 'POE_1':
          return currency.type === 'CURRENCY_POE1'
        case 'D4':
          return currency.type === 'CURRENCY_D4'
        default:
          return true // Return all if no specific game version
      }
    })
  }

  // Get POE currencies that have inventory data
  const getPoeCurrenciesWithInventory = () => {
    const currencyIds = new Set(currencyInventory.value.map((inv) => inv.currency_attribute_id))
    return poeCurrencies.value.filter((currency) => currencyIds.has(currency.id))
  }

  // Load attributes data
  const loadPoeCurrencies = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('attributes')
        .select('*')
        .eq('type', 'CURRENCY_POE1')
        .eq('is_active', true)
        .order('sort_order')

      if (fetchError) throw fetchError
      attributes.value = data || []

      console.log('Loaded POE currencies:', attributes.value.length)

      // Also try to load other currency types
      const { data: poe2Data, error: poe2Error } = await supabase
        .from('attributes')
        .select('*')
        .eq('type', 'CURRENCY_POE2')
        .eq('is_active', true)
        .order('sort_order')

      if (poe2Error) throw poe2Error
      attributes.value = [...attributes.value, ...(poe2Data || [])]

      const { data: d4Data, error: d4Error } = await supabase
        .from('attributes')
        .select('*')
        .eq('type', 'CURRENCY_D4')
        .eq('is_active', true)
        .order('sort_order')

      if (d4Error) throw d4Error
      attributes.value = [...attributes.value, ...(d4Data || [])]

      console.log('Total POE currencies loaded:', attributes.value.length)
    } catch (err) {
      console.error('Error loading POE currencies:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Load currency inventory data
  const loadCurrencyInventory = async () => {
    try {
      const { data, error: fetchError } = await supabase
        .from('currency_inventory')
        .select('*')
        .order('quantity', { ascending: false })

      if (fetchError) throw fetchError
      currencyInventory.value = data || []
      console.log('Loaded currency inventory:', currencyInventory.value.length)
    } catch (err) {
      console.error('Error loading currency inventory:', err)
    }
  }

  // Initialize data
  const initialize = async () => {
    await Promise.all([loadPoeCurrencies(), loadCurrencyInventory()])
  }

  return {
    // State
    attributes,
    currencyInventory,
    loading,
    error,

    // Computed
    poeCurrencies,

    // Methods
    getPoeCurrenciesByGame,
    getPoeCurrenciesWithInventory,
    loadPoeCurrencies,
    loadCurrencyInventory,
    initialize,
  }
}
