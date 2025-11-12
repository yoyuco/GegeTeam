<template>
  <n-modal
    v-model:show="visible"
    :mask-closable="false"
    preset="card"
    title="Hoàn tất đơn hàng"
    size="medium"
    class="w-full max-w-5xl"
    @close="handleClose"
  >
    <template #header-extra>
      <n-button
        size="small"
        quaternary
        @click="handleClose"
      >
        <template #icon>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </template>
      </n-button>
    </template>

    <div class="max-h-[75vh] overflow-y-auto space-y-4">
      <!-- Order Information -->
      <div class="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-xl p-6">
        <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
          <div>
            <h3 class="font-bold text-gray-800 text-xl">{{ order?.order_number }}</h3>
            <div class="flex flex-col sm:flex-row sm:items-center gap-2 mt-2">
              <n-tag :type="order?.order_type === 'PURCHASE' ? 'info' : 'warning'" size="medium">
                {{ order?.order_type === 'PURCHASE' ? 'Đơn Mua' : 'Đơn Bán' }}
              </n-tag>
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
        </div>

        <!-- Payment Status Toggle (Full width for sale orders) -->
        <div v-if="order?.order_type === 'SALE'" class="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div class="flex items-center justify-between gap-4">
            <div class="flex items-center gap-3">
              <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
                <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <h4 class="font-medium text-gray-800 text-sm">Trạng thái thanh toán</h4>
                <p class="text-xs text-gray-500">Đánh dấu khi khách đã thanh toán</p>
              </div>
            </div>
            <n-switch
              v-model:value="isPaymentCompleted"
              :checked-value="true"
              :unchecked-value="false"
              size="medium"
            >
              <template #checked>✅ Đã thanh toán</template>
              <template #unchecked>⏳ Chưa thanh toán</template>
            </n-switch>
          </div>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="flex justify-end gap-3 pt-4 border-t">
        <n-button size="large" @click="handleClose">
          <template #icon>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </template>
          Hủy
        </n-button>
        <n-button
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
      </div>
    </template>
  </n-modal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import {
  NModal,
  NButton,
  NTag,
  NFormItem,
  NInput,
  NSwitch,
  useMessage
} from 'naive-ui'
import { supabase } from '@/lib/supabase'
import ProofGridDisplay from '@/components/ProofGridDisplay.vue'
import SimpleProofUpload from '@/components/SimpleProofUpload.vue'

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
const isPaymentCompleted = ref(false)
const newPaymentProofs = ref<any[]>([])

// Computed properties for proofs
const allProofs = computed(() => {
  if (!props.order?.proofs) return []
  return Array.isArray(props.order.proofs) ? props.order.proofs : []
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
    isPaymentCompleted.value = false
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

  // Validate requirements
  if (props.order.order_type === 'PURCHASE') {
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
  } else {
    if (!hasDeliveryProof.value) {
      message.error('Vui lòng tải lên bằng chứng giao hàng (bắt buộc)')
      return
    }
  }

  loading.value = true

  try {
    // Import uploadFile function
    const { uploadFile } = await import('@/lib/supabase')

    // Combine existing proofs with new payment proofs
    let finalProofs = [...allProofs.value]

    // Upload new payment proofs
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
            // Add uploaded file to final proofs
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

    // Update order with proofs and status
    const { error: updateError } = await supabase
      .from('currency_orders')
      .update({
        proofs: finalProofs,
        status: 'completed'
      })
      .eq('id', props.order.id)

    if (updateError) {
      throw new Error(`Không thể cập nhật đơn hàng: ${updateError.message}`)
    }

    message.success(`✅ Đã hoàn tất đơn #${props.order.order_number} thành công`)
    emit('completed')
    handleClose()

  } catch (error: any) {
    console.error('Error completing order:', error)
    message.error(error.message || 'Có lỗi xảy ra khi hoàn tất đơn hàng')
  } finally {
    loading.value = false
  }
}

</script>