<template>
  <div class="space-y-6">
    <!-- Employee Shift Assignments -->
    <n-card title="Phân công Nhân viên vào Ca" :bordered="false">
      <template #header-extra>
        <n-button type="primary" @click="openEmployeeAssignmentModal()">
          <template #icon>
            <n-icon :component="AddIcon" />
          </template>
          Phân công Nhân viên
        </n-button>
      </template>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-4">
        <n-select
          v-model:value="selectedDate"
          type="date"
          placeholder="Chọn ngày"
          @update:value="loadEmployeeAssignments"
        />
        <n-select
          v-model:value="selectedShift"
          :options="shiftOptions"
          placeholder="Lọc theo ca"
          clearable
          @update:value="loadEmployeeAssignments"
        />
      </div>

      <n-data-table
        :columns="employeeAssignmentColumns"
        :data="employeeAssignments"
        :loading="loadingEmployeeAssignments"
        :bordered="false"
        :single-line="false"
        :pagination="{ pageSize: 10 }"
      />
    </n-card>

    <!-- Account Access Assignments -->
    <n-card title="Phân quyền truy cập Tài khoản" :bordered="false">
      <template #header-extra>
        <n-button type="primary" @click="openAccountAccessModal()">
          <template #icon>
            <n-icon :component="AddIcon" />
          </template>
          Phân quyền Account
        </n-button>
      </template>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-4">
        <n-select
          v-model:value="accessFilter.employee"
          :options="employeeOptions"
          placeholder="Lọc theo nhân viên"
          clearable
          @update:value="loadAccountAccess"
        />
        <n-select
          v-model:value="accessFilter.shift"
          :options="shiftOptions"
          placeholder="Lọc theo ca"
          clearable
          @update:value="loadAccountAccess"
        />
        <n-select
          v-model:value="accessFilter.channel"
          :options="channelOptions"
          placeholder="Lọc theo kênh"
          clearable
          @update:value="loadAccountAccess"
        />
      </div>

      <n-data-table
        :columns="accountAccessColumns"
        :data="accountAccess"
        :loading="loadingAccountAccess"
        :bordered="false"
        :single-line="false"
        :pagination="{ pageSize: 15 }"
      />
    </n-card>

    <!-- Employee Assignment Modal -->
    <n-modal v-model:show="employeeModal.open">
      <n-card
        style="width: 500px"
        title="Phân công Nhân viên vào Ca làm việc"
        :bordered="false"
        size="huge"
      >
        <n-form :model="employeeModal.form" :rules="employeeAssignmentRules" ref="employeeFormRef">
          <n-form-item label="Nhân viên" path="employee_profile_id">
            <n-select
              v-model:value="employeeModal.form.employee_profile_id"
              :options="employeeOptions"
              placeholder="Chọn nhân viên"
              filterable
            />
          </n-form-item>
          <n-form-item label="Ca làm việc" path="shift_id">
            <n-select
              v-model:value="employeeModal.form.shift_id"
              :options="shiftOptions"
              placeholder="Chọn ca làm việc"
            />
          </n-form-item>
          <n-form-item label="Ngày phân công" path="assigned_date">
            <n-date-picker
              v-model:value="employeeModal.form.assigned_date"
              type="date"
              placeholder="Chọn ngày"
            />
          </n-form-item>
          <n-form-item>
            <n-switch v-model:value="employeeModal.form.is_active">
              <template #checked>Đang hoạt động</template>
              <template #unchecked>Không hoạt động</template>
            </n-switch>
          </n-form-item>
        </n-form>

        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="employeeModal.open = false">Hủy</n-button>
            <n-button type="primary" :loading="employeeModal.saving" @click="saveEmployeeAssignment">
              Lưu
            </n-button>
          </div>
        </template>
      </n-card>
    </n-modal>

    <!-- Account Access Modal -->
    <n-modal v-model:show="accountAccessModal.open">
      <n-card
        style="width: 600px"
        title="Phân quyền truy cập Tài khoản Game"
        :bordered="false"
        size="huge"
      >
        <n-form :model="accountAccessModal.form" :rules="accountAccessRules" ref="accountAccessFormRef">
          <div class="grid grid-cols-2 gap-4">
            <n-form-item label="Nhân viên" path="employee_profile_id">
              <n-select
                v-model:value="accountAccessModal.form.employee_profile_id"
                :options="employeeOptions"
                placeholder="Chọn nhân viên"
                filterable
              />
            </n-form-item>
            <n-form-item label="Ca làm việc" path="shift_id">
              <n-select
                v-model:value="accountAccessModal.form.shift_id"
                :options="shiftOptions"
                placeholder="Chọn ca làm việc"
              />
            </n-form-item>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <n-form-item label="Tài khoản Game" path="game_account_id">
              <n-select
                v-model:value="accountAccessModal.form.game_account_id"
                :options="gameAccountOptions"
                placeholder="Chọn tài khoản"
                filterable
              />
            </n-form-item>
            <n-form-item label="Kênh" path="channel_id">
              <n-select
                v-model:value="accountAccessModal.form.channel_id"
                :options="channelOptions"
                placeholder="Chọn kênh"
              />
            </n-form-item>
          </div>
          <n-form-item label="Cấp độ truy cập" path="access_level">
            <n-select
              v-model:value="accountAccessModal.form.access_level"
              :options="accessLevelOptions"
              placeholder="Chọn cấp độ truy cập"
            />
          </n-form-item>
          <n-form-item label="Ngày phân công" path="assigned_date">
            <n-date-picker
              v-model:value="accountAccessModal.form.assigned_date"
              type="date"
              placeholder="Chọn ngày"
            />
          </n-form-item>
          <n-form-item label="Ghi chú" path="notes">
            <n-input
              v-model:value="accountAccessModal.form.notes"
              type="textarea"
              placeholder="Ghi chú về phân công này"
              :rows="3"
            />
          </n-form-item>
          <n-form-item>
            <n-switch v-model:value="accountAccessModal.form.is_active">
              <template #checked>Đang hoạt động</template>
              <template #unchecked>Không hoạt động</template>
            </n-switch>
          </n-form-item>
        </n-form>

        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="accountAccessModal.open = false">Hủy</n-button>
            <n-button type="primary" :loading="accountAccessModal.saving" @click="saveAccountAccess">
              Lưu
            </n-button>
          </div>
        </template>
      </n-card>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, h } from 'vue'
