<!-- path: src/components/admin/RoleManagerManagement.vue -->
<template>
  <div class="role-manager-management">
    <!-- Header Actions -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-semibold">Quản lý Vai trò & Quyền hạn</h2>
        <n-tag type="info" size="small">{{ filteredRoles.length }} vai trò</n-tag>
      </div>
      <div class="flex items-center gap-2">
        <n-button type="primary" @click="openCreateRoleModal">
          <template #icon>
            <n-icon><PlusIcon /></n-icon>
          </template>
          Thêm vai trò mới
        </n-button>
      </div>
    </div>

    <!-- Main Content -->
    <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
      <!-- Role List -->
      <div class="lg:col-span-1">
        <n-card title="Danh sách Vai trò" size="small">
          <div class="space-y-2">
            <n-button
              v-for="role in roles"
              :key="role.id"
              block
              :type="selectedRoleId === role.id ? 'primary' : 'default'"
              :tertiary="selectedRoleId !== role.id"
              @click="selectRole(role.id)"
            >
              <div class="flex items-center justify-between w-full">
                <span>{{ role.name }}</span>
                <n-tag
                  :type="getRoleTagType(role.code)"
                  size="small"
                >
                  {{ role.code }}
                </n-tag>
              </div>
            </n-button>
          </div>
        </n-card>
      </div>

      <!-- Permission Management -->
      <div class="lg:col-span-3">
        <n-spin :show="loading">
          <n-card v-if="!selectedRoleId" title="Chọn vai trò để quản lý quyền hạn">
            <div class="text-center py-8 text-gray-500">
              Vui lòng chọn một vai trò từ danh sách bên trái để xem và quản lý quyền hạn.
            </div>
          </n-card>

          <div v-else class="space-y-4">
            <!-- Role Info -->
            <n-card size="small">
              <template #header>
                <div class="flex items-center justify-between">
                  <span>Thông tin vai trò: {{ selectedRoleName }}</span>
                  <n-button
                    size="small"
                    type="error"
                    ghost
                    @click="openDeleteRoleModal"
                  >
                    <template #icon>
                      <n-icon><TrashIcon /></n-icon>
                    </template>
                    Xóa vai trò
                  </n-button>
                </div>
              </template>
              <div class="text-sm text-gray-600">
                <p><strong>Mã vai trò:</strong> {{ selectedRole?.code }}</p>
                <p><strong>Số quyền hạn:</strong> {{ selectedPermissionIds.length }} / {{ permissions.length }}</p>
              </div>
            </n-card>

            <!-- Permission Groups -->
            <n-card title="Quản lý Quyền hạn">
              <div v-if="groupedPermissions.length === 0" class="text-center py-8 text-gray-500">
                Không có quyền hạn nào trong hệ thống.
              </div>

              <div v-else class="space-y-6">
                <div
                  v-for="group in groupedPermissions"
                  :key="group.name"
                  class="border rounded-lg p-4"
                >
                  <div class="flex items-center justify-between mb-3">
                    <h4 class="font-medium text-gray-900">{{ group.name }}</h4>
                    <n-button
                      size="small"
                      @click="toggleGroup(group.name)"
                    >
                      {{ isGroupSelected(group.name) ? 'Bỏ chọn tất cả' : 'Chọn tất cả' }}
                    </n-button>
                  </div>

                  <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <n-checkbox
                      v-for="permission in group.permissions"
                      :key="permission.id"
                      :checked="selectedPermissionIds.includes(permission.id)"
                      @update:checked="(checked) => togglePermission(permission.id, checked)"
                    >
                      <div class="flex items-center gap-2">
                        <span class="font-medium">{{ permission.description }}</span>
                        <n-tag size="small" type="info">{{ permission.code }}</n-tag>
                      </div>
                    </n-checkbox>
                  </div>
                </div>
              </div>

              <template #footer>
                <div class="flex justify-between items-center">
                  <div class="text-sm text-gray-600">
                    Đã chọn {{ selectedPermissionIds.length }} quyền hạn
                  </div>
                  <div class="flex gap-2">
                    <n-button @click="resetPermissions">Hủy thay đổi</n-button>
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
              </template>
            </n-card>
          </div>
        </n-spin>
      </div>
    </div>

    <!-- Create/Edit Role Modal -->
    <n-modal v-model:show="roleModalOpen" :mask-closable="false">
      <n-card
        style="width: 500px"
        :title="editingRole ? 'Chỉnh sửa Vai trò' : 'Thêm Vai trò mới'"
        :bordered="false"
        size="huge"
        role="dialog"
        aria-modal="true"
      >
        <n-form
          ref="roleFormRef"
          :model="roleFormData"
          :rules="roleFormRules"
          label-placement="left"
          label-width="120px"
          require-mark-placement="right-hanging"
        >
          <n-form-item label="Mã vai trò" path="code">
            <n-input
              v-model:value="roleFormData.code"
              placeholder="Nhập mã vai trò (ví dụ: trader1)"
              :disabled="!!editingRole"
            />
          </n-form-item>

          <n-form-item label="Tên vai trò" path="name">
            <n-input
              v-model:value="roleFormData.name"
              placeholder="Nhập tên vai trò"
            />
          </n-form-item>
        </n-form>

        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="closeRoleModal">Hủy</n-button>
            <n-button
              type="primary"
              :loading="roleSubmitting"
              @click="handleRoleSubmit"
            >
              {{ editingRole ? 'Cập nhật' : 'Tạo mới' }}
            </n-button>
          </div>
        </template>
      </n-card>
    </n-modal>

    <!-- Delete Role Confirmation Modal -->
    <n-modal v-model:show="deleteRoleModalOpen" :mask-closable="false">
      <n-card
        style="width: 400px"
        title="Xác nhận xóa vai trò"
        :bordered="false"
        size="medium"
        role="dialog"
        aria-modal="true"
      >
        <div class="py-4">
          <p>
            Bạn có chắc chắn muốn xóa vai trò <strong>{{ selectedRoleName }}</strong> không?
          </p>
          <p class="text-sm text-gray-500 mt-2">
            Hành động này không thể hoàn tác và sẽ xóa tất cả các phân quyền liên quan đến vai trò này.
          </p>
        </div>

        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="closeDeleteRoleModal">Hủy</n-button>
            <n-button
              type="error"
              :loading="deletingRole"
              @click="handleDeleteRole"
            >
              Xóa
            </n-button>
          </div>
        </template>
      </n-card>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useMessage } from 'naive-ui'
