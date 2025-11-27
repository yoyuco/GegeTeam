<!-- path: src/components/admin/RoleManagement.vue -->
<template>
  <div class="roles-management">
    <!-- Header Actions -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-semibold">Quản lý Vai trò & Quyền hạn</h2>
        <n-tag type="info" size="small">{{ filteredRoles.length }} vai trò</n-tag>
        <n-tag type="success" size="small">{{ permissions.length }} quyền hạn</n-tag>
      </div>
      <div class="flex items-center gap-2">
        <n-button type="primary" @click="openCreateRoleModal">
          <template #icon>
            <n-icon><PlusIcon /></n-icon>
          </template>
          Thêm vai trò mới
        </n-button>
        <n-button type="tertiary" @click="refreshRoles">
          <template #icon>
            <n-icon><RefreshIcon /></n-icon>
          </template>
          Làm mới
        </n-button>
      </div>
    </div>

    <!-- Filter Panel -->
    <FilterPanel
      :show-status-filter="true"
      :show-role-search="true"
      @filter-change="handleFilterChange"
    />

    <!-- Role Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="role in filteredRoles"
        :key="role.id"
        class="role-card bg-white border border-gray-200 rounded-lg p-4 hover:shadow-lg transition-all duration-200 cursor-pointer hover:border-blue-300"
        @click="selectRole(role)"
      >
        <div class="flex justify-between items-start mb-3">
          <div class="flex-1">
            <h3 class="font-semibold text-lg text-gray-900 mb-1">{{ role.name }}</h3>
            <p class="text-sm text-gray-600">Code: {{ role.code }}</p>
          </div>
          <div class="flex gap-2">
            <n-button size="small" type="primary" tertiary @click.stop="editRole(role)">
              <template #icon><EditIcon /></template>
            </n-button>
            <n-button size="small" type="error" tertiary @click.stop="deleteRole(role)">
              <template #icon><TrashIcon /></template>
            </n-button>
          </div>
        </div>
        <div class="flex justify-between items-center">
          <div class="text-sm text-gray-600">
            {{ getRolePermissionCount(role.id) }} quyền hạn được gán
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="filteredRoles.length === 0 && !loading" class="text-center py-10">
      <n-empty description="Không tìm thấy vai trò nào">
        <template #extra>
          <n-button type="primary" @click="openCreateRoleModal">
            Tạo vai trò mới
          </n-button>
        </template>
      </n-empty>
    </div>

    <!-- Create/Edit Role Modal -->
    <n-modal
      v-model:show="roleModalOpen"
      :mask-closable="false"
      :style="{ width: '600px' }"
      preset="card"
      :title="editingRole ? 'Chỉnh sửa Vai trò' : 'Thêm Vai trò mới'"
      size="large"
    >
      <div class="role-form">
        <n-form
          ref="roleFormRef"
          :model="roleForm"
          :rules="roleFormRules"
          label-placement="top"
          label-width="auto"
          require-mark-placement="right-hanging"
          size="large"
        >
          <n-form-item label="Code vai trò" path="code">
            <n-input
              v-model:value="roleForm.code"
              placeholder="Nhập code vai trò (ví dụ: ADMIN, MANAGER)"
              size="large"
            />
          </n-form-item>

          <n-form-item label="Tên vai trò" path="name">
            <n-input
              v-model:value="roleForm.name"
              placeholder="Nhập tên vai trò (ví dụ: Admin, Manager)"
              size="large"
            />
          </n-form-item>
        </n-form>

        <div class="flex justify-end gap-3 mt-6">
          <n-button @click="roleModalOpen = false">Hủy</n-button>
          <n-button type="primary" :loading="saving" @click="saveRole">
            {{ editingRole ? 'Cập nhật' : 'Tạo' }}
          </n-button>
        </div>
      </div>
    </n-modal>

    <!-- Permission Management Modal -->
    <n-modal
      v-model:show="permissionModalOpen"
      :mask-closable="false"
      :style="{ width: '900px', maxHeight: '80vh' }"
      preset="card"
      :title="`Quản lý Quyền hạn cho vai trò: ${selectedRole?.name}`"
      size="large"
    >
      <div class="permission-modal">
        <n-spin :show="saving">
          <div class="space-y-6">
            <!-- Permission Search -->
            <n-input
              v-model:value="permissionSearchQuery"
              placeholder="Tìm kiếm quyền hạn..."
              clearable
              size="large"
            >
              <template #prefix>
                <n-icon><SearchIcon /></n-icon>
              </template>
            </n-input>

            <!-- Permission Groups -->
            <div v-for="(group, groupName) in groupedPermissions" :key="groupName">
              <h3 class="text-lg font-semibold mb-3 border-b pb-2">{{ groupName }}</h3>
              <n-checkbox-group v-model:value="selectedPermissionIds">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-x-4 gap-y-3">
                  <div v-for="perm in group" :key="perm.id">
                    <n-checkbox :value="perm.id">
                      <n-tooltip v-if="perm.description_vi" trigger="hover" placement="top-start">
                        <template #trigger>
                          <span class="font-mono text-sm">{{ perm.code }}</span>
                        </template>
                        {{ perm.description_vi }}
                      </n-tooltip>
                      <span v-else class="font-mono text-sm">{{ perm.code }}</span>
                    </n-checkbox>
                  </div>
                </div>
              </n-checkbox-group>
            </div>

            <!-- Action Buttons -->
            <div class="flex justify-between items-center pt-4 border-t">
              <div class="text-sm text-gray-600">
                Đã chọn {{ selectedPermissionIds.length }} quyền hạn
              </div>
              <div class="flex gap-3">
                <n-button @click="permissionModalOpen = false">Hủy</n-button>
                <n-button
                  type="primary"
                  :loading="saving"
                  :disabled="!hasChanges"
                  @click="savePermissions"
                >
                  Lưu thay đổi
                </n-button>
              </div>
            </div>
          </div>
        </n-spin>
      </div>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch, reactive } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/auth'
