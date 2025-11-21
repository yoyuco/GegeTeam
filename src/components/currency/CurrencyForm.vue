<!-- path: src/components/currency/CurrencyForm.vue -->
<!-- Dynamic Currency Form Component with Buy/Sell Tabs -->
<template>
  <div class="bg-white rounded-xl shadow-sm border border-gray-200">
    <!-- Tab Content -->
    <div class="p-6">
      <!-- Buy Tab -->
      <div v-if="transactionType === 'purchase'" class="space-y-6">

        <!-- Currency Selection -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-blue-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Loại Currency</label>
            <span class="text-red-500">*</span>
          </div>
          <n-select
            v-model:value="buyFormData.currencyId"
            :options="currencyOptions"
            :placeholder="loading ? 'Đang tải...' : 'Chọn loại currency'"
            filterable
            :loading="loading"
            size="large"
            class="w-full"
            clearable
          />
        </div>

        <!-- Quantity -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-green-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Số lượng</label>
            <span class="text-red-500">*</span>
          </div>
          <n-input-number
            v-model:value="buyFormData.quantity"
            :min="0"
            placeholder="Nhập số lượng"
            size="large"
            class="w-full"
          />
        </div>

        <!-- Total Price -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-yellow-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Tổng tiền</label>
            <span class="text-red-500">*</span>
            <!-- Exchange Rate Display with Price Warning -->
            <div v-if="buyFormData.currencyId && buyFormData.quantity && buyFormData.totalPrice"
                 :class="getPriceComparisonClass(buyFormData.currencyId, buyFormData.totalPrice / buyFormData.quantity)"
                 class="ml-auto text-xs px-2 py-1 rounded-full border font-medium flex items-center gap-1">
              1 {{ getCurrencyName(buyFormData.currencyId) }} = {{ formatCurrency(buyFormData.totalPrice / buyFormData.quantity) }}/{{ buyFormData.currencyCode }}
              <!-- Warning Icon -->
              <div v-if="priceComparisonData.warning_level === 'high'"
                   class="w-3 h-3 bg-orange-100 rounded-full flex items-center justify-center"
                   :title="priceComparisonData.comparison_message">
                <svg class="w-2 h-2 text-orange-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                </svg>
              </div>
            </div>
          </div>
          <div class="flex gap-2">
            <n-input-number
              v-model:value="buyFormData.totalPrice"
              :min="0"
              placeholder="Nhập tổng tiền"
              size="large"
              class="flex-1"
              @blur="validatePurchasePrice"
            />
            <n-select
              v-model:value="buyFormData.currencyCode"
              :options="currencyCodeOptions"
              placeholder="VND"
              size="large"
              class="w-20"
              style="min-width: 80px; max-width: 100px;"
            />
          </div>
          <!-- Price Comparison Warning -->
          <div v-if="priceComparisonData.warning_level === 'high' && priceComparisonData.has_inventory_pool"
               class="mt-2 p-2 bg-red-50 border border-red-200 rounded-lg">
            <p class="text-sm text-red-800 font-medium">
              ⚠️ {{ priceComparisonData.price_difference_percent > 0 ? 'Giá cao hơn' : 'Giá thấp hơn' }}
              {{ Math.abs(priceComparisonData.price_difference_percent).toFixed(1) }}% so với TB giá
              ({{ formatCurrency(priceComparisonData.average_cost) }} {{ priceComparisonData.cost_currency }})
            </p>
          </div>
        </div>

        <!-- Notes -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-gray-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Ghi chú</label>
          </div>
          <n-input
            v-model:value="buyFormData.notes"
            placeholder="Ghi chú thêm về giao dịch mua vào"
            size="large"
            class="w-full"
          />
        </div>
      </div>

      <!-- Sell Tab -->
      <div v-if="transactionType === 'sale'" class="space-y-6">

        <!-- Currency Selection -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-blue-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Loại Currency</label>
            <span class="text-red-500">*</span>
          </div>
          <n-select
            v-model:value="sellFormData.currencyId"
            :options="currencyOptions"
            :placeholder="loading ? 'Đang tải...' : 'Chọn loại currency'"
            filterable
            :loading="loading"
            size="large"
            class="w-full"
            clearable
          />
        </div>

        <!-- Quantity -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-green-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Số lượng</label>
            <span class="text-red-500">*</span>
          </div>
          <n-input-number
            v-model:value="sellFormData.quantity"
            :min="0"
            placeholder="Nhập số lượng"
            size="large"
            class="w-full"
          />
        </div>

        <!-- Total Price -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-yellow-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Tổng tiền</label>
            <span class="text-red-500">*</span>
            <!-- Exchange Rate Display -->
            <div v-if="sellFormData.currencyId && sellFormData.quantity && sellFormData.totalPrice"
                 class="ml-auto bg-blue-100 text-blue-700 text-xs px-2 py-1 rounded-full border border-blue-200 font-medium">
              1 {{ getCurrencyName(sellFormData.currencyId) }} = {{ formatCurrency(sellFormData.totalPrice / sellFormData.quantity) }}/{{ sellFormData.currencyCode }}
            </div>
          </div>
          <div class="flex gap-2">
            <n-input-number
              v-model:value="sellFormData.totalPrice"
              :min="0"
              placeholder="Nhập tổng tiền"
              size="large"
              class="flex-1"
            />
            <n-select
              v-model:value="sellFormData.currencyCode"
              :options="currencyCodeOptions"
              placeholder="VND"
              size="large"
              class="w-20"
              style="min-width: 80px; max-width: 100px;"
            />
          </div>
        </div>

        <!-- Notes -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-gray-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Ghi chú</label>
          </div>
          <n-input
            v-model:value="sellFormData.notes"
            placeholder="Ghi chú thêm về giao dịch bán ra"
            size="large"
            class="w-full"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, watch, ref } from 'vue'