import {
  NButton, NTag, NIcon, NCard, NSpin, NForm, NFormItem, NInput, NCheckbox
} from 'naive-ui'
import {
  CreateOutline as EditIcon,
  TrashOutline as TrashIcon,
  AddOutline as PlusIcon,
  ShieldCheckmarkOutline as ShieldIcon
} from '@vicons/ionicons5'
import { supabase } from '@/lib/supabase'
import type { FormInst, FormRules } from 'naive-ui'

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

// Types
interface Role {
  id: string
  code: string
  name: string
}

interface Permission {
  id: string
  code: string
  description: string
  description_vi: string | null
  group: string
}

interface GroupedPermission {
  name: string
  permissions: Permission[]
}

interface RoleFormData {
  code: string
  name: string
}

// State
const loading = ref(false)
const saving = ref(false)
const roleSubmitting = ref(false)
const deletingRole = ref(false)
const roleModalOpen = ref(false)
const deleteRoleModalOpen = ref(false)
const roles = ref<Role[]>([])
const permissions = ref<Permission[]>([])
const selectedRoleId = ref<string>('')
const selectedPermissionIds = ref<string[]>([])
const initialPermissionIds = ref<string[]>([])
const editingRole = ref<Role | null>(null)
const roleFormRef = ref<FormInst | null>(null)

const roleFormData = ref<RoleFormData>({
  code: '',
  name: ''
})

// Form validation rules
const roleFormRules: FormRules = {
  code: [
    { required: true, message: 'Vui lòng nhập mã vai trò', trigger: 'blur' },
    { min: 2, message: 'Mã vai trò phải có ít nhất 2 ký tự', trigger: 'blur' },
    { pattern: /^[a-z0-9_]+$/, message: 'Mã vai trò chỉ chứa chữ thường, số và dấu gạch dưới', trigger: 'blur' }
  ],
  name: [
    { required: true, message: 'Vui lòng nhập tên vai trò', trigger: 'blur' },
    { min: 2, message: 'Tên vai trò phải có ít nhất 2 ký tự', trigger: 'blur' }
  ]
}