import { supabase } from '@/lib/supabase'
import {
  NCard,
  NButton,
  NIcon,
  NDataTable,
  type DataTableColumns,
  NModal,
  NForm,
  NFormItem,
  NSelect,
  NDatePicker,
  NInput,
  NSwitch,
  NTag,
  createDiscreteApi,
} from 'naive-ui'
import { Add as AddIcon, Trash as TrashIcon } from '@vicons/ionicons5'
import {
  getGMT7TodayTimestamp,
  formatGMT7Date,
  formatGMT7Vietnamese
} from '@/utils/timezoneHelper'
import { AssignmentHelper } from '@/utils/assignmentHelper'

const { message } = createDiscreteApi(['message'])

// Types
type EmployeeAssignment = {
  id: string
  employee_profile_id: string
  employee_name: string
  shift_id: string
  shift_name: string
  assigned_date: string
  is_active: boolean
  assigned_at: string
  last_handover_time?: string
  handover_count?: number
  backup_employee_id?: string
  is_fallback?: boolean
  fallback_reason?: string
  fallback_time?: string
}

type AccountAccess = {
  id: string
  employee_profile_id: string
  employee_name: string
  shift_id: string
  shift_name: string
  game_account_id: string
  game_account_name: string
  game_code: string
  channel_id: string
  channel_name: string
  access_level: string
  assigned_date: string
  is_active: boolean
  notes: string | null
  granted_at: string
}

