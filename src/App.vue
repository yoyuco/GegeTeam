<template>
  <n-config-provider>
    <n-dialog-provider>
      <n-message-provider>
        <div class="min-h-screen flex bg-neutral-100/50 text-neutral-900">
          <aside class="w-64 flex flex-col bg-white border-r border-neutral-200/80 p-4">
            <div class="flex items-center gap-3 mb-6 px-2">
              <img src="@/assets/gege_icon.png" alt="Gege Team Logo" class="h-8 w-8">
              <span class="text-lg font-bold text-neutral-800">Gege Team</span>
            </div>

            <nav class="flex flex-col space-y-2">
              <RouterLink v-if="auth.hasPermission('orders:view_all')" to="/" class="menu-item">
                <n-icon><HomeIcon /></n-icon><span>Dashboard</span>
              </RouterLink>
              <RouterLink v-if="auth.hasPermission('orders:create', { game_code: 'DIABLO_4', business_area_code: 'SERVICE' })" to="/sales" class="menu-item">
                <n-icon><CashIcon /></n-icon><span>Bán hàng</span>
              </RouterLink>
              <RouterLink v-if="auth.hasPermission('orders:view_all', { game_code: 'DIABLO_4', business_area_code: 'SERVICE' })" to="/service-boosting" class="menu-item">
                <n-icon><RocketIcon /></n-icon><span>Service – Boosting</span>
              </RouterLink>
              <RouterLink v-if="auth.hasPermission('reports:view')" to="/reports" class="menu-item">
                <n-icon><ArchiveIcon /></n-icon><span>Quản lý Báo cáo</span>
              </RouterLink>
              <RouterLink v-if="auth.hasPermission('admin:manage_roles')" to="/employees" class="menu-item">
                <n-icon><PeopleIcon /></n-icon><span>Nhân viên</span>
              </RouterLink>
              <RouterLink v-if="auth.hasPermission('admin:manage_roles')" to="/role-management" class="menu-item">
                <n-icon><ShieldCheckmarkOutline /></n-icon><span>Phân quyền vai trò</span>
              </RouterLink>
              <RouterLink v-if="auth.hasPermission('system:view_audit_logs')" to="/systemops" class="menu-item">
                <n-icon><AnalyticsIcon /></n-icon><span>Thao tác hệ thống</span>
              </RouterLink>
            </nav>

            <div v-if="auth.user" class="mt-auto pt-4 border-t border-neutral-200/80">
              <div class="text-sm font-medium mb-2">
                {{ auth.profile?.display_name || auth.user?.user_metadata?.display_name || auth.user?.email }}
              </div>
              
              <div class="space-y-1 mb-4">
                <div v-for="(asg, i) in auth.assignments" :key="i" class="flex items-center gap-1.5">
                  <n-icon :component="roleDisplay[asg.role_code]?.icon" :color="roleDisplay[asg.role_code]?.color" :title="asg.role_name" />
                  <span class="text-xs font-semibold" :style="{ color: roleDisplay[asg.role_code]?.color }">
                    {{ asg.role_name }}
                  </span>
                  <span v-if="asg.game_name || asg.business_area_name" class="text-xs text-neutral-500">
                    ({{ [asg.game_name, asg.business_area_name].filter(Boolean).join('/') }})
                  </span>
                </div>
              </div>

              <button class="flex items-center gap-2 text-red-600 hover:underline text-sm" @click="logout">
                <n-icon><LogoutIcon /></n-icon><span>Đăng xuất</span>
              </button>
            </div>
          </aside>

          <main class="flex-1 p-4">
            <RouterView />
          </main>
        </div>
      </n-message-provider>
    </n-dialog-provider>
  </n-config-provider>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router';
import { NConfigProvider, NMessageProvider, NDialogProvider, NIcon, createDiscreteApi } from 'naive-ui';
import { useAuth } from '@/stores/auth';
import { 
  HomeOutline as HomeIcon, 
  CashOutline as CashIcon, 
  RocketOutline as RocketIcon, 
  ArchiveOutline as ArchiveIcon, 
  PeopleOutline as PeopleIcon, 
  AnalyticsOutline as AnalyticsIcon, 
  DiamondOutline, 
  ShieldCheckmarkOutline, 
  BuildOutline, 
  BarChartOutline, 
  LogOutOutline as LogoutIcon, 
  RibbonOutline, 
  SparklesOutline, 
  HourglassOutline, 
  NewspaperOutline,
} from '@vicons/ionicons5';

const router = useRouter();
const auth = useAuth();
const { message } = createDiscreteApi(['message']);

const roleDisplay: Record<string, { icon: any, color: string }> = {
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
};

const logout = async () => {
  try {
    await auth.signOut();
    message.success('Đã đăng xuất');
    // THÊM DÒNG CHUYỂN TRANG VÀO ĐÂY
    router.replace('/login');
  } catch (e: any) {
    message.error(e?.message ?? 'Đăng xuất thất bại');
  }
};
</script>

<style scoped>
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