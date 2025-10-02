// path: src/main.ts
import './style.css'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { useAuth } from './stores/auth'

async function startApp() {
  const app = createApp(App)
  const pinia = createPinia()
  app.use(pinia)

  // === THAY ĐỔI CỐT LÕI ===
  // 1. Khởi tạo auth store
  const auth = useAuth(pinia)

  // 2. Chạy và ĐỢI cho auth.init() hoàn thành
  await auth.init()

  // 3. SAU KHI auth đã sẵn sàng, mới sử dụng router
  app.use(router)

  // 4. Mount ứng dụng
  app.mount('#app')
}

// Bắt đầu ứng dụng
startApp().catch((error) => {
  console.error('Failed to start application:', error)
  // Hiển thị lỗi cho user
  document.body.innerHTML = `
    <div style="display: flex; align-items: center; justify-content: center; height: 100vh; font-family: sans-serif;">
      <div style="text-align: center;">
        <h1 style="color: #e53e3e;">Lỗi khởi động ứng dụng</h1>
        <p style="color: #4a5568;">Vui lòng tải lại trang hoặc liên hệ hỗ trợ.</p>
        <button onclick="location.reload()" style="margin-top: 1rem; padding: 0.5rem 1rem; background: #3182ce; color: white; border: none; border-radius: 0.25rem; cursor: pointer;">
          Tải lại trang
        </button>
      </div>
    </div>
  `
})
