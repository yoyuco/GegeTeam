<template>
  <div class="p-4">
    <div class="flex items-center justify-between mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-semibold">Phân công Account theo Ca</h2>
        <n-tag type="info" size="small">{{ assignments.length }} phân công</n-tag>
      </div>
      <n-button type="primary" @click="openModal">
        <template #icon>
          <n-icon><AddIcon /></n-icon>
        </template>
        Thêm phân công
      </n-button>
    </div>

    <!-- Filter Panel -->
    <FilterPanel
      :show-game-filter="true"
      :show-employee-filter="true"
      :show-channel-filter="true"
      :show-date-filter="true"
      :show-shift-filter="true"
      :game-codes="['POE_1', 'POE_2', 'DIABLO_4']"
      @filter-change="handleFilterChange"
    />

    <n-data-table
      :columns="columns"
      :data="assignments"
      :loading="loading"
      :pagination="pagination"
      striped
    />

    <!-- Modal -->
    <n-modal
      v-model:show="modal.open"
      :style="{ width: '600px' }"
      preset="card"
      :title="modal.editingId ? 'Cập nhật phân công' : 'Thêm phân công mới'"
      size="large"
    >
      <div class="assignment-form">
        <n-form
          ref="formRef"
          :model="modal.form"
          :rules="rules"
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

            <n-grid :cols="2" :x-gap="16">
              <n-gi>
                <n-form-item label="Game Account" path="game_account_id">
                  <n-select
                    v-model:value="modal.form.game_account_id"
                    :options="gameAccountOptions"
                    placeholder="🎮 Chọn game account"
                    filterable
                    :loading="gameAccountOptions.length === 0"
                  />
                </n-form-item>
              </n-gi>

              <n-gi>
                <n-form-item label="Nhân viên" path="employee_profile_id">
                  <n-select
                    v-model:value="modal.form.employee_profile_id"
                    :options="employeeOptions"
                    placeholder="👤 Chọn nhân viên"
                    filterable
                    :loading="employeeOptions.length === 0"
                  />
                </n-form-item>
              </n-gi>
            </n-grid>
          </div>

          <!-- Schedule Section -->
          <div class="form-section">
            <div class="section-title">
              <n-icon size="20" color="#2080f0">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 22L12 18.56L5.82 22L7 14.14l-5-4.87l6.91-1.01L12 2z"/></svg>
              </n-icon>
              <span>Lịch làm việc</span>
            </div>

            <n-form-item label="Ca làm việc" path="shift_id">
              <n-select
                v-model:value="modal.form.shift_id"
                :options="shiftOptions"
                placeholder="⏰ Chọn ca làm việc"
                :loading="shiftOptions.length === 0"
              />
            </n-form-item>
          </div>

          <!-- Additional Details Section -->
          <div class="form-section">
            <div class="section-title">
              <n-icon size="20" color="#2080f0">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
              </n-icon>
              <span>Chi tiết khác</span>
            </div>

            <n-grid :cols="2" :x-gap="16">
              <n-gi>
                <n-form-item label="Kênh" path="channels_id">
                  <n-select
                    v-model:value="modal.form.channels_id"
                    :options="channelOptions"
                    placeholder="📢 Chọn kênh"
                    filterable
                    :loading="channelOptions.length === 0"
                  />
                </n-form-item>
              </n-gi>

              <n-gi>
                <n-form-item label="Tiền tệ" path="currency_code">
                  <n-select
                    v-model:value="modal.form.currency_code"
                    :options="currencyOptions"
                    placeholder="💰 Chọn tiền tệ"
                    filterable
                    :loading="currencyOptions.length === 0"
                  />
                </n-form-item>
              </n-gi>
            </n-grid>

            <n-form-item>
              <template #label>
                <div style="display: flex; align-items: center; gap: 8px;">
                  <span>Trạng thái</span>
                  <n-tag :type="modal.form.is_active ? 'success' : 'default'" size="small">
                    {{ modal.form.is_active ? 'Hoạt động' : 'Không hoạt động' }}
                  </n-tag>
                </div>
              </template>
              <n-switch v-model:value="modal.form.is_active" size="large">
                <template #checked>
                  <span style="display: flex; align-items: center; gap: 4px;">
                    <n-icon color="#18a058">
                      <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                    </n-icon>
                    Hoạt động
                  </span>
                </template>
                <template #unchecked>
                  <span style="display: flex; align-items: center; gap: 4px;">
                    <n-icon color="#909399">
                      <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
                    </n-icon>
                    Không hoạt động
                  </span>
                </template>
              </n-switch>
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
            <n-button size="large" @click="modal.open = false">
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
              @click="saveAssignment"
              :loading="modal.saving"
              :disabled="!modal.form.game_account_id || !modal.form.employee_profile_id || !modal.form.shift_id || !modal.form.channels_id"
            >
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19L21 7l-1.41-1.41L9 16.17z"/></svg>
                </n-icon>
              </template>
              {{ modal.editingId ? 'Cập nhật' : 'Thêm phân công' }}
            </n-button>
          </n-space>
        </div>
      </template>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, h, computed, watch } from 'vue'
