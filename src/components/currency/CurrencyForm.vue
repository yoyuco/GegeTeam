<!-- path: src/components/currency/CurrencyForm.vue -->
<!-- Dynamic Currency Form Component -->
<template>
  <div class="bg-gradient-to-br from-gray-50 to-white rounded-xl p-6">
    <!-- Currency Selection -->
    <div class="mb-6">
      <div class="flex items-center gap-2 mb-3">
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
        <label class="text-sm font-semibold text-gray-700">Loại Currency</label>
        <span class="text-red-500">*</span>
      </div>
      <n-select
        v-model:value="formData.currencyId"
        :options="currencyOptions"
        placeholder="Chọn loại currency"
        filterable
        :loading="loading"
        size="large"
        class="w-full"
      />
    </div>

    <!-- Quantity and Price Section -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
      <!-- Quantity Input -->
      <div>
        <div class="flex items-center gap-2 mb-3">
          <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
            <svg
              class="w-4 h-4 text-green-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14"
              />
            </svg>
          </div>
          <label class="text-sm font-semibold text-gray-700">Số lượng</label>
          <span class="text-red-500">*</span>
        </div>
        <n-input-number
          v-model:value="formData.quantity"
          :min="0"
          :precision="currency?.type?.includes('GOLD') ? 0 : 2"
          placeholder="Nhập số lượng"
          size="large"
          class="w-full"
        />
      </div>

      <!-- Price USD -->
      <div>
        <div class="flex items-center gap-2 mb-3">
          <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center">
            <svg
              class="w-4 h-4 text-purple-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
          <label class="text-sm font-semibold text-gray-700">Giá (USD)</label>
        </div>
        <n-input-number
          v-model:value="formData.unitPriceUsd"
          :min="0"
          :precision="2"
          placeholder="Giá USD"
          size="large"
          class="w-full"
        />
      </div>

      <!-- Price VND -->
      <div>
        <div class="flex items-center gap-2 mb-3">
          <div class="w-8 h-8 bg-yellow-100 rounded-lg flex items-center justify-center">
            <svg
              class="w-4 h-4 text-yellow-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
          <label class="text-sm font-semibold text-gray-700">Giá (VND)</label>
        </div>
        <n-input-number
          v-model:value="formData.unitPriceVnd"
          :min="0"
          :precision="0"
          placeholder="Giá VND"
          size="large"
          class="w-full"
        />
      </div>
    </div>

    <!-- Account Selection -->
    <div class="mb-6">
      <div class="flex items-center gap-2 mb-3">
        <div class="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center">
          <svg
            class="w-4 h-4 text-orange-600"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
            />
          </svg>
        </div>
        <label class="text-sm font-semibold text-gray-700">Kho (Account Name)</label>
        <span class="text-red-500">*</span>
      </div>
      <n-select
        v-model:value="formData.gameAccountId"
        :options="accountOptions"
        placeholder="Chọn tài khoản game"
        :loading="accountsLoading"
        size="large"
        class="w-full"
      />
    </div>

    <!-- Notes Section -->
    <div class="mb-6">
      <div class="flex items-center gap-2 mb-3">
        <div class="w-8 h-8 bg-gray-100 rounded-lg flex items-center justify-center">
          <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
            />
          </svg>
        </div>
        <label class="text-sm font-semibold text-gray-700">Ghi chú</label>
      </div>
      <n-input v-model:value="formData.notes" placeholder="Ghi chú thêm..." size="large" />
    </div>

    <!-- Summary Section -->
    <div
      v-if="formData.quantity && (formData.unitPriceVnd || formData.unitPriceUsd)"
      class="bg-blue-50 border border-blue-200 rounded-lg p-4"
    >
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="text-sm">
          <span class="text-gray-600">Tổng giá trị VND:</span>
          <span class="font-semibold text-blue-700 ml-2">
            {{ formatCurrency(totalValueVND) }} ₫
          </span>
        </div>
        <div class="text-sm">
          <span class="text-gray-600">Tổng giá trị USD:</span>
          <span class="font-semibold text-blue-700 ml-2">
            ${{ formatCurrency(totalValueUSD) }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { NSelect, NInputNumber, NInput, useMessage } from 'naive-ui'
import type { Currency, GameAccount } from '@/types/composables'

// Props
interface Props {
  transactionType?: 'purchase' | 'sale' | 'exchange'
  initialData?: Record<string, unknown>
  submitText?: string
  leagueId?: string | null
  gameCode?: string | null
  currencies?: { label: string; value: string; data: Currency }[]
  gameAccounts?: GameAccount[]
  loading?: boolean
  accountsLoading?: boolean
  loadAccounts?: () => Promise<void>
}

const props = withDefaults(defineProps<Props>(), {
  transactionType: 'purchase',
  initialData: () => ({}),
  submitText: 'Giao dịch',
  gameCode: null,
  leagueId: null,
  currencies: () => [],
  gameAccounts: () => [],
  loading: false,
  accountsLoading: false,
  loadAccounts: undefined,
})

// Emits
const emit = defineEmits<{
  submit: [data: Record<string, unknown>]
  cancel: []
  'currency-changed': [currencyId: string]
  'price-changed': [price: { vnd?: number; usd?: number }]
  'quantity-changed': [quantity: number]
}>()

// Composables
const message = useMessage()

// Use props instead of composables to ensure reactivity
const currencies = computed(() => props.currencies)
const gameAccounts = computed(() => props.gameAccounts)
const loading = computed(() => props.loading)
const accountsLoading = computed(() => props.accountsLoading)

// Local state
const submitting = ref(false)
const formData = ref({
  currencyId: null as string | null,
  quantity: null as number | null,
  unitPriceVnd: null as number | null,
  unitPriceUsd: null as number | null,
  gameAccountId: null as string | null,
  notes: '',
})

// Computed
const currency = computed((): Currency | null => {
  if (!currencies.value || currencies.value.length === 0) {
    return null
  }
  // Find currency in the options array (which has { label, value, data } structure)
  const currencyOption = currencies.value.find((c) => c.value === formData.value.currencyId)
  return currencyOption?.data || null
})

const currencyOptions = computed(() => {
  // Currencies are already filtered and formatted in calling component
  return currencies.value
})

const accountOptions = computed(() => {
  return gameAccounts.value
    .filter((account: GameAccount) => account.is_active)
    .map((account: GameAccount) => ({
      label: `${account.name} - ${account.description || 'No description'}`,
      value: account.id,
    }))
})

// Summary computed properties
const totalValueVND = computed(() => {
  return (formData.value.quantity || 0) * (formData.value.unitPriceVnd || 0)
})

const totalValueUSD = computed(() => {
  return (formData.value.quantity || 0) * (formData.value.unitPriceUsd || 0)
})

// Utility function for currency formatting
const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('vi-VN').format(Math.round(amount))
}

