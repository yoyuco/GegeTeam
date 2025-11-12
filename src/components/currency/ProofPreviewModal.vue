<template>
  <div class="space-y-4">
    <!-- Image Grid -->
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      <div
        v-for="(proof, index) in proofs"
        :key="index"
        class="relative group cursor-pointer"
        @click="openPreview(index)"
      >
        <div class="aspect-square rounded-lg overflow-hidden bg-gray-100 border border-gray-200 hover:border-blue-400 transition-colors">
          <img
            :src="proof.url || proof"
            :alt="`Bằng chứng ${index + 1}`"
            class="w-full h-full object-cover"
            @error="handleImageError"
          />
        </div>
        <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 transition-opacity rounded-lg flex items-center justify-center">
          <svg class="w-8 h-8 text-white opacity-0 group-hover:opacity-100 transition-opacity" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7" />
          </svg>
        </div>
        <div class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
          <n-button
            size="tiny"
            circle
            type="error"
            @click.stop="removeProof(index)"
          >
            <template #icon>
              <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </template>
          </n-button>
        </div>
      </div>
    </div>

    <!-- Preview Modal -->
    <n-modal
      v-model:show="previewVisible"
      :mask-closable="true"
      preset="card"
      size="huge"
      class="w-full max-w-6xl"
      @close="closePreview"
    >
      <template #header-extra>
        <n-button
          size="small"
          quaternary
          @click="closePreview"
        >
          <template #icon>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </template>
        </n-button>
      </template>

      <div class="flex flex-col items-center">
        <!-- Image Navigation -->
        <div class="flex items-center justify-between w-full mb-4">
          <n-button
            :disabled="currentImageIndex === 0"
            @click="previousImage"
            size="medium"
          >
            <template #icon>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </template>
            Ảnh trước
          </n-button>

          <h3 class="text-lg font-semibold text-gray-800">
            {{ title }} - {{ currentImageIndex + 1 }} / {{ proofs.length }}
          </h3>

          <n-button
            :disabled="currentImageIndex === proofs.length - 1"
            @click="nextImage"
            size="medium"
          >
            Ảnh tiếp theo
            <template #icon>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </template>
          </n-button>
        </div>

        <!-- Main Image Display -->
        <div class="w-full max-h-[60vh] flex items-center justify-center bg-gray-50 rounded-lg p-4">
          <img
            :src="currentProof?.url || currentProof"
            :alt="`Bằng chứng ${currentImageIndex + 1}`"
            class="max-w-full max-h-full object-contain rounded-lg shadow-lg"
            @error="handleImageError"
          />
        </div>

        <!-- Image Info -->
        <div class="mt-4 text-center text-sm text-gray-500">
          <p v-if="currentProof?.uploaded_at">
            Tải lên: {{ formatDate(currentProof.uploaded_at) }}
          </p>
          <p v-if="currentProof?.file_name">
            Tệp: {{ currentProof.file_name }}
          </p>
        </div>
      </div>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { NModal, NButton } from 'naive-ui'

interface Props {
  proofs: any[]
  title: string
}

interface Emits {
  (e: 'update', proofs: any[]): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

// Preview state
const previewVisible = ref(false)
const currentImageIndex = ref(0)

// Computed properties
const currentProof = computed(() => props.proofs[currentImageIndex.value])

// Methods
const openPreview = (index: number) => {
  currentImageIndex.value = index
  previewVisible.value = true
}

const closePreview = () => {
  previewVisible.value = false
}

const previousImage = () => {
  if (currentImageIndex.value > 0) {
    currentImageIndex.value--
  }
}

const nextImage = () => {
  if (currentImageIndex.value < props.proofs.length - 1) {
    currentImageIndex.value++
  }
}

const removeProof = (index: number) => {
  const newProofs = [...props.proofs]
  newProofs.splice(index, 1)
  emit('update', newProofs)
}

const handleImageError = (event: Event) => {
  const img = event.target as HTMLImageElement
  img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBmaWxsPSIjRjNGNEY2Ii8+CjxwYXRoIGQ9Ik0yMCAyNkMxOC44OTU0IDI2IDE4IDI1LjEwNDYgMTggMjRDMTggMjIuODk1NCAxOC44OTU0IDIyIDIwIDIyQzIxLjEwNDYgMjIgMjIgMjIuODk1NCAyMiAyNEMyMiAyNS4xMDQ2IDIxLjEwNDYgMjYgMjAgMjZaIiBmaWxsPSIjOUNBM0FGIi8+CjxwYXRoIGQ9Ik0yMCAxOEMxOC44OTU0IDE4IDE4IDE3LjEwNDYgMTggMTZDMTggMTQuODk1NCAxOC44OTU0IDE0IDIwIDE0QzIxLjEwNDYgMTQgMjIgMTQuODk1NCAyMiAxNkMyMiAxNy4xMDQ2IDIxLjEwNDYgMTggMjAgMThaIiBmaWxsPSIjOUNBM0FGIi8+Cjwvc3ZnPgo='
}

const formatDate = (dateString: string) => {
  try {
    return new Date(dateString).toLocaleString('vi-VN')
  } catch {
    return dateString
  }
}

// Keyboard navigation
const handleKeydown = (event: KeyboardEvent) => {
  if (!previewVisible.value) return

  switch (event.key) {
    case 'ArrowLeft':
      previousImage()
      break
    case 'ArrowRight':
      nextImage()
      break
    case 'Escape':
      closePreview()
      break
  }
}

// Add keyboard event listener
if (typeof window !== 'undefined') {
  window.addEventListener('keydown', handleKeydown)
}
</script>