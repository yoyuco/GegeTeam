// --- path: src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '@/pages/Dashboard.vue'
import { useAuth } from '@/stores/auth'

const routes = [
  { path: '/login', component: () => import('@/pages/Login.vue') },
  { path: '/', component: Dashboard, meta: { requiresAuth: true } },
  { path: '/orders', component: () => import('@/pages/Orders.vue'), meta: { requiresAuth: true } },
  { path: '/tasks', component: () => import('@/pages/Tasks.vue'), meta: { requiresAuth: true } },
  { path: '/kpi', component: () => import('@/pages/KPI.vue'), meta: { requiresAuth: true } },
]

export const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  const auth = useAuth()
  if (to.meta.requiresAuth && !auth.user) return '/login'
})