import { useMessage } from 'naive-ui'
import {
  NButton,
  NTag,
  NSpace,
  NModal,
  NForm,
  NFormItem,
  NSelect,
  NSwitch,
  NDataTable,
  NIcon,
  NGrid,
  NGi,
  useDialog
} from 'naive-ui'
import {
  Add as AddIcon,
  CreateOutline as EditIcon,
  TrashOutline as DeleteIcon
} from '@vicons/ionicons5'
import { supabase } from '@/lib/supabase'
import type { DataTableColumns, FormRules } from 'naive-ui'
import FilterPanel from './FilterPanel.vue'
import { TIMEZONE_OFFSET } from '@/utils/timezoneHelper'

// Helper function for consistent GMT+7 time display
const ensureGMT7Display = (timeString: string) => {
  if (!timeString) return ''

  // Create a date object with the time, treating it as GMT+7
  const [hours, minutes] = timeString.split(':').map(Number)
  const date = new Date()
  date.setHours(hours, minutes, 0, 0)

  // Format with explicit GMT+7 timezone
  return date.toLocaleTimeString('vi-VN', {
    timeZone: 'Asia/Bangkok',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
}

// Props
const props = defineProps<{
  searchQuery?: string
  refreshTrigger?: number
}>()

// Emits
const emit = defineEmits<{
  'refreshed': [tabName: string]
  'loading-change': [loading: boolean]
}>()

interface ShiftAssignment {
  id: string
  game_account_id: string
  game_account_name: string
  employee_profile_id: string
  employee_name: string
  shift_id: string
  shift_name: string
  channels_id: string
  channel_name: string
  currency_code: string
  currency_name: string
  is_active: boolean
  assigned_at: string
}

interface Employee {
  id: string
  display_name: string
}

interface GameAccount {
  id: string
  account_name: string
  purpose: string
}

const message = useMessage()
const dialog = useDialog()
const loading = ref(false)
const assignments = ref<ShiftAssignment[]>([])
const allAssignments = ref<ShiftAssignment[]>([])
const employeeOptions = ref<Array<{label: string, value: string}>>([])
const gameAccountOptions = ref<Array<{label: string, value: string}>>([])
const shiftOptions = ref<Array<{label: string, value: string}>>([])
const channelOptions = ref<Array<{label: string, value: string}>>([])
const currencyOptions = ref<Array<{label: string, value: string}>>([])
const formRef = ref()

// Filter state
const currentFilters = ref<any>({})

const modal = reactive({
  open: false,
  editingId: null as string | null,
  saving: false,
  form: {
    game_account_id: '',
    employee_profile_id: '',
    shift_id: '',
    channels_id: '',
    currency_code: 'VND',
    is_active: true
  }
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  showSizePicker: true,
  pageSizes: [10, 20, 50]
})

const rules: FormRules = {
  game_account_id: [
    { required: true, message: 'Vui lòng chọn game account', trigger: ['change', 'blur'] }
  ],
  employee_profile_id: [
    { required: true, message: 'Vui lòng chọn nhân viên', trigger: ['change', 'blur'] }
  ],
  shift_id: [
    { required: true, message: 'Vui lòng chọn ca làm việc', trigger: ['change', 'blur'] }
  ],
  channels_id: [
    { required: true, message: 'Vui lòng chọn kênh', trigger: ['change', 'blur'] }
  ],
  currency_code: [
    { required: true, message: 'Vui lòng chọn tiền tệ', trigger: ['change', 'blur'] }
  ]
}

const columns: DataTableColumns<ShiftAssignment> = [
  {
    title: 'Game Account',
    key: 'game_account_name',
    render(row) {
      return h('span', row.game_account_name)
    }
  },
  {
    title: 'Nhân viên',
    key: 'employee_name',
    render(row) {
      return h('span', row.employee_name)
    }
  },
  {
    title: 'Ca làm việc',
    key: 'shift_name',
    render(row) {
      return h('span', row.shift_name)
    }
  },
  {
    title: 'Kênh',
    key: 'channel_name',
    render(row) {
      return h('span', row.channel_name)
    }
  },
  {
    title: 'Tiền tệ',
    key: 'currency_code',
    render(row) {
      return h(NTag, { type: 'info' }, {
        default: () => `${row.currency_code} - ${row.currency_name}`
      })
    }
  },
  {
    title: 'Trạng thái',
    key: 'is_active',
    render(row) {
      const type = row.is_active ? 'success' : 'error'
      const text = row.is_active ? 'Hoạt động' : 'Không hoạt động'
      return h(NTag, { type }, { default: () => text })
    }
  },
  {
    title: 'Ngày phân công',
    key: 'assigned_at',
    render(row) {
      return new Date(row.assigned_at).toLocaleDateString('vi-VN')
    }
  },
  {
    title: 'Thao tác',
    key: 'actions',
    width: 120,
    render(row) {
      return h(NSpace, { size: 'small' }, {
        default: () => [
          h(NButton, {
            size: 'small',
            type: 'primary',
            tertiary: true,
            style: { padding: '4px 8px' },
            onClick: () => editAssignment(row)
          }, {
            default: () => h(NIcon, { size: 14 }, { default: () => h(EditIcon) })
          }),
          h(NButton, {
            size: 'small',
            type: 'error',
            tertiary: true,
            style: { padding: '4px 8px' },
            onClick: () => deleteAssignment(row)
          }, {
            default: () => h(NIcon, { size: 14 }, { default: () => h(DeleteIcon) })
          })
        ]
      })
    }
  }
]

async function loadEmployees() {
  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_all_active_profiles_direct')

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('profiles')
        .select('id, display_name')
        .eq('status', 'active')
        .order('display_name')

      if (fallbackError) throw fallbackError
      employeeOptions.value = (fallbackData || []).map(emp => ({
        label: emp.display_name || 'Unknown',
        value: emp.id
      }))
    } else {
      employeeOptions.value = (data as Employee[] || []).map((emp: Employee) => ({
        label: emp.display_name || 'Unknown',
        value: emp.id
      }))
    }
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách nhân viên')
  }
}

