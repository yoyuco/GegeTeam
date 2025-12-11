<template>
  <n-modal
    v-model:show="visible"
    :mask-closable="false"
    size="medium"
    class="w-full max-w-5xl"
    :on-close="handleClose"
  >
    <div class="h-full flex flex-col bg-white rounded-lg">
      <!-- Custom Header -->
      <div class="flex items-center justify-between p-6 border-b bg-white">
        <h2 class="text-xl font-bold text-gray-800">Hoàn tất đơn hàng</h2>
        <button
          @click="handleClose"
          class="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Main Content -->
      <div class="flex-1 p-6 max-h-[75vh] overflow-y-auto space-y-4">
        <!-- Order Information -->
        <div class="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-xl p-6">
          <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            <div>
              <h3 class="font-bold text-gray-800 text-xl">{{ order?.order_number }}</h3>
              <div class="flex flex-wrap items-center gap-2 mt-2">
                <n-tag :type="order?.order_type === 'PURCHASE' ? 'info' : 'warning'" size="medium">
                  {{ order?.order_type === 'PURCHASE' ? 'Đơn Mua' : 'Đơn Bán' }}
                </n-tag>
                <span class="text-sm text-gray-600">
                  Game: <strong>{{ order?.game_name || order?.game_attribute?.name || order?.game?.name || 'Chưa có' }}</strong>
                </span>
                <span class="text-sm text-gray-600">
                  Server: <strong>{{ order?.server_name || order?.server_attribute?.name || order?.server?.name || 'Chưa có' }}</strong>
                </span>
                <span class="text-sm text-gray-600">
                  Currency: <strong>{{ order?.currencyName || order?.currency_attribute?.name || order?.currency?.name || 'Chưa có' }}</strong>
                </span>
                <span class="text-sm text-gray-600">
                  Số lượng: <strong>{{ formatNumber(order?.quantity) }}</strong>
                </span>
                <span class="text-sm text-gray-600">
                  Giá trị: <strong>{{ formatNumber(order?.sale_amount || order?.cost_amount) }} {{ order?.sale_currency_code || order?.cost_currency_code }}</strong>
                </span>
              </div>
            </div>
            <div class="text-center lg:text-right">
              <div class="text-sm text-gray-500 mb-1">Trạng thái hiện tại</div>
              <n-tag type="info" size="large">{{ formatOrderStatus(order?.status) }}</n-tag>
            </div>
          </div>

          <!-- Additional Order Details -->
          <div class="mt-4 pt-4 border-t border-blue-200">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- Channel Information -->
              <div class="flex items-center gap-2">
                <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span class="text-sm text-gray-600">Kênh:</span>
                <span class="text-sm font-medium text-gray-800">{{ order?.channel?.name || 'Chưa có kênh' }}</span>
              </div>

              <!-- Customer/Supplier Information -->
              <div class="flex items-center gap-2">
                <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                <span class="text-sm text-gray-600">{{ order?.order_type === 'PURCHASE' ? 'Nhà cung cấp:' : 'Khách hàng:' }}</span>
                <span class="text-sm font-medium text-gray-800">{{ order?.party?.name || 'Chưa có thông tin' }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Proof Management -->
        <div>
          <h3 class="font-bold text-gray-800 text-lg mb-6 flex items-center gap-2">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            Quản lý bằng chứng
          </h3>

          <!-- Purchase Order Proofs -->
          <div v-if="order?.order_type === 'PURCHASE'" class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <!-- Negotiation Proof Section -->
            <div class="border border-gray-200 rounded-lg p-4 bg-white shadow-sm">
              <div class="flex items-center justify-between mb-4">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
                    <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                    </svg>
                  </div>
                  <div>
                    <h4 class="font-medium text-gray-800 text-sm">Đàm phán</h4>
                  </div>
                </div>
                <n-tag v-if="hasNegotiationProof" type="success" size="small">
                  <template #icon>
                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                    </svg>
                  </template>
                  Đã có
                </n-tag>
                <n-tag v-else type="error" size="small">
                  <template #icon>
                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                  </template>
                  Bắt buộc
                </n-tag>
              </div>

              <!-- Proof Display -->
              <div v-if="negotiationProofs.length > 0">
                <ProofGridDisplay :proofs="negotiationProofs" />
              </div>
              <div v-else class="text-center py-6 bg-gray-50 rounded border border-dashed border-gray-300">
                <svg class="w-8 h-8 text-gray-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <p class="text-gray-500 text-sm">Chưa có</p>
              </div>
            </div>

            <!-- Delivery Proof Section -->
            <div class="border border-gray-200 rounded-lg p-4 bg-white shadow-sm">
              <div class="flex items-center justify-between mb-4">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                    <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                    </svg>
                  </div>
                  <div>
                    <h4 class="font-medium text-gray-800 text-sm">Nhận hàng</h4>
                  </div>
                </div>
                <n-tag v-if="hasDeliveryProof" type="success" size="small">
                  <template #icon>
                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                    </svg>
                  </template>
                  Đã có
                </n-tag>
                <n-tag v-else type="error" size="small">
                  <template #icon>
                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                  </template>
                  Bắt buộc
                </n-tag>
              </div>

              <!-- Proof Display -->
              <div v-if="deliveryProofs.length > 0">
                <ProofGridDisplay :proofs="deliveryProofs" />
              </div>
              <div v-else class="text-center py-6 bg-gray-50 rounded border border-dashed border-gray-300">
                <svg class="w-8 h-8 text-gray-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                </svg>
                <p class="text-gray-500 text-sm">Chưa có</p>
              </div>
            </div>

            <!-- Payment Proof Section -->
            <div class="border border-gray-200 rounded-lg p-4 bg-white shadow-sm">
              <div class="flex items-center justify-between mb-4">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center">
                    <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                  </div>
                  <div>
                    <h4 class="font-medium text-gray-800 text-sm">Thanh toán</h4>
                  </div>
                </div>
                <n-tag v-if="hasPaymentProof" type="success" size="small">
                  <template #icon>
                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                    </svg>
                  </template>
                  Đã có
                </n-tag>
                <n-tag v-else type="error" size="small">
                  <template #icon>
                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                  </template>
                  Bắt buộc
                </n-tag>
              </div>

              <!-- Existing Payment Proofs -->
              <div v-if="paymentProofs.length > 0" class="mb-4">
                <ProofGridDisplay :proofs="paymentProofs" />
              </div>

              <!-- Upload Payment Proof -->
              <SimpleProofUpload
                label="Bằng chứng thanh toán"
                :max-files="3"
                :upload-path="`currency/purchase/${order?.order_number}/payment`"
                :order-id="order?.order_number"
                :auto-upload="false"
                :hide-label-icon="true"
                @update:model-value="handlePaymentProofUpload"
              />
            </div>
          </div>

          <!-- Sale Order Proofs -->
          <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Exchange Proof Section -->
            <div class="border border-gray-200 rounded-lg p-4 bg-white shadow-sm">
              <div class="flex items-center justify-between mb-4">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center">
                    <svg class="w-4 h-4 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                    </svg>
                  </div>
                  <div>
                    <h4 class="font-medium text-gray-800 text-sm">Quy đổi</h4>
                  </div>
                </div>
                <n-tag v-if="hasExchangeProof" type="success" size="small">
                  <template #icon>
                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                    </svg>
                  </template>
                  Đã có
                </n-tag>
                <n-tag v-else type="info" size="small">
                  Tùy chọn
                </n-tag>
              </div>

              <!-- Proof Display -->
              <div v-if="exchangeProofs.length > 0">
                <ProofGridDisplay :proofs="exchangeProofs" />
              </div>
              <div v-else class="text-center py-6 bg-gray-50 rounded border border-dashed border-gray-300">
                <svg class="w-8 h-8 text-gray-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                </svg>
                <p class="text-gray-500 text-sm">Chưa có</p>
              </div>
            </div>

            <!-- Delivery Proof Section -->
            <div class="border border-gray-200 rounded-lg p-4 bg-white shadow-sm">
              <div class="flex items-center justify-between mb-4">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                    <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                    </svg>
                  </div>
                  <div>
                    <h4 class="font-medium text-gray-800 text-sm">Giao hàng</h4>
                  </div>
                </div>
                <n-tag v-if="hasDeliveryProof" type="success" size="small">
                  <template #icon>
                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                    </svg>
                  </template>
                  Đã có
                </n-tag>
                <n-tag v-else type="error" size="small">
                  <template #icon>
                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                  </template>
                  Bắt buộc
                </n-tag>
              </div>

              <!-- Proof Display using ProofGridDisplay -->
              <div v-if="deliveryProofs.length > 0">
                <ProofGridDisplay :proofs="deliveryProofs" />
              </div>
              <div v-else class="text-center py-6 bg-gray-50 rounded border border-dashed border-gray-300">
                <svg class="w-8 h-8 text-gray-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                </svg>
                <p class="text-gray-500 text-sm">Chưa có</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Custom Footer -->
      <div class="flex justify-end gap-3 p-6 border-t bg-gray-50">
      <n-button size="large" @click="handleClose">
        <template #icon>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </template>
        Hủy
      </n-button>

      <!-- Show complete button for purchase orders -->
      <n-button
        v-if="order?.order_type === 'PURCHASE'"
        type="primary"
        size="large"
        :loading="loading"
        @click="handleCompleteOrder"
      >
        <template #icon>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </template>
        Hoàn tất đơn hàng
      </n-button>

      <!-- Show complete button for sale orders -->
      <n-button
        v-else-if="order?.order_type === 'SALE'"
        type="primary"
        size="large"
        :loading="loading"
        @click="handleCompleteSaleOrder"
      >
        <template #icon>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </template>
        Hoàn tất đơn bán
      </n-button>

      <!-- Hide complete button for other cases -->
      <span v-else class="text-sm text-gray-500 italic">
        Đơn hàng chưa ở trạng thái phù hợp để hoàn tất
      </span>
      </div>
    </div>
  </n-modal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import {
  NModal,
  NButton,
  NTag,
  useMessage
} from 'naive-ui'
import { supabase, callRPC } from '@/lib/supabase'
import ProofGridDisplay from '@/components/ProofGridDisplay.vue'
import SimpleProofUpload from '@/components/SimpleProofUpload.vue'
import { useCurrencyOps } from '@/composables/useCurrencyOps.js'

interface Props {
  show: boolean
  order: any
}

interface Emits {
  (e: 'update:show', value: boolean): void
  (e: 'completed'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const message = useMessage()

// Modal visibility
const visible = computed({
  get: () => props.show,
  set: (value) => emit('update:show', value)
})

// Form data
const loading = ref(false)
const newPaymentProofs = ref<any[]>([])
const completionNotes = ref('')

// Helper function to handle both object and array proof formats (same as DataListCurrency)
const getProofsArray = (proofs: any) => {
  if (!proofs) return []

  // If it's already an array, return as is
  if (Array.isArray(proofs)) return proofs

  // If it's an object with url property, convert to array
  if (typeof proofs === 'object' && proofs.url) {
    return [proofs]
  }

  // If it's any other object, try to convert to array
  if (typeof proofs === 'object') {
    return [proofs]
  }

  return []
}

// Computed properties for proofs
const allProofs = computed(() => {
  const proofs = getProofsArray(props.order?.proofs)
  return proofs
})

const negotiationProofs = computed(() => {
  return allProofs.value.filter((proof: any) => proof.type === 'negotiation')
})

const deliveryProofs = computed(() => {
  return allProofs.value.filter((proof: any) => proof.type === 'receiving' || proof.type === 'delivery')
})

const paymentProofs = computed(() => {
  return allProofs.value.filter((proof: any) => proof.type === 'payment')
})

const exchangeProofs = computed(() => {
  return allProofs.value.filter((proof: any) => proof.type === 'exchange')
})

// Proof availability checks
const hasNegotiationProof = computed(() => negotiationProofs.value.length > 0)
const hasDeliveryProof = computed(() => deliveryProofs.value.length > 0)
const hasPaymentProof = computed(() => paymentProofs.value.length > 0)
const hasExchangeProof = computed(() => exchangeProofs.value.length > 0)

// Initialize data when order changes
watch(() => props.order, (newOrder) => {
  if (newOrder) {
    newPaymentProofs.value = []
  }
}, { immediate: true })

// Utility functions
const formatNumber = (num: number | string) => {
  if (!num) return '0'
  return Number(num).toLocaleString('vi-VN')
}

const formatOrderStatus = (status: string): string => {
  if (!status) return status

  const statusMap: Record<string, string> = {
    'pending': 'Chờ xử lý',
    'confirmed': 'Đã xác nhận',
    'preparing': 'Đang chuẩn bị',
    'ready_for_delivery': 'Sẵn sàng giao hàng',
    'delivering': 'Đang giao hàng',
    'delivered': 'Đã nhận hàng',
    'completed': 'Đã hoàn thành',
    'cancelled': 'Đã hủy',
    'refunded': 'Đã hoàn tiền'
  }

  return statusMap[status] || status
}

// File upload handlers
const handlePaymentProofUpload = (files: any[]) => {
  // Store files that need to be uploaded
  newPaymentProofs.value = files
}


// Modal handlers
const handleClose = () => {
  emit('update:show', false)
}

const handleCompleteOrder = async () => {
  if (!props.order) return

  // Validation logic based on order type and status
  if (props.order.order_type === 'SALE') {
    // 📥 ĐƠN BÁN: Chỉ cần ở trạng thái delivered và có delivery proof
    // Delivery proof đã có từ khi trader xác nhận giao hàng

    // Check if sale order is in correct status for completion
    if (props.order.status !== 'delivered') {
      message.error('Đơn bán phải ở trạng thái "đã giao hàng" để hoàn tất')
      return
    }

    // Check if delivery proof exists (should already be there from trader confirmation)
    if (!hasDeliveryProof.value) {
      message.error('Thiếu bằng chứng giao hàng. Vui lòng kiểm tra lại.')
      return
    }
  } else if (props.order.order_type === 'PURCHASE') {
    // 🛒 ĐƠN MUA: Cần payment proof để hoàn tất

    if (props.order.status === 'delivered') {
      // Already delivered, need NEW payment proof
      if (newPaymentProofs.value.length === 0) {
        message.error('Đơn mua cần bằng chứng thanh toán để hoàn tất. Vui lòng tải lên.')
        return
      }
    } else {
      // Standard validation for non-delivered purchase orders
      if (!hasNegotiationProof.value) {
        message.error('Vui lòng tải lên bằng chứng đàm phán (bắt buộc)')
        return
      }
      if (!hasDeliveryProof.value) {
        message.error('Vui lòng tải lên bằng chứng nhận hàng (bắt buộc)')
        return
      }
      if (!hasPaymentProof.value && newPaymentProofs.value.length === 0) {
        message.error('Vui lòng tải lên bằng chứng thanh toán (bắt buộc)')
        return
      }
    }
  }

  loading.value = true

  try {
    // Import uploadFile function
    const { uploadFile } = await import('@/lib/supabase')
    const { createUniqueFilename } = await import('@/utils/filenameUtils')

    // Start with existing proofs
    let finalProofs = [...allProofs.value]

    // Upload new payment proofs only if there are new files
    if (newPaymentProofs.value.length > 0) {

      for (const fileInfo of newPaymentProofs.value) {
        if (fileInfo.file) {
          // Create unique filename
          const timestamp = Date.now()
          const randomString = Math.random().toString(36).substring(2, 8)
          const filename = `${timestamp}-${randomString}-${fileInfo.file.name}`
          const filePath = `currency/purchase/${props.order.order_number}/payment/${filename}`

          // Upload file to Supabase Storage
          const uploadResult = await uploadFile(fileInfo.file, filePath, 'work-proofs')

          if (uploadResult.success) {
            // Add uploaded file to final proofs with proper structure
            finalProofs.push({
              url: uploadResult.publicUrl,
              path: uploadResult.path,
              type: 'payment',
              filename: fileInfo.file.name,
              uploaded_at: new Date().toISOString()
            })
          }
        }
      }
    }

    // Handle different scenarios based on order status and type
    if (props.order.status === 'delivered') {
      // For delivered orders waiting final completion
      if (props.order.order_type === 'SALE') {
        // 📥 ĐƠN BÁN: delivered → completed
        // Chỉ cần chuyển trạng thái, không cần thêm proofs (delivery proofs đã có)
        const { data: profileId } = await supabase.rpc('get_current_profile_id')

        if (!profileId) {
          throw new Error('Không thể xác định profile người dùng')
        }

        const { callRPC } = await import('@/lib/supabase')
        const result = await callRPC('complete_sale_order_v2', {
          p_order_id: props.order.id,
          p_user_id: profileId
        })

        if (!result.success) {
          const errorMessage = result.data?.message || result.error || 'Không thể hoàn tất đơn bán'
          throw new Error(errorMessage)
        }

        message.success(`✅ Đã hoàn tất đơn bán #${props.order.order_number}`)
        emit('completed')
        handleClose()

      } else if (props.order.order_type === 'PURCHASE') {
        // 🛒 ĐƠN MUA: delivered → completed
        // CẦN upload payment proofs + cập nhật trạng thái

        if (newPaymentProofs.value.length === 0) {
          message.warning('Đơn mua cần có bằng chứng thanh toán để hoàn tất')
          loading.value = false
          return
        }

        // Upload payment proofs before completing
        const uploadedProofs = []
        for (const fileInfo of newPaymentProofs.value) {
          const filename = createUniqueFilename(fileInfo.file.name)
          const filePath = `currency/purchase/${props.order.order_number}/completion/${filename}`

          const { uploadFile } = await import('@/lib/supabase')
          const uploadResult = await uploadFile(fileInfo.file, filePath, 'work-proofs')

          if (!uploadResult.success) {
            throw new Error(`Upload failed for ${fileInfo.file.name}: ${uploadResult.error}`)
          }

          uploadedProofs.push({
            url: uploadResult.publicUrl,
            path: uploadResult.path,
            filename: fileInfo.file.name,
            type: 'payment',
            uploaded_at: new Date().toISOString()
          })
        }

        // Merge new payment proofs with existing proofs
        const allProofs = [...props.order.proofs || [], ...uploadedProofs]

        // Update order with new proofs and change status to completed
        const { error: updateError } = await supabase
          .from('currency_orders')
          .update({
            proofs: allProofs,
            status: 'completed',
            completed_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          })
          .eq('id', props.order.id)

        if (updateError) {
          throw updateError
        }

        message.success(`✅ Đã hoàn tất đơn mua #${props.order.order_number} với ${uploadedProofs.length} bằng chứng thanh toán`)
        emit('completed')
        handleClose()
      }
    } else {
      // For non-delivered orders: use standard completion flow
      const { completeCurrencyOrder: completeOrderFunction } = useCurrencyOps()


      const result = await completeOrderFunction(props.order.id, {
        notes: completionNotes.value || 'Đơn hàng đã hoàn thành',
        proofUrls: finalProofs,
        actualQuantity: props.order.quantity,
        actualUnitPriceVnd: props.order.cost_amount / props.order.quantity
      })

      if (result && !result.success) {
        throw new Error(result.error || 'Failed to complete order')
      }

      message.success(`✅ Đã hoàn tất đơn #${props.order.order_number} thành công`)
      emit('completed')
      handleClose()
    }

  } catch (error: any) {
    console.error('Error completing order:', error)
    message.error(error.message || 'Có lỗi xảy ra khi hoàn tất đơn hàng')
  } finally {
    loading.value = false
  }
}

// Handle sale order completion
const handleCompleteSaleOrder = async () => {
  if (!props.order) return

  // Validation: must have delivery proof for sale orders
  if (!hasDeliveryProof.value) {
    message.error('Đơn bán cần có bằng chứng giao hàng để hoàn tất')
    return
  }

  // Check if sale order is in correct status for completion
  if (props.order.status !== 'delivered') {
    message.error('Đơn bán phải ở trạng thái "đã giao hàng" để hoàn tất')
    return
  }

  loading.value = true

  try {
    // Use complete_sale_order_v2 function with proper authentication
    // Following memory.md rule: Frontend calls get_current_profile_id()
    const { data: profileId } = await supabase.rpc('get_current_profile_id')

    if (!profileId) {
      throw new Error('Không thể xác định profile người dùng')
    }

    const result = await callRPC('complete_sale_order_v2', {
      p_order_id: props.order.id,
      p_user_id: profileId  // Use profiles.id from get_current_profile_id()
    })

    if (!result.success) {
      // complete_sale_order_v2 function returns table with message column
      const errorMessage = result.data?.message || result.error || 'Không thể hoàn tất đơn bán'
      throw new Error(errorMessage)
    }

    message.success(`✅ Đã hoàn tất đơn bán #${props.order.order_number}`)
    emit('completed')
    handleClose()

  } catch (error: any) {
    console.error('Error completing sale order:', error)
    message.error(error.message || 'Có lỗi xảy ra khi hoàn tất đơn bán')
  } finally {
    loading.value = false
  }
}

</script>