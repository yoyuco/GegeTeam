<template>
  <div class="profiles-management">
    <!-- Header with Actions -->
    <div class="flex justify-between items-center mb-6">
      <div class="flex items-center gap-4">
        <h2 class="text-xl font-semibold text-gray-800">Quản lý Profile</h2>
        <n-tag type="info" size="small">{{ filteredProfiles.length }} profiles</n-tag>
      </div>
      <div class="flex gap-2">
        <n-button type="primary" @click="refreshData">
          <template #icon>
            <n-icon><RefreshIcon /></n-icon>
          </template>
          Tải lại
        </n-button>
      </div>
    </div>

    <!-- Filter Panel -->
    <FilterPanel
      :show-status-filter="true"
      :show-employee-filter="true"
      :show-date-filter="true"
      @filter-change="handleFilterChange"
    />

    <!-- Profiles Table -->
    <n-card>
      <n-data-table
        :key="profilesKey"
        :columns="columns"
        :data="filteredProfiles"
        :loading="loading"
        :pagination="pagination"
        :row-key="(row: Profile) => row.id"
        striped
        size="medium"
      />
    </n-card>

    <!-- Edit Profile Modal -->
    <n-modal
      v-model:show="editModalOpen"
      :mask-closable="false"
      :style="{ width: '600px' }"
      preset="card"
      title="Cập nhật thông tin nhân viên"
      size="large"
    >
      <div class="profile-form">
        <n-form
          ref="editFormRef"
          :model="editForm"
          :rules="editFormRules"
          label-placement="top"
          label-width="auto"
          require-mark-placement="right-hanging"
          size="large"
        >
          <!-- Basic Information Section -->
          <div class="form-section">
            <div class="section-title">
              <n-icon size="20" color="#2080f0">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
              </n-icon>
              <span>Thông tin cơ bản</span>
            </div>

            <n-form-item label="Tên hiển thị" path="display_name">
              <n-input
                v-model:value="editForm.display_name"
                placeholder="👤 Nhập tên hiển thị"
                size="large"
              />
            </n-form-item>

            <n-form-item label="Username" path="username">
              <n-input
                v-model:value="editForm.username"
                placeholder="🔑 Tên đăng nhập"
                size="large"
                disabled
              />
            </n-form-item>

            <n-form-item label="Email" path="email">
              <n-input
                v-model:value="editForm.email"
                placeholder="📧 Địa chỉ email"
                size="large"
                disabled
              />
            </n-form-item>

            <n-form-item label="Số điện thoại" path="phone">
              <n-input
                v-model:value="editForm.phone"
                placeholder="📞 Nhập số điện thoại"
                size="large"
              />
            </n-form-item>
          </div>

  
          <!-- Notes Section -->
          <div class="form-section">
            <div class="section-title">
              <n-icon size="20" color="#2080f0">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zM16 18H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>
              </n-icon>
              <span>Ghi chú</span>
            </div>

            <n-form-item label="Ghi chú" path="notes">
              <n-input
                v-model:value="editForm.notes"
                type="textarea"
                placeholder="📝 Nhập ghi chú về nhân viên"
                :rows="3"
                size="large"
              />
            </n-form-item>
          </div>
        </n-form>
      </div>

      <template #action>
        <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
          <div style="font-size: 14px; color: #909399;">
            Các trường có <span style="color: #d03050;">*</span> là bắt buộc
          </div>
          <n-space>
            <n-button size="large" @click="closeEditModal">
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 6.41L17.59 5L12 10.59L6.41 5L5 6.41L10.59 12L5 17.59L6.41 19L12 13.41L17.59 19L19 17.59L13.41 12L19 6.41z"/></svg>
                </n-icon>
              </template>
              Hủy
            </n-button>
            <n-button
              type="primary"
              size="large"
              :loading="saving"
              :disabled="!editForm.display_name"
              @click="saveProfile"
            >
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19L21 7l-1.41-1.41L9 16.17z"/></svg>
                </n-icon>
              </template>
              Lưu thay đổi
            </n-button>
          </n-space>
        </div>
      </template>
    </n-modal>

    <!-- Status Change Modal -->
    <n-modal
      v-model:show="statusModalOpen"
      :mask-closable="false"
      :style="{ width: '450px' }"
      preset="card"
      title="Thay đổi trạng thái nhân viên"
      size="medium"
    >
      <div class="status-change-form">
        <div v-if="statusForm.profile" class="profile-info">
          <n-alert type="info" style="margin-bottom: 16px;">
            <div style="display: flex; align-items: center; gap: 8px;">
              <n-icon size="20">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
              </n-icon>
              <span>Bạn đang thay đổi trạng thái của: <strong>{{ statusForm.profile.display_name }}</strong></span>
            </div>
          </n-alert>
        </div>

        <n-form
          ref="statusFormRef"
          :model="statusForm"
          :rules="statusFormRules"
          label-placement="top"
          label-width="auto"
          require-mark-placement="right-hanging"
          size="medium"
        >
          <n-form-item label="Trạng thái mới" path="status">
            <n-select
              v-model:value="statusForm.status"
              :options="statusOptions"
              placeholder="🔄 Chọn trạng thái mới"
              size="medium"
            />
          </n-form-item>

          <n-form-item label="Lý do thay đổi" path="reason">
            <n-input
              v-model:value="statusForm.reason"
              type="textarea"
              placeholder="📝 Nhập lý do thay đổi trạng thái"
              :rows="4"
              size="medium"
            />
          </n-form-item>
        </n-form>
      </div>

      <template #action>
        <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
          <div style="font-size: 13px; color: #909399;">
            Thay đổi sẽ được ghi nhận vào lịch sử
          </div>
          <n-space>
            <n-button size="medium" @click="closeStatusModal">
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 6.41L17.59 5L12 10.59L6.41 5L5 6.41L10.59 12L5 17.59L6.41 19L12 13.41L17.59 19L19 17.59L13.41 12L19 6.41z"/></svg>
                </n-icon>
              </template>
              Hủy
            </n-button>
            <n-button
              type="primary"
              size="medium"
              :loading="statusSaving"
              :disabled="!statusForm.status || !statusForm.reason"
              @click="saveStatusChange"
            >
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19L21 7l-1.41-1.41L9 16.17z"/></svg>
                </n-icon>
              </template>
              Xác nhận thay đổi
            </n-button>
          </n-space>
        </div>
      </template>
    </n-modal>

    <!-- Role Assignments Modal -->
    <n-modal
      v-model:show="roleAssignmentsModalOpen"
      :mask-closable="false"
      :style="{ width: '900px' }"
      preset="card"
      :title="`Phân quyền - ${modalEditingUser?.display_name || modalEditingUser?.username}`"
      size="large"
    >
      <div class="role-assignments-form">
        <div v-if="modalEditingUser" class="user-info">
          <n-alert type="info" style="margin-bottom: 20px;">
            <div style="display: flex; align-items: center; gap: 8px;">
              <n-icon size="20">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
              </n-icon>
              <span>Quản lý vai trò và phân quyền cho: <strong>{{ modalEditingUser.display_name }}</strong></span>
            </div>
          </n-alert>
        </div>

        <!-- Add new role assignment form -->
        <div class="form-section">
          <div class="section-title">
            <n-icon size="20" color="#2080f0">
              <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 22L12 18.56L5.82 22L7 14.14l-5-4.87l6.91-1.01L12 2z"/></svg>
            </n-icon>
            <span>Gán vai trò mới</span>
          </div>

          <n-form
            ref="roleAssignmentFormRef"
            :model="roleAssignmentForm"
            label-placement="top"
            label-width="auto"
            require-mark-placement="right-hanging"
            size="large"
          >
            <n-grid :cols="3" :x-gap="16">
              <n-gi>
                <n-form-item label="Vai trò" path="role_id">
                  <n-select
                    v-model:value="roleAssignmentForm.role_id"
                    :options="roleOptions"
                    placeholder="👥 Chọn vai trò"
                    clearable
                    size="large"
                  />
                </n-form-item>
              </n-gi>

              <n-gi>
                <n-form-item label="Game" path="game_attribute_id">
                  <n-select
                    v-model:value="roleAssignmentForm.game_attribute_id"
                    :options="gameAttributeOptions"
                    placeholder="🎮 Chọn game (nếu có)"
                    clearable
                    size="large"
                  />
                </n-form-item>
              </n-gi>

              <n-gi>
                <n-form-item label="Lĩnh vực" path="business_area_attribute_id">
                  <n-select
                    v-model:value="roleAssignmentForm.business_area_attribute_id"
                    :options="businessAreaAttributeOptions"
                    placeholder="🏢 Chọn lĩnh vực (nếu có)"
                    clearable
                    size="large"
                  />
                </n-form-item>
              </n-gi>
            </n-grid>

            <n-form-item style="margin-top: 16px;">
              <n-button
                type="primary"
                size="large"
                :loading="assigningRole"
                :disabled="!roleAssignmentForm.role_id"
                @click="assignRole"
              >
                <template #icon>
                  <n-icon>
                    <svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
                  </n-icon>
                </template>
                Gán vai trò
              </n-button>
            </n-form-item>
          </n-form>
        </div>

        <!-- Current role assignments -->
        <div class="form-section" style="margin-top: 24px;">
          <div class="section-title">
            <n-icon size="20" color="#2080f0">
              <svg viewBox="0 0 24 24"><path fill="currentColor" d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
              </n-icon>
            <span>Vai trò hiện tại</span>
          </div>

          <div v-if="modalCurrentAssignments.length === 0" class="empty-state">
            <div style="text-align: center; padding: 40px; color: #909399;">
              <n-icon size="48" color="#c0c4cc">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
              </n-icon>
              <div style="margin-top: 12px; font-size: 14px;">
                Người dùng này chưa được phân quyền nào.
              </div>
            </div>
          </div>

          <div v-else>
            <n-data-table
              :columns="roleAssignmentColumns"
              :data="modalCurrentAssignments"
              :pagination="false"
              size="medium"
              striped
              :bordered="false"
            />
          </div>
        </div>
      </div>

      <template #action>
        <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
          <div style="font-size: 14px; color: #909399;">
            Các vai trò sẽ xác định quyền truy cập của người dùng
          </div>
          <n-space>
            <n-button size="large" @click="closeRoleAssignmentsModal">
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 6.41L17.59 5L12 10.59L6.41 5L5 6.41L10.59 12L5 17.59L6.41 19L12 13.41L17.59 19L19 17.59L13.41 12L19 6.41z"/></svg>
                </n-icon>
              </template>
              Đóng
            </n-button>
          </n-space>
        </div>
      </template>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/auth'