// Computed
const filteredRoles = computed(() => {
  if (!props.searchQuery) return roles.value

  const query = props.searchQuery.toLowerCase()
  return roles.value.filter(role =>
    role.code.toLowerCase().includes(query) ||
    role.name.toLowerCase().includes(query)
  )
})

const selectedRole = computed(() => {
  return roles.value.find(role => role.id === selectedRoleId.value)
})

const selectedRoleName = computed(() => {
  return selectedRole.value?.name || ''
})

const groupedPermissions = computed(() => {
  const groups: Record<string, Permission[]> = {}

  permissions.value.forEach(permission => {
    if (!groups[permission.group]) {
      groups[permission.group] = []
    }
    groups[permission.group].push(permission)
  })

  return Object.entries(groups).map(([name, permissions]) => ({
    name,
    permissions
  }))
})

const hasChanges = computed(() => {
  return JSON.stringify(selectedPermissionIds.value.sort()) !==
         JSON.stringify(initialPermissionIds.value.sort())
})

// Methods
const getRoleTagType = (code: string) => {
  const adminRoles = ['admin', 'mod', 'manager']
  const leaderRoles = ['leader', 'trader_leader', 'farmer_leader']

  if (adminRoles.includes(code)) return 'error'
  if (leaderRoles.includes(code)) return 'warning'
  return 'info'
}

const loadRoles = async () => {
  loading.value = true
  emit('loadingChange', true)

  try {
    const { data, error } = await supabase
      .from('roles')
      .select('*')
      .order('code')

    if (error) throw error
    roles.value = data || []
  } catch (error) {
    console.error('Error loading roles:', error)
    message.error('Không thể tải danh sách vai trò')
  } finally {
    loading.value = false
    emit('loadingChange', false)
  }
}

const loadPermissions = async () => {
  try {
    const { data, error } = await supabase
      .from('permissions')
      .select('*')
      .order('group, code')

    if (error) throw error
    permissions.value = data || []
  } catch (error) {
    console.error('Error loading permissions:', error)
    message.error('Không thể tải danh sách quyền hạn')
  }
}

const selectRole = async (roleId: string) => {
  selectedRoleId.value = roleId
  await loadRolePermissions(roleId)
}

const loadRolePermissions = async (roleId: string) => {
  try {
    const { data, error } = await supabase
      .from('role_permissions')
      .select('permission_id')
      .eq('role_id', roleId)

    if (error) throw error

    selectedPermissionIds.value = (data || []).map(rp => rp.permission_id)
    initialPermissionIds.value = [...selectedPermissionIds.value]
  } catch (error) {
    console.error('Error loading role permissions:', error)
    message.error('Không thể tải quyền hạn của vai trò')
  }
}

const togglePermission = (permissionId: string, checked: boolean) => {
  if (checked) {
    if (!selectedPermissionIds.value.includes(permissionId)) {
      selectedPermissionIds.value.push(permissionId)
    }
  } else {
    const index = selectedPermissionIds.value.indexOf(permissionId)
    if (index > -1) {
      selectedPermissionIds.value.splice(index, 1)
    }
  }
}

const toggleGroup = (groupName: string) => {
  const group = groupedPermissions.value.find(g => g.name === groupName)
  if (!group) return

  const groupPermissionIds = group.permissions.map(p => p.id)
  const isAllSelected = groupPermissionIds.every(id => selectedPermissionIds.value.includes(id))

  if (isAllSelected) {
    // Remove all permissions in this group
    selectedPermissionIds.value = selectedPermissionIds.value.filter(
      id => !groupPermissionIds.includes(id)
    )
  } else {
    // Add all permissions in this group
    groupPermissionIds.forEach(id => {
      if (!selectedPermissionIds.value.includes(id)) {
        selectedPermissionIds.value.push(id)
      }
    })
  }
}

const isGroupSelected = (groupName: string) => {
  const group = groupedPermissions.value.find(g => g.name === groupName)
  if (!group) return false

  const groupPermissionIds = group.permissions.map(p => p.id)
  return groupPermissionIds.every(id => selectedPermissionIds.value.includes(id))
}

