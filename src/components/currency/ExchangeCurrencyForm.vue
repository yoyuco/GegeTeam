<!-- path: src/components/currency/ExchangeCurrencyForm.vue -->
<template>
  <div class="exchange-currency-form">
    <!-- Currency Exchange Section - 2 Column Layout -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
      <div class="p-6">

        <!-- Currency Tables Side by Side -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Currency A Table -->
          <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div class="flex items-center gap-2 mb-4">
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
              <h3 class="text-lg font-semibold text-blue-800">Currency Nguồn</h3>
            </div>

            <!-- Loại Currency -->
            <div class="mb-4">
              <div class="flex items-center gap-2 mb-3">
                <div class="w-5 h-5 bg-blue-100 rounded flex items-center justify-center">
                  <svg class="w-2.5 h-2.5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
                v-model:value="sourceCurrencyId"
                :options="currencies"
                placeholder="Chọn loại currency"
                filterable
                :loading="loading"
                size="large"
                class="w-full"
                @update:value="onSourceCurrencyChange"
              />
            </div>

            <!-- Số lượng -->
            <div>
              <div class="flex items-center gap-2 mb-3">
                <div class="w-5 h-5 bg-green-100 rounded flex items-center justify-center">
                  <svg class="w-2.5 h-2.5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
                v-model:value="sourceAmount"
                placeholder="Nhập số lượng"
                :min="0"
                :precision="0"
                size="large"
                class="w-full"
              />
            </div>
          </div>

          <!-- Currency B Table -->
          <div class="bg-green-50 border border-green-200 rounded-lg p-4">
            <div class="flex items-center gap-2 mb-4">
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
              <h3 class="text-lg font-semibold text-green-800">Currency Đích</h3>
            </div>

            <!-- Loại Currency -->
            <div class="mb-4">
              <div class="flex items-center gap-2 mb-3">
                <div class="w-5 h-5 bg-green-100 rounded flex items-center justify-center">
                  <svg class="w-2.5 h-2.5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
                v-model:value="destCurrencyId"
                :options="destCurrencyOptions"
                placeholder="Chọn loại currency"
                filterable
                :loading="loading"
                size="large"
                class="w-full"
                @update:value="onDestCurrencyChange"
              />
            </div>

            <!-- Số lượng -->
            <div>
              <div class="flex items-center gap-2 mb-3">
                <div class="w-5 h-5 bg-yellow-100 rounded flex items-center justify-center">
                  <svg class="w-2.5 h-2.5 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
                v-model:value="destAmount"
                placeholder="Nhập số lượng"
                :min="0"
                :precision="0"
                size="large"
                class="w-full"
              />
            </div>
          </div>
        </div>

        <!-- Account Selection and Exchange Rate in Same Row -->
        <div class="mt-6 grid grid-cols-1 lg:grid-cols-2 gap-4">
          <!-- Account Selection -->
          <div class="bg-purple-25 border border-purple-200 rounded-lg p-4" style="background-color: rgba(147, 51, 234, 0.05);">
            <div class="flex items-center gap-2 mb-3">
              <div class="w-5 h-5 bg-purple-100 rounded flex items-center justify-center">
                <svg class="w-2.5 h-2.5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                  />
                </svg>
              </div>
              <label class="text-sm font-medium text-gray-700">Kho (Account)</label>
              <span class="text-red-500">*</span>
            </div>
            <n-select
              v-model:value="sourceAccountId"
              :options="accountOptions"
              placeholder="Chọn kho để thực hiện đổi currency"
              filterable
              :loading="loadingAccounts"
              size="large"
              class="w-full"
            />
          </div>

          <!-- Exchange Rate Info -->
          <div class="bg-gray-50 border border-gray-200 rounded-lg p-4">
            <div class="flex flex-col space-y-2">
              <span class="text-sm text-gray-700 font-medium">Tỷ lệ đổi:</span>
              <span class="text-sm font-bold text-gray-800">
                {{ sourceAmount || '0' }} {{ sourceCurrencyName }} = {{ exchangeRate }} {{ destCurrencyName }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Notes and Proof Upload Section - 2 Columns -->
    <div class="mt-6">
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Notes Section -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center gap-2 mb-3">
            <div class="w-5 h-5 bg-gray-100 rounded flex items-center justify-center">
              <svg class="w-2.5 h-2.5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Ghi chú</label>
          </div>
          <n-input
            v-model:value="notes"
            type="textarea"
            placeholder="Nhập ghi chú cho giao dịch (nếu có)"
            :rows="4"
            class="w-full"
          />
        </div>

        <!-- Proof Upload Section -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="flex items-center gap-2 mb-4">
            <div class="w-5 h-5 bg-purple-100 rounded flex items-center justify-center">
              <svg class="w-2.5 h-2.5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Tải lên bằng chứng giao dịch</label>
          </div>
          <SimpleProofUpload
            v-model:files="proofFiles"
            :max-files="5"
          />
        </div>
      </div>
    </div>

    <!-- Action Buttons -->
    <div class="mt-6 flex items-center gap-3 justify-end">
      <n-button size="large" @click="onReset">
        <template #icon>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
            />
          </svg>
        </template>
        Làm lại
      </n-button>

      <n-button
        type="primary"
        size="large"
        :loading="submitting"
        :disabled="!isFormValid"
        @click="onSubmit"
      >
        <template #icon>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 7l5 5m0 0l-5 5m5-5H6"
            />
          </svg>
        </template>
        Đổi currency
      </n-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { NInput, NSelect, NInputNumber, NButton } from 'naive-ui'
import SimpleProofUpload from '@/components/SimpleProofUpload.vue'

// Props - Match CurrencyForm pattern
interface Props {
  currencies?: Array<{ label: string; value: string }>
  accountOptions?: Array<{ label: string; value: string }>
  loading?: boolean
  loadingAccounts?: boolean
  submitting?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  currencies: () => [],
  accountOptions: () => [],
  loading: false,
  loadingAccounts: false,
  submitting: false
})

