<!-- path: src/components/currency/ProfitCalculator.vue -->
<!-- Profit Calculator Component -->
<template>
  <div class="bg-white p-4 rounded-lg shadow-sm">
    <h3 class="text-lg font-semibold mb-4">Tính toán lợi nhuận</h3>

    <div class="grid grid-cols-2 gap-6">
      <!-- Purchase Information -->
      <div class="space-y-3">
        <h4 class="font-medium text-gray-700">Thông tin mua vào</h4>

        <div>
          <label class="text-sm text-gray-600">Giá mua (VND)</label>
          <n-input-number
            v-model:value="purchaseData.priceVnd"
            :min="0"
            :precision="0"
            placeholder="Giá mua"
            style="width: 100%"
            @update:value="calculateProfit"
          />
        </div>

        <div>
          <label class="text-sm text-gray-600">Số lượng</label>
          <n-input-number
            v-model:value="purchaseData.quantity"
            :min="0"
            placeholder="Số lượng"
            style="width: 100%"
            @update:value="calculateProfit"
          />
        </div>

        <div class="pt-2 border-t">
          <div class="flex justify-between text-sm">
            <span>Tổng tiền mua:</span>
            <span class="font-medium">{{ formatCurrency(purchaseTotal) }} VND</span>
          </div>
        </div>
      </div>

      <!-- Sale Information -->
      <div class="space-y-3">
        <h4 class="font-medium text-gray-700">Thông tin bán ra</h4>

        <div>
          <label class="text-sm text-gray-600">Giá bán (USD)</label>
          <n-input-number
            v-model:value="saleData.priceUsd"
            :min="0"
            :precision="2"
            placeholder="Giá bán"
            style="width: 100%"
            @update:value="calculateProfit"
          />
        </div>

        <div>
          <label class="text-sm text-gray-600">Tỷ giá (USD→VND)</label>
          <n-input-number
            v-model:value="saleData.exchangeRate"
            :min="0"
            :precision="0"
            placeholder="Tỷ giá"
            style="width: 100%"
            @update:value="calculateProfit"
          />
        </div>

        <div class="pt-2 border-t">
          <div class="flex justify-between text-sm">
            <span>Tổng tiền bán:</span>
            <span class="font-medium">{{ formatCurrency(saleTotalVnd) }} VND</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Fee Chain -->
    <div class="mt-6 pt-4 border-t">
      <div class="flex items-center justify-between mb-3">
        <h4 class="font-medium text-gray-700">Chuỗi phí</h4>
        <n-select
          v-model:value="selectedChannelId"
          :options="channelOptions"
          placeholder="Chọn kênh bán"
          style="width: 250px"
          @update:value="calculateProfit"
        />
      </div>

      <div v-if="feeBreakdown.length > 0" class="space-y-2">
        <div
          v-for="fee in feeBreakdown"
          :key="fee.step_number"
          class="flex justify-between text-sm bg-gray-50 p-2 rounded"
        >
          <span>{{ fee.description }}</span>
          <span class="font-medium"
            >{{ formatCurrency(fee.fee_amount) }} {{ fee.fee_currency }}</span
          >
        </div>
      </div>
    </div>

    <!-- Profit Summary -->
    <div class="mt-6 pt-4 border-t">
      <div class="space-y-2">
        <div class="flex justify-between">
          <span class="font-medium">Tổng phí:</span>
          <span class="font-medium text-red-600">{{ formatCurrency(totalFees) }} VND</span>
        </div>

        <div class="flex justify-between text-lg font-bold">
          <span>Lợi nhuận ròng:</span>
          <span :class="profitClass">
            {{ formatCurrency(netProfit) }} VND ({{ profitMargin }}%)
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { NInputNumber, NSelect, useMessage } from 'naive-ui'
import { useCurrency } from '@/composables/useCurrency.js'
import type { Channel, FeeStep } from '@/types/composables'

// Props
interface Props {
  channelId?: string | null
  currencyId?: string | null
  quantity?: number | null
  sellPriceUsd?: number | null
  purchasePriceVnd?: number | null
}

