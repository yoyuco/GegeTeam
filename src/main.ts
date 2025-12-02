// path: src/main.ts
import './style.css'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { useAuth } from './stores/auth'
import { errorLogger } from './utils/errorLogger'

// Suppress annoying browser warnings in development
if (import.meta.env.DEV) {
  const originalConsoleWarn = console.warn
  const originalConsoleError = console.error

  // Filter console.warn
  console.warn = (...args: any[]) => {
    const message = args[0]
    if (
      typeof message === 'string' && (
        message.includes('Added non-passive event listener') ||
        message.includes('wheel event') ||
        message.includes('passive') ||
        message.includes('chrome-status')
      )
    ) {
      return // Suppress these specific warnings
    }
    originalConsoleWarn.apply(console, args)
  }

  // Filter console.error (for violations)
  console.error = (...args: any[]) => {
    const message = args[0]
    if (
      typeof message === 'string' && (
        message.includes('[Violation]') ||
        message.includes('Added non-passive event listener to a scroll-blocking') ||
        message.includes('wheel event')
      )
    ) {
      return // Suppress violation errors
    }
    originalConsoleError.apply(console, args)
  }
}

async function startApp() {
  try {
    const app = createApp(App)
    const pinia = createPinia()

    // Global error handler for Vue app
    app.config.errorHandler = (err, instance, info) => {
      errorLogger.log(err as Error, {
        component: 'Vue Global Error Handler',
        errorInfo: info,
        route: router.currentRoute.value.fullPath,
      })
    }

    // Global warning handler
    app.config.warnHandler = (msg, instance, trace) => {
      errorLogger.logWarning(msg, {
        component: 'Vue Global Warning Handler',
        trace,
        route: router.currentRoute.value.fullPath,
      })
    }

    app.use(pinia)

    // === THAY ĐỔI CỐT LÕI ===
    // 1. Khởi tạo auth store
    const auth = useAuth(pinia)

    // 2. Chạy và ĐỢI cho auth.init() hoàn thành
    await auth.init()

    // 3. SAU KHI auth đã sẵn sàng, mới sử dụng router
    app.use(router)

    // 4. Mount ứng dụng với ErrorBoundary
    app.mount('#app')

    // Commented out to reduce console noise in development
    // errorLogger.logInfo('Application started successfully', {
    //   route: router.currentRoute.value.fullPath,
    //   userAgent: navigator.userAgent,
    // })
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred'
    errorLogger.log(error instanceof Error ? error : new Error(errorMessage), {
      component: 'Application Startup',
      phase: 'initialization',
    })

    showFatalError(errorMessage)
  }
}

function showFatalError(message: string) {
  const errorId = Math.random().toString(36).substr(2, 9)

  // Log error ID for debugging
  console.error(`Fatal Error [${errorId}]:`, message)

  // Show user-friendly error page
  document.body.innerHTML = `
    <div style="display: flex; align-items: center; justify-content: center; min-height: 100vh; font-family: system-ui, -apple-system, sans-serif; background: #f8fafc;">
      <div style="text-align: center; max-width: 500px; padding: 2rem; background: white; border-radius: 0.5rem; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);">
        <div style="margin-bottom: 1.5rem;">
          <svg width="64" height="64" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 9V13M12 17H12.01M22 12C22 17.5228 17.5228 22 12 22C6.47715 22 2 17.5228 2 12C2 6.47715 6.47715 2 12 2C17.5228 2 22 6.47715 22 12Z" stroke="#EF4444" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>

        <h1 style="color: #dc2626; font-size: 1.5rem; font-weight: 600; margin-bottom: 1rem;">
          Lỗi khởi động ứng dụng
        </h1>

        <p style="color: #6b7280; margin-bottom: 1.5rem; line-height: 1.5;">
          Không thể khởi động ứng dụng. Vui lòng thử lại hoặc liên hệ hỗ trợ.
        </p>

        <div style="margin-bottom: 1.5rem;">
          <details style="text-align: left; background: #f9fafb; padding: 1rem; border-radius: 0.25rem; border: 1px solid #e5e7eb;">
            <summary style="cursor: pointer; font-weight: 500; color: #374151;">Chi tiết lỗi</summary>
            <div style="margin-top: 0.5rem; font-size: 0.875rem; color: #6b7280;">
              <p><strong>Mã lỗi:</strong> ${errorId}</p>
              <p><strong>Thời gian:</strong> ${new Date().toLocaleString('vi-VN')}</p>
              <p><strong>Thông báo:</strong> ${message}</p>
            </div>
          </details>
        </div>

        <div style="display: flex; gap: 0.75rem; justify-content: center; flex-wrap: wrap;">
          <button onclick="location.reload()" style="padding: 0.5rem 1rem; background: #3b82f6; color: white; border: none; border-radius: 0.375rem; font-weight: 500; cursor: pointer;">
            Thử lại
          </button>
          <button onclick="window.location.href='/'" style="padding: 0.5rem 1rem; background: #6b7280; color: white; border: none; border-radius: 0.375rem; font-weight: 500; cursor: pointer;">
            Về trang chủ
          </button>
          <button onclick="navigator.clipboard.writeText('${errorId}')" style="padding: 0.5rem 1rem; background: transparent; color: #6b7280; border: 1px solid #d1d5db; border-radius: 0.375rem; font-weight: 500; cursor: pointer;">
            Sao chép mã lỗi
          </button>
        </div>
      </div>
    </div>
  `
}

// Setup global error handlers before starting app
if (typeof window !== 'undefined') {
  // Handle unhandled promise rejections
  window.addEventListener('unhandledrejection', (event) => {
    // Completely suppress ResizeObserver errors since they're non-critical browser warnings
    if (event.reason && event.reason.message &&
        event.reason.message.includes('ResizeObserver loop completed with undelivered notifications')) {
      // Silently ignore ResizeObserver errors - they don't affect functionality
      // Only log for debugging in development mode, but not in production
      if (process.env.NODE_ENV === 'development') {
        console.debug('ResizeObserver loop suppressed (non-critical)', {
          reason: event.reason.message,
          phase: 'pre-startup'
        })
      }
    } else {
      errorLogger.log(event.reason, {
        type: 'unhandledRejection',
        phase: 'pre-startup',
      })
    }

    // Prevent default browser behavior
    event.preventDefault()
  }, { passive: true })

  // Handle global errors
  window.addEventListener('error', (event) => {
    // Completely suppress ResizeObserver errors since they're non-critical browser warnings
    if (event.message && event.message.includes('ResizeObserver loop completed with undelivered notifications')) {
      return // Silently ignore ResizeObserver errors
    } else {
      errorLogger.log(event.error || new Error(event.message), {
        type: 'globalError',
        filename: event.filename,
        lineno: event.lineno,
        colno: event.colno,
        phase: 'pre-startup',
      })
    }
  }, { passive: true })
}

// Bắt đầu ứng dụng
startApp()
