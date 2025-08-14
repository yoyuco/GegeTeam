// --- path: src/main.ts
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import { router } from './router'
import { useAuth } from '@/stores/auth'
import './style.css'

const app = createApp(App)
app.use(createPinia())
app.use(router)

useAuth().init()

app.mount('#app')