import {
  Create as EditIcon,
  Refresh as RefreshIcon,
  Toggle as StatusIcon
} from '@vicons/ionicons5'
import type { DataTableColumns, FormInst, FormRules } from 'naive-ui'
import { NAlert, NButton, NCard, NDataTable, NForm, NFormItem, NGi, NGrid, NIcon, NInput, NModal, NSelect, NSpace, NTag, useMessage } from 'naive-ui'
import { computed, h, nextTick, onMounted, ref, watch } from 'vue'
import FilterPanel from './FilterPanel.vue'

// Props
interface Props {
  searchQuery?: string
  refreshTrigger?: number
}

const props = withDefaults(defineProps<Props>(), {
  searchQuery: '',
  refreshTrigger: 0
})

// Emits
const emit = defineEmits<{
  refreshed: [tabName: string]
  loadingChange: [loading: boolean]
}>()

// Composables
const message = useMessage()
const auth = useAuth()

// State
const loading = ref(false)
const saving = ref(false)
const statusSaving = ref(false)
const profiles = ref<Profile[]>([])
const roles = ref<Role[]>([])
const searchQuery = ref('')
const statusFilter = ref<string | null>(null)
const roleFilter = ref<string | null>(null)
const currentFilters = ref<Record<string, any>>({})

// Force refresh key
const profilesKey = ref(0)

