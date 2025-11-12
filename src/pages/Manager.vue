<template>
  <div class="p-4">
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Quản lý Hệ thống</h1>
        <p class="text-gray-600 mt-1">Quản lý tất cả các tài nguyên và cấu hình hệ thống</p>
      </div>
      <div class="flex items-center gap-2">
        <n-input
          v-model:value="searchQuery"
          placeholder="Tìm kiếm trong tab hiện tại..."
          clearable
          style="width: 300px"
          @input="handleSearch"
        />
        <n-button tertiary @click="refreshCurrentTab">
          <template #icon>
            <n-icon><RefreshIcon /></n-icon>
          </template>
          Làm mới
        </n-button>
      </div>
    </div>

    <n-card v-if="!canManage" :bordered="false" class="shadow-sm">
      <n-alert type="error" title="Không có quyền truy cập">
        Bạn không có quyền quản lý tổ chức và vận hành.
      </n-alert>
    </n-card>

    <div v-else>
      <!-- Custom Tabs Navigation -->
      <div class="bg-white border border-gray-200 rounded-xl mb-4">
        <div class="flex">
          <button
            :class="[
              'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
              activeTab === 'shifts'
                ? 'tab-active text-blue-600 border-b-2 border-blue-600 bg-blue-50'
                : 'tab-inactive text-gray-500 hover:text-gray-700 hover:bg-gray-50',
            ]"
            @click="activeTab = 'shifts'"
          >
            ⏰ Ca làm việc
          </button>
          <button
            :class="[
              'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
              activeTab === 'profiles'
                ? 'tab-active text-green-600 border-b-2 border-green-600 bg-green-50'
                : 'tab-inactive text-gray-500 hover:text-gray-700 hover:bg-gray-50',
            ]"
            @click="activeTab = 'profiles'"
          >
            👤 Quản lý Profile
          </button>
          <button
            :class="[
              'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
              activeTab === 'channels'
                ? 'tab-active text-purple-600 border-b-2 border-purple-600 bg-purple-50'
                : 'tab-inactive text-gray-500 hover:text-gray-700 hover:bg-gray-50',
            ]"
            @click="activeTab = 'channels'"
          >
            📡 Quản lý Channels
          </button>
          <button
            :class="[
              'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
              activeTab === 'gameAccounts'
                ? 'tab-active text-orange-600 border-b-2 border-orange-600 bg-orange-50'
                : 'tab-inactive text-gray-500 hover:text-gray-700 hover:bg-gray-50',
            ]"
            @click="activeTab = 'gameAccounts'"
          >
            🎮 Quản lý Game Accounts
          </button>
          <button
            :class="[
              'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
              activeTab === 'shiftAssignments'
                ? 'tab-active text-indigo-600 border-b-2 border-indigo-600 bg-indigo-50'
                : 'tab-inactive text-gray-500 hover:text-gray-700 hover:bg-gray-50',
            ]"
            @click="activeTab = 'shiftAssignments'"
          >
            📅 Phân công Ca làm việc
          </button>
          <button
            :class="[
              'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
              activeTab === 'fees'
                ? 'tab-active text-pink-600 border-b-2 border-pink-600 bg-pink-50'
                : 'tab-inactive text-gray-500 hover:text-gray-700 hover:bg-gray-50',
            ]"
            @click="activeTab = 'fees'"
          >
            💰 Quản lý Phí
          </button>
          <button
            :class="[
              'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
              activeTab === 'businessProcesses'
                ? 'tab-active text-teal-600 border-b-2 border-teal-600 bg-teal-50'
                : 'tab-inactive text-gray-500 hover:text-gray-700 hover:bg-gray-50',
            ]"
            @click="activeTab = 'businessProcesses'"
          >
            ⚙️ Quy trình Kinh doanh
          </button>
        </div>
      </div>

      <!-- Tab Content with local loading indicator -->
      <div class="flex-1 relative">
        <!-- Tab-level loading indicator (only covers tab content, not entire screen) -->
        <div
          v-if="tabLoadingStates[activeTab]"
          class="absolute top-4 right-4 z-10 bg-white rounded-lg shadow-md p-2 flex items-center gap-2"
        >
          <n-spin size="small" />
          <span class="text-sm text-gray-600">Đang tải...</span>
        </div>
        <!-- Tab 1: Ca làm việc -->
        <div v-if="activeTab === 'shifts'" class="tab-pane">
          <ShiftsManagement
            :search-query="searchQuery"
            :refresh-trigger="refreshTriggers.shifts"
            @refreshed="handleTabRefreshed('shifts')"
            @loading-change="handleTabLoading('shifts', $event)"
          />
        </div>

        <!-- Tab 3: Quản lý Profile -->
        <div v-if="activeTab === 'profiles'" class="tab-pane">
          <ProfilesManagement
            :search-query="searchQuery"
            :refresh-trigger="refreshTriggers.profiles"
            @refreshed="handleTabRefreshed('profiles')"
            @loading-change="handleTabLoading('profiles', $event)"
          />
        </div>

        <!-- Tab 4: Quản lý Channels -->
        <div v-if="activeTab === 'channels'" class="tab-pane">
          <ChannelsManagement
            :search-query="searchQuery"
            :refresh-trigger="refreshTriggers.channels"
            @refreshed="handleTabRefreshed('channels')"
            @loading-change="handleTabLoading('channels', $event)"
          />
        </div>

        <!-- Tab 5: Quản lý Game Accounts -->
        <div v-if="activeTab === 'gameAccounts'" class="tab-pane">
          <GameAccountsManagement
            :search-query="searchQuery"
            :refresh-trigger="refreshTriggers.gameAccounts"
            @refreshed="handleTabRefreshed('gameAccounts')"
            @loading-change="handleTabLoading('gameAccounts', $event)"
          />
        </div>

        <!-- Tab 6: Phân công Ca làm việc -->
        <div v-if="activeTab === 'shiftAssignments'" class="tab-pane">
          <ShiftAssignments
            :search-query="searchQuery"
            :refresh-trigger="refreshTriggers.shiftAssignments"
            @refreshed="handleTabRefreshed('shiftAssignments')"
            @loading-change="handleTabLoading('shiftAssignments', $event)"
          />
        </div>

        <!-- Tab 7: Quản lý Phí -->
        <div v-if="activeTab === 'fees'" class="tab-pane">
          <FeesManagement
            :search-query="searchQuery"
            :refresh-trigger="refreshTriggers.fees"
            @refreshed="handleTabRefreshed('fees')"
            @loading-change="handleTabLoading('fees', $event)"
          />
        </div>

        <!-- Tab 8: Quy trình Kinh doanh -->
        <div v-if="activeTab === 'businessProcesses'" class="tab-pane">
          <BusinessProcessesManagement
            :search-query="searchQuery"
            :refresh-trigger="refreshTriggers.businessProcesses"
            @refreshed="handleTabRefreshed('businessProcesses')"
            @loading-change="handleTabLoading('businessProcesses', $event)"
          />
        </div>
      </div>
    </div>

    <!-- Loading Indicator (only shows in current tab area) -->
    <!-- Global loading removed to prevent covering the app menu -->
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { NIcon } from 'naive-ui'
import { Refresh as RefreshIcon } from '@vicons/ionicons5'
import { useAuth } from '@/stores/auth'
import {
  NCard,
  NAlert,
  NButton,
  NInput,
  NSpin,
  createDiscreteApi
} from 'naive-ui'

