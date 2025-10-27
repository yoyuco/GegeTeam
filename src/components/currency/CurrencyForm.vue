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

        <!-- Total Prices -->
        <div class="grid grid-cols-2 gap-4">
          <!-- Total Price USD -->
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
              <label class="text-sm font-medium text-gray-700">Tổng tiền (USD)</label>
              <span class="text-red-500">*</span>
            </div>
            <n-input-number
              v-model:value="buyFormData.totalPriceUsd"
              :min="0"
              :placeholder="isBuyVndFilled ? 'VND has value, USD will be cleared' : 'Nhập tổng tiền USD'"
              size="large"
              class="w-full"
              :class="{ 'border-yellow-400 bg-yellow-50': isBuyVndFilled }"
              @update:value="onBuyUsdChange"
            />
          </div>

          <!-- Total Price VND -->
          <div>
            <div class="flex items-center gap-2 mb-3">
              <div class="w-6 h-6 bg-green-100 rounded flex items-center justify-center">
                <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              </div>
              <label class="text-sm font-medium text-gray-700">Tổng tiền (VND)</label>
              <span class="text-red-500">*</span>
            </div>
            <n-input-number
              v-model:value="buyFormData.totalPriceVnd"
              :min="0"
              :placeholder="isBuyUsdFilled ? 'USD has value, VND will be cleared' : 'Nhập tổng tiền VND'"
              size="large"
              class="w-full"
              :class="{ 'border-yellow-400 bg-yellow-50': isBuyUsdFilled }"
              @update:value="onBuyVndChange"
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

        <!-- Total Prices -->
        <div class="grid grid-cols-2 gap-4">
          <!-- Total Price USD -->
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
              <label class="text-sm font-medium text-gray-700">Tổng tiền (USD)</label>
              <span class="text-red-500">*</span>
            </div>
            <n-input-number
              v-model:value="sellFormData.totalPriceUsd"
              :min="0"
              :placeholder="isSellVndFilled ? 'VND has value, USD will be cleared' : 'Nhập tổng tiền USD'"
              size="large"
              class="w-full"
              :class="{ 'border-yellow-400 bg-yellow-50': isSellVndFilled }"
              @update:value="onSellUsdChange"
            />
          </div>

          <!-- Total Price VND -->
          <div>
            <div class="flex items-center gap-2 mb-3">
              <div class="w-6 h-6 bg-green-100 rounded flex items-center justify-center">
                <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              </div>
              <label class="text-sm font-medium text-gray-700">Tổng tiền (VND)</label>
              <span class="text-red-500">*</span>
            </div>
            <n-input-number
              v-model:value="sellFormData.totalPriceVnd"
              :min="0"
              :placeholder="isSellUsdFilled ? 'USD has value, VND will be cleared' : 'Nhập tổng tiền VND'"
              size="large"
              class="w-full"
              :class="{ 'border-yellow-400 bg-yellow-50': isSellUsdFilled }"
              @update:value="onSellVndChange"
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
import { computed, watch, ref, nextTick } from 'vue'
import { NSelect, NInputNumber, NInput } from 'naive-ui'

// Props
interface Props {
  buyModelValue?: {
    currencyId: string | null
    quantity: number | null
    totalPriceVnd: number | null
    totalPriceUsd: number | null
    notes: string
  }
  sellModelValue?: {
    currencyId: string | null
    quantity: number | null
    totalPriceVnd: number | null
    totalPriceUsd: number | null
    notes: string
  }
  currencies: any[]
  loading?: boolean
  transactionType?: 'sale' | 'purchase'
  activeTab?: 'buy' | 'sell'
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  transactionType: 'sale',
  activeTab: 'sell'
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
    totalPriceVnd: null,
    totalPriceUsd: null,
    notes: ''
  },
  set: (value) => emit('update:buyModelValue', value),
})