// State
const loadingEmployeeAssignments = ref(false)
const loadingAccountAccess = ref(false)
const employeeAssignments = ref<EmployeeAssignment[]>([])
const accountAccess = ref<AccountAccess[]>([])

const selectedDate = ref(new Date().toISOString().split('T')[0])
const selectedShift = ref<string>('')

const employeeFormRef = ref()
const accountAccessFormRef = ref()

// Filters
const accessFilter = reactive({
  employee: '',
  shift: '',
  channel: '',
})

// Options
const employeeOptions = ref<{ label: string; value: string }[]>([])
const shiftOptions = ref<{ label: string; value: string }[]>([])
const gameAccountOptions = ref<{ label: string; value: string }[]>([])
const channelOptions = ref<{ label: string; value: string }[]>([])
const accessLevelOptions = [
  { label: 'Toàn quyền (Full)', value: 'full' },
  { label: 'Chỉ xem (Read Only)', value: 'read_only' },
  { label: 'Chỉ giao dịch (Trade Only)', value: 'trade_only' },
]

// Employee Assignment Modal
const employeeModal = reactive({
  open: false,
  saving: false,
  editingAssignment: null as EmployeeAssignment | null,
  form: {
    employee_profile_id: '',
    shift_id: '',
    assigned_date: getGMT7TodayTimestamp(),
    is_active: true,
  },
})

// Account Access Modal
const accountAccessModal = reactive({
  open: false,
  saving: false,
  form: {
    employee_profile_id: '',
    shift_id: '',
    game_account_id: '',
    channel_id: '',
    access_level: 'full',
    assigned_date: getGMT7TodayTimestamp(),
    notes: '',
    is_active: true,
  },
})

// Form validation rules
const employeeAssignmentRules = {
  employee_profile_id: [
    { required: true, message: 'Vui lòng chọn nhân viên', trigger: 'change' },
  ],
  shift_id: [
    { required: true, message: 'Vui lòng chọn ca làm việc', trigger: 'change' },
  ],
  assigned_date: [
    {
      required: true,
      validator: (rule: any, value: number) => {
        return value && value > 0 && !isNaN(value)
      },
      message: 'Vui lòng chọn ngày phân công',
      trigger: ['change', 'blur']
    },
  ],
}

const accountAccessRules = {
  employee_profile_id: [
    { required: true, message: 'Vui lòng chọn nhân viên', trigger: 'change' },
  ],
  shift_id: [
    { required: true, message: 'Vui lòng chọn ca làm việc', trigger: 'change' },
  ],
  game_account_id: [
    { required: true, message: 'Vui lòng chọn tài khoản game', trigger: 'change' },
  ],
  channel_id: [
    { required: true, message: 'Vui lòng chọn kênh', trigger: 'change' },
  ],
  access_level: [
    { required: true, message: 'Vui lòng chọn cấp độ truy cập', trigger: 'change' },
  ],
  assigned_date: [
    {
      required: true,
      validator: (rule: any, value: number) => {
        return value && value > 0 && !isNaN(value)
      },
      message: 'Vui lòng chọn ngày phân công',
      trigger: ['change', 'blur']
    },
  ],
}

