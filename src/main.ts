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
startApp()