import {
  NCard,
  NButton,
  NSpin,
  NTag,
  NModal,
  NForm,
  NFormItem,
  NInput,
  NSwitch,
  NCheckboxGroup,
  NCheckbox,
  NTooltip,
  NIcon,
  NEmpty,
  createDiscreteApi,
  type FormInst,
  type FormRules,
} from 'naive-ui'
import {
  Add as PlusIcon,
  Refresh as RefreshIcon,
  Search as SearchIcon,
  Create as EditIcon,
  Trash as TrashIcon
} from '@vicons/ionicons5'
import FilterPanel from './FilterPanel.vue'

// Types
interface Role {
  id: string
  code: string
  name: string
  // Note: description, is_active, created_at, updated_at không tồn tại trong bảng thực tế
}

interface Permission {
  id: string
  code: string
  group: string
  description: string | null
  description_vi: string | null
}

interface RolePermissionAssignment {
  role_id: string
  permission_id: string
  assigned_at: string
  assigned_by: string
}

interface RoleForm {
  name: string
  code: string
}

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
const { message } = createDiscreteApi(['message'])
const auth = useAuth()

// State
const loading = ref(true)
const saving = ref(false)
const roles = ref<Role[]>([])
const permissions = ref<Permission[]>([])
const assignments = ref<RolePermissionAssignment[]>([])

const roleModalOpen = ref(false)
const permissionModalOpen = ref(false)
const selectedRole = ref<Role | null>(null)
const editingRole = ref<Role | null>(null)

const selectedPermissionIds = ref<string[]>([])
const initialPermissionIds = ref<string[]>([])
const permissionSearchQuery = ref('')
const currentFilters = ref<Record<string, any>>({})

// Forms
const roleFormRef = ref<FormInst | null>(null)
const roleForm = reactive<RoleForm>({
  name: '',
  code: ''
})

const roleFormRules: FormRules = {
  code: [
    { required: true, message: 'Vui lòng nhập code vai trò', trigger: 'blur' },
    { min: 2, message: 'Code vai trò phải có ít nhất 2 ký tự', trigger: 'blur' },
    { pattern: /^[A-Z0-9_]+$/, message: 'Code chỉ chứa chữ hoa, số và dấu gạch dưới', trigger: 'blur' }
  ],
  name: [
    { required: true, message: 'Vui lòng nhập tên vai trò', trigger: 'blur' },
    { min: 2, message: 'Tên vai trò phải có ít nhất 2 ký tự', trigger: 'blur' }
  ]
}

// Computed
const filteredRoles = computed(() => {
  let result = roles.value

  // Apply search query
  if (props.searchQuery) {
    const query = props.searchQuery.toLowerCase()
    result = result.filter(role =>
      role.name.toLowerCase().includes(query) ||
      role.code.toLowerCase().includes(query)
    )
  }

  // Apply role search filter
  if (currentFilters.value.roleSearch) {
    const search = currentFilters.value.roleSearch.toLowerCase()
    result = result.filter(role =>
      role.name.toLowerCase().includes(search) ||
      role.code.toLowerCase().includes(search)
    )
  }

  return result
})

