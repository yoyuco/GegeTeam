<template>
  <div class="proof-grid-display">
    <!-- Use n-upload to display existing proofs in image-card format -->
    <n-upload
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

    <!-- Proof Viewer Modal -->
    <n-modal
      v-model:show="showViewer"
      :mask-closable="true"
      preset="card"
      :title="selectedProof?.filename"
      size="large"
      class="w-full max-w-6xl"
      @close="closeViewer"
    >
      <template #header-extra>
        <n-button
          size="small"
          quaternary
          @click="closeViewer"
        >
          <template #icon>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </template>
        </n-button>
      </template>

      <div class="flex justify-center items-center min-h-[400px]">
        <img
          v-if="selectedProof && isImageFile(selectedProof)"
          :src="selectedProof.url"
          :alt="selectedProof.filename"
          class="max-w-full max-h-[70vh] object-contain rounded-lg"
        />
        <div v-else-if="selectedProof" class="text-center">
          <div class="bg-gray-100 rounded-lg p-8">
            <svg class="w-16 h-16 mx-auto mb-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <p class="text-gray-600 mb-4">{{ selectedProof.filename }}</p>
            <n-button
              type="primary"
              @click="downloadFile(selectedProof)"
            >
              <template #icon>
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </template>
              Tải xuống
            </n-button>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="flex justify-between items-center text-sm text-gray-600">
          <div>
            <p v-if="selectedProof?.uploaded_at">
              Tải lên: {{ new Date(selectedProof.uploaded_at).toLocaleString('vi-VN') }}
            </p>
            <p v-if="selectedProof?.file_size">
              Kích thước: {{ formatFileSize(selectedProof.file_size) }}
            </p>
          </div>
          <div class="flex gap-2">
            <n-button
              v-if="selectedProof"
              size="small"
              @click="downloadFile(selectedProof)"
            >
              <template #icon>
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                </svg>
              </template>
              Tải xuống
            </n-button>
            <n-button
              v-if="selectedProof && isImageFile(selectedProof)"
              size="small"
              @click="openImageInNewTab(selectedProof)"
            >
              <template #icon>
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                </svg>
              </template>
              Mở tab mới
            </n-button>
          </div>
        </div>
      </template>
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

// Utility functions
const isImageFile = (proof: Proof): boolean => {
  if (!proof.filename) return false
  const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg']
  const extension = proof.filename.toLowerCase().split('.').pop()
  return imageExtensions.includes(`.${extension}`)
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
  showViewer.value = true
}

const closeViewer = () => {
  showViewer.value = false
  selectedProof.value = null
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
  const link = document.createElement('a')
  link.href = proof.url
  link.download = proof.filename
  link.target = '_blank'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
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