async function loadGameAccounts() {
  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_all_game_accounts_direct')

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('game_accounts')
        .select('id, account_name')
        .eq('is_active', true)
        .eq('purpose', 'INVENTORY')
        .order('account_name')

      if (fallbackError) throw fallbackError
      gameAccountOptions.value = (fallbackData as GameAccount[] || [])
        .filter((account: GameAccount) => account.purpose === 'INVENTORY')
        .map((account: GameAccount) => ({
          label: account.account_name,
          value: account.id
        }))
    } else {
      gameAccountOptions.value = (data as GameAccount[] || [])
        .filter((account: GameAccount) => account.purpose === 'INVENTORY')
        .map((account: GameAccount) => ({
          label: account.account_name,
          value: account.id
        }))
    }
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách game accounts')
  }
}

async function loadShifts() {
  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_all_work_shifts_direct')

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('work_shifts')
        .select('id, name, start_time, end_time')
        .eq('is_active', true)
        .order('start_time')

      if (fallbackError) throw fallbackError
      shiftOptions.value = (fallbackData || []).map((shift: any) => ({
        label: `${shift.name} (${ensureGMT7Display(shift.start_time)} - ${ensureGMT7Display(shift.end_time)})`,
        value: shift.id
      }))
    } else {
      shiftOptions.value = (data || []).map((shift: any) => ({
        label: `${shift.name} (${ensureGMT7Display(shift.start_time)} - ${ensureGMT7Display(shift.end_time)})`,
        value: shift.id
      }))
    }
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách ca làm việc')
  }
}

async function loadChannels() {
  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_all_channels_direct')

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('channels')
        .select('id, name')
        .eq('is_active', true)
        .order('name')

      if (fallbackError) throw fallbackError
      channelOptions.value = (fallbackData || []).map((channel: any) => ({
        label: channel.name,
        value: channel.id
      }))
    } else {
      channelOptions.value = (data || []).map((channel: any) => ({
        label: channel.name,
        value: channel.id
      }))
    }
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách kênh')
  }
}