import { NSelect, NInputNumber, NInput } from 'naive-ui'
import { supabase } from '@/lib/supabase'

// Helper functions for exchange rate display
const getCurrencyName = (currencyId: string) => {
  const currency = currencyOptions.value.find((c: any) => c.value === currencyId)
  return currency?.data?.name || currency?.data?.code || currency?.label || 'Unknown'
}

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('vi-VN', {
    minimumFractionDigits: 0,
    maximumFractionDigits: amount < 1 ? 4 : amount < 10 ? 2 : 0
  }).format(amount)
}

// Price comparison reactive state
const priceComparisonData = ref({
  has_inventory_pool: false,
  average_cost: 0,
  cost_currency: '',
  price_difference_percent: 0,
  warning_level: 'no_data',
  comparison_message: ''
})

// Price comparison methods
const getPriceComparisonClass = (_currencyId: string, _unitPrice: number) => {
  if (props.transactionType !== 'purchase') {
    return 'bg-blue-100 text-blue-700 border-blue-200'
  }

  switch (priceComparisonData.value.warning_level) {
    case 'high':
      return 'bg-red-100 text-red-700 border-red-200'
    case 'medium':
      return 'bg-orange-100 text-orange-700 border-orange-200'
    case 'low':
      return 'bg-green-100 text-green-700 border-green-200'
    default:
      return 'bg-blue-100 text-blue-700 border-blue-200'
  }
}