// DataTable columns
const employeeAssignmentColumns: DataTableColumns<EmployeeAssignment> = [
  {
    title: 'Nhân viên',
    key: 'employee_name',
    width: 150,
  },
  {
    title: 'Ca làm việc',
    key: 'shift_name',
    width: 120,
  },
  {
    title: 'Ngày phân công',
    key: 'assigned_date',
    width: 140,
    render: (row) => {
      const dateStr = formatGMT7Vietnamese(row.assigned_date)
      if (row.is_fallback) {
        return h('div', [
          h('div', dateStr),
          h('div', { class: 'text-xs text-orange-500' }, '(Fallback)')
        ])
      }
      return dateStr
    },
  },
  {
    title: 'Handover',
    key: 'handover_info',
    width: 100,
    render: (row) => {
      if (row.handover_count > 0) {
        return h('div', [
          h('div', { class: 'text-xs text-blue-600' }, `${row.handover_count} lần`),
          row.last_handover_time &&
            h('div', { class: 'text-xs text-gray-500' },
              new Date(row.last_handover_time).toLocaleDateString('vi-VN')
            )
        ])
      }
      return '-'
    },
  },
  {
    title: 'Trạng thái',
    key: 'is_active',
    width: 100,
    render: (row) => {
      return row.is_active
        ? h('span', { class: 'text-green-600' }, 'Hoạt động')
        : h('span', { class: 'text-red-600' }, 'Không')
    },
  },
  {
    title: 'Hành động',
    key: 'actions',
    align: 'right',
    width: 120,
    render: (row) =>
      h('div', { class: 'flex gap-1' }, [
        h(
          NButton,
          {
            size: 'small',
            type: 'primary',
            onClick: () => openEmployeeAssignmentModal(row),
          },
          { default: () => 'Sửa' }
        ),
        h(
          NButton,
          {
            size: 'small',
            type: 'error',
            onClick: () => deleteEmployeeAssignment(row.id),
          },
          { default: () => 'Xóa' }
        ),
      ]),
  },
]

const accountAccessColumns: DataTableColumns<AccountAccess> = [
  {
    title: 'Nhân viên',
    key: 'employee_name',
    width: 120,
  },
  {
    title: 'Ca',
    key: 'shift_name',
    width: 80,
  },
  {
    title: 'Tài khoản Game',
    key: 'game_account_name',
    width: 150,
    render: (row) => `${row.game_account_name} (${row.game_code})`,
  },
  {
    title: 'Kênh',
    key: 'channel_name',
    width: 100,
  },
  {
    title: 'Quyền truy cập',
    key: 'access_level',
    width: 120,
    render: (row) => {
      const level = accessLevelOptions.find(l => l.value === row.access_level)
      return level?.label || row.access_level
    },
  },
  {
    title: 'Ngày',
    key: 'assigned_date',
    width: 100,
    render: (row) => formatGMT7Vietnamese(row.assigned_date),
  },
  {
    title: 'Trạng thái',
    key: 'is_active',
    width: 80,
    render: (row) => {
      return row.is_active
        ? h('span', { class: 'text-green-600' }, '✔')
        : h('span', { class: 'text-red-600' }, '✘')
    },
  },
  {
    title: 'Hành động',
    key: 'actions',
    align: 'right',
    width: 80,
    render: (row) =>
      h(
        NButton,
        {
          size: 'small',
          type: 'error',
          onClick: () => deleteAccountAccess(row.id),
        },
        { default: () => 'Xóa' }
      ),
  },
]

// Methods
async function loadOptions() {
  try {
    // Load employees
    const { data: employeeData } = await supabase
      .from('profiles')
      .select('id, display_name')
      .eq('status', 'active')
      .order('display_name')

    employeeOptions.value = (employeeData || []).map(e => ({
      label: e.display_name,
      value: e.id,
    }))

    // Load shifts
    const { data: shiftData } = await supabase
      .from('work_shifts')
      .select('id, name')
      .eq('is_active', true)
      .order('name')

    shiftOptions.value = (shiftData || []).map(s => ({
      label: s.name,
      value: s.id,
    }))

    // Load game accounts
    const { data: accountData } = await supabase
      .from('game_accounts')
      .select('id, account_name, game_code')
      .eq('is_active', true)
      .order('game_code, account_name')

    gameAccountOptions.value = (accountData || []).map(a => ({
      label: `${a.account_name} (${a.game_code})`,
      value: a.id,
    }))

    // Load channels
    const { data: channelData } = await supabase
      .from('channels')
      .select('id, name')
      .eq('is_active', true)
      .order('name')

    channelOptions.value = (channelData || []).map(c => ({
      label: c.name,
      value: c.id,
    }))
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách lựa chọn')
  }
}