async function loadCurrencies() {
  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_all_currencies_direct')

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('currencies')
        .select('code, name')
        .eq('is_active', true)
        .order('code')

      if (fallbackError) throw fallbackError
      currencyOptions.value = (fallbackData || []).map((currency: any) => ({
        label: `${currency.code} - ${currency.name}`,
        value: currency.code
      }))
    } else {
      currencyOptions.value = (data || []).map((currency: any) => ({
        label: `${currency.code} - ${currency.name}`,
        value: currency.code
      }))
    }
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách tiền tệ')
  }
}

function getCurrencyName(currencyCode: string): string {
  const currency = currencyOptions.value.find(opt => opt.value === currencyCode)
  return currency ? currency.label.replace(`${currencyCode} - `, '') : currencyCode
}

async function loadAssignments() {
  loading.value = true
  emit('loading-change', true)
  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_all_shift_assignments_direct')

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)

      // First load assignments
      const { data: assignmentsData, error: assignmentsError } = await supabase
        .from('shift_assignments')
        .select('*')
        .order('game_account_id, shift_id')

      if (assignmentsError) throw assignmentsError

      if (!assignmentsData || assignmentsData.length === 0) {
        assignments.value = []
        return
      }

      // Get related data separately
      const [gameAccountsRes, profilesRes, workShiftsRes, channelsRes] = await Promise.all([
        supabase.from('game_accounts').select('id, account_name').in('id', [...new Set(assignmentsData.map(a => a.game_account_id))]),
        supabase.from('profiles').select('id, display_name').in('id', [...new Set(assignmentsData.map(a => a.employee_profile_id))]),
        supabase.from('work_shifts').select('id, name, start_time, end_time').in('id', [...new Set(assignmentsData.map(a => a.shift_id))]),
        supabase.from('channels').select('id, name').in('id', [...new Set(assignmentsData.map(a => a.channels_id))])
      ])

      if (gameAccountsRes.error) throw gameAccountsRes.error
      if (profilesRes.error) throw profilesRes.error
      if (workShiftsRes.error) throw workShiftsRes.error
      if (channelsRes.error) throw channelsRes.error

      // Create lookup maps
      const gameAccountMap = new Map((gameAccountsRes.data || []).map(acc => [acc.id, acc.account_name]))
      const profileMap = new Map((profilesRes.data || []).map(profile => [profile.id, profile.display_name]))
      const workShiftMap = new Map((workShiftsRes.data || []).map(shift => [shift.id, shift]))
      const channelMap = new Map((channelsRes.data || []).map(channel => [channel.id, channel.name]))

      // Combine data
      const combinedData = assignmentsData.map((item: any) => {
        const workShift = workShiftMap.get(item.shift_id)
        return {
          id: item.id,
          game_account_id: item.game_account_id,
          game_account_name: gameAccountMap.get(item.game_account_id) || 'Unknown',
          employee_profile_id: item.employee_profile_id,
          employee_name: profileMap.get(item.employee_profile_id) || 'Unknown',
          shift_id: item.shift_id,
          shift_name: workShift ? `${workShift.name} (${ensureGMT7Display(workShift.start_time)} - ${ensureGMT7Display(workShift.end_time)})` : 'Unknown',
          channels_id: item.channels_id,
          channel_name: channelMap.get(item.channels_id) || 'Unknown',
          currency_code: item.currency_code || 'VND',
          currency_name: getCurrencyName(item.currency_code || 'VND'),
          is_active: item.is_active,
          assigned_at: item.assigned_at
        }
      })

      allAssignments.value = combinedData
    } else {
      // Use RPC data with combined information
      allAssignments.value = (data || []).map((item: any) => ({
        id: item.id,
        game_account_id: item.game_account_id,
        game_account_name: item.game_account_name,
        employee_profile_id: item.employee_profile_id,
        employee_name: item.employee_name,
        shift_id: item.shift_id,
        shift_name: `${item.shift_name} (${ensureGMT7Display(item.shift_start_time)} - ${ensureGMT7Display(item.shift_end_time)})`,
        channels_id: item.channels_id,
        channel_name: item.channel_name,
        currency_code: item.currency_code,
        currency_name: item.currency_name,
        is_active: item.is_active,
        assigned_at: item.assigned_at
      }))
    }

    applyFilters()
  } catch (error: any) {
    console.error('Error loading assignments:', error)
    message.error(error.message || 'Không thể tải danh sách phân công')
  } finally {
    loading.value = false
    emit('loading-change', false)
  }
}

// Filter functions
function handleFilterChange(filters: any) {
  currentFilters.value = filters
  applyFilters()
}

