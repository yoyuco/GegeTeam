<template>
  <div class="space-y-6">
    <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6 items-start">
      <div class="col-span-1 space-y-2 sticky top-4">
        <div class="text-sm font-medium text-neutral-600 px-2">Chọn vai trò để sửa</div>
        <n-button
          v-for="role in roles"
          :key="role.id"
          block
          :type="selectedRoleId === role.id ? 'primary' : 'default'"
          :tertiary="selectedRoleId !== role.id"
          @click="selectRole(role.id)"
        >
          {{ role.name }}
        </n-button>
      </div>

      <div class="md:col-span-2 lg:col-span-3">
        <n-spin :show="loading">
          <div v-if="!selectedRoleId" class="text-center text-neutral-500 py-10">
            Vui lòng chọn một vai trò từ danh sách bên trái.
          </div>
          <div v-else class="space-y-6">
            <div v-for="(group, groupName) in groupedPermissions" :key="groupName">
              <h3 class="text-lg font-semibold mb-3 border-b pb-2">{{ groupName }}</h3>
              <n-checkbox-group v-model:value="selectedPermissionIds">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-x-4 gap-y-3">
                  <div v-for="perm in group" :key="perm.id">
                    <n-checkbox :value="perm.id">
                      <n-tooltip v-if="perm.description_vi" trigger="hover" placement="top-start">
                        <template #trigger>
                          <span>{{ perm.code }}</span>
                        </template>
                        {{ perm.description_vi }}
                      </n-tooltip>
                      <span v-else>{{ perm.code }}</span>
                    </n-checkbox>
                  </div>
                </div>
              </n-checkbox-group>
            </div>
            <n-button
              type="primary"
              :loading="saving"
              :disabled="!hasChanges"
              @click="savePermissions"
            >
              Lưu thay đổi cho vai trò {{ selectedRoleName }}
            </n-button>
          </div>
        </n-spin>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import {
  NSpin,
  NButton,
  NCheckboxGroup,
  NCheckbox,
  NTooltip,
  createDiscreteApi,
} from 'naive-ui'
import type { Role, Permission, RolePermissionAssignment } from '@/types/app'

// TYPES
const { message } = createDiscreteApi(['message'])

// STATE
const loading = ref(true)
const saving = ref(false)

const roles = ref<Role[]>([])
const permissions = ref<Permission[]>([])
const assignments = ref<RolePermissionAssignment[]>([])

const selectedRoleId = ref<string | null>(null)
const selectedPermissionIds = ref<string[]>([])
const initialPermissionIds = ref<string[]>([])

// COMPUTED
const groupedPermissions = computed(() => {
  const groups: Record<string, Permission[]> = {}
  for (const perm of permissions.value) {
    if (!groups[perm.group]) {
      groups[perm.group] = []
    }
    groups[perm.group].push(perm)
  }
  return groups
})

const selectedRoleName = computed(() => {
  return roles.value.find((r) => r.id === selectedRoleId.value)?.name || ''
})

const hasChanges = computed(() => {
  if (!selectedRoleId.value) return false
  const initialSet = new Set(initialPermissionIds.value)
  const currentSet = new Set(selectedPermissionIds.value)
  if (initialSet.size !== currentSet.size) return true
  for (const id of initialSet) {
    if (!currentSet.has(id)) return true
  }
  return false
})

// METHODS
async function loadData() {
  loading.value = true
  try {
    const { data, error } = await supabase.rpc('admin_get_roles_and_permissions')
    if (error) throw error
    roles.value = data.roles || []
    permissions.value = data.permissions || []
    assignments.value = data.assignments || []
  } catch (e: unknown) {
    const error = e as Error
    message.error(error.message || 'Không thể tải dữ liệu phân quyền.')
  } finally {
    loading.value = false
  }
}

function selectRole(roleId: string) {
  selectedRoleId.value = roleId
  const currentAssignments = assignments.value
    .filter((a) => a.role_id === roleId)
    .map((a) => a.permission_id)

  selectedPermissionIds.value = [...currentAssignments]
  initialPermissionIds.value = [...currentAssignments]
}

async function savePermissions() {
  if (!selectedRoleId.value) return
  saving.value = true
  try {
    const { error } = await supabase.rpc('admin_update_permissions_for_role', {
      p_role_id: selectedRoleId.value,
      p_permission_ids: selectedPermissionIds.value,
    })
    if (error) throw error
    message.success(`Đã cập nhật quyền cho vai trò "${selectedRoleName.value}"`)
    // Tải lại dữ liệu để đồng bộ
    await loadData()
    // Cập nhật lại initial state sau khi lưu
    initialPermissionIds.value = [...selectedPermissionIds.value]
  } catch (e: unknown) {
    const error = e as Error
    message.error(error.message || 'Lưu thất bại.')
  } finally {
    saving.value = false
  }
}

// LIFECYCLE
onMounted(() => {
  loadData()
})
</script>