// --- path: src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '@/stores/auth'

const routes = [
  { path: '/login', component: () => import('@/pages/Login.vue') },
  { path: '/auth/callback', name: 'auth-callback', component: () => import('@/pages/AuthCallback.vue') },

  // Khu vực cần đăng nhập
  { path: '/', component: () => import('@/pages/Dashboard.vue'), meta: { requiresAuth: true } },
  { path: '/sales', component: () => import('@/pages/Sales.vue'), meta: { requiresAuth: true } },
  { path: '/orders', component: () => import('@/pages/Orders.vue'), meta: { requiresAuth: true } },

  // 🔥 Trang mới: chỉ hiển thị đơn hàng service (Boosting)
  { path: '/service-boosting', component: () => import('@/pages/ServiceBoosting.vue'), meta: { requiresAuth: true } },

  { path: '/customers', component: () => import('@/pages/Customers.vue'), meta: { requiresAuth: true } },
  { path: '/employees', component: () => import('@/pages/Employees.vue'), meta: { requiresAuth: true } },
  { path: '/tasks', component: () => import('@/pages/Tasks.vue'), meta: { requiresAuth: true } },
  { path: '/kpi', component: () => import('@/pages/KPI.vue'), meta: { requiresAuth: true } },

  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to) => {
  const auth = useAuth()

  // Nếu store chưa có session (refresh lần đầu), cố lấy từ supabase
  if (!auth.user && to.meta.requiresAuth) {
    const { supabase } = await import('@/lib/supabase')
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) {
      return { path: '/login', query: { redirect: to.fullPath } }
    }
    // có session thì cập nhật store
    auth.session = session
    auth.user = session.user
  }

  if (to.path === '/login' && auth.user) return '/'
})

export default router
