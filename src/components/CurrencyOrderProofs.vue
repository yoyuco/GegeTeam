<template>
  <div class="currency-order-proofs">
    <div class="proof-header">
      <h3>Quản lý bằng chứng</h3>
      <p class="text-sm text-gray-600">
        Upload và quản lý bằng chứng cho từng giai đoạn của đơn hàng
      </p>
    </div>

    <!-- Proof Stages -->
    <div v-for="stage in proofStages" :key="stage.key" class="proof-stage mb-6">
      <div class="stage-header">
        <h4>{{ stage.label }}</h4>
        <p class="text-sm text-gray-500">{{ stage.description }}</p>
      </div>

      <!-- Stage content based on stage type -->
      <div v-if="stage.key === 'order_creation'" class="stage-content">
        <div class="category-section">
          <h5>{{ orderType === 'purchase' ? 'Bằng chứng mua hàng' : 'Bằng chứng bán hàng' }}</h5>
          <div class="description-input mb-3">
            <label class="block text-sm font-medium text-gray-700 mb-1"> Mô tả </label>
            <input
              v-model="stageProofs[stage.key][orderType].description"
              type="text"
              class="w-full p-2 border rounded"
              placeholder="Mô tả chi tiết về bằng chứng..."
            />
          </div>

          <ProofUploadArea
            :stage="stage.key"
            :category="orderType"
            :files="getProofFiles(stage.key, orderType)"
            @upload="handleUpload"
            @remove="handleRemove"
          />
        </div>
      </div>

      <div v-else-if="stage.key === 'order_processing'" class="stage-content">
        <!-- Purchase processing -->
        <div v-if="orderType === 'purchase'" class="category-section mb-4">
          <h5>Nhận hàng</h5>
          <div class="description-input mb-3">
            <input
              v-model="stageProofs[stage.key].purchase.receiving.description"
              type="text"
              class="w-full p-2 border rounded"
              placeholder="Mô tả về việc nhận hàng..."
            />
          </div>

          <ProofUploadArea
            :stage="stage.key"
            category="purchase.receiving"
            :files="getProofFiles(stage.key, 'purchase.receiving')"
            @upload="handleUpload"
            @remove="handleRemove"
          />

          <h5 class="mt-4">Cập nhật tồn kho</h5>
          <div class="description-input mb-3">
            <input
              v-model="stageProofs[stage.key].purchase.inventory_update.description"
              type="text"
              class="w-full p-2 border rounded"
              placeholder="Mô tả về cập nhật tồn kho..."
            />
          </div>

          <ProofUploadArea
            :stage="stage.key"
            category="purchase.inventory_update"
            :files="getProofFiles(stage.key, 'purchase.inventory_update')"
            @upload="handleUpload"
            @remove="handleRemove"
          />
        </div>

        <!-- Sell processing -->
        <div v-else-if="orderType === 'sell'" class="category-section">
          <h5>Giao hàng</h5>
          <div class="description-input mb-3">
            <input
              v-model="stageProofs[stage.key].sell.delivery.description"
              type="text"
              class="w-full p-2 border rounded"
              placeholder="Mô tả về việc giao hàng..."
            />
          </div>

          <ProofUploadArea
            :stage="stage.key"
            category="sell.delivery"
            :files="getProofFiles(stage.key, 'sell.delivery')"
            @upload="handleUpload"
            @remove="handleRemove"
          />
        </div>
      </div>

      <div v-else-if="stage.key === 'order_completion'" class="stage-content">
        <div class="category-section">
          <h5>
            {{ orderType === 'purchase' ? 'Xác nhận hoàn thành mua' : 'Xác nhận hoàn thành bán' }}
          </h5>
          <div class="description-input mb-3">
            <input
              v-model="stageProofs[stage.key][orderType].description"
              type="text"
              class="w-full p-2 border rounded"
              placeholder="Mô tả về việc hoàn thành đơn hàng..."
            />
          </div>

          <ProofUploadArea
            :stage="stage.key"
            :category="orderType"
            :files="getProofFiles(stage.key, orderType)"
            @upload="handleUpload"
            @remove="handleRemove"
          />
        </div>
      </div>

      <div v-else-if="stage.key === 'currency_exchange'" class="stage-content">
        <!-- Before exchange -->
        <div class="category-section mb-4">
          <h5>Trước khi đổi</h5>
          <div class="description-input mb-3">
            <input
              v-model="stageProofs[stage.key].before_exchange.description"
              type="text"
              class="w-full p-2 border rounded"
              placeholder="Mô tả balance trước khi đổi..."
            />
          </div>

          <ProofUploadArea
            :stage="stage.key"
            category="before_exchange"
            :files="getProofFiles(stage.key, 'before_exchange')"
            @upload="handleUpload"
            @remove="handleRemove"
          />
        </div>

        <!-- Exchange process -->
        <div class="category-section mb-4">
          <h5>Quá trình đổi</h5>
          <div class="description-input mb-3">
            <input
              v-model="stageProofs[stage.key].exchange_process.description"
              type="text"
              class="w-full p-2 border rounded"
              placeholder="Mô tả quá trình đổi currency..."
            />
          </div>

          <ProofUploadArea
            :stage="stage.key"
            category="exchange_process"
            :files="getProofFiles(stage.key, 'exchange_process')"
            @upload="handleUpload"
            @remove="handleRemove"
          />
        </div>

        <!-- After exchange -->
        <div class="category-section">
          <h5>Sau khi đổi</h5>
          <div class="description-input mb-3">
            <input
              v-model="stageProofs[stage.key].after_exchange.description"
              type="text"
              class="w-full p-2 border rounded"
              placeholder="Mô tả balance sau khi đổi..."
            />
          </div>

          <ProofUploadArea
            :stage="stage.key"
            category="after_exchange"
            :files="getProofFiles(stage.key, 'after_exchange')"
            @upload="handleUpload"
            @remove="handleRemove"
          />
        </div>
      </div>
    </div>

    <!-- Summary -->
    <div class="proof-summary mt-6 p-4 bg-gray-50 rounded">
      <h4>Tổng quan bằng chứng</h4>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-2">
        <div class="text-center">
          <div class="text-2xl font-bold">{{ totalProofs }}</div>
          <div class="text-sm text-gray-600">Tổng files</div>
        </div>
        <div class="text-center">
          <div class="text-2xl font-bold">{{ imageProofs }}</div>
          <div class="text-sm text-gray-600">Hình ảnh</div>
        </div>
        <div class="text-center">
          <div class="text-2xl font-bold">{{ videoProofs }}</div>
          <div class="text-sm text-gray-600">Video</div>
        </div>
        <div class="text-center">
          <div class="text-2xl font-bold">{{ completedStages }}</div>
          <div class="text-sm text-gray-600">Giai đoạn hoàn thành</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, watch, ref, onMounted } from 'vue'