function applyFilters() {
  let filtered = [...allAssignments.value]

  // Search query filter
  if (props.searchQuery) {
    const searchLower = props.searchQuery.toLowerCase()
    filtered = filtered.filter(assignment =>
      assignment.game_account_name.toLowerCase().includes(searchLower) ||
      assignment.employee_name.toLowerCase().includes(searchLower) ||
      assignment.shift_name.toLowerCase().includes(searchLower) ||
      assignment.channel_name.toLowerCase().includes(searchLower)
    )
  }

  // Game filter (handle both single string and array) - filter by game account name
  if (currentFilters.value.game) {
    if (Array.isArray(currentFilters.value.game)) {
      if (currentFilters.value.game.length > 0) {
        filtered = filtered.filter(assignment =>
          currentFilters.value.game.some((game: string) =>
            assignment.game_account_name.toLowerCase().includes(game.toLowerCase())
          )
        )
      }
    } else {
      filtered = filtered.filter(assignment =>
        assignment.game_account_name.toLowerCase().includes(currentFilters.value.game.toLowerCase())
      )
    }
  }

  // Employee filter (handle both single string and array)
  if (currentFilters.value.employee) {
    if (Array.isArray(currentFilters.value.employee)) {
      if (currentFilters.value.employee.length > 0) {
        filtered = filtered.filter(assignment =>
          currentFilters.value.employee.includes(assignment.employee_profile_id)
        )
      }
    } else {
      filtered = filtered.filter(assignment =>
        assignment.employee_profile_id === currentFilters.value.employee
      )
    }
  }

  // Channel filter (handle both single string and array)
  if (currentFilters.value.channel) {
    if (Array.isArray(currentFilters.value.channel)) {
      if (currentFilters.value.channel.length > 0) {
        filtered = filtered.filter(assignment =>
          currentFilters.value.channel.includes(assignment.channels_id)
        )
      }
    } else {
      filtered = filtered.filter(assignment =>
        assignment.channels_id === currentFilters.value.channel
      )
    }
  }

  // Shift filter
  if (currentFilters.value.shift) {
    if (Array.isArray(currentFilters.value.shift)) {
      if (currentFilters.value.shift.length > 0) {
        filtered = filtered.filter(assignment =>
          currentFilters.value.shift.includes(assignment.shift_id)
        )
      }
    } else {
      filtered = filtered.filter(assignment =>
        assignment.shift_id === currentFilters.value.shift
      )
    }
  }

  // Date range filter
  if (currentFilters.value.dateFrom) {
    const fromDate = new Date(currentFilters.value.dateFrom)
    filtered = filtered.filter(assignment =>
      new Date(assignment.assigned_at) >= fromDate
    )
  }

  if (currentFilters.value.dateTo) {
    const toDate = new Date(currentFilters.value.dateTo)
    toDate.setHours(23, 59, 59, 999) // End of day
    filtered = filtered.filter(assignment =>
      new Date(assignment.assigned_at) <= toDate
    )
  }

  assignments.value = filtered
}

// Watch for search query changes
watch(() => props.searchQuery, () => {
  applyFilters()
})

// Watch for refresh trigger
watch(() => props.refreshTrigger, () => {
  loadAssignments()
  emit('refreshed', 'shiftAssignments')
})

function openModal() {
  modal.editingId = null as string | null
  modal.form = {
    game_account_id: '',
    employee_profile_id: '',
    shift_id: '',
    channels_id: '',
    currency_code: 'VND',
    is_active: true
  }
  modal.open = true
}

function editAssignment(assignment: ShiftAssignment) {
  modal.editingId = assignment.id
  modal.form = {
    game_account_id: assignment.game_account_id,
    employee_profile_id: assignment.employee_profile_id,
    shift_id: assignment.shift_id,
    channels_id: assignment.channels_id,
    currency_code: assignment.currency_code,
    is_active: assignment.is_active
  }
  modal.open = true
}

function deleteAssignment(assignment: ShiftAssignment) {
  dialog.warning({
    title: 'Xóa phân công',
    content: `Bạn có chắc muốn xóa phân công này?`,
    positiveText: 'Xóa',
    negativeText: 'Hủy',
    onPositiveClick: async () => {
      try {
        // Use RPC function to bypass RLS
        const { data, error } = await supabase.rpc('delete_shift_assignment_direct', {
          p_assignment_id: assignment.id
        })

        if (error) throw error

        // Check RPC response
        if (data && !data.success) {
          message.error(data.message || 'Không thể xóa phân công')
          return
        }

        message.success('Xóa phân công thành công!')
        await loadAssignments()
      } catch (error: any) {
        message.error(error.message || 'Không thể xóa phân công')
      }
    }
  })
}