// Methods
const resetForm = () => {
  formData.value = {
    currencyId: null,
    quantity: null,
    unitPriceVnd: null,
    unitPriceUsd: null,
    gameAccountId: null,
    notes: '',
  }
}

const validateForm = () => {
  const errors = []

  if (!formData.value.currencyId) {
    errors.push('Chọn loại currency')
  }

  if (!formData.value.quantity || formData.value.quantity <= 0) {
    errors.push('Nhập số lượng hợp lệ')
  }

  if (!formData.value.gameAccountId) {
    errors.push('Chọn tài khoản game')
  }

  if (
    props.transactionType === 'purchase' &&
    !formData.value.unitPriceVnd &&
    !formData.value.unitPriceUsd
  ) {
    errors.push('Nhập giá mua')
  }

  return errors
}

const handleSubmit = async () => {
  const errors = validateForm()
  if (errors.length > 0) {
    message.error(errors.join(', '))
    return
  }

  submitting.value = true

  try {
    const submitData = {
      ...formData.value,
      gameCode: props.gameCode,
      leagueId: props.leagueId,
      transactionType: props.transactionType,
    }

    emit('submit', submitData)
    resetForm()
  } catch {
    message.error('Lỗi khi xử lý giao dịch')
  } finally {
    submitting.value = false
  }
}

// Lifecycle
onMounted(async () => {
  if (props.gameCode && props.leagueId && props.loadAccounts) {
    await props.loadAccounts()
  }
})

// Watch for form changes to emit events
watch(
  () => formData.value.currencyId,
  (newCurrencyId) => {
    if (newCurrencyId) {
      emit('currency-changed', newCurrencyId)
    }
  }
)

watch(
  () => formData.value.quantity,
  (newQuantity) => {
    if (newQuantity !== null) {
      emit('quantity-changed', newQuantity)
    }
  }
)

watch([() => formData.value.unitPriceVnd, () => formData.value.unitPriceUsd], ([vnd, usd]) => {
  emit('price-changed', { vnd: vnd || undefined, usd: usd || undefined })
})

// Watch for props changes
watch([() => props.gameCode, () => props.leagueId], async () => {
  if (props.gameCode && props.leagueId && props.loadAccounts) {
    await props.loadAccounts()
  }
})

// Expose methods for parent component
defineExpose({
  resetForm,
  validateForm,
  handleSubmit,
  formData,
})
</script>