import { useCurrencyOrderProofs } from '@/composables/useCurrencyOrderProofs'
import { supabase } from '@/lib/supabase'
import ProofUploadArea from './ProofUploadArea.vue'

const props = defineProps({
  orderId: {
    type: String,
    required: true,
  },
  orderType: {
    type: String,
    required: true,
    validator: (value) => ['purchase', 'sale', 'exchange'].includes(value),
  },
})

const { proofs, loadProofs, proofStages, getProofFiles, uploadProofFiles, removeProofFile } =
  useCurrencyOrderProofs()

// Reactive proofs structure
const stageProofs = computed(() => proofs.value)

// Watch for changes and update database
watch(
  stageProofs,
  async (newProofs) => {
    try {
      const { error } = await supabase
        .from('currency_orders')
        .update({ proofs: newProofs })
        .eq('id', props.orderId)

      if (error) {
        console.error('Failed to update proofs:', error)
      }
    } catch (error) {
      console.error('Error updating proofs:', error)
    }
  },
  { deep: true }
)

// Computed properties for summary
const totalProofs = computed(() => {
  return getAllProofFiles.value.length
})

const imageProofs = computed(() => {
  return getAllProofFiles.value.filter((file) => file.type === 'image').length
})

const videoProofs = computed(() => {
  return getAllProofFiles.value.filter((file) => file.type === 'video').length
})

const completedStages = computed(() => {
  return Object.values(proofs.value).filter((stage) => {
    return Object.values(stage).some((category) => category.files?.length > 0)
  }).length
})

const getAllProofFiles = computed(() => {
  const allFiles = []

  Object.values(proofs.value).forEach((stage) => {
    Object.values(stage).forEach((category) => {
      if (category.files) {
        allFiles.push(...category.files)
      }
    })
  })

  return allFiles
})

// Methods
const handleUpload = async (stage, category, files, description) => {
  try {
    await uploadProofFiles(props.orderId, stage, category, files, description)
    await loadProofs(props.orderId) // Reload to get updated structure
  } catch (error) {
    console.error('Upload failed:', error)
    // You might want to show an error message to the user
  }
}

const handleRemove = async (stage, category, fileIndex) => {
  try {
    await removeProofFile(props.orderId, stage, category, fileIndex)
    await loadProofs(props.orderId) // Reload to get updated structure
  } catch (error) {
    console.error('Remove failed:', error)
    // You might want to show an error message to the user
  }
}

// Load proofs on mount
const mounted = ref(false)
onMounted(async () => {
  if (!mounted.value) {
    await loadProofs(props.orderId)
    mounted.value = true
  }
})
</script>

<style scoped>
.proof-stage {
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  padding: 1rem;
}

.stage-header {
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.stage-header h4 {
  font-size: 1.125rem;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 0.25rem;
}

.category-section {
  background-color: #f9fafb;
  padding: 0.75rem;
  border-radius: 0.25rem;
}

.category-section h5 {
  font-size: 1rem;
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.5rem;
}

.description-input label {
  display: block;
}

.description-input input {
  border-color: #e5e7eb;
}

.description-input input:focus {
  box-shadow: 0 0 0 2px #2563eb;
  border-color: #2563eb;
}

.proof-summary {
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
}

.proof-summary h4 {
  font-size: 1.125rem;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 0.5rem;
}

.proof-summary .grid {
  gap: 1rem;
}

.proof-summary .text-center {
  background-color: white;
  padding: 0.75rem;
  border-radius: 0.25rem;
  border: 1px solid #e5e7eb;
}

.proof-summary .text-2xl {
  color: #2563eb;
  font-size: 1.5rem;
  line-height: 2rem;
}

.proof-summary .text-sm {
  color: #6b7280;
  font-size: 0.875rem;
  line-height: 1.25rem;
}
</style>
