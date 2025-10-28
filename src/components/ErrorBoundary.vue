<!-- path: src/components/ErrorBoundary.vue -->
<template>
  <div v-if="error" class="error-boundary">
    <div class="error-content">
      <div class="error-icon">
        <svg
          width="64"
          height="64"
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M12 9V13M12 17H12.01M22 12C22 17.5228 17.5228 22 12 22C6.47715 22 2 17.5228 2 12C2 6.47715 6.47715 2 12 2C17.5228 2 22 6.47715 22 12Z"
            stroke="#EF4444"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </div>

      <h2 class="error-title">Đã có lỗi xảy ra</h2>

      <p class="error-message">
        {{ userFriendlyMessage }}
      </p>

      <details v-if="showDetails && errorDetails" class="error-details">
        <summary>Chi tiết kỹ thuật</summary>
        <pre>{{ errorDetails }}</pre>
      </details>

      <div class="error-actions">
        <button class="btn btn-primary" @click="retry">Thử lại</button>
        <button class="btn btn-secondary" @click="goHome">Về trang chủ</button>
        <button v-if="!showDetails" class="btn btn-outline" @click="showDetails = true">
          Hiển thị chi tiết
        </button>
      </div>
    </div>
  </div>
  <slot v-else />
</template>

<script setup lang="ts">
import { ref, computed, onErrorCaptured, nextTick, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'

interface ErrorBoundaryProps {
  fallbackMessage?: string
  showErrorDetails?: boolean
}

const props = withDefaults(defineProps<ErrorBoundaryProps>(), {
  fallbackMessage: 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.',
  showErrorDetails: false,
})

const router = useRouter()
const error = ref<Error | null>(null)
const errorInfo = ref<unknown>(null)
const showDetails = ref(props.showErrorDetails)

const userFriendlyMessage = computed(() => {
  if (!error.value) return ''

  // Common error patterns and user-friendly messages
  const message = error.value.message.toLowerCase()

  if (message.includes('network') || message.includes('fetch')) {
    return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.'
  }

  if (message.includes('permission') || message.includes('unauthorized')) {
    return 'Bạn không có quyền truy cập tính năng này. Vui lòng đăng nhập lại.'
  }

  if (message.includes('not found')) {
    return 'Không tìm thấy trang bạn yêu cầu.'
  }

  if (message.includes('validation')) {
    return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin đã nhập.'
  }

  return props.fallbackMessage
})

const errorDetails = computed(() => {
  if (!error.value) return ''

  return `Error: ${error.value.message}\n\nStack:\n${error.value.stack}`
})

const retry = async () => {
  error.value = null
  errorInfo.value = null
  showDetails.value = props.showErrorDetails

  await nextTick()

  // Try to reload the current route
  if (router.currentRoute.value.path !== '/') {
    await router.replace({
      path: '/reload',
      query: { redirect: router.currentRoute.value.fullPath },
    })
    await nextTick()
    await router.replace((router.currentRoute.value.query.redirect as string) || '/')
  } else {
    window.location.reload()
  }
}

const goHome = () => {
  error.value = null
  router.push('/')
}

// Error lifecycle
onErrorCaptured((err: Error, instance, info) => {
  console.error('ErrorBoundary caught error:', err)
  console.error('Component instance:', instance)
  console.error('Error info:', info)

  error.value = err
  errorInfo.value = { instance, info }

  // Log error to monitoring service (if available)
  if (window.$errorLogger) {
    window.$errorLogger.log(err, {
      component: 'ErrorBoundary',
      errorInfo: info,
      route: router.currentRoute.value.fullPath,
    })
  }

  // Prevent error from propagating
  return false
})

// Handle unhandled promise rejections
const handleUnhandledRejection = (event: PromiseRejectionEvent) => {
  console.error('Unhandled promise rejection:', event.reason)

  if (window.$errorLogger) {
    window.$errorLogger.log(event.reason, {
      type: 'unhandledRejection',
      route: router.currentRoute.value.fullPath,
    })
  }

  event.preventDefault()
}

// Handle global errors
const handleGlobalError = (event: ErrorEvent) => {
  console.error('Global error:', event.error)

  if (window.$errorLogger) {
    window.$errorLogger.log(event.error, {
      type: 'globalError',
      filename: event.filename,
      lineno: event.lineno,
      colno: event.colno,
      route: router.currentRoute.value.fullPath,
    })
  }
}

// Setup global error handlers
if (typeof window !== 'undefined') {
  window.addEventListener('unhandledrejection', handleUnhandledRejection, { passive: true })
  window.addEventListener('error', handleGlobalError, { passive: true })
}

// Cleanup on unmount
onUnmounted(() => {
  if (typeof window !== 'undefined') {
    window.removeEventListener('unhandledrejection', handleUnhandledRejection)
    window.removeEventListener('error', handleGlobalError)
  }
})
</script>

<style scoped>
.error-boundary {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  padding: 2rem;
}

.error-content {
  max-width: 500px;
  text-align: center;
  background: white;
  padding: 2rem;
  border-radius: 0.5rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  border: 1px solid #e5e7eb;
}

.error-icon {
  margin-bottom: 1rem;
}

.error-title {
  color: #dc2626;
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 1rem;
}

.error-message {
  color: #6b7280;
  margin-bottom: 1.5rem;
  line-height: 1.5;
}

.error-details {
  text-align: left;
  margin: 1rem 0;
  padding: 1rem;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 0.25rem;
}

.error-details summary {
  cursor: pointer;
  font-weight: 500;
  margin-bottom: 0.5rem;
}

.error-details pre {
  white-space: pre-wrap;
  word-break: break-word;
  font-size: 0.875rem;
  color: #4b5563;
  margin: 0;
}

.error-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: center;
  flex-wrap: wrap;
}

.btn {
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid transparent;
}

.btn-primary {
  background-color: #3b82f6;
  color: white;
}

.btn-primary:hover {
  background-color: #2563eb;
}

.btn-secondary {
  background-color: #6b7280;
  color: white;
}

.btn-secondary:hover {
  background-color: #4b5563;
}

.btn-outline {
  background-color: transparent;
  color: #6b7280;
  border-color: #d1d5db;
}

.btn-outline:hover {
  background-color: #f9fafb;
}
</style>
