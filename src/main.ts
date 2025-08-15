// path: src/main.ts
import './style.css'            // <-- QUAN TRỌNG: nạp Tailwind v4

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { useAuth } from '@/stores/auth'

const app = createApp(App)
const pinia = createPinia()
app.use(pinia)
app.use(router)

// khôi phục session
useAuth().init()

app.mount('#app')