const validatePurchasePrice = async () => {
  if (props.transactionType !== 'purchase') {
    return
  }

  if (!buyFormData.value.currencyId || !buyFormData.value.quantity || !buyFormData.value.totalPrice) {
    return
  }

  const unitPrice = buyFormData.value.totalPrice / buyFormData.value.quantity

  if (!props.gameCode || !props.channelId) {
    return
  }

  try {
    const { data, error } = await supabase.rpc('check_purchase_price_vs_inventory', {
      p_game_code: props.gameCode,
      p_server_attribute_code: props.serverCode || '',
      p_currency_attribute_id: buyFormData.value.currencyId,
      p_channel_id: props.channelId,
      p_currency_code: buyFormData.value.currencyCode,
      p_unit_price: unitPrice
    })

    if (!error && data && data.length > 0) {
      priceComparisonData.value = {
        ...data[0],
        has_inventory_pool: data[0].has_inventory_pool
      }
    } else {
      // Reset to no data state on error
      priceComparisonData.value = {
        has_inventory_pool: false,
        average_cost: 0,
        cost_currency: '',
        price_difference_percent: 0,
        warning_level: 'no_data',
        comparison_message: ''
      }
    }
  } catch (err) {
    console.error('Error validating purchase price:', err)
    // Reset to no data state on error
    priceComparisonData.value = {
      has_inventory_pool: false,
      average_cost: 0,
      cost_currency: '',
      price_difference_percent: 0,
      warning_level: 'no_data',
      comparison_message: ''
    }
  }
}


// Props
interface Props {
  buyModelValue?: {
    currencyId: string | null
    quantity: number | null
    totalPrice: number | null
    currencyCode: string
    notes: string
  }
  sellModelValue?: {
    currencyId: string | null
    quantity: number | null
    totalPrice: number | null
    currencyCode: string
    notes: string
  }
  currencies: any[]
  currencyCodeOptions?: any[]
  loading?: boolean
  transactionType?: 'sale' | 'purchase'
  activeTab?: 'buy' | 'sell'
  gameCode?: string
  serverCode?: string
  channelId?: string | null
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  transactionType: 'sale',
  activeTab: 'sell',
  currencyCodeOptions: () => []
})

// Emits
const emit = defineEmits<{
  'update:buyModelValue': [value: Props['buyModelValue']]
  'update:sellModelValue': [value: Props['sellModelValue']]
  'update:activeTab': [value: 'buy' | 'sell']
  'currency-changed': [currencyId: string | null]
  'quantity-changed': [quantity: number | null]
  'price-changed': [price: { vnd?: number; usd?: number }]
}>()

// Reactive state
const activeTab = ref<'buy' | 'sell'>(props.activeTab)

// Form data
const buyFormData = computed({
  get: () => props.buyModelValue || {
    currencyId: null,
    quantity: null,
    totalPrice: null,
    currencyCode: 'VND',
    notes: ''
  },
  set: (value) => emit('update:buyModelValue', value),
})

const sellFormData = computed({
  get: () => props.sellModelValue || {
    currencyId: null,
    quantity: null,
    totalPrice: null,
    currencyCode: 'VND',
    notes: ''
  },
  set: (value) => emit('update:sellModelValue', value),
})

// Computed properties
const loading = computed(() => props.loading)

const currencyOptions = computed(() => {
  // When loading or currencies empty, return array with loading placeholder
  if (props.loading || !props.currencies || !Array.isArray(props.currencies) || props.currencies.length === 0) {
    // Return empty array to prevent UUID display
    return []
  }
  // Check if current currency ID is still valid in the options
  const buyId = buyFormData.value.currencyId
  const sellId = sellFormData.value.currencyId

  // If we have a selected ID that's not in the options, return empty to prevent invalid display
  if (buyId && !props.currencies.some((c: any) => c.value === buyId)) {
    return []
  }
  if (sellId && !props.currencies.some((c: any) => c.value === sellId)) {
    return []
  }

  return props.currencies
})

// Currency code options for the dropdown - use provided options or fallback to extracting from currencies
const currencyCodeOptions = computed(() => {
  // Use provided currency code options if available
  if (props.currencyCodeOptions && Array.isArray(props.currencyCodeOptions) && props.currencyCodeOptions.length > 0) {
    return props.currencyCodeOptions
  }

  // Fallback: extract from currencies data (for backward compatibility)
  if (!props.currencies || !Array.isArray(props.currencies) || props.currencies.length === 0) {
    return []
  }

  // Extract unique currency codes from the currencies data
  const uniqueCodes = [...new Set(props.currencies.map((currency: any) => currency.code).filter(Boolean))]

  // Sort alphabetically for better UX
  return uniqueCodes.sort().map(code => ({
    label: code,
    value: code
  }))
})