// Emits
interface Emits {
  (e: 'submit', data: ExchangeData): void
  (e: 'reset'): void
}

const emit = defineEmits<Emits>()

// Data interfaces
interface ExchangeData {
  sourceCurrency: {
    id: string
    name: string
    amount: number
    accountId: string
  }
  destCurrency: {
    id: string
    name: string
    amount: number
    accountId: string
  }
  notes: string
  proofFiles: Array<any>
}

// Form data
const sourceCurrencyId = ref('')
const sourceAccountId = ref('')
const destCurrencyId = ref('')
const sourceAmount = ref<number | null>(null)
const destAmount = ref<number | null>(null)
const notes = ref('')
const proofFiles = ref<Array<any>>([])

// Computed properties
const sourceCurrencyName = computed(() => {
  const currency = props.currencies.find(c => c.value === sourceCurrencyId.value)
  return currency ? currency.label : ''
})

const destCurrencyName = computed(() => {
  const currency = props.currencies.find(c => c.value === destCurrencyId.value)
  return currency ? currency.label : ''
})

// Filter destination currency options to exclude selected source currency
const destCurrencyOptions = computed(() => {
  if (!sourceCurrencyId.value) {
    return props.currencies
  }
  return props.currencies.filter(c => c.value !== sourceCurrencyId.value)
})

const exchangeRate = computed(() => {
  // Check if destination amount is valid number (>= 0)
  const destValid = destAmount.value !== null && destAmount.value !== undefined && destAmount.value >= 0

  if (destValid) {
    return destAmount.value!.toString()
  }
  return '0'
})

const isFormValid = computed(() => {
  return (
    sourceCurrencyId.value &&
    sourceAccountId.value &&
    destCurrencyId.value &&
    sourceAmount.value && sourceAmount.value > 0 &&
    destAmount.value && destAmount.value > 0
  )
})

// Event handlers
const onSourceCurrencyChange = () => {
  // Currency change handler - no auto-calculation needed
}

const onDestCurrencyChange = () => {
  // Currency change handler - no auto-calculation needed
}

const onSubmit = () => {
  if (!isFormValid.value) return

  const data: ExchangeData = {
    sourceCurrency: {
      id: sourceCurrencyId.value,
      name: sourceCurrencyName.value,
      amount: sourceAmount.value!,
      accountId: sourceAccountId.value
    },
    destCurrency: {
      id: destCurrencyId.value,
      name: destCurrencyName.value,
      amount: destAmount.value!,
      accountId: sourceAccountId.value // Same account for both currencies
    },
    notes: notes.value,
    proofFiles: proofFiles.value
  }

  emit('submit', data)
}