// Modal states
const editModalOpen = ref(false)
const statusModalOpen = ref(false)
const roleAssignmentsModalOpen = ref(false)
const editFormRef = ref<FormInst | null>(null)
const statusFormRef = ref<FormInst | null>(null)

// Forms
const editForm = ref<Partial<Profile>>({})
const statusForm = ref<{
  profile: Profile | null
  status: string | null
  reason: string
}>({
  profile: null,
  status: null,
  reason: ''
})

// Role assignments state
const modalCurrentAssignments = ref<RoleAssignment[]>([])
const modalEditingUser = ref<Profile | null>(null)

// Role assignment form state
const roleAssignmentFormRef = ref<FormInst | null>(null)
const assigningRole = ref(false)
const roleAssignmentForm = ref<{
  role_id: string | null
  game_attribute_id: string | null
  business_area_attribute_id: string | null
}>({
  role_id: null,
  game_attribute_id: null,
  business_area_attribute_id: null
})

// Game and business area attributes options
const gameAttributeOptions = ref<{ label: string; value: string }[]>([])
const businessAreaAttributeOptions = ref<{ label: string; value: string }[]>([])

// Types
interface Profile {
  id: string
  auth_id: string // Foreign key to auth.users.id
  display_name: string | null
  status: string
  created_at: string
  updated_at: string
  // Joined fields from auth.users
  username: string // Extracted from raw_user_meta_data or email
  email: string // From auth.users
  last_sign_in_at?: string | null // From auth.users (database is already GMT+7)
  avatar_url?: string | null // User avatar URL
  // Computed fields for display
  role_name: string // Computed from role_assignments
  role_assignments?: RoleAssignment[] // From user_role_assignments
  phone?: string // For compatibility, but not in actual schema
  notes?: string // For compatibility, but not in actual schema
}

interface Role {
  id: string
  name: string
  code: string
}

interface RoleAssignment {
  assignment_id: string
  role_name: string
  game_name?: string
  business_area_name?: string
}

// Pagination
const pagination = ref({
  page: 1,
  pageSize: 20,
  itemCount: 0,
  showSizePicker: true,
  pageSizes: [10, 20, 50, 100]
})

// Options
const statusOptions = [
  { label: 'Hoạt động', value: 'active' },
  { label: 'Tạm dừng', value: 'suspended' },
  { label: 'Đã nghỉ', value: 'terminated' },
  { label: 'Chờ xác nhận', value: 'pending' }
]

const roleOptions = computed(() => {
  return roles.value.map(role => ({
    label: role.name,
    value: role.id
  }))
})