const sellFormData = computed({
  get: () => props.sellModelValue || {
    currencyId: null,
    quantity: null,
    totalPriceVnd: null,
    totalPriceUsd: null,
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


// Computed properties for mutual exclusivity
const isBuyVndFilled = computed(() => {
  const vndValue = buyFormData.value.totalPriceVnd
  return vndValue != null && vndValue > 0 && isFinite(vndValue)
})

const isBuyUsdFilled = computed(() => {
  return buyFormData.value.totalPriceUsd != null && buyFormData.value.totalPriceUsd > 0
})

const isSellVndFilled = computed(() => {
  const vndValue = sellFormData.value.totalPriceVnd
  return vndValue != null && vndValue > 0 && isFinite(vndValue)
})

const isSellUsdFilled = computed(() => {
  const usdValue = sellFormData.value.totalPriceUsd
  return usdValue != null && usdValue > 0 && isFinite(usdValue)
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
  () => buyFormData.value.totalPriceVnd,
  (newPriceVnd: number | null) => {
    emit('price-changed', {
      vnd: newPriceVnd || undefined,
      usd: buyFormData.value.totalPriceUsd || undefined
    })
  }
)

watch(
  () => buyFormData.value.totalPriceUsd,
  (newPriceUsd: number | null) => {
    emit('price-changed', {
      vnd: buyFormData.value.totalPriceVnd || undefined,
      usd: newPriceUsd || undefined
    })
  }
)

// Watch for individual buy form changes and emit update:buyModelValue
watch(
  () => buyFormData.value.currencyId,
  (newCurrencyId) => {
    emit('update:buyModelValue', { ...buyFormData.value, currencyId: newCurrencyId })
  }
)

watch(
  () => buyFormData.value.quantity,
  (newQuantity) => {
    emit('update:buyModelValue', { ...buyFormData.value, quantity: newQuantity })
  }
)

watch(
  () => buyFormData.value.totalPriceVnd,
  (newPriceVnd) => {
    emit('update:buyModelValue', { ...buyFormData.value, totalPriceVnd: newPriceVnd })
  }
)

watch(
  () => buyFormData.value.totalPriceUsd,
  (newPriceUsd) => {
    emit('update:buyModelValue', { ...buyFormData.value, totalPriceUsd: newPriceUsd })
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

// Watch for sell form changes and emit events (simple like buy tab)
watch(
  () => sellFormData.value.totalPriceVnd,
  (newPriceVnd: number | null) => {
    emit('price-changed', {
      vnd: newPriceVnd || undefined,
      usd: sellFormData.value.totalPriceUsd || undefined
    })
  }
)

watch(
  () => sellFormData.value.totalPriceUsd,
  (newPriceUsd: number | null) => {
    emit('price-changed', {
      vnd: sellFormData.value.totalPriceVnd || undefined,
      usd: newPriceUsd || undefined
    })
  }
)


// Methods for parent component
const resetForm = () => {
  if (props.transactionType === 'purchase') {
    emit('update:buyModelValue', {
      currencyId: null,
      quantity: null,
      totalPriceVnd: null,
      totalPriceUsd: null,
      notes: '',
    })
  } else {
    emit('update:sellModelValue', {
      currencyId: null,
      quantity: null,
      totalPriceVnd: null,
      totalPriceUsd: null,
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
    const hasVndPrice = buyFormData.value.totalPriceVnd && buyFormData.value.totalPriceVnd > 0
    const hasUsdPrice = buyFormData.value.totalPriceUsd && buyFormData.value.totalPriceUsd > 0
    if (!hasVndPrice && !hasUsdPrice) {
      errors.push('Tổng giá phải lớn hơn 0 (VND hoặc USD)')
    }
  } else {
    if (!sellFormData.value.currencyId) {
      errors.push('Vui lòng chọn loại currency')
    }
    if (!sellFormData.value.quantity || sellFormData.value.quantity <= 0) {
      errors.push('Số lượng phải lớn hơn 0')
    }
    const hasSellVndPrice = sellFormData.value.totalPriceVnd && sellFormData.value.totalPriceVnd > 0
    const hasSellUsdPrice = sellFormData.value.totalPriceUsd && sellFormData.value.totalPriceUsd > 0
    if (!hasSellVndPrice && !hasSellUsdPrice) {
      errors.push('Tổng giá phải lớn hơn 0 (VND hoặc USD)')
    }
  }

  return errors
}

// Methods for mutual exclusivity
const onBuyUsdChange = (value: number | null) => {
  if (value && value > 0) {
    // Clear VND field when USD is entered
    buyFormData.value.totalPriceVnd = null
  }
  // Emit price change immediately to ensure parent gets the latest values
  nextTick(() => {
    emit('price-changed', {
      vnd: buyFormData.value.totalPriceVnd || undefined,
      usd: value || undefined
    })
  })
}

const onBuyVndChange = (value: number | null) => {
  if (value && value > 0) {
    // Clear USD field when VND is entered
    buyFormData.value.totalPriceUsd = null
  }
  // Emit price change immediately to ensure parent gets the latest values
  nextTick(() => {
    emit('price-changed', {
      vnd: value || undefined,
      usd: buyFormData.value.totalPriceUsd || undefined
    })
  })
}

const onSellUsdChange = (value: number | null) => {
  if (value && value > 0) {
    // Clear VND field when USD is entered
    sellFormData.value.totalPriceVnd = null
  }
}

const onSellVndChange = (value: number | null) => {
  if (value && value > 0) {
    // Clear USD field when VND is entered
    sellFormData.value.totalPriceUsd = null
  }
}

// Focus handlers removed - mutual exclusivity is handled by change handlers only

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