const onReset = () => {
  sourceCurrencyId.value = ''
  sourceAccountId.value = ''
  destCurrencyId.value = ''
  sourceAmount.value = null
  destAmount.value = null
  notes.value = ''
  proofFiles.value = []

  // Auto-select currencies after reset if options are available
  if (props.currencies.length > 0) {
    // Auto-select first currency for source
    sourceCurrencyId.value = props.currencies[0].value

    // Auto-select first available destination currency (different from source)
    const availableDestOptions = props.currencies.filter(c => c.value !== props.currencies[0].value)
    if (availableDestOptions.length > 0) {
      destCurrencyId.value = availableDestOptions[0].value
    }
  }

  emit('reset')
}

// Watch for currency changes to update exchange rates
watch([sourceCurrencyId, destCurrencyId], () => {
  // Exchange rate is now manually calculated - no auto-update needed
})

// Watch for source currency changes to handle destination currency conflicts
watch(sourceCurrencyId, (newSourceId) => {
  if (newSourceId && destCurrencyId.value === newSourceId) {
    // Destination currency is the same as source, need to change it
    const availableDestOptions = props.currencies.filter(c => c.value !== newSourceId)
    if (availableDestOptions.length > 0) {
      // Auto-select first available destination currency
      destCurrencyId.value = availableDestOptions[0].value
    }
  }
})

// Watch for destination currency to ensure it's always valid
watch(destCurrencyId, (newDestId) => {
  if (newDestId && sourceCurrencyId.value === newDestId) {
    // Destination currency is the same as source, need to change it
    const availableDestOptions = props.currencies.filter(c => c.value !== sourceCurrencyId.value)
    if (availableDestOptions.length > 0) {
      // Auto-select first available destination currency
      destCurrencyId.value = availableDestOptions[0].value
    }
  }
})

// Watch for component key changes (game changes) to reset form
watch(() => props.currencies, (newCurrencies, oldCurrencies) => {
  // Reset form when currencies change (game change detected)
  if (newCurrencies && oldCurrencies &&
      (newCurrencies.length !== oldCurrencies.length ||
       newCurrencies[0]?.value !== oldCurrencies[0]?.value)) {
    // Reset all selections except account
    sourceCurrencyId.value = ''
    destCurrencyId.value = ''
    sourceAmount.value = null
    destAmount.value = null
    notes.value = ''
    proofFiles.value = []
  }

  // Auto-select when we have currencies and no source selected
  if (newCurrencies && newCurrencies.length > 0 && !sourceCurrencyId.value) {
    // Auto-select first currency for source if not already selected
    sourceCurrencyId.value = newCurrencies[0].value

    // Auto-select first available destination currency (different from source)
    const availableDestOptions = newCurrencies.filter(c => c.value !== newCurrencies[0].value)
    if (availableDestOptions.length > 0) {
      destCurrencyId.value = availableDestOptions[0].value
    }
  }
}, { immediate: true })


</script>

<style scoped>
.exchange-currency-form {
  animation: fadeInUp 0.3s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Custom styling for currency columns */
.exchange-currency-form .bg-blue-50 {
  background: linear-gradient(135deg, #f8fafc 0%, #e0f2fe 50%);
}

.exchange-currency-form .bg-green-50 {
  background: linear-gradient(135deg, #f8fafc 0%, #dcfce7 50%);
}

/* Form field styling */
.exchange-currency-form .n-input,
.exchange-currency-form .n-select,
.exchange-currency-form .n-input-number {
  transition: all 0.2s ease;
}

.exchange-currency-form .n-input:hover .n-input__input-el,
.exchange-currency-form .n-select:hover .n-base-selection,
.exchange-currency-form .n-input-number:hover .n-input__input-el {
  border-color: #10b981;
}

.exchange-currency-form .n-input:focus-within .n-input__input-el,
.exchange-currency-form .n-select:focus-within .n-base-selection,
.exchange-currency-form .n-input-number:focus-within .n-input__input-el {
  border-color: #059669;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

/* Button styling */
.exchange-currency-form .n-button--primary-type {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border: none;
  transition: all 0.2s ease;
}

.exchange-currency-form .n-button--primary-type:hover {
  background: linear-gradient(135deg, #059669 0%, #047857 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}


/* Responsive design */
@media (max-width: 1024px) {
  .exchange-currency-form .grid-cols-2 {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }

  .exchange-currency-form .lg\:mt-20 {
    margin-top: 2rem;
  }
}
</style>