// Form validation rules
const editFormRules: FormRules = {
  display_name: [
    { required: true, message: 'Vui lòng nhập tên hiển thị', trigger: 'blur' }
  ]
}

const statusFormRules: FormRules = {
  status: [
    { required: true, message: 'Vui lòng chọn trạng thái', trigger: 'change' }
  ],
  reason: [
    { required: true, message: 'Vui lòng nhập lý do thay đổi', trigger: 'blur' }
  ]
}

// Computed
const filteredProfiles = computed(() => {
  let filtered = profiles.value

  // Apply search query
  if (props.searchQuery) {
    const query = props.searchQuery.toLowerCase()
    filtered = filtered.filter(profile =>
      profile.display_name?.toLowerCase().includes(query) ||
      profile.username.toLowerCase().includes(query) ||
      profile.email.toLowerCase().includes(query) ||
      profile.phone?.toLowerCase().includes(query) ||
      profile.role_name.toLowerCase().includes(query)
    )
  }

  // Apply FilterPanel filters
  if (currentFilters.value.status) {
    if (Array.isArray(currentFilters.value.status) && currentFilters.value.status.length > 0) {
      filtered = filtered.filter(profile =>
        currentFilters.value.status.some((status: string) =>
          profile.status === status
        )
      )
    }
  }

  if (currentFilters.value.employee) {
    if (Array.isArray(currentFilters.value.employee) && currentFilters.value.employee.length > 0) {
      filtered = filtered.filter(profile =>
        currentFilters.value.employee.some((employeeId: string) =>
          profile.id === employeeId
        )
      )
    }
  }

  // Apply date filters
  if (currentFilters.value.dateFrom) {
    filtered = filtered.filter(profile => {
      const createdDate = new Date(profile.created_at).getTime()
      return createdDate >= currentFilters.value.dateFrom
    })
  }

  if (currentFilters.value.dateTo) {
    filtered = filtered.filter(profile => {
      const createdDate = new Date(profile.created_at).getTime()
      return createdDate <= currentFilters.value.dateTo
    })
  }

  // Apply legacy filters for compatibility
  if (statusFilter.value) {
    filtered = filtered.filter(profile => profile.status === statusFilter.value)
  }

  if (roleFilter.value) {
    filtered = filtered.filter(profile => {
      const roleName = profile.role_name
      const roleOption = roleOptions.value.find(option => option.value === roleFilter.value)
      return roleName === roleOption?.label
    })
  }

  pagination.value.itemCount = filtered.length
  return filtered
})

