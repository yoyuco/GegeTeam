<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between mb-4">
      <div class="flex items-center gap-2">
        <n-input
          v-model:value="q"
          placeholder="Tìm kiếm nhân viên..."
          clearable
          style="width: 280px"
        />
        <n-button tertiary :loading="loading" @click="reload">Làm mới</n-button>
      </div>
    </div>

    <n-data-table
      :columns="columns"
      :data="filteredRows"
      :loading="loading"
      :bordered="false"
      :single-line="false"
      :row-key="(row) => row.id"
      :pagination="{ pageSize: 20 }"
    />

    <n-modal v-model:show="modal.open">
      <n-card
        style="width: 680px"
        :title="`Phân quyền cho: ${modal.editingUser?.display_name}`"
        :bordered="false"
        size="huge"
      >
        <div class="font-medium mb-2">Các gán quyền hiện tại</div>
        <div v-if="!modal.currentAssignments.length" class="text-sm text-neutral-500 mb-4">
          Nhân viên này chưa có gán quyền nào.
        </div>
        <div v-else class="space-y-2 mb-4">
          <div
            v-for="asg in modal.currentAssignments"
            :key="asg.assignment_id"
            class="flex items-center gap-2 bg-neutral-50 p-2 rounded-md"
          >
            <n-tag :bordered="false">{{ asg.role_name }}</n-tag>
            <n-tag v-if="asg.game_code" type="info" :bordered="false">{{ asg.game_code }}</n-tag>
            <n-tag v-if="asg.business_area_code" type="success" :bordered="false">{{
              asg.business_area_code
            }}</n-tag>
            <div class="flex-grow"></div>
            <n-button text type="error" @click="removeAssignment(asg.assignment_id)">
              <template #icon><n-icon :component="CloseIcon" /></template>
            </n-button>
          </div>
        </div>

        <n-divider />

        <div class="font-medium mb-2">Thêm gán quyền mới</div>
        <div class="grid grid-cols-4 gap-3 items-end">
          <n-form-item label="Vai trò" class="col-span-2">
            <n-select
              v-model:value="modal.newAssignment.role_id"
              :options="roleOptions"
              placeholder="Chọn vai trò"
              clearable
            />
          </n-form-item>
          <n-form-item label="Game">
            <n-select
              v-model:value="modal.newAssignment.game_attribute_id"
              :options="gameOptions"
              placeholder="Tất cả"
              clearable
            />
          </n-form-item>
          <n-form-item label="Mảng nghiệp vụ">
            <n-select
              v-model:value="modal.newAssignment.business_area_attribute_id"
              :options="areaOptions"
              placeholder="Tất cả"
              clearable
            />
          </n-form-item>
        </div>
        <n-button block tertiary :disabled="!modal.newAssignment.role_id" @click="addAssignment"
          >Thêm</n-button
        >

        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="modal.open = false">Hủy</n-button>
            <n-button type="primary" :loading="modal.saving" @click="saveAssignments"
              >Lưu thay đổi</n-button
            >
          </div>
        </template>
      </n-card>
    </n-modal>

    <n-modal v-model:show="statusModal.open">
      <n-card
        style="width: 460px"
        :title="`Sửa trạng thái cho: ${modal.editingUser?.display_name}`"
        :bordered="false"
        size="huge"
      >
        <n-form-item label="Trạng thái tài khoản">
          <n-select v-model:value="statusModal.selectedStatus" :options="statusOptions" />
        </n-form-item>
        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="statusModal.open = false">Hủy</n-button>
            <n-button type="primary" :loading="statusModal.saving" @click="saveStatus"
              >Lưu</n-button
            >
          </div>
        </template>
      </n-card>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { computed, h, onMounted, ref, reactive } from 'vue'
import {
  NDataTable,
  type DataTableColumns,
  NTag,
  NButton,
  NModal,
  NSelect,
  NInput,
  NDivider,
  NFormItem,
  NIcon,
  createDiscreteApi,
} from 'naive-ui'
import {
  DiamondOutline,
  ShieldCheckmarkOutline,
  BuildOutline,
  RocketOutline,
  BarChartOutline,
  CloseCircleOutline as CloseIcon,
  RibbonOutline,
  SparklesOutline,
  HourglassOutline,
  NewspaperOutline,
} from '@vicons/ionicons5'
import { supabase } from '@/lib/supabase'