async function saveAssignment() {
  try {
    await formRef.value?.validate()
  } catch {
    return
  }

  modal.saving = true
  try {
    const assignmentData = {
      p_game_account_id: modal.form.game_account_id,
      p_employee_profile_id: modal.form.employee_profile_id,
      p_shift_id: modal.form.shift_id,
      p_channels_id: modal.form.channels_id,
      p_currency_code: modal.form.currency_code,
      p_is_active: modal.form.is_active
    }

    let error: any

    if (modal.editingId) {
      // Use RPC function to update existing assignment
      const { error: updateError } = await supabase.rpc('update_shift_assignment_direct', {
        p_assignment_id: modal.editingId,
        ...assignmentData
      })
      error = updateError
    } else {
      // Use RPC function to create new assignment
      const { error: createError } = await supabase.rpc('create_shift_assignment_direct', assignmentData)
      error = createError
    }

    if (error) throw error

    message.success(modal.editingId ? 'Cập nhật phân công thành công!' : 'Thêm phân công thành công!')
    modal.open = false
    await loadAssignments()
  } catch (error: any) {
    message.error(error.message || 'Không thể lưu phân công')
  } finally {
    modal.saving = false
  }
}

onMounted(async () => {
  await Promise.all([
    loadEmployees(),
    loadGameAccounts(),
    loadShifts(),
    loadChannels(),
    loadCurrencies(),
    loadAssignments()
  ])
})
</script>

<style scoped>
.assignment-form {
  padding: 0;
}

.form-section {
  margin-bottom: 24px;
  padding: 20px;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
}

.form-section:last-child {
  margin-bottom: 0;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
  font-weight: 600;
  font-size: 16px;
  color: #1f2937;
  padding-bottom: 8px;
  border-bottom: 2px solid #e5e7eb;
}

.section-title span {
  color: #374151;
}

/* Custom form item styling */
.form-section :deep(.n-form-item) {
  margin-bottom: 16px;
}

.form-section :deep(.n-form-item-label) {
  font-weight: 500;
  color: #374151;
  margin-bottom: 6px;
}

.form-section :deep(.n-select .n-base-selection) {
  border-radius: 8px;
  transition: all 0.2s ease;
}

.form-section :deep(.n-select .n-base-selection:hover) {
  border-color: #60a5fa;
}

.form-section :deep(.n-select.n-base-selection--focus .n-base-selection) {
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
}

/* Switch styling */
.form-section :deep(.n-switch) {
  margin-top: 4px;
}

/* Button styling */
.form-section :deep(.n-button) {
  border-radius: 8px;
  transition: all 0.2s ease;
}

.form-section :deep(.n-button--primary-type) {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  border: none;
}

.form-section :deep(.n-button--primary-type:hover) {
  background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
}

/* Modal card styling */
:deep(.n-card) {
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
}

:deep(.n-card .n-card__header) {
  padding: 24px 24px 16px;
  border-bottom: 1px solid #e5e7eb;
}

:deep(.n-card .n-card__content) {
  padding: 24px;
}

:deep(.n-card .n-card__action) {
  padding: 16px 24px 24px;
  border-top: 1px solid #e5e7eb;
}

/* Grid styling */
:deep(.n-grid) {
  width: 100%;
}

/* Tag styling */
:deep(.n-tag) {
  border-radius: 6px;
  font-weight: 500;
}

/* Loading state styling */
.form-section :deep(.n-base-loading .n-base-loading__container) {
  border-radius: 8px;
}

/* Responsive design */
@media (max-width: 768px) {
  .form-section {
    padding: 16px;
    margin-bottom: 16px;
  }

  .section-title {
    font-size: 14px;
    margin-bottom: 12px;
  }

  :deep(.n-grid) {
    grid-template-columns: 1fr !important;
  }

  :deep(.n-card) {
    margin: 16px;
    width: calc(100vw - 32px);
  }
}

/* Animation for form sections */
.form-section {
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Success/Warning colors */
.form-section .section-title .n-icon[data-color="#2080f0"] {
  color: #3b82f6;
}

/* Custom placeholder styling */
:deep(.n-base-selection-placeholder) {
  color: #9ca3af;
  font-style: italic;
}
</style>