// Table columns
const columns: DataTableColumns<Profile> = [
  {
    title: 'Nhân viên',
    key: 'display_name',
    render(row) {
      return h('div', { class: 'flex items-center gap-2' }, [
        // TODO: Avatar sẽ được phát triển sau
        // h('img', {
        //   src: row.avatar_url || '/default-avatar.png',
        //   class: 'w-8 h-8 rounded-full',
        //   alt: row.display_name || row.username
        // }),
        h('div', [
          h('div', { class: 'font-medium' }, row.display_name || row.username),
          h('div', { class: 'text-sm text-gray-500' }, `@${row.username}`)
        ])
      ])
    }
  },
  {
    title: 'Email',
    key: 'email',
    render(row) {
      return h('div', [
        h('div', row.email),
        row.phone && h('div', { class: 'text-sm text-gray-500' }, row.phone)
      ])
    }
  },
  {
    title: 'Chi tiết vai trò',
    key: 'role_details',
    width: 300,
    render(row) {
      if (!row.role_assignments || row.role_assignments.length === 0) {
        return h(NTag, {
          type: 'default',
          size: 'medium'
        }, () => 'Chưa có vai trò')
      }

      const roleColors: Record<string, string> = {
        administrator: '#FF4757',    // Admin - Đỏ nổi (cao nhất)
        admin: '#FF4757',            // Admin - Đỏ nổi (cao nhất)
        moderator: '#7B68EE',       // Mod - Tím sáng (cao hơn Manager)
        mod: '#7B68EE',             // Mod - Tím sáng (cao hơn Manager)
        manager: '#FFA502',         // Manager - Vàng cam (trung cấp)
        leader: '#A55EEA',          // Leader - Tím đậm
        farmer_leader: '#FF9F43',   // Farmer Leader - Cam sáng
        farmer_manager: '#EE5A24',  // Farmer Manager - Cam đậm
        trader_leader: '#F368E0',   // Trader Leader - Hồng
        trader_manager: '#EA2027',  // Trader Manager - Đỏ đậm
        trader: '#05C46B',          // Trader - Xanh lá đậm
        trader1: '#00D2D3',         // Trader 1 - Xanh ngọc
        trader2: '#10AC84',         // Trader 2 - Xanh lá cổ vịt
        farmer: '#26DE81',          // Farmer - Xanh lá mạ
        accountant: '#006BA6',      // Accountant - Xanh dương nhạt
        trial: '#95A5A6'            // Trial - Xám nhạt
      }

      return h('div', {
        class: 'flex flex-col gap-1 w-full'
      },
        row.role_assignments.map((assignment: any) => {
          const originalRoleName = assignment.role_name || 'Unknown'
          const gameName = assignment.game_name || 'All'
          const businessArea = assignment.business_area_name || 'All'

          // Format role names for better display
          let displayRoleName = originalRoleName
          if (originalRoleName.toLowerCase() === 'administrator') {
            displayRoleName = 'Admin'
          } else if (originalRoleName.toLowerCase() === 'trader1') {
            displayRoleName = 'Trader 1'
          } else if (originalRoleName.toLowerCase() === 'trader2') {
            displayRoleName = 'Trader 2'
          } else if (originalRoleName.toLowerCase() === 'moderator' || originalRoleName.toLowerCase() === 'mod') {
            displayRoleName = 'Mod'
          } else if (originalRoleName.toLowerCase() === 'farmer_leader') {
            displayRoleName = 'Farmer Leader'
          } else if (originalRoleName.toLowerCase() === 'farmer_manager') {
            displayRoleName = 'Farmer Manager'
          } else if (originalRoleName.toLowerCase() === 'trader_leader') {
            displayRoleName = 'Trader Leader'
          } else if (originalRoleName.toLowerCase() === 'trader_manager') {
            displayRoleName = 'Trader Manager'
          }

          const roleText = `${displayRoleName} - ${gameName} - ${businessArea}`

          const roleColor = roleColors[originalRoleName?.toLowerCase()] || '#95A5A6'

          return h('div', {
            class: 'flex-shrink-0 w-fit'
          }, [
            h(NTag, {
              type: 'default',
              size: 'medium',
              style: {
                fontWeight: '500',
                padding: '4px 12px',
                backgroundColor: roleColor + '20',
                color: roleColor,
                borderColor: roleColor,
                border: '1px solid ' + roleColor,
                width: '100%'
              }
            }, () => roleText)
          ])
        })
      )
    }
  },
  {
    title: 'Trạng thái',
    key: 'status',
    render(row) {
      const statusColors: Record<string, 'success' | 'warning' | 'error' | 'info' | 'default'> = {
        active: 'success',
        suspended: 'warning',
        terminated: 'error',
        pending: 'info'
      }
      return h(NTag, {
        type: statusColors[row.status] || 'default',
        size: 'small'
      }, () => statusOptions.find(opt => opt.value === row.status)?.label || row.status)
    }
  },
  {
    title: 'Lần cuối đăng nhập',
    key: 'last_sign_in_at',
    render(row) {
      return row.last_sign_in_at
        ? new Date(row.last_sign_in_at).toLocaleString('vi-VN', {
            timeZone: 'Asia/Bangkok',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
          })
        : 'Chưa đăng nhập'
    }
  },
  {
    title: 'Thao tác',
    key: 'actions',
    width: 200,
    render(row) {
      return h('div', { class: 'flex gap-2' }, [
        h(
          NButton,
          {
            size: 'small',
            type: 'primary',
            ghost: true,
            onClick: () => openEditModal(row)
          },
          () => h(NIcon, { size: 14 }, () => h(EditIcon))
        ),
        h(
          NButton,
          {
            size: 'small',
            type: 'info',
            ghost: true,
            onClick: () => openRoleAssignmentsModal(row)
          },
          () => h(NIcon, { size: 14 }, () => h(StatusIcon))
        ),
        h(
          NButton,
          {
            size: 'small',
            type: 'warning',
            ghost: true,
            onClick: () => openStatusModal(row)
          },
          () => h(NIcon, { size: 14 }, () => h(StatusIcon))
        )
      ])
    }
  }
]

// Role assignments table columns