// Types
type Assignment = {
  assignment_id: string
  role_id: string
  role_code: string
  role_name: string
  game_attribute_id: string | null
  game_code: string | null
  game_name: string | null
  business_area_attribute_id: string | null
  business_area_code: string | null
  business_area_name: string | null
}
type UserRow = {
  id: string
  display_name: string
  email: string
  status: string | null
  assignments: Assignment[]
}

// Initialization
const { message } = createDiscreteApi(['message'])

// State
const loading = ref(false)
const rows = ref<UserRow[]>([])
const q = ref('')
const roleOptions = ref<{ label: string; value: string }[]>([])
const gameOptions = ref<{ label: string; value: string }[]>([])
const areaOptions = ref<{ label: string; value: string }[]>([])

const statusOptions = ref([
  { label: 'Đang hoạt động', value: 'active' },
  { label: 'Tạm nghỉ', value: 'inactive' },
  { label: 'Nghỉ vĩnh viễn', value: 'blocked' },
])

const statusModal = reactive({
  open: false,
  saving: false,
  selectedStatus: 'active',
})

const modal = reactive({
  open: false,
  saving: false,
  editingUser: null as UserRow | null,
  currentAssignments: [] as Assignment[],
  newAssignment: {
    role_id: null as string | null,
    game_attribute_id: null as string | null,
    business_area_attribute_id: null as string | null,
  },
})

import type { Component } from 'vue'

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
  farmer: { icon: RocketOutline, color: '#10b981' },
  accountant: { icon: NewspaperOutline, color: '#4f46e5' },
  trial: { icon: HourglassOutline, color: '#64748b' },
  default: { icon: BuildOutline, color: '#64748b' },
}

// Computed
const filteredRows = computed(() => {
  const s = q.value.trim().toLowerCase()
  if (!s) return rows.value
  return rows.value.filter(
    (r) =>
      r.display_name.toLowerCase().includes(s) ||
      r.email.toLowerCase().includes(s) ||
      r.assignments.some((asg) => asg.role_name.toLowerCase().includes(s))
  )
})

// Data Table Columns
const columns: DataTableColumns<UserRow> = [
  {
    title: 'Tên hiển thị',
    key: 'display_name',
    sorter: 'default',
    fixed: 'left',
    width: 180,
  },
  {
    title: 'Email',
    key: 'email',
    ellipsis: true,
    width: 220,
  },
  {
    title: 'Phân quyền chi tiết',
    key: 'assignments',
    render: (row) => {
      if (!row.assignments?.length) return h('span', { class: 'text-neutral-500' }, 'Chưa có')

      const assignmentNodes = row.assignments.map((asg) => {
        const displayInfo = roleDisplay[asg.role_code] || roleDisplay.default
        // Sửa lại để hiển thị name thay vì code
        const context = [asg.game_name, asg.business_area_name].filter(Boolean).join(' / ')

        const roleNode = h('div', { class: 'flex items-center gap-1.5' }, [
          h(NIcon, { component: displayInfo.icon, color: displayInfo.color, title: asg.role_name }),
          h('span', { style: `color: ${displayInfo.color}; font-weight: 500;` }, asg.role_name),
        ])

        const contextNode = h('span', { class: 'text-xs text-neutral-500 ml-5' }, context)

        return h('div', { class: 'my-1' }, [roleNode, context ? contextNode : null])
      })

      return h('div', { class: 'flex flex-col' }, assignmentNodes)
    },
  },
  {
    title: 'Trạng thái',
    key: 'status',
    width: 180,
    render: (row) => {
      const statusText =
        statusOptions.value.find((s) => s.value === row.status)?.label || row.status || 'Chưa rõ'
      const statusTag = h(
        NTag,
        {
          type:
            row.status === 'active' ? 'success' : row.status === 'blocked' ? 'error' : 'warning',
          size: 'small',
        },
        { default: () => statusText }
      )

      const editButton = h(
        NButton,
        {
          size: 'tiny',
          tertiary: true,
          style: 'margin-left: 8px;',
          onClick: () => openStatusModal(row),
        },
        { default: () => 'Sửa' }
      )
      return h('div', { class: 'flex items-center' }, [statusTag, editButton])
    },
  },
  {
    title: 'Hành động',
    key: 'actions',
    align: 'right',
    fixed: 'right',
    width: 120,
    render: (row) =>
      h(NButton, { size: 'small', onClick: () => openModal(row) }, { default: () => 'Sửa quyền' }),
  },
]

