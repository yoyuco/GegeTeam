<template>
  <ErrorBoundary>
    <n-config-provider>
      <n-dialog-provider>
        <n-message-provider>
          <div class="min-h-screen flex bg-neutral-100/50 text-neutral-900">
            <aside class="sidebar-fixed">
              <div class="flex items-center gap-3 mb-6 px-2">
                <img src="@/assets/gege_icon.png" alt="Gege Team Logo" class="h-8 w-8" />
                <span class="text-lg font-bold text-neutral-800">Gege Team</span>
              </div>

              <nav class="flex flex-col space-y-2">
                <RouterLink v-if="auth.hasPermission('orders:view_all')" to="/" class="menu-item">
                  <n-icon><HomeIcon /></n-icon><span>Dashboard</span>
                </RouterLink>
                <RouterLink
                  v-if="permissions.hasPermissionForCurrency('currency:create_orders')"
                  to="/currency/create-orders"
                  class="menu-item"
                >
                  <n-icon><CashIcon /></n-icon><span>Mua Bán Currency</span>
                </RouterLink>
                <RouterLink
                  v-if="
                    permissions.hasPermissionForCurrency('currency:view_orders') ||
                    permissions.hasPermissionForCurrency('currency:exchange_orders') ||
                    permissions.hasPermissionForCurrency('currency:view_inventory')
                  "
                  to="/currency/ops"
                  class="menu-item"
                >
                  <n-icon><BarChartOutline /></n-icon><span>Vận hành Currency</span>
                </RouterLink>
                <RouterLink
                  v-if="
                    auth.hasPermission('orders:create', {
                      game_code: 'DIABLO_4',
                      business_area_code: 'SERVICE',
                    })
                  "
                  to="/sales"
                  class="menu-item"
                >
                  <n-icon><CashIcon /></n-icon><span>Bán hàng Boosting</span>
                </RouterLink>
                <RouterLink
                  v-if="
                    auth.hasPermission('orders:view_all', {
                      game_code: 'DIABLO_4',
                      business_area_code: 'SERVICE',
                    })
                  "
                  to="/service-boosting"
                  class="menu-item"
                >
                  <n-icon><RocketIcon /></n-icon><span>Service – Boosting</span>
                </RouterLink>
                <RouterLink
                  v-if="
                    auth.hasPermission('admin:manage_roles') ||
                    auth.hasPermission('shift:manage') ||
                    auth.hasPermission('account:manage')
                  "
                  to="/manager"
                  class="menu-item"
                >
                  <n-icon><SettingsIcon /></n-icon><span>Quản lý Tổ chức</span>
                </RouterLink>
                <RouterLink
                  v-if="auth.hasPermission('reports:view')"
                  to="/reports"
                  class="menu-item"
                >
                  <n-icon><ArchiveIcon /></n-icon><span>Quản lý Báo cáo</span>
                </RouterLink>
                <RouterLink
                  v-if="auth.hasPermission('system:view_audit_logs')"
                  to="/systemops"
                  class="menu-item"
                >
                  <n-icon><AnalyticsIcon /></n-icon><span>Thao tác hệ thống</span>
                </RouterLink>
              </nav>

              <div v-if="auth.user" class="mt-auto pt-4 border-t border-neutral-200/80">
                <div class="text-sm font-medium mb-2">
                  {{
                    auth.profile?.display_name ||
                    auth.user?.user_metadata?.display_name ||
                    auth.user?.email
                  }}
                </div>

                <div class="space-y-1 mb-4">
                  <div
                    v-for="(asg, i) in auth.assignments"
                    :key="i"
                    class="flex items-center gap-1.5"
                  >
                    <n-icon
                      :component="roleDisplay[asg.role_code]?.icon"
                      :color="roleDisplay[asg.role_code]?.color"
                      :title="asg.role_name"
                    />
                    <span
                      class="text-xs font-semibold"
                      :style="{ color: roleDisplay[asg.role_code]?.color }"
                    >
                      {{ asg.role_name }}
                    </span>
                    <span
                      v-if="asg.game_name || asg.business_area_name"
                      class="text-xs text-neutral-500"
                    >
                      ({{ [asg.game_name, asg.business_area_name].filter(Boolean).join('/') }})
                    </span>
                  </div>
                </div>

                <button
                  class="flex items-center gap-2 text-red-600 hover:underline text-sm"
                  @click="logout"
                >
                  <n-icon><LogoutIcon /></n-icon><span>Đăng xuất</span>
                </button>
              </div>
            </aside>

            <main class="main-content">
              <RouterView />
            </main>
          </div>
        </n-message-provider>
      </n-dialog-provider>
    </n-config-provider>
  </ErrorBoundary>
</template>

