// path: src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '@/stores/auth'

const routes = [
  { path: '/login', component: () => import('@/pages/Login.vue') },
  {
    path: '/auth/callback',
    name: 'auth-callback',
    component: () => import('@/pages/AuthCallback.vue'),
  },
  {
    path: '/reset-password',
    name: 'reset-password',
    component: () => import('@/pages/ResetPassword.vue'),
  },
  { path: '/', component: () => import('@/pages/Dashboard.vue'), meta: { requiresAuth: true } },
  { path: '/sales', component: () => import('@/pages/Sales.vue'), meta: { requiresAuth: true } },
  {
    path: '/service-boosting',
    component: () => import('@/pages/ServiceBoosting.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/reports',
    component: () => import('@/pages/ReportManagement.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/employees',
    component: () => import('@/pages/Employees.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/role-management',
    name: 'role-management',
    component: () => import('../pages/RoleManagement.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/systemops',
    component: () => import('@/pages/SystemOps.vue'),
    meta: { requiresAuth: true },
  },
  { path: '/:pathMatch(.*)*', redirect: '/' },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// Navigation Guard SIÊU ĐƠN GIẢN VÀ VỮNG CHẮC
router.beforeEach((to) => {
  const auth = useAuth()

  // Do main.ts đã `await auth.init()`, ở đây chúng ta có thể tin tưởng 100% vào trạng thái của store
  const isAuthenticated = auth.isAuthenticated
  const requiresAuth = to.meta.requiresAuth

  if (requiresAuth && !isAuthenticated) {
    // Nếu route yêu cầu đăng nhập mà người dùng chưa đăng nhập -> về trang login
    return { path: '/login', query: { redirect: to.fullPath } }
  }

  if (to.path === '/login' && isAuthenticated) {
    // Nếu người dùng đã đăng nhập mà vào trang login -> về trang chủ
    return '/'
  }

  // Mọi trường hợp khác, cho phép điều hướng
})

// Add currency routes
router.addRoute({
  path: '/currency/create-orders',
  name: 'currency-create-orders',
  component: () => import('@/pages/CurrencyCreateOrders.vue'),
  meta: { requiresAuth: true },
})

router.addRoute({
  path: '/currency/ops',
  name: 'currency-ops',
  component: () => import('@/pages/CurrencyOps.vue'),
  meta: { requiresAuth: true },
})

export default router