const props = withDefaults(defineProps<Props>(), {
  channelId: null,
  currencyId: null,
  quantity: null,
  sellPriceUsd: null,
  purchasePriceVnd: null,
})

// Emits
const emit = defineEmits<{
  'profit-calculated': [profit: number, margin: number]
}>()

// Composables
const message = useMessage()
const { channels, getChannelsWithFeeChains } = useCurrency()

// Local state
const purchaseData = ref({
  priceVnd: props.purchasePriceVnd,
  quantity: props.quantity,
})

const saleData = ref({
  priceUsd: props.sellPriceUsd,
  exchangeRate: 25700, // Default rate
})

const selectedChannelId = ref(props.channelId)
const feeBreakdown = ref<FeeStep[]>([])

// Computed
const purchaseTotal = computed(() => {
  return (purchaseData.value.priceVnd || 0) * (purchaseData.value.quantity || 0)
})

const saleTotalVnd = computed(() => {
  return (
    (saleData.value.priceUsd || 0) *
    (purchaseData.value.quantity || 0) *
    (saleData.value.exchangeRate || 1)
  )
})

const totalFees = computed(() => {
  return feeBreakdown.value.reduce((total, fee) => {
    // Convert to VND for consistency
    if (fee.fee_currency === 'USD') {
      return total + fee.fee_amount * (saleData.value.exchangeRate || 1)
    }
    return total + fee.fee_amount
  }, 0)
})

const netProfit = computed(() => {
  return saleTotalVnd.value - purchaseTotal.value - totalFees.value
})

const profitMargin = computed(() => {
  if (saleTotalVnd.value === 0) return 0
  return Math.round((netProfit.value / saleTotalVnd.value) * 100)
})

const profitClass = computed(() => {
  if (netProfit.value > 0) return 'text-green-600'
  if (netProfit.value < 0) return 'text-red-600'
  return 'text-gray-600'
})

const channelOptions = computed(() => {
  return getChannelsWithFeeChains.value.map((channel: Channel) => ({
    label: `${channel.name} - ${channel.channel_type}`,
    value: channel.id,
  }))
})

// Methods
const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('vi-VN').format(Math.round(amount))
}

const calculateProfit = async () => {
  if (!selectedChannelId.value || !purchaseData.value.priceVnd || !saleData.value.priceUsd) {
    feeBreakdown.value = []
    return
  }

  try {
    // Get fee chain for selected channel
    if (!channels.value || channels.value.length === 0) {
      feeBreakdown.value = []
      return
    }

    const channel = channels.value.find((c: Channel) => c.id === selectedChannelId.value) as
      | Channel
      | undefined
    if (!channel) {
      feeBreakdown.value = []
      return
    }

    // For now, set empty fee breakdown since trading_fee_chain_id is not available
    feeBreakdown.value = []
  } catch (error) {
    console.error('Error calculating profit:', error)
    message.error('Lỗi khi tính toán lợi nhuận')
    feeBreakdown.value = []
  }
}

// Watchers
watch(
  () => props.channelId,
  (newChannelId) => {
    selectedChannelId.value = newChannelId
    calculateProfit()
  }
)

watch(
  () => props.quantity,
  (newQuantity) => {
    purchaseData.value.quantity = newQuantity
    calculateProfit()
  }
)

watch(
  () => props.sellPriceUsd,
  (newSellPrice) => {
    saleData.value.priceUsd = newSellPrice
    calculateProfit()
  }
)

watch(
  () => props.purchasePriceVnd,
  (newPurchasePrice) => {
    purchaseData.value.priceVnd = newPurchasePrice
    calculateProfit()
  }
)

// Watch for profit changes and emit
watch(netProfit, (newProfit) => {
  emit('profit-calculated', newProfit, profitMargin.value)
})

// Lifecycle
onMounted(() => {
  // Set default exchange rate
  saleData.value.exchangeRate = 25700

  // Initial calculation if we have props
  if (props.channelId && props.sellPriceUsd && props.quantity) {
    calculateProfit()
  }
})
</script>