const resetPermissions = () => {
  selectedPermissionIds.value = [...initialPermissionIds.value]
}

const savePermissions = async () => {
  if (!selectedRoleId.value) return

  saving.value = true

  try {
    // Delete existing role permissions
    await supabase
      .from('role_permissions')
      .delete()
      .eq('role_id', selectedRoleId.value)

    // Insert new role permissions
    if (selectedPermissionIds.value.length > 0) {
      const rolePermissions = selectedPermissionIds.value.map(permissionId => ({
        role_id: selectedRoleId.value,
        permission_id: permissionId
      }))

      const { error } = await supabase
        .from('role_permissions')
        .insert(rolePermissions)

      if (error) throw error
    }

    initialPermissionIds.value = [...selectedPermissionIds.value]
    message.success('Lưu quyền hạn thành công')
    emit('refreshed', 'roleManager')
  } catch (error) {
    console.error('Error saving role permissions:', error)
    message.error('Không thể lưu quyền hạn')
  } finally {
    saving.value = false
  }
}

const openCreateRoleModal = () => {
  editingRole.value = null
  roleFormData.value = {
    code: '',
    name: ''
  }
  roleModalOpen.value = true
}

const openEditRoleModal = (role: Role) => {
  editingRole.value = role
  roleFormData.value = {
    code: role.code,
    name: role.name
  }
  roleModalOpen.value = true
}

const closeRoleModal = () => {
  roleModalOpen.value = false
  editingRole.value = null
  roleFormRef.value?.restoreValidation()
}

const handleRoleSubmit = async () => {
  if (!roleFormRef.value) return

  try {
    await roleFormRef.value.validate()
    roleSubmitting.value = true

    const roleData = {
      code: roleFormData.value.code.trim(),
      name: roleFormData.value.name.trim()
    }

    let error: any

    if (editingRole.value) {
      // Update existing role
      const { error: updateError } = await supabase
        .from('roles')
        .update(roleData)
        .eq('id', editingRole.value.id)
      error = updateError
    } else {
      // Create new role
      const { error: createError } = await supabase
        .from('roles')
        .insert(roleData)
      error = createError
    }

    if (error) throw error

    message.success(editingRole.value ? 'Cập nhật vai trò thành công' : 'Tạo vai trò thành công')
    closeRoleModal()
    await loadRoles()
    emit('refreshed', 'roleManager')
  } catch (error) {
    console.error('Error saving role:', error)
    message.error('Không thể lưu vai trò')
  } finally {
    roleSubmitting.value = false
  }
}

const openDeleteRoleModal = () => {
  deleteRoleModalOpen.value = true
}

const closeDeleteRoleModal = () => {
  deleteRoleModalOpen.value = false
}

const handleDeleteRole = async () => {
  if (!selectedRoleId.value) return

  deletingRole.value = true

  try {
    // Delete role permissions first
    await supabase
      .from('role_permissions')
      .delete()
      .eq('role_id', selectedRoleId.value)

    // Delete the role
    const { error } = await supabase
      .from('roles')
      .delete()
      .eq('id', selectedRoleId.value)

    if (error) throw error

    message.success('Xóa vai trò thành công')
    selectedRoleId.value = ''
    await loadRoles()
    emit('refreshed', 'roleManager')
  } catch (error) {
    console.error('Error deleting role:', error)
    message.error('Không thể xóa vai trò')
  } finally {
    deletingRole.value = false
    closeDeleteRoleModal()
  }
}

// Lifecycle
onMounted(() => {
  loadRoles()
  loadPermissions()
})

// Watch for refresh trigger
watch(() => props.refreshTrigger, () => {
  loadRoles()
})
</script>

<style scoped>

:deep(.n-form-item-label) {
  font-weight: 500;
}

/* Role button styling */
.role-button {
  transition: all 0.2s ease;
}

.role-button:hover {
  transform: translateX(4px);
}

/* Permission group styling */
.permission-group {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.permission-group:hover {
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

/* Checkbox styling */
:deep(.n-checkbox) {
  align-items: flex-start;
  padding: 8px 0;
}

:deep(.n-checkbox__label) {
  flex: 1;
  margin-left: 8px;
}
</style>