async function loadEmployeeAssignments() {
  loadingEmployeeAssignments.value = true
  try {
    let query = supabase
      .from('employee_shift_assignments')
      .select(`
        *,
        profiles!employee_shift_assignments_employee_profile_id_fkey(display_name),
        work_shifts(name)
      `)
      .order('assigned_date', { ascending: false })

    if (selectedDate.value) {
      query = query.eq('assigned_date', selectedDate.value)
    }
    if (selectedShift.value) {
      query = query.eq('shift_id', selectedShift.value)
    }

    const { data, error } = await query

    if (error) throw error

    employeeAssignments.value = (data || []).map(item => ({
      id: item.id,
      employee_profile_id: item.employee_profile_id,
      employee_name: item.profiles?.display_name || 'Unknown',
      shift_id: item.shift_id,
      shift_name: item.work_shifts?.name || 'Unknown',
      assigned_date: item.assigned_date,
      is_active: item.is_active,
      assigned_at: item.assigned_at,
      last_handover_time: item.last_handover_time,
      handover_count: item.handover_count || 0,
      backup_employee_id: item.backup_employee_id,
      is_fallback: item.is_fallback || false,
      fallback_reason: item.fallback_reason,
      fallback_time: item.fallback_time,
    }))
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách phân công nhân viên')
  } finally {
    loadingEmployeeAssignments.value = false
  }
}

async function loadAccountAccess() {
  loadingAccountAccess.value = true
  try {
    let query = supabase
      .from('shift_account_access')
      .select(`
        *,
        profiles!shift_account_access_employee_profile_id_fkey(display_name),
        work_shifts(name),
        game_accounts(account_name, game_code),
        channels(name)
      `)
      .order('assigned_date', { ascending: false })

    if (accessFilter.employee) {
      query = query.eq('employee_profile_id', accessFilter.employee)
    }
    if (accessFilter.shift) {
      query = query.eq('shift_id', accessFilter.shift)
    }
    if (accessFilter.channel) {
      query = query.eq('channel_id', accessFilter.channel)
    }

    const { data, error } = await query

    if (error) throw error

    accountAccess.value = (data || []).map(item => ({
      id: item.id,
      employee_profile_id: item.employee_profile_id,
      employee_name: item.profiles?.display_name || 'Unknown',
      shift_id: item.shift_id,
      shift_name: item.work_shifts?.name || 'Unknown',
      game_account_id: item.game_account_id,
      game_account_name: item.game_accounts?.account_name || 'Unknown',
      game_code: item.game_accounts?.game_code || 'Unknown',
      channel_id: item.channel_id,
      channel_name: item.channels?.name || 'Unknown',
      access_level: item.access_level,
      assigned_date: item.assigned_date,
      is_active: item.is_active,
      notes: item.notes,
      granted_at: item.granted_at,
    }))
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách phân quyền truy cập')
  } finally {
    loadingAccountAccess.value = false
  }
}

function openEmployeeAssignmentModal(assignment: EmployeeAssignment | null = null) {
  employeeModal.editingAssignment = assignment

  if (assignment) {
    // Edit mode
    employeeModal.form = {
      employee_profile_id: assignment.employee_profile_id,
      shift_id: assignment.shift_id,
      assigned_date: new Date(assignment.assigned_date).getTime(),
      is_active: assignment.is_active,
    }
  } else {
    // Add mode
    employeeModal.form = {
      employee_profile_id: '',
      shift_id: '',
      assigned_date: getGMT7TodayTimestamp(),
      is_active: true,
    }
  }
  employeeModal.open = true
}

function openAccountAccessModal() {
  accountAccessModal.form = {
    employee_profile_id: '',
    shift_id: '',
    game_account_id: '',
    channel_id: '',
    access_level: 'full',
    assigned_date: getGMT7TodayTimestamp(),
    notes: '',
    is_active: true,
  }
  accountAccessModal.open = true
}

