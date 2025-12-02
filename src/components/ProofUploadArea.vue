<template>
  <div class="proof-upload-area">
    <!-- Upload Area -->
    <div
      class="upload-zone"
      :class="{ dragover: isDragOver }"
      @drop="handleDrop"
      @dragover.prevent
      @dragenter.prevent
      @dragleave.prevent
      @click="triggerFileInput"
    >
      <input
        ref="fileInput"
        type="file"
        multiple
        accept="image/*,video/*"
        class="hidden"
        @change="handleFileSelect"
      />

      <div v-if="!files.length" class="upload-placeholder">
        <svg class="upload-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
          />
        </svg>
        <p class="text-lg font-medium text-gray-600">Kéo và thả files vào đây</p>
        <p class="text-sm text-gray-400">hoặc click để chọn files</p>
        <p class="text-xs text-gray-400 mt-1">Hỗ trợ: JPG, PNG, GIF, MP4, WebM</p>
      </div>

      <div v-else class="uploaded-files">
        <div v-for="(file, index) in files" :key="file.url" class="file-item">
          <!-- File preview -->
          <div class="file-preview">
            <img
              v-if="file.type === 'image'"
              :src="file.url"
              :alt="file.name"
              class="preview-image"
              @error="handleImageError"
            />
            <video
              v-else-if="file.type === 'video'"
              :src="file.url"
              class="preview-video"
              controls
            />
            <div v-else class="preview-placeholder">
              <svg class="file-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2 2v5a2 2 0 002 2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.707.293H19a2 2 0 002-2v-5a2 2 0 00-2-2H9z"
                />
              </svg>
            </div>
          </div>

          <!-- File info -->
          <div class="file-info flex-1">
            <p class="file-name">{{ file.name }}</p>
            <p class="file-meta">
              <span class="file-type">{{ file.type.toUpperCase() }}</span>
              <span class="file-size">{{ formatFileSize(file.size) }}</span>
              <span class="file-date">{{ formatDate(file.uploaded_at) }}</span>
            </p>
          </div>

          <!-- Actions -->
          <div class="file-actions">
            <button class="btn-preview" title="Preview" @click="previewFile(file)">
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                />
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.065 7-9.542 7S2.458 16.057 1.274 12z"
                />
              </svg>
            </button>

            <button class="btn-download" title="Download" @click="downloadFile(file)">
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l4 4m0 0l-4 4m4-4v-4"
                />
              </svg>
            </button>

            <button class="btn-remove" title="Remove" @click="removeFile(index)">
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-2-1.998L5 7m5 4v6m0 0v6m0-6h6m-6 0h6"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Upload Progress -->
    <div v-if="uploading" class="upload-progress">
      <div class="progress-bar">
        <div class="progress-fill" :style="{ width: uploadProgress + '%' }"></div>
      </div>
      <p class="text-sm text-gray-600 mt-1">Đang upload... {{ uploadProgress }}%</p>
    </div>

    <!-- File Preview Modal -->
    <div v-if="previewModal.show" class="modal-overlay" @click="closePreviewModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>{{ previewModal.file.name }}</h3>
          <button class="btn-close" @click="closePreviewModal">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>
        <div class="modal-body">
          <img
            v-if="previewModal.file.type === 'image'"
            :src="previewModal.file.url"
            :alt="previewModal.file.name"
            class="modal-image"
          />
          <video
            v-else-if="previewModal.file.type === 'video'"
            :src="previewModal.file.url"
            controls
            autoplay
            class="modal-video"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  stage: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
  },
  files: {
    type: Array,
    default: () => [],
  },
})

const emit = defineEmits(['upload', 'remove'])

const fileInput = ref(null)
const isDragOver = ref(false)
const uploading = ref(false)
const uploadProgress = ref(0)
const previewModal = ref({
  show: false,
  file: null,
})

// Methods
const triggerFileInput = () => {
  fileInput.value.click()
}

const handleFileSelect = (event) => {
  const files = Array.from(event.target.files)
  handleFiles(files)
}

const handleDrop = (event) => {
  event.preventDefault()
  isDragOver.value = false

  const files = Array.from(event.dataTransfer.files)
  handleFiles(files)
}

const handleFiles = async (files) => {
  if (!files.length) return

  uploading.value = true
  uploadProgress.value = 0

  try {
    // Simulate progress
    const progressInterval = setInterval(() => {
      uploadProgress.value = Math.min(uploadProgress.value + 10, 90)
    }, 100)

    // Emit upload event to parent
    await new Promise((resolve) => {
      emit('upload', {
        stage: props.stage,
        category: props.category,
        files,
        description: '',
      })
      resolve()
    })

    clearInterval(progressInterval)
    uploadProgress.value = 100

    // Reset after a short delay
    setTimeout(() => {
      uploading.value = false
      uploadProgress.value = 0
      if (fileInput.value) {
        fileInput.value.value = ''
      }
    }, 500)
  } catch (error) {
    console.error('Upload failed:', error)
    uploading.value = false
    uploadProgress.value = 0
  }
}

const removeFile = (index) => {
  emit('remove', {
    stage: props.stage,
    category: props.category,
    index,
  })
}

const previewFile = (file) => {
  previewModal.value = {
    show: true,
    file,
  }
}

const closePreviewModal = () => {
  previewModal.value = {
    show: false,
    file: null,
  }
}

const downloadFile = (file) => {
  const link = document.createElement('a')
  link.href = file.url
  link.download = file.name
  link.target = '_blank'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

const handleImageError = (event) => {
  event.target.src = '/placeholder-image.png'
}

// Utility functions
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}
</script>

<!-- <style scoped>
/* Styles temporarily commented out for debugging */
</style> -->