// Watch for tab changes
watch(activeTab, (newTab) => {
  emit('update:activeTab', newTab)
})

// Watch for loading state and currency availability to handle auto-selection
watch(
  () => [props.loading, props.currencies],
  ([isLoading, currencies]) => {
    if (!isLoading && currencies && Array.isArray(currencies) && currencies.length > 0) {
      // Loading completed and currencies are available

      // Auto-select first currency for buy form if not selected
      if (!buyFormData.value.currencyId) {
        buyFormData.value.currencyId = (currencies as any[])[0].value
      }

      // Auto-select first currency for sell form if not selected
      if (!sellFormData.value.currencyId) {
        sellFormData.value.currencyId = (currencies as any[])[0].value
      }
    } else if (isLoading) {
      // When loading starts, reset invalid currency IDs
      const currentBuyCurrencyId = buyFormData.value.currencyId
      const currentSellCurrencyId = sellFormData.value.currencyId

      // Only reset if the current ID won't be in the new options
      if (currentBuyCurrencyId && currencies && Array.isArray(currencies) && !(currencies as any[]).some((c: any) => c.value === currentBuyCurrencyId)) {
        buyFormData.value.currencyId = null
      }
      if (currentSellCurrencyId && currencies && Array.isArray(currencies) && !(currencies as any[]).some((c: any) => c.value === currentSellCurrencyId)) {
        sellFormData.value.currencyId = null
      }
    }
  },
  { immediate: true }
)

// Watch for buy form changes and emit events
watch(
  () => buyFormData.value.currencyId,
  (newCurrencyId: string | null) => {
    emit('currency-changed', newCurrencyId)
  }
)

watch(
  () => buyFormData.value.quantity,
  (newQuantity: number | null) => {
    emit('quantity-changed', newQuantity)
  }
)

watch(
  () => buyFormData.value.totalPrice,
  (newPrice: number | null) => {
    emit('price-changed', {
      [buyFormData.value.currencyCode]: newPrice || undefined
    })
  }
)

watch(
  () => buyFormData.value.currencyCode,
  (newCurrencyCode: string) => {
    emit('price-changed', {
      [newCurrencyCode]: buyFormData.value.totalPrice || undefined
    })
  }
)

// Watch for individual buy form changes and emit update:buyModelValue
watch(
  () => buyFormData.value.currencyId,
  (newCurrencyId) => {
    emit('update:buyModelValue', { ...buyFormData.value, currencyId: newCurrencyId })
    // Reset price comparison when currency changes
    priceComparisonData.value = {
      has_inventory_pool: false,
      average_cost: 0,
      cost_currency: '',
      price_difference_percent: 0,
      warning_level: 'no_data',
      comparison_message: ''
    }
    // Validate price after reset
    validatePurchasePrice()
  }
)

watch(
  () => buyFormData.value.quantity,
  (newQuantity) => {
    emit('update:buyModelValue', { ...buyFormData.value, quantity: newQuantity })
    // Validate price when quantity changes
    validatePurchasePrice()
  }
)

watch(
  () => buyFormData.value.totalPrice,
  (newPrice) => {
    emit('update:buyModelValue', { ...buyFormData.value, totalPrice: newPrice })
    // Validate price when price changes
    validatePurchasePrice()
  }
)

watch(
  () => buyFormData.value.currencyCode,
  (newCurrencyCode) => {
    emit('update:buyModelValue', { ...buyFormData.value, currencyCode: newCurrencyCode })
    // Validate price when currency code changes
    validatePurchasePrice()
  }
)

watch(
  () => buyFormData.value.notes,
  (newNotes) => {
    emit('update:buyModelValue', { ...buyFormData.value, notes: newNotes })
  }
)