async function saveEmployeeAssignment() {
  try {
    await employeeFormRef.value?.validate()
  } catch {
    return
  }

  employeeModal.saving = true
  try {
    const formData = { ...employeeModal.form }
    const formattedDate = formatGMT7Date(formData.assigned_date)

    if (employeeModal.editingAssignment) {
      // Update existing assignment using AssignmentHelper
      const result = await AssignmentHelper.handleAssignmentChange(
        employeeModal.editingAssignment.id,
        {
          employee_profile_id: formData.employee_profile_id,
          shift_id: formData.shift_id,
          assigned_date: formattedDate,
          is_active: formData.is_active,
        }
      )

      if (result.success) {
        // Show appropriate message based on impact
        switch (result.impact.type) {
          case 'future':
            message.success('Cập nhật phân công thành công (có hiệu lực từ ngày mai)')
            break
          case 'active_handover':
            message.warning('Handover đã được khởi tạo - nhân viên sẽ được thông báo')
            break
          case 'emergency':
            message.error('Emergency reassignment đã được thực hiện!')
            break
          default:
            message.success('Cập nhật phân công thành công')
        }
      } else {
        throw new Error(result.impact.message)
      }
    } else {
      // Create new assignment
      const { error } = await supabase.rpc('assign_employee_to_shift', {
        p_employee_profile_id: formData.employee_profile_id,
        p_shift_id: formData.shift_id,
        p_assigned_date: formattedDate,
        p_is_active: formData.is_active,
      })

      if (error) throw error
      message.success('Phân công nhân viên thành công!')
    }

    employeeModal.open = false
    await loadEmployeeAssignments()
  } catch (error: any) {
    message.error(error.message || 'Không thể phân công nhân viên')
  } finally {
    employeeModal.saving = false
  }
}

async function saveAccountAccess() {
  try {
    await accountAccessFormRef.value?.validate()
  } catch {
    return
  }

  accountAccessModal.saving = true
  try {
    const formData = { ...accountAccessModal.form }
    formData.assigned_date = formatGMT7Date(formData.assigned_date)

    const { error } = await supabase.from('shift_account_access').insert({
      shift_id: formData.shift_id,
      game_account_id: formData.game_account_id,
      channel_id: formData.channel_id,
      employee_profile_id: formData.employee_profile_id,
      access_level: formData.access_level,
      assigned_date: formData.assigned_date,
      notes: formData.notes || null,
      is_active: formData.is_active,
      granted_by: (await supabase.auth.getUser()).data.user?.id,
    })

    if (error) throw error
    message.success('Phân quyền truy cập thành công!')
    accountAccessModal.open = false
    await loadAccountAccess()
  } catch (error: any) {
    message.error(error.message || 'Không thể phân quyền truy cập')
  } finally {
    accountAccessModal.saving = false
  }
}

async function deleteEmployeeAssignment(assignmentId: string) {
  if (!confirm('Bạn có chắc chắn muốn xóa phân công này?')) return

  try {
    const { error } = await supabase
      .from('employee_shift_assignments')
      .delete()
      .eq('id', assignmentId)

    if (error) throw error
    message.success('Xóa phân công thành công!')
    await loadEmployeeAssignments()
  } catch (error: any) {
    message.error(error.message || 'Không thể xóa phân công')
  }
}

async function deleteAccountAccess(accessId: string) {
  if (!confirm('Bạn có chắc chắn muốn xóa phân quyền này?')) return

  try {
    const { error } = await supabase
      .from('shift_account_access')
      .delete()
      .eq('id', accessId)

    if (error) throw error
    message.success('Xóa phân quyền thành công!')
    await loadAccountAccess()
  } catch (error: any) {
    message.error(error.message || 'Không thể xóa phân quyền')
  }
}

// Lifecycle
onMounted(async () => {
  await loadOptions()
  await loadEmployeeAssignments()
  await loadAccountAccess()
})
</script>