<script setup lang="ts">
import ErrorBoundary from '@/components/ErrorBoundary.vue'
import { useAuth } from '@/stores/auth'
import { usePermissions } from '@/composables/usePermissions'
import {
  AnalyticsOutline as AnalyticsIcon,
  ArchiveOutline as ArchiveIcon,
  BarChartOutline,
  BuildOutline,
  CashOutline as CashIcon,
  DiamondOutline,
  HomeOutline as HomeIcon,
  HourglassOutline,
  LogOutOutline as LogoutIcon,
  NewspaperOutline,
  RibbonOutline,
  RocketOutline as RocketIcon,
  SettingsOutline as SettingsIcon,
  ShieldCheckmarkOutline,
  SparklesOutline,
} from '@vicons/ionicons5'
import {
  NConfigProvider,
  NDialogProvider,
  NIcon,
  NMessageProvider,
  createDiscreteApi,
} from 'naive-ui'
import type { Component } from 'vue'
import { useRouter } from 'vue-router'
import { watch } from 'vue'
import type { User } from '@supabase/supabase-js'

const router = useRouter()
const auth = useAuth()
const permissions = usePermissions()
const { message } = createDiscreteApi(['message'])

// Debug currency permissions in development
if (import.meta.env.DEV) {
  // Debug permissions when user data is loaded
  watch(() => auth.user, (user: User | null) => {
    if (user) {
      setTimeout(() => {
        permissions.debugCurrencyPermissions()

        // Test specific tab visibility logic
        console.group('📋 Tab Visibility Test')
        console.log('Create Orders Tab:', permissions.hasPermissionForCurrency('currency:create_orders'))
        console.log('Ops Tab (View):', permissions.hasPermissionForCurrency('currency:view_orders'))
        console.log('Ops Tab (Exchange):', permissions.hasPermissionForCurrency('currency:exchange_orders'))
        console.log('Ops Tab (Inventory):', permissions.hasPermissionForCurrency('currency:view_inventory'))
        console.log('Ops Tab (Combined):',
          permissions.hasPermissionForCurrency('currency:view_orders') ||
          permissions.hasPermissionForCurrency('currency:exchange_orders') ||
          permissions.hasPermissionForCurrency('currency:view_inventory')
        )
        console.groupEnd()
      }, 1000) // Delay to ensure assignments are loaded
    }
  })
}

const roleDisplay: Record<string, { icon: Component; color: string }> = {
  admin: { icon: DiamondOutline, color: '#d946ef' },
  mod: { icon: ShieldCheckmarkOutline, color: '#f97316' },
  manager: { icon: ShieldCheckmarkOutline, color: '#f97316' },
  trader_manager: { icon: RibbonOutline, color: '#0d9488' },
  farmer_manager: { icon: RibbonOutline, color: '#0d9488' },
  leader: { icon: SparklesOutline, color: '#f59e0b' },
  trader_leader: { icon: SparklesOutline, color: '#f59e0b' },
  farmer_leader: { icon: SparklesOutline, color: '#f59e0b' },
  trader1: { icon: BarChartOutline, color: '#0ea5e9' },
  trader2: { icon: BarChartOutline, color: '#0ea5e9' },
  farmer: { icon: RocketIcon, color: '#10b981' },
  accountant: { icon: NewspaperOutline, color: '#4f46e5' },
  trial: { icon: HourglassOutline, color: '#64748b' },
  default: { icon: BuildOutline, color: '#64748b' },
}

const logout = async () => {
  try {
    await auth.signOut()
    message.success('Đã đăng xuất')
    // THÊM DÒNG CHUYỂN TRANG VÀO ĐÂY
    router.replace('/login')
  } catch (e: unknown) {
    const error = e as Error
    message.error(error?.message ?? 'Đăng xuất thất bại')
  }
}
</script>

<style scoped>
.sidebar-fixed {
  position: fixed;
  top: 0;
  left: 0;
  width: 16rem; /* 256px = w-64 */
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: white;
  border-right: 1px solid rgba(229, 229, 229, 0.8);
  padding: 1rem;
  overflow-y: auto;
}

.main-content {
  margin-left: 16rem; /* Same as sidebar width */
  flex: 1;
  padding: 1rem;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 0.75rem; /* 12px */
  padding: 0.5rem 0.75rem; /* 8px 12px */
  border-radius: 6px;
  font-weight: 500;
  color: #475569; /* slate-600 */
  transition: all 0.2s;
}
.menu-item:hover {
  background-color: #f1f5f9; /* slate-100 */
  color: #0f172a; /* slate-900 */
}
/* Active link style */
.router-link-exact-active {
  background-color: #e2e8f0; /* slate-200 */
  color: #0f172a; /* slate-900 */
}
</style>