const groupedPermissions = computed(() => {
  const groups: Record<string, Permission[]> = {}
  for (const perm of permissions.value) {
    const code = perm.code.toLowerCase()
    const search = permissionSearchQuery.value.toLowerCase()

    if (!search || code.includes(search) || perm.description_vi?.toLowerCase().includes(search)) {
      if (!groups[perm.group]) {
        groups[perm.group] = []
      }
      groups[perm.group].push(perm)
    }
  }
  return groups
})

const hasChanges = computed(() => {
  if (!selectedRole.value) return false
  const initialSet = new Set(initialPermissionIds.value)
  const currentSet = new Set(selectedPermissionIds.value)
  if (initialSet.size !== currentSet.size) return true
  for (const id of initialSet) {
    if (!currentSet.has(id)) return true
  }
  return false
})

// Methods
const loadData = async () => {
  loading.value = true
  emit('loadingChange', true)

  try {
    const { data, error } = await supabase.rpc('admin_get_roles_and_permissions')
    if (error) throw error
    roles.value = data.roles || []
    permissions.value = data.permissions || []
    assignments.value = data.assignments || []
  } catch (error) {
    console.error('Error loading role data:', error)
    message.error('Không thể tải dữ liệu phân quyền')
  } finally {
    loading.value = false
    emit('loadingChange', false)
  }
}

const selectRole = (role: Role) => {
  selectedRole.value = role
  const currentAssignments = assignments.value
    .filter((a) => a.role_id === role.id)
    .map((a) => a.permission_id)

  selectedPermissionIds.value = [...currentAssignments]
  initialPermissionIds.value = [...currentAssignments]
  permissionModalOpen.value = true
}

const openCreateRoleModal = () => {
  editingRole.value = null
  roleForm.name = ''
  roleForm.code = ''
  roleModalOpen.value = true
}

const editRole = (role: Role) => {
  editingRole.value = role
  roleForm.name = role.name
  roleForm.code = role.code
  roleModalOpen.value = true
}

const deleteRole = (role: Role) => {
  if (confirm(`Bạn có chắc chắn muốn xóa vai trò "${role.name}"?`)) {
    // TODO: Implement delete functionality
    message.warning('Chức năng xóa vai trò sẽ được triển khai sau')
  }
}

const saveRole = async () => {
  try {
    await roleFormRef.value?.validate()
  } catch {
    return
  }

  saving.value = true
  try {
    if (editingRole.value) {
      // Update existing role
      const { error } = await supabase
        .from('roles')
        .update({
          code: roleForm.code.toUpperCase(),
          name: roleForm.name
        })
        .eq('id', editingRole.value.id)

      if (error) throw error
      message.success('Đã cập nhật vai trò thành công')
    } else {
      // Create new role
      const { error } = await supabase
        .from('roles')
        .insert({
          code: roleForm.code.toUpperCase(),
          name: roleForm.name
        })

      if (error) throw error
      message.success('Đã tạo vai trò thành công')
    }

    roleModalOpen.value = false
    await loadData()
  } catch (error) {
    console.error('Error saving role:', error)
    message.error('Không thể lưu vai trò')
  } finally {
    saving.value = false
  }
}

const savePermissions = async () => {
  if (!selectedRole.value) return

  saving.value = true
  try {
    const { error } = await supabase.rpc('admin_update_permissions_for_role', {
      p_role_id: selectedRole.value.id,
      p_permission_ids: selectedPermissionIds.value,
    })
    if (error) throw error

    message.success(`Đã cập nhật quyền cho vai trò "${selectedRole.value.name}"`)
    await loadData()

    // Update initial state after saving
    initialPermissionIds.value = [...selectedPermissionIds.value]
    permissionModalOpen.value = false
  } catch (error) {
    console.error('Error saving permissions:', error)
    message.error('Lưu thất bại')
  } finally {
    saving.value = false
  }
}

const getRolePermissionCount = (roleId: string) => {
  return assignments.value.filter(a => a.role_id === roleId).length
}

const handleFilterChange = (filters: any) => {
  currentFilters.value = filters
}

const refreshRoles = () => {
  loadData()
}

// Watch for refresh trigger
watch(() => props.refreshTrigger, () => {
  loadData()
})

// Lifecycle
onMounted(() => {
  loadData()
})
</script>

<style scoped>
.roles-management {
  /* Component-specific styles */
}

.role-card {
  transition: all 0.2s ease-in-out;
}

.role-card:hover {
  transform: translateY(-2px);
}

.role-form, .permission-modal {
  max-height: 70vh;
  overflow-y: auto;
}

:deep(.n-checkbox-group) {
  width: 100%;
}

:deep(.n-checkbox) {
  margin-bottom: 8px;
  width: 100%;
}

.permission-modal {
  padding: 1rem 0;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .grid {
    grid-template-columns: 1fr;
  }
}
</style>