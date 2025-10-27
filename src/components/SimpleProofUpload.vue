<template>
  <div class="proof-upload-section">
    <label v-if="label" class="block text-sm font-medium text-gray-700 mb-2">{{ label }}</label>
    <n-upload
      v-model:file-list="uploadFileList"
      :max="maxFiles"
      multiple
      list-type="image-card"
      :default-upload="false"
      :custom-request="() => {}"
      :on-remove="handleFileRemove"
      :on-change="handleFileChange"
      :show-file-list="true"
      accept="image/*"
      class="w-full"
    />

    <!-- Upload Status -->
    <div
      v-if="uploadStatus.uploading"
      class="mt-4 p-4 bg-blue-50 rounded-lg border border-blue-200"
    >
      <div class="flex items-center gap-3">
        <div class="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center">
          <div
            class="w-3 h-3 border-2 border-blue-600 border-t-transparent rounded-full animate-spin"
          ></div>
        </div>
        <div>
          <p class="text-sm font-medium text-blue-900">Đang upload...</p>
          <p class="text-xs text-blue-700">{{ uploadStatus.message }}</p>
        </div>
      </div>
    </div>

    <!-- Success Message -->
    <div
      v-if="uploadStatus.success"
      class="mt-4 p-4 bg-green-50 rounded-lg border border-green-200"
    >
      <div class="flex items-center gap-3">
        <div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center">
          <svg class="w-3 h-3 text-green-600" fill="currentColor" viewBox="0 0 20 20">
            <path
              fill-rule="evenodd"
              d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
              clip-rule="evenodd"
            />
          </svg>
        </div>
        <div>
          <p class="text-sm font-medium text-green-900">Upload thành công!</p>
          <p class="text-xs text-green-700">{{ uploadStatus.message }}</p>
        </div>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="uploadStatus.error" class="mt-4 p-4 bg-red-50 rounded-lg border border-red-200">
      <div class="flex items-center gap-3">
        <div class="w-6 h-6 bg-red-100 rounded-full flex items-center justify-center">
          <svg class="w-3 h-3 text-red-600" fill="currentColor" viewBox="0 0 20 20">
            <path
              fill-rule="evenodd"
              d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
              clip-rule="evenodd"
            />
          </svg>
        </div>
        <div>
          <p class="text-sm font-medium text-red-900">Upload thất bại</p>
          <p class="text-xs text-red-700">{{ uploadStatus.message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { NUpload, useMessage, type UploadFileInfo, type UploadCustomRequestOptions } from 'naive-ui'
import { uploadFile } from '@/utils/supabase.js'

interface FileInfo {
  id: string
  file?: File
  name: string
  url?: string
  path?: string
  status: 'pending' | 'uploading' | 'finished' | 'error'
  error?: string
}

interface Props {
  label?: string
  maxFiles?: number
  modelValue?: FileInfo[]
  uploadPath?: string
  bucket?: string
}

const props = withDefaults(defineProps<Props>(), {
  label: '',
  maxFiles: 10,
  modelValue: () => [],
  uploadPath: 'exchange-proofs',
  bucket: 'work-proofs',
})

const emit = defineEmits(['update:modelValue', 'upload-complete'])

// Debug: Log when component is mounted
console.log('🔍 SimpleProofUpload: Component mounted with props:', {
  uploadPath: props.uploadPath,
  bucket: props.bucket,
  maxFiles: props.maxFiles
})

const message = useMessage()

const fileList = ref<FileInfo[]>([...props.modelValue])
const uploadStatus = ref({
  uploading: false,
  success: false,
  error: false,
  message: '',
})

// Convert to NUpload format with writable computed for v-model
const uploadFileList = computed({
  get() {
    return fileList.value.map(
      (file) =>
        ({
          id: file.id,
          name: file.name,
          status: file.status as 'pending' | 'uploading' | 'finished' | 'error',
          url: file.url,
          file: file.file,
        }) as UploadFileInfo
    )
  },
  set(newValue: UploadFileInfo[]) {
    // Convert NUpload format back to FileInfo format
    fileList.value = newValue.map(
      (item) =>
        ({
          id: item.id || generateId(),
          name: item.name,
          status: item.status || 'pending',
          url: item.url,
          file: item.file,
        }) as FileInfo
    )
    // Emit update to parent
    emit('update:modelValue', [...fileList.value])
  }
})

// Helper function to generate unique ID
const generateId = () => {
  return `file_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
}

// Watch for external changes
watch(
  () => props.modelValue,
  (newValue) => {
    fileList.value = [...newValue]
  },
  { deep: true }
)

// Watch for internal changes and emit
watch(
  fileList,
  (newValue) => {
    emit('update:modelValue', newValue)
  },
  { deep: true }
)

const handleCustomUpload = async (options: UploadCustomRequestOptions) => {
  console.log('🔍 SimpleProofUpload: handleCustomUpload called with:', options.file?.name)
  const { file, onProgress, onError, onFinish } = options

  // Use the file ID from n-upload to avoid "no corresponding id" error
  const fileId = (file as any).id || `file-${Date.now()}-${Math.random().toString(36).substring(2, 8)}`

  // Update existing file status to uploading
  const existingFileIndex = fileList.value.findIndex((f) => f.id === fileId || f.name === file.name)
  if (existingFileIndex >= 0) {
    fileList.value[existingFileIndex].status = 'uploading'
  }

  try {
    // Reset global status
    uploadStatus.value = {
      uploading: true,
      success: false,
      error: false,
      message: `Đang upload ${file.name}...`,
    }

    // Validate file
    if (!file.file || !validateFile(file.file as File)) {
      throw new Error('File không hợp lệ')
    }

    const actualFile = file.file as File

    // Create unique filename with timestamp
    const timestamp = Date.now()
    const randomString = Math.random().toString(36).substring(2, 8)
    const filename = `${timestamp}-${randomString}-${actualFile.name}`
    const filePath = `${props.uploadPath}/${filename}`

    // Simulate progress for better UX
    let progress = 0
    const progressInterval = setInterval(() => {
      progress += Math.random() * 15
      if (progress <= 85) {
        onProgress({ percent: progress })
      } else {
        clearInterval(progressInterval)
      }
    }, 200)

    // Upload file to Supabase Storage
    const uploadResult = await uploadFile(actualFile, filePath, props.bucket)

    // Clean up progress interval
    clearInterval(progressInterval)
    onProgress({ percent: 100 })

    if (uploadResult.success) {
      // Update file info with successful upload
      const successFileInfo: FileInfo = {
        id: fileId,
        file: actualFile,
        name: actualFile.name,
        url: uploadResult.publicUrl,
        path: uploadResult.path,
        status: 'finished',
      }

      // Update file list
      const fileIndex = fileList.value.findIndex((f) => f.id === fileId)
      if (fileIndex >= 0) {
        fileList.value[fileIndex] = successFileInfo
      }

      // Update global status
      uploadStatus.value = {
        uploading: false,
        success: true,
        error: false,
        message: `${actualFile.name} đã được upload thành công`,
      }

      message.success(`${actualFile.name} upload thành công!`)

      // Call onFinish to let n-upload know the file is processed
      if (onFinish) {
        onFinish()
      }

      // Emit upload completion for parent components
      const uploadedData = [
        {
          url: uploadResult.publicUrl,
          name: actualFile.name,
          path: uploadResult.path,
        },
      ]
      console.log('🔍 SimpleProofUpload: About to emit upload-complete with:', uploadedData)
      emit('upload-complete', uploadedData)

      // Clear success status after 3 seconds
      setTimeout(() => {
        uploadStatus.value = {
          uploading: false,
          success: false,
          error: false,
          message: '',
        }
      }, 3000)
    } else {
      throw new Error(uploadResult.error || 'Upload thất bại')
    }
  } catch (error) {
    console.error('🔍 SimpleProofUpload: Upload error:', error)

    // Update file status to error
    const errorFileInfo: FileInfo = {
      id: fileId,
      name: file.name,
      status: 'error',
      error: error instanceof Error ? error.message : 'Upload thất bại',
    }

    const fileIndex = fileList.value.findIndex((f) => f.id === fileId)
    if (fileIndex >= 0) {
      fileList.value[fileIndex] = errorFileInfo
    }

    // Update global status
    uploadStatus.value = {
      uploading: false,
      success: false,
      error: true,
      message: error instanceof Error ? error.message : 'Upload thất bại',
    }

    if (onError) {
      onError()
    }
    message.error(
      `Upload thất bại: ${error instanceof Error ? error.message : 'Lỗi không xác định'}`
    )

    // Clear error status after 5 seconds
    setTimeout(() => {
      uploadStatus.value = {
        uploading: false,
        success: false,
        error: false,
        message: '',
      }
    }, 5000)
  }
}

const handleFileChange = (options: any) => {
  console.log('🔍 SimpleProofUpload: handleFileChange called with:', options.file?.name)
  // This might trigger the upload
}

const handleUploadFinish = () => {
  // This is called when n-upload considers the upload finished
  // We handle the actual upload in handleCustomUpload
}

const handleFileRemove = ({ file }: { file: UploadFileInfo }) => {
  // File is automatically removed from fileList by n-upload
  message.info(`Đã xóa ${file.name}`)
}

const validateFile = (file: File): boolean => {
  // Check file type
  const validTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
    'video/mp4',
    'video/webm',
  ]
  if (!validTypes.includes(file.type)) {
    message.error(`Chỉ hỗ trợ hình ảnh (JPG, PNG, WebP, GIF) và video (MP4, WebM)`)
    return false
  }

  // Check file size (max 10MB)
  const maxSize = 10 * 1024 * 1024 // 10MB
  if (file.size > maxSize) {
    message.error(`File quá lớn. Tối đa 10MB`)
    return false
  }

  return true
}

// Expose method to upload files on demand
const uploadFiles = async () => {
  console.log('🔍 SimpleProofUpload: Starting upload of', fileList.value.length, 'files')

  if (fileList.value.length === 0) {
    return []
  }

  const uploadResults = []

  for (const fileInfo of fileList.value) {
    if (fileInfo.status === 'finished') {
      // Already uploaded
      uploadResults.push({
        url: fileInfo.url,
        name: fileInfo.name,
        path: fileInfo.path,
      })
      continue
    }

    if (fileInfo.file) {
      try {
        uploadStatus.value = {
          uploading: true,
          success: false,
          error: false,
          message: `Đang upload ${fileInfo.name}...`,
        }

        // Create unique filename
        const timestamp = Date.now()
        const randomString = Math.random().toString(36).substring(2, 8)
        const filename = `${timestamp}-${randomString}-${fileInfo.file.name}`
        const filePath = `${props.uploadPath}/${filename}`

        // Upload to Supabase
        const uploadResult = await uploadFile(fileInfo.file, filePath, props.bucket)

        if (uploadResult.success) {
          // Update file info
          fileInfo.status = 'finished'
          fileInfo.url = uploadResult.publicUrl
          fileInfo.path = uploadResult.path

          uploadResults.push({
            url: uploadResult.publicUrl,
            name: fileInfo.name,
            path: uploadResult.path,
          })

          message.success(`${fileInfo.name} upload thành công!`)
        } else {
          throw new Error(uploadResult.error)
        }
      } catch (error) {
        console.error('Upload error:', error)
        fileInfo.status = 'error'
        message.error(`Upload thất bại: ${error instanceof Error ? error.message : 'Lỗi không xác định'}`)
      }
    }
  }

  uploadStatus.value = {
    uploading: false,
    success: uploadResults.length > 0,
    error: uploadResults.length === 0,
    message: uploadResults.length > 0 ?
      `Đã upload thành công ${uploadResults.length} file` :
      'Upload thất bại',
  }

  if (uploadResults.length > 0) {
    emit('upload-complete', uploadResults)
  }

  return uploadResults
}

// Expose method to parent
defineExpose({
  uploadFiles
})
</script>

<style scoped>
.proof-upload-section {
  width: 100%;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