// Watch for sell form changes and emit events
watch(
  () => sellFormData.value.currencyId,
  (newCurrencyId: string | null) => {
    emit('currency-changed', newCurrencyId)
  }
)

watch(
  () => sellFormData.value.quantity,
  (newQuantity: number | null) => {
    emit('quantity-changed', newQuantity)
  }
)

// Watch for sell form changes and emit events
watch(
  () => sellFormData.value.totalPrice,
  (newPrice: number | null) => {
    emit('price-changed', {
      [sellFormData.value.currencyCode]: newPrice || undefined
    })
  }
)

watch(
  () => sellFormData.value.currencyCode,
  (newCurrencyCode: string) => {
    emit('price-changed', {
      [newCurrencyCode]: sellFormData.value.totalPrice || undefined
    })
  }
)

// Watch for context changes to reset price comparison
watch(
  [() => props.gameCode, () => props.serverCode, () => props.channelId],
  ([newGameCode, newServerCode, newChannelId], [oldGameCode, oldServerCode, oldChannelId]) => {
    // Only reset if any context value actually changed and has a value
    if (
      (newGameCode && newGameCode !== oldGameCode) ||
      (newServerCode && newServerCode !== oldServerCode) ||
      (newChannelId && newChannelId !== oldChannelId)
    ) {
      priceComparisonData.value = {
        has_inventory_pool: false,
        average_cost: 0,
        cost_currency: '',
        price_difference_percent: 0,
        warning_level: 'no_data',
        comparison_message: ''
      }
    }
  },
  { immediate: false }
)


// Methods for parent component
const resetForm = () => {
  if (props.transactionType === 'purchase') {
    emit('update:buyModelValue', {
      currencyId: null,
      quantity: null,
      totalPrice: null,
      currencyCode: 'VND',
      notes: '',
    })
  } else {
    emit('update:sellModelValue', {
      currencyId: null,
      quantity: null,
      totalPrice: null,
      currencyCode: 'VND',
      notes: '',
    })
  }
}

const validateForm = () => {
  const errors = []

  if (activeTab.value === 'buy') {
    if (!buyFormData.value.currencyId) {
      errors.push('Vui lòng chọn loại currency')
    }
    if (!buyFormData.value.quantity || buyFormData.value.quantity <= 0) {
      errors.push('Số lượng phải lớn hơn 0')
    }
    if (!buyFormData.value.currencyCode) {
      errors.push('Vui lòng chọn đơn vị tiền tệ')
    }
    if (buyFormData.value.totalPrice === null || buyFormData.value.totalPrice < 0) {
      errors.push('Tổng tiền phải lớn hơn hoặc bằng 0')
    }
  } else {
    if (!sellFormData.value.currencyId) {
      errors.push('Vui lòng chọn loại currency')
    }
    if (!sellFormData.value.quantity || sellFormData.value.quantity <= 0) {
      errors.push('Số lượng phải lớn hơn 0')
    }
    if (!sellFormData.value.currencyCode) {
      errors.push('Vui lòng chọn đơn vị tiền tệ')
    }
    if (sellFormData.value.totalPrice === null || sellFormData.value.totalPrice < 0) {
      errors.push('Tổng tiền phải lớn hơn hoặc bằng 0')
    }
  }

  return errors
}


// Expose methods for parent component
defineExpose({
  resetForm,
  validateForm,
  buyFormData,
  sellFormData,
  activeTab,
})
</script>

<style scoped>
.tab-active {
  background: linear-gradient(to bottom, transparent, rgba(34, 197, 94, 0.05));
}

.tab-inactive {
  position: relative;
}

.tab-inactive:hover {
  background: linear-gradient(to bottom, transparent, rgba(156, 163, 175, 0.05));
}

.tab-icon {
  transition: all 0.2s ease;
}

.tab-active .tab-icon {
  transform: scale(1.1);
}

/* Form field styling */
.space-y-6 > div {
  transition: all 0.2s ease;
}

.space-y-6 > div:hover {
  transform: translateX(2px);
}
</style>