// Import management components
import ShiftsManagement from '@/components/admin/ShiftsManagement.vue'
import ProfilesManagement from '@/components/admin/ProfilesManagement.vue'
import ChannelsManagement from '@/components/admin/ChannelsManagement.vue'
import GameAccountsManagement from '@/components/admin/GameAccountsManagement.vue'
import ShiftAssignments from '@/components/admin/ShiftAssignments.vue'
import FeesManagement from '@/components/admin/FeesManagement.vue'
import BusinessProcessesManagement from '@/components/admin/BusinessProcessesManagement.vue'

const { message } = createDiscreteApi(['message'])
const auth = useAuth()

// Reactive state
const activeTab = ref('shifts')
const searchQuery = ref('')
const tabLoadingStates = ref<Record<string, boolean>>({})
const refreshTriggers = ref<Record<string, number>>({
  shifts: 0,
  profiles: 0,
  channels: 0,
  gameAccounts: 0,
  shiftAssignments: 0,
  fees: 0,
  businessProcesses: 0,
  disabled: 0
})

// State
const canManage = ref(false)

// Event handlers
const handleSearch = (value: string) => {
  // Search is handled by individual components via prop
}

const refreshCurrentTab = () => {
  if (refreshTriggers.value[activeTab.value] !== undefined) {
    refreshTriggers.value[activeTab.value]++
  }
}

const handleTabRefreshed = (tabName: string) => {
  tabLoadingStates.value[tabName] = false
}

const handleTabLoading = (tabName: string, loading: boolean) => {
  tabLoadingStates.value[tabName] = loading
}

// updateGlobalLoadingState removed - no longer needed without global loading overlay

// Keyboard shortcuts
const handleKeyboardShortcuts = (event: KeyboardEvent) => {
  if (event.ctrlKey || event.metaKey) {
    switch (event.key) {
      case 'r':
        event.preventDefault()
        refreshCurrentTab()
        break
      case 'f':
        event.preventDefault()
        // Focus search input
        const searchInput = document.querySelector('input[placeholder*="Tìm kiếm"]') as HTMLInputElement
        searchInput?.focus()
        break
    }
  }
}

// Check permissions on mount
onMounted(() => {
  document.addEventListener('keydown', handleKeyboardShortcuts)

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
          auth.hasPermission('account:manage') ||
          auth.hasPermission('system.management') ||
          auth.hasPermission('system.admin') ||
          auth.hasPermission('admin')

        if (!canManage.value) {
          message.error('Bạn không có quyền quản lý hệ thống.')
        }

        if (unwatch) {
          unwatch()
        }
      }
    },
    { immediate: true }
  )
})

// Cleanup
onUnmounted(() => {
  document.removeEventListener('keydown', handleKeyboardShortcuts)
})
</script>

<style scoped>
.n-tabs {
  background: white;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1);
}

.n-tab-pane {
  padding-top: 16px;
}

/* Custom tabs styling */
.tab-active {
  font-weight: 600;
  border-bottom: 3px solid currentColor;
}

.tab-inactive {
  font-weight: 500;
  transition: all 0.2s ease;
}

.tab-inactive:hover {
  font-weight: 550;
}

/* Tab pane animation */
.tab-pane {
  animation: fadeIn 0.15s ease-in-out;
}

/* Custom tabs navigation flexbox */
.flex .tab-active,
.flex .tab-inactive {
  border-radius: 8px 8px 0 0;
  margin: 0 2px;
}

/* Search input styling */
:deep(.n-input) {
  border-radius: 6px;
}

/* Loading overlay animation */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.fixed {
  animation: fadeIn 0.2s ease-in-out;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .flex.items-center.justify-between.mb-6 {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }

  .flex.items-center.gap-2 {
    flex-direction: column;
  }

  :deep(.n-input) {
    width: 100% !important;
  }
}
</style>