// Methods
async function reload() {
  loading.value = true
  try {
    const { data, error } = await supabase.rpc('admin_get_all_users')
    if (error) throw error
    rows.value = data || []
  } catch (e: unknown) {
    const error = e as Error
    message.error(error.message ?? 'Không tải được danh sách nhân viên.')
  } finally {
    loading.value = false
  }
}

async function loadOptions() {
  // Load Roles
  const { data: roleData } = await supabase.from('roles').select('id, name')
  roleOptions.value = (roleData || []).map((r) => ({ label: r.name, value: r.id }))

  // Load Games & Areas from Attributes
  const { data: attrData } = await supabase
    .from('attributes')
    .select('id, name, type')
    .in('type', ['GAME', 'BUSINESS_AREA'])
  gameOptions.value = (attrData || [])
    .filter((a) => a.type === 'GAME')
    .map((a) => ({ label: a.name, value: a.id }))
  areaOptions.value = (attrData || [])
    .filter((a) => a.type === 'BUSINESS_AREA')
    .map((a) => ({ label: a.name, value: a.id }))
}

function openModal(row: UserRow) {
  modal.editingUser = row
  modal.currentAssignments = JSON.parse(JSON.stringify(row.assignments || [])) // Deep copy
  modal.open = true
}

function openStatusModal(row: UserRow) {
  modal.editingUser = row // Dùng lại editingUser từ modal phân quyền
  statusModal.selectedStatus = row.status || 'active'
  statusModal.open = true
}

async function saveStatus() {
  if (!modal.editingUser) return
  statusModal.saving = true
  try {
    const { error } = await supabase.rpc('admin_update_user_status', {
      p_user_id: modal.editingUser.id,
      p_new_status: statusModal.selectedStatus,
    })
    if (error) throw error

    message.success('Cập nhật trạng thái thành công!')
    statusModal.open = false
    await reload()
  } catch (e: unknown) {
    const error = e as Error
    message.error(error.message ?? 'Lỗi khi lưu trạng thái.')
  } finally {
    statusModal.saving = false
  }
}

function addAssignment() {
  if (!modal.newAssignment.role_id) return

  const newAsg = {
    ...modal.newAssignment,
    assignment_id: `new_${Date.now()}`, // temp id
    role_name: roleOptions.value.find((r) => r.value === modal.newAssignment.role_id)?.label || '',
    game_code:
      gameOptions.value.find((g) => g.value === modal.newAssignment.game_attribute_id)?.label ||
      null,
    business_area_code:
      areaOptions.value.find((a) => a.value === modal.newAssignment.business_area_attribute_id)
        ?.label || null,
  }

  // Kiểm tra trùng lặp
  const isDuplicate = modal.currentAssignments.some(
    (asg) =>
      asg.role_id === newAsg.role_id &&
      asg.game_attribute_id === newAsg.game_attribute_id &&
      asg.business_area_attribute_id === newAsg.business_area_attribute_id
  )

  if (isDuplicate) {
    message.warning('Gán quyền này đã tồn tại.')
    return
  }

  modal.currentAssignments.push(newAsg as Assignment)

  // Reset form
  modal.newAssignment.role_id = null
  modal.newAssignment.game_attribute_id = null
  modal.newAssignment.business_area_attribute_id = null
}

function removeAssignment(assignmentId: string) {
  const index = modal.currentAssignments.findIndex((a) => a.assignment_id === assignmentId)
  if (index > -1) {
    modal.currentAssignments.splice(index, 1)
  }
}

async function saveAssignments() {
  if (!modal.editingUser) return
  modal.saving = true
  try {
    const payload = modal.currentAssignments.map((asg) => ({
      role_id: asg.role_id,
      game_attribute_id: asg.game_attribute_id,
      business_area_attribute_id: asg.business_area_attribute_id,
    }))

    const { error } = await supabase.rpc('admin_update_user_assignments', {
      p_user_id: modal.editingUser.id,
      p_assignments: payload,
    })
    if (error) throw error

    message.success('Cập nhật phân quyền thành công!')
    modal.open = false
    await reload()
  } catch (e: unknown) {
    const error = e as Error
    message.error(error.message ?? 'Lỗi khi lưu phân quyền.')
  } finally {
    modal.saving = false
  }
}

// Lifecycle
onMounted(() => {
  Promise.all([reload(), loadOptions()])
})
</script>