// Methods
const loadProfiles = async () => {
  loading.value = true
  emit('loadingChange', true)

  try {
    // Load profiles first
    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .order('created_at', { ascending: false })

    // Get user emails and last_sign_in_at using RPC function
    const authIds = (profileData || []).map(profile => profile.auth_id).filter(Boolean)
    let userData: { [key: string]: any } = {}

    if (authIds.length > 0) {
      const { data: usersData } = await supabase.rpc('get_user_emails', { user_ids: authIds })
      if (usersData) {
        userData = usersData.reduce((acc: any, item: any) => {
          acc[item.user_id] = item
          return acc
        }, {})
      }
    }

    
    // Try RPC function first to bypass RLS issues
    let roleAssignmentsMap: { [key: string]: any[] } = {}

    try {
      const { data: rpcData, error: rpcError } = await supabase.rpc('get_user_role_assignments_with_roles')

      if (rpcError) {
        // Fallback to direct query
        tryDirectQuery()
      } else {
        if (rpcData) {
          for (const item of rpcData) {
            if (!roleAssignmentsMap[item.user_id]) {
              roleAssignmentsMap[item.user_id] = []
            }
            roleAssignmentsMap[item.user_id].push({
              assignment_id: item.id,
              role_name: item.role_name || `Unknown (ID: ${item.role_id})`,
              game_name: item.game_name || null,
              business_area_name: item.business_area_name || null
            })
          }
        }
      }
    } catch (error) {
      tryDirectQuery()
    }

    function tryDirectQuery() {
      supabase
        .from('user_role_assignments')
        .select('id, user_id, role_id')
        .then(({ data, error }) => {
          if (error) {
            // Error handling but no logging
          }
        })
    }

    // Note: Removed sample data creation - only show real data from database

    // Transform data and get role assignments
    const transformedProfiles = await Promise.all(
      (profileData || []).map(async (profile: any) => {
        // Get role assignments from our map
        const userRoleAssignments = roleAssignmentsMap[profile.id] || []

        // Get user data from userData lookup
        const userInfo = userData[profile.auth_id] || {}
        const email = userInfo.email || 'N/A'

        // Extract username from email or use default
        const username = email !== 'N/A' ? email.split('@')[0] : 'User'

        // Use last_sign_in_at as-is (database is already GMT+7)
        let lastSignInGmt7 = null
        if (userInfo.last_sign_in_at) {
          // Database is already GMT+7, no conversion needed
          lastSignInGmt7 = new Date(userInfo.last_sign_in_at)
        }

        return {
          ...profile,
          username: username,
          email: email,
          last_sign_in_at: lastSignInGmt7,
          phone: profile.phone || null,
          // avatar_url: null, // TODO: Phát triển chức năng avatar sau
          role_assignments: userRoleAssignments,
          role_name: userRoleAssignments.length > 0 ? userRoleAssignments.map(ra => ra.role_name).join(', ') : 'Chưa có vai trò'
        }
      })
    )

    profiles.value = transformedProfiles
  } catch (error: any) {
    console.error('Error loading profiles:', error)
    message.error(`Lỗi khi tải danh sách profile: ${error.message}`)
  } finally {
    loading.value = false
    emit('loadingChange', false)
  }
}

const loadRoles = async () => {
  try {
    const { data, error } = await supabase
      .from('roles')
      .select('id, name, code')
      .order('name')

    if (error) throw error
    roles.value = data || []
  } catch (error: any) {
    console.error('Error loading roles:', error)
    message.error(`Lỗi khi tải danh sách vai trò: ${error.message}`)
  }
}

const refreshData = async () => {
  await loadRoles()
  await loadProfiles()
  emit('refreshed', 'profiles')
}

const filterProfiles = () => {
  pagination.value.page = 1
}

const handleFilterChange = (filters: any) => {
  currentFilters.value = filters
}

const openEditModal = (profile: Profile) => {
  editForm.value = { ...profile }
  editModalOpen.value = true
}

const closeEditModal = () => {
  editModalOpen.value = false
  editForm.value = {}
  editFormRef.value?.restoreValidation()
}

const saveProfile = async () => {
  if (!editFormRef.value) return

  try {
    await editFormRef.value.validate()
    saving.value = true

    const { id, display_name, phone, notes } = editForm.value

    const { error } = await supabase
      .from('profiles')
      .update({
        display_name: display_name,
        phone: phone || null,
        notes: notes || null,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)

    if (error) {
      console.error('Update error:', error)
      throw error
    }

    message.success('Cập nhật thông tin nhân viên thành công')
    closeEditModal()

    // Force reload profiles with multiple approaches
    await nextTick()
    setTimeout(async () => {
      // Increment key to force refresh
      profilesKey.value++

      // Clear and reload profiles
      profiles.value = []
      await nextTick()

      await loadProfiles()
    }, 200)
  } catch (error: any) {
    console.error('Save profile error:', error)
    message.error(`Lỗi khi cập nhật profile: ${error.message}`)
  } finally {
    saving.value = false
  }
}

const openStatusModal = (profile: Profile) => {
  statusForm.value = {
    profile,
    status: profile.status,
    reason: ''
  }
  statusModalOpen.value = true
}

const closeStatusModal = () => {
  statusModalOpen.value = false
  statusForm.value = { profile: null, status: null, reason: '' }
  statusFormRef.value?.restoreValidation()
}

// Role assignments functions
const openRoleAssignmentsModal = async (profile: Profile) => {
  modalEditingUser.value = profile
  await loadUserAssignments(profile.id)
  roleAssignmentsModalOpen.value = true
}

const closeRoleAssignmentsModal = () => {
  roleAssignmentsModalOpen.value = false
  modalEditingUser.value = null
  modalCurrentAssignments.value = []

  // Reset form
  roleAssignmentForm.value = {
    role_id: null,
    game_attribute_id: null,
    business_area_attribute_id: null
  }
}


const saveStatusChange = async () => {
  if (!statusFormRef.value || !statusForm.value.profile) return

  try {
    await statusFormRef.value.validate()
    statusSaving.value = true

    // Use RPC function to bypass RLS completely
    const { data, error } = await supabase.rpc('update_profile_status_direct', {
      p_profile_id: statusForm.value.profile.id,
      p_new_status: statusForm.value.status,
      p_change_reason: statusForm.value.reason || null
    })

    if (error) {
      throw error
    }

    const result = data as any
    if (!result?.success) {
      throw new Error(result?.message || 'Không thể thay đổi trạng thái')
    }

    message.success('Thay đổi trạng thái nhân viên thành công')
    closeStatusModal()

    // Force reload profiles with multiple approaches
    await nextTick()
    setTimeout(async () => {
      // Increment key to force refresh
      profilesKey.value++

      // Clear and reload profiles
      profiles.value = []
      await nextTick()

      await loadProfiles()
    }, 200)
  } catch (error: any) {
    message.error(`Lỗi khi thay đổi trạng thái: ${error.message}`)
  } finally {
    statusSaving.value = false
  }
}

// Watchers
watch(() => props.refreshTrigger, () => {
  refreshData()
})

watch(() => props.searchQuery, (newQuery) => {
  searchQuery.value = newQuery
  filterProfiles()
})

// Role assignment functions
const loadAttributes = async () => {
  try {
    // Load game attributes
    const { data: gameData } = await supabase
      .from('attributes')
      .select('id, name')
      .eq('type', 'GAME')
      .eq('is_active', true)
      .order('name')

    gameAttributeOptions.value = (gameData || []).map(attr => ({
      label: attr.name,
      value: attr.id
    }))

    // Load business area attributes
    const { data: businessData } = await supabase
      .from('attributes')
      .select('id, name')
      .eq('type', 'BUSINESS_AREA')
      .eq('is_active', true)
      .order('name')

    businessAreaAttributeOptions.value = (businessData || []).map(attr => ({
      label: attr.name,
      value: attr.id
    }))
  } catch (error: any) {
    console.error('Error loading attributes:', error)
    message.error(`Lỗi khi tải danh sách thuộc tính: ${error.message}`)
  }
}

const assignRole = async () => {
  if (!modalEditingUser.value || !roleAssignmentForm.value.role_id) {
    message.error('Vui lòng chọn vai trò')
    return
  }

  assigningRole.value = true

  try {
    const { data, error } = await supabase.rpc('assign_role_to_user', {
      p_user_id: modalEditingUser.value.id,
      p_role_id: roleAssignmentForm.value.role_id,
      p_game_attribute_id: roleAssignmentForm.value.game_attribute_id,
      p_business_area_attribute_id: roleAssignmentForm.value.business_area_attribute_id
    })

    if (error) throw error

    const result = data as any
    if (result?.success) {
      message.success(result.message || 'Đã gán vai trò thành công')

      // Reset form
      roleAssignmentForm.value = {
        role_id: null,
        game_attribute_id: null,
        business_area_attribute_id: null
      }

      // Reload user assignments
      await loadUserAssignments(modalEditingUser.value.id)

      // Reload profiles to update role display
      await loadProfiles()
    } else {
      message.error(result?.message || 'Không thể gán vai trò')
    }
  } catch (error: any) {
    console.error('Error assigning role:', error)
    message.error(`Lỗi khi gán vai trò: ${error.message}`)
  } finally {
    assigningRole.value = false
  }
}

const removeRoleAssignment = async (assignmentId: string) => {
  try {
    const { data, error } = await supabase.rpc('remove_role_from_user', {
      p_assignment_id: assignmentId
    })

    if (error) throw error

    const result = data as any
    if (result?.success) {
      message.success(result.message || 'Đã xóa vai trò thành công')

      // Reload user assignments
      if (modalEditingUser.value) {
        await loadUserAssignments(modalEditingUser.value.id)
      }

      // Reload profiles to update role display
      await loadProfiles()
    } else {
      message.error(result?.message || 'Không thể xóa vai trò')
    }
  } catch (error: any) {
    console.error('Error removing role:', error)
    message.error(`Lỗi khi xóa vai trò: ${error.message}`)
  }
}

const loadUserAssignments = async (userId: string) => {
  try {
    const { data, error } = await supabase.rpc('get_user_role_assignments', {
      p_user_id: userId
    })

    if (error) throw error

    modalCurrentAssignments.value = (data || []).map((assignment: any) => ({
      assignment_id: assignment.assignment_id,
      role_name: assignment.role_name,
      game_name: assignment.game_attribute_name,
      business_area_name: assignment.business_area_attribute_name
    }))
  } catch (error: any) {
    console.error('Error loading user assignments:', error)
    message.error(`Lỗi khi tải phân quyền: ${error.message}`)
  }
}

// Update roleAssignmentColumns to include remove action
const roleAssignmentColumns: DataTableColumns<RoleAssignment> = [
  {
    title: 'Vai trò',
    key: 'role_name'
  },
  {
    title: 'Game',
    key: 'game_name',
    render(row) {
      return row.game_name || '-'
    }
  },
  {
    title: 'Lĩnh vực',
    key: 'business_area_name',
    render(row) {
      return row.business_area_name || '-'
    }
  },
  {
    title: 'Hành động',
    key: 'actions',
    width: 100,
    render(row) {
      return h(NButton, {
        size: 'small',
        type: 'error',
        ghost: true,
        onClick: () => removeRoleAssignment(row.assignment_id)
      }, {
        default: () => 'Xóa',
        icon: () => h(NIcon, { class: 'text-sm' }, () => h(StatusIcon))
      })
    }
  }
]

// Lifecycle
onMounted(async () => {
  await loadRoles()
  await loadAttributes()
  await loadProfiles()
})
</script>

<style scoped>
.profiles-management > * {
  margin-bottom: 1rem;
}

.profiles-management > *:last-child {
  margin-bottom: 0;
}

/* Form sections styling */
.form-section {
  margin-bottom: 24px;
  padding: 20px;
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.form-section:hover {
  border-color: #2080f0;
  box-shadow: 0 2px 8px rgba(32, 128, 240, 0.1);
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
  font-weight: 600;
  color: #333;
  font-size: 16px;
  padding-bottom: 8px;
  border-bottom: 2px solid #2080f0;
}

.profile-form :deep(.n-form-item-label) {
  font-weight: 500;
  color: #555;
}

.profile-form :deep(.n-input) {
  transition: all 0.2s ease;
}

.profile-form :deep(.n-input:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.profile-form :deep(.n-select) {
  transition: all 0.2s ease;
}

.profile-form :deep(.n-select:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.status-change-form :deep(.n-form-item-label) {
  font-weight: 500;
  color: #555;
}

.role-assignments-form :deep(.n-form-item-label) {
  font-weight: 500;
  color: #555;
}

.role-assignments-form :deep(.n-data-table) {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.role-assignments-form :deep(.n-data-table .n-data-table-th) {
  background-color: #f8f9fa;
  font-weight: 600;
}

.empty-state {
  background: #fafbfc;
  border: 2px dashed #d1d5db;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.empty-state:hover {
  border-color: #2080f0;
  background: #f0f7ff;
}

/* Button animations */
.profiles-management :deep(.n-button) {
  transition: all 0.2s ease;
}

.profiles-management :deep(.n-button:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.profiles-management :deep(.n-button:active) {
  transform: translateY(0);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

/* Enhanced action buttons styling */
.profiles-management :deep(.n-button[data-type="primary"]) {
  position: relative;
  overflow: hidden;
}

.profiles-management :deep(.n-button[data-type="primary"]:hover) {
  background: linear-gradient(135deg, #4096ff 0%, #1677ff 100%);
  border-color: #1677ff;
}

.profiles-management :deep(.n-button[data-type="info"]:hover) {
  background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%);
  border-color: #0284c7;
}

.profiles-management :deep(.n-button[data-type="warning"]:hover) {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  border-color: #d97706;
}

/* Modal animations */
.profiles-management :deep(.n-modal) {
  backdrop-filter: blur(8px);
}

.profiles-management :deep(.n-modal .n-card) {
  border-radius: 12px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
  border: none;
  animation: modalSlideIn 0.3s ease-out;
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-30px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* Data table styling */
.profiles-management :deep(.n-data-table) {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.profiles-management :deep(.n-data-table .n-data-table-th) {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #374151;
}

.profiles-management :deep(.n-data-table .n-data-table-tr:hover) {
  background-color: #f0f9ff;
}

/* Tag styling improvements */
.profiles-management :deep(.n-tag) {
  font-weight: 500;
  border-radius: 6px;
  transition: all 0.2s ease;
}

.profiles-management :deep(.n-tag:hover) {
  transform: scale(1.05);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Alert styling */
.profiles-management :deep(.n-alert) {
  border-radius: 8px;
  border-left: 4px solid;
  transition: all 0.2s ease;
}

.profiles-management :deep(.n-alert:hover) {
  transform: translateX(2px);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

/* Responsive design */
@media (max-width: 768px) {
  .form-section {
    padding: 16px;
    margin-bottom: 16px;
  }

  .section-title {
    font-size: 14px;
  }

  .profiles-management :deep(.n-grid) {
    grid-template-columns: 1fr !important;
  }
}

/* Loading states */
.profiles-management :deep(.n-button[loading]) {
  position: relative;
}

.profiles-management :deep(.n-button[loading]::before) {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  animation: loadingShimmer 1.5s infinite;
}

@keyframes loadingShimmer {
  0% { left: -100%; }
  100% { left: 100%; }
}
</style>