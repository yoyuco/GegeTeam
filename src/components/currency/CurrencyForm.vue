<!-- path: src/components/currency/CurrencyForm.vue -->
<!-- Dynamic Currency Form Component with Buy/Sell Tabs -->
<template>
  <div class="bg-white rounded-xl shadow-sm border border-gray-200">
    <!-- Tab Headers -->
    <div class="flex border-b border-gray-200">
      <button
        :class="[
          'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
          activeTab === 'buy'
            ? 'tab-active text-green-600 border-b-2 border-green-600'
            : 'tab-inactive text-gray-500 hover:text-gray-700',
        ]"
        @click="activeTab = 'buy'"
      >
        <svg class="w-4 h-4 tab-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.446 1.707H17a2 2 0 002-2v-2a2 2 0 00-2-2H7a2 2 0 00-2 2v2a2 2 0 002 2z"
          />
        </svg>
        Mua vào
      </button>
      <button
        :class="[
          'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
          activeTab === 'sell'
            ? 'tab-active text-blue-600 border-b-2 border-blue-600'
            : 'tab-inactive text-gray-500 hover:text-gray-700',
        ]"
        @click="activeTab = 'sell'"
      >
        <svg class="w-4 h-4 tab-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.446 1.707H17a2 2 0 002-2v-2a2 2 0 00-2-2H7a2 2 0 00-2 2v2a2 2 0 002 2z"
          />
        </svg>
        Bán ra
      </button>
    </div>

    <!-- Tab Content -->
    <div class="p-6">
      <!-- Buy Tab -->
      <div v-if="activeTab === 'buy'" class="space-y-6">
        <div class="flex items-center gap-2 mb-4">
          <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
            <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-gray-800">Thông tin mua vào</h3>
        </div>

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
            placeholder="Chọn loại currency"
            filterable
            :loading="loading"
            size="large"
            class="w-full"
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

        <!-- Total Price VND -->
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
            <label class="text-sm font-medium text-gray-700">Tổng giá (VND)</label>
            <span class="text-red-500">*</span>
          </div>
          <n-input-number
            v-model:value="buyFormData.totalPriceVnd"
            :min="0"
            placeholder="Nhập tổng giá mua vào"
            size="large"
            class="w-full"
          />
        </div>

        <!-- Unit Price (calculated) -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-purple-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Đơn giá (VND)</label>
            <span class="text-gray-400 text-xs">(Tự động tính)</span>
          </div>
          <n-input-number
            :value="calculatedBuyUnitPrice"
            :disabled="true"
            placeholder="Đơn giá sẽ được tính tự động"
            size="large"
            class="w-full"
          />
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
            type="textarea"
            :rows="3"
            size="large"
            class="w-full"
          />
        </div>
      </div>

      <!-- Sell Tab -->
      <div v-if="activeTab === 'sell'" class="space-y-6">
        <div class="flex items-center gap-2 mb-4">
          <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-gray-800">Thông tin bán ra</h3>
        </div>

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
            placeholder="Chọn loại currency"
            filterable
            :loading="loading"
            size="large"
            class="w-full"
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

        <!-- Unit Price VND -->
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
            <label class="text-sm font-medium text-gray-700">Đơn giá (VND)</label>
            <span class="text-red-500">*</span>
          </div>
          <n-input-number
            v-model:value="sellFormData.unitPriceVnd"
            :min="0"
            placeholder="Nhập đơn giá bán ra"
            size="large"
            class="w-full"
          />
        </div>

        <!-- Total Price (calculated) -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-purple-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Tổng giá</label>
            <span class="text-gray-400 text-xs">(Tự động tính)</span>
          </div>
          <n-input-number
            :value="calculatedSellTotalPrice"
            :disabled="true"
            placeholder="Tổng giá sẽ được tính tự động"
            size="large"
            class="w-full"
          />
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
            type="textarea"
            :rows="3"
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

// Props
interface Props {
  buyModelValue: {
    currencyId: string | null
    quantity: number | null
    totalPriceVnd: number | null
    notes: string
  }
  sellModelValue: {
    currencyId: string | null
    quantity: number | null
    unitPriceVnd: number | null
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
  get: () => props.buyModelValue,
  set: (value) => emit('update:buyModelValue', value),
})

const sellFormData = computed({
  get: () => props.sellModelValue,
  set: (value) => emit('update:sellModelValue', value),
})

// Computed properties
const loading = computed(() => props.loading)

const currencyOptions = computed(() => {
  // Currencies are already filtered and formatted in calling component
  return props.currencies
})

const calculatedBuyUnitPrice = computed(() => {
  if (buyFormData.value.quantity && buyFormData.value.totalPriceVnd) {
    return Math.round(buyFormData.value.totalPriceVnd / buyFormData.value.quantity)
  }
  return 0
})

const calculatedSellTotalPrice = computed(() => {
  if (sellFormData.value.quantity && sellFormData.value.unitPriceVnd) {
    return sellFormData.value.quantity * sellFormData.value.unitPriceVnd
  }
  return 0
})

// Watch for tab changes
watch(activeTab, (newTab) => {
  emit('update:activeTab', newTab)
})

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
  (newPrice: number | null) => {
    emit('price-changed', { vnd: newPrice || undefined })
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

watch(
  () => sellFormData.value.unitPriceVnd,
  (newPrice: number | null) => {
    emit('price-changed', { vnd: newPrice || undefined })
  }
)

// Methods for parent component
const resetForm = () => {
  if (activeTab.value === 'buy') {
    emit('update:buyModelValue', {
      currencyId: null,
      quantity: null,
      totalPriceVnd: null,
      notes: '',
    })
  } else {
    emit('update:sellModelValue', {
      currencyId: null,
      quantity: null,
      unitPriceVnd: null,
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
    if (!buyFormData.value.totalPriceVnd || buyFormData.value.totalPriceVnd <= 0) {
      errors.push('Tổng giá phải lớn hơn 0')
    }
  } else {
    if (!sellFormData.value.currencyId) {
      errors.push('Vui lòng chọn loại currency')
    }
    if (!sellFormData.value.quantity || sellFormData.value.quantity <= 0) {
      errors.push('Số lượng phải lớn hơn 0')
    }
    if (!sellFormData.value.unitPriceVnd || sellFormData.value.unitPriceVnd <= 0) {
      errors.push('Đơn giá phải lớn hơn 0')
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