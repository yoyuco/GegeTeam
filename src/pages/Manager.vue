<template>
  <div class="p-4">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold tracking-tight">Quản lý Tổ chức & Vận hành</h1>
    </div>

    <n-card v-if="!canManage" :bordered="false" class="shadow-sm">
      <n-alert type="error" title="Không có quyền truy cập">
        Bạn không có quyền quản lý tổ chức và vận hành.
      </n-alert>
    </n-card>

    <div v-else>
      <n-tabs v-model:value="activeTab" type="card" animated>
        <!-- Tab 1: Quản lý Ca làm việc -->
        <n-tab-pane name="shifts" tab="🕐 Quản lý Ca làm việc">
          <ShiftManagement />
        </n-tab-pane>

        <!-- Tab 2: Quản lý Tài khoản Game -->
        <n-tab-pane name="accounts" tab="🎮 Quản lý Tài khoản Game">
          <AccountManagement />
        </n-tab-pane>

        <!-- Tab 3: Phân công theo Ca -->
        <n-tab-pane name="assignments" tab="👥 Phân công theo Ca">
          <ShiftAssignment />
        </n-tab-pane>

        <!-- Tab 4: Vai trò & Quyền hạn -->
        <n-tab-pane name="roles" tab="🛡️ Vai trò & Quyền hạn">
          <RoleManagement />
        </n-tab-pane>

        <!-- Tab 5: Nhân viên & Phân quyền -->
        <n-tab-pane name="employees" tab="👤 Nhân viên & Phân quyền">
          <EmployeeManagement />
        </n-tab-pane>
      </n-tabs>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useAuth } from '@/stores/auth'
import {
  NCard,
  NAlert,
  NTabs,
  NTabPane,
  createDiscreteApi
} from 'naive-ui'

// Import tab components
import ShiftManagement from '@/components/manager/ShiftManagement.vue'
import AccountManagement from '@/components/manager/AccountManagement.vue'
import ShiftAssignment from '@/components/manager/ShiftAssignment.vue'
import RoleManagement from '@/components/manager/RoleManagement.vue'
import EmployeeManagement from '@/components/manager/EmployeeManagement.vue'

const { message } = createDiscreteApi(['message'])
const auth = useAuth()

// State
const canManage = ref(false)
const activeTab = ref('shifts')

// Check permissions on mount
onMounted(() => {
  let unwatch: () => void

  unwatch = watch(
    () => auth.loading,
    (isLoading) => {
      if (!isLoading) {
        // Check if user has any management permissions
        canManage.value =
          auth.hasPermission('admin:manage_roles') ||
          auth.hasPermission('admin:manage_users') ||
          auth.hasPermission('shift:manage') ||
          auth.hasPermission('account:manage')

        if (!canManage.value) {
          message.error('Bạn không có quyền quản lý tổ chức và vận hành.')
        }

        if (unwatch) {
          unwatch()
        }
      }
    },
    { immediate: true }
  )
})
</script>