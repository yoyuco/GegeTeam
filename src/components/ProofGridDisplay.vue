<template>
  <div class="proof-grid-display">
    <!-- Use n-upload to display existing proofs in image-card format -->
    <n-upload
      v-if="displayFileList.length > 0"
      :file-list="displayFileList"
      :show-remove-button="false"
      :show-upload-button="false"
      :show-file-list="true"
      list-type="image-card"
      :max="999"
      :on-preview="handlePreview"
      :on-download="handleDownload"
      class="w-full"
    >
    </n-upload>
    <div v-else class="text-center py-8 text-gray-500">
      <svg class="w-12 h-12 mx-auto mb-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
      </svg>
      <p>Chưa có bằng chứng nào</p>
    </div>

    <!-- Image Viewer Modal -->
    <n-modal
      v-model:show="showViewer"
      :mask-closable="true"
      size="huge"
      :show-icon="false"
      @close="closeViewer"
    >
      <div class="h-screen flex flex-col bg-black">
        <!-- Header -->
        <div class="flex items-center justify-between p-4 bg-gray-900 bg-opacity-50 backdrop-blur-sm">
          <div class="text-white">
            <p class="font-medium">{{ selectedProof?.filename }}</p>
            <p class="text-sm text-gray-300">
              {{ selectedProof?.uploaded_at ? `Tải lên: ${new Date(selectedProof.uploaded_at).toLocaleString('vi-VN')}` : '' }}
            </p>
          </div>
          <div class="flex items-center gap-2">
            <n-button
              v-if="selectedProof"
              type="primary"
              size="small"
              @click="downloadFile(selectedProof)"
              class="text-white"
            >
              <template #icon>
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                </svg>
              </template>
              Tải xuống
            </n-button>
            <button
              @click="closeViewer"
              class="p-2 hover:bg-gray-700 rounded-lg transition-colors"
            >
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        <!-- Image Display -->
        <div class="flex-1 flex items-center justify-center p-4">
          <img
            v-if="selectedProof && isImageFile(selectedProof)"
            :src="selectedProof.url"
            :alt="selectedProof.filename"
            class="object-contain"
            :style="imageStyle"
            @load="handleImageLoad"
          />
          <div v-else-if="selectedProof" class="text-center">
            <div class="bg-gray-800 rounded-lg p-12">
              <svg class="w-24 h-24 mx-auto mb-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              <p class="text-gray-300 text-lg mb-6">{{ selectedProof.filename || 'Tệp đính kèm' }}</p>
              <n-button
                type="primary"
                size="large"
                @click="downloadFile(selectedProof)"
              >
                <template #icon>
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                </template>
                Tải xuống
              </n-button>
            </div>
          </div>
        </div>
      </div>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { NModal, NButton, NUpload } from 'naive-ui'

interface Proof {
  id?: string
  url: string
  filename: string
  uploaded_at?: string
  file_size?: number
  path?: string
}

interface Props {
  proofs: Proof[]
}

const props = defineProps<Props>()

// Viewer state
const showViewer = ref(false)
const selectedProof = ref<Proof | null>(null)
const imageDimensions = ref({ width: 0, height: 0 })

// Convert proofs to n-upload format
const displayFileList = computed(() => {
  const proofs = props.proofs || []
  return proofs.map((proof, index) => ({
    id: proof.id || `proof-${index}`,
    name: proof.filename || `proof-${index}`,
    status: 'finished' as const,
    url: proof.url,
    thumbUrl: proof.url
  }))
})

// Compute image style dynamically
const imageStyle = computed(() => {
  const vh = window.innerHeight
  const baseStyle = {
    maxWidth: '100%',
    maxHeight: `${vh - 200}px`
  }

  // After image loads, set dimensions to auto
  if (imageDimensions.value.width > 0) {
    return {
      ...baseStyle,
      width: 'auto',
      height: 'auto'
    }
  }

  return baseStyle
})

// Utility functions
const isImageFile = (proof: Proof): boolean => {
  if (!proof.filename) {
    // Try to determine if it's an image from the URL
    const url = proof.url || ''
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'jfif', 'bmp'] // cspell:disable-line
    const urlExtension = url.toLowerCase().split('.').pop()?.split('?')[0]
    if (urlExtension && imageExtensions.includes(urlExtension)) {
      return true
    }
    // Check if the URL contains common image patterns
    if (url.includes('/work-proofs/') && (url.includes('screenshot') || url.includes('image'))) {
      return true
    }
    return false
  }
  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'jfif', 'bmp'] // cspell:disable-line
  const extension = proof.filename.toLowerCase().split('.').pop()
  return extension ? imageExtensions.includes(extension) : false
}


const formatFileSize = (bytes: number): string => {
  if (!bytes) return ''
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(1024))
  return `${Math.round(bytes / Math.pow(1024, i) * 100) / 100} ${sizes[i]}`
}

// Modal handlers
const openProofViewer = (proof: Proof) => {
  selectedProof.value = proof
  // Reset image dimensions when opening new image
  imageDimensions.value = { width: 0, height: 0 }
  showViewer.value = true
}

const closeViewer = () => {
  showViewer.value = false
  selectedProof.value = null
  imageDimensions.value = { width: 0, height: 0 }
}

const handleImageLoad = (event: Event) => {
  // Get actual image dimensions
  const img = event.target as HTMLImageElement
  imageDimensions.value = {
    width: img.naturalWidth,
    height: img.naturalHeight
  }
}

// n-upload handlers
const handlePreview = (file: any) => {
  // Find the corresponding proof and open in viewer
  const proofs = props.proofs || []
  const proof = proofs.find((p) =>
    p.url === file.url || (p.id === file.id) || (p.filename === file.name)
  )
  if (proof) {
    openProofViewer(proof)
  }
}

const handleDownload = (file: any) => {
  const link = document.createElement('a')
  link.href = file.url || file.thumbUrl
  link.download = file.name
  link.target = '_blank'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

// File operations
const downloadFile = (proof: Proof) => {
  // Generate filename from URL if not available
  const filename = proof.filename || proof.url?.split('/').pop()?.split('?')[0] || 'file'

  fetch(proof.url)
    .then(response => response.blob())
    .then(blob => {
      const url = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = filename
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      window.URL.revokeObjectURL(url)
    })
    .catch(error => {
      console.error('Error downloading file:', error)
      // Fallback to direct download if fetch fails
      const link = document.createElement('a')
      link.href = proof.url
      link.download = filename
      link.target = '_blank'
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
    })
}

const openImageInNewTab = (proof: Proof) => {
  window.open(proof.url, '_blank')
}
</script>

<style scoped>
.proof-grid-display {
  width: 100%;
}

.aspect-square {
  aspect-ratio: 1 / 1;
}
</style>