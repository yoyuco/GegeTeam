<template>
  <div class="filter-panel mb-4 p-4 bg-white rounded-lg border border-gray-200">
    <div class="flex items-center justify-between mb-3">
      <h3 class="text-sm font-medium text-gray-700 flex items-center gap-2">
        <n-icon size="16">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
          </svg>
        </n-icon>
        Bộ lọc
      </h3>
      <n-button text size="small" @click="clearAllFilters" v-if="hasActiveFilters">
        <template #icon>
          <n-icon size="14">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </n-icon>
        </template>
        Xóa bộ lọc
      </n-button>
    </div>

    <div class="flex flex-nowrap gap-2 items-end overflow-x-auto pb-2">
      <!-- Game Filter -->
      <div class="filter-item" v-if="showGameFilter">
        <label class="filter-label">Game</label>
        <n-select
          v-model:value="filters.game"
          :options="gameOptions"
          placeholder="Chọn game..."
          clearable
          multiple
          size="small"
          :max-tag-count="1"
          :style="getGameFilterStyle()"
          @update:value="handleFilterChange"
        />
      </div>

      <!-- Server Filter -->
      <div class="filter-item" v-if="showServerFilter">
        <label class="filter-label">Server</label>
        <n-select
          v-model:value="filters.server"
          :options="serverOptions"
          placeholder="Chọn server..."
          clearable
          multiple
          size="small"
          :max-tag-count="1"
          :style="getServerFilterStyle()"
          @update:value="handleFilterChange"
        />
      </div>

      <!-- Status Filter -->
      <div class="filter-item" v-if="showStatusFilter">
        <label class="filter-label">Trạng thái</label>
        <n-select
          v-model:value="filters.status"
          :options="statusOptions"
          placeholder="Chọn trạng thái..."
          clearable
          multiple
          size="small"
          :max-tag-count="1"
          :style="getStatusFilterStyle()"
          @update:value="handleFilterChange"
        />
      </div>

      <!-- Channel Filter -->
      <div class="filter-item" v-if="showChannelFilter">
        <label class="filter-label">Kênh</label>
        <n-select
          v-model:value="filters.channel"
          :options="channelOptions"
          placeholder="Chọn kênh..."
          clearable
          multiple
          size="small"
          :max-tag-count="1"
          :style="getChannelFilterStyle()"
          @update:value="handleFilterChange"
        />
      </div>

      <!-- Date Filter -->
      <div class="filter-item" v-if="showDateFilter">
        <label class="filter-label">Ngày tạo</label>
        <n-date-picker
          v-model:value="filters.dateFrom"
          type="date"
          placeholder="Ngày tạo"
          clearable
          size="small"
          style="width: 160px; height: 32px; min-width: 140px"
          @update:value="handleFilterChange"
        />
      </div>

  
      <!-- Employee Filter -->
      <div class="filter-item" v-if="showEmployeeFilter">
        <label class="filter-label">Nhân viên</label>
        <n-select
          v-model:value="filters.employee"
          :options="employeeOptions"
          placeholder="Chọn nhân viên..."
          clearable
          multiple
          size="small"
          :max-tag-count="1"
          :style="getEmployeeFilterStyle()"
          filterable
          @update:value="handleFilterChange"
        />
      </div>

      <!-- Purpose Filter -->
      <div class="filter-item" v-if="showPurposeFilter">
        <label class="filter-label">Mục đích</label>
        <n-select
          v-model:value="filters.purpose"
          :options="purposeOptions"
          placeholder="Chọn mục đích..."
          clearable
          multiple
          size="small"
          :max-tag-count="1"
          :style="getPurposeFilterStyle()"
          @update:value="handleFilterChange"
        />
      </div>

      <!-- Account Type Filter -->
      <div class="filter-item" v-if="showAccountTypeFilter">
        <label class="filter-label">Loại TK</label>
        <n-select
          v-model:value="filters.accountType"
          :options="accountTypeOptions"
          placeholder="Chọn loại TK..."
          clearable
          multiple
          size="small"
          :max-tag-count="1"
          :style="getAccountTypeFilterStyle()"
          @update:value="handleFilterChange"
        />
      </div>

      <!-- Shift Filter -->
      <div class="filter-item" v-if="showShiftFilter">
        <label class="filter-label">Ca</label>
        <n-select
          v-model:value="filters.shift"
          :options="shiftOptions"
          placeholder="Chọn ca..."
          clearable
          multiple
          size="small"
          :max-tag-count="1"
          :style="getShiftFilterStyle()"
          @update:value="handleFilterChange"
        />
      </div>
    </div>

  
    <!-- Active Filters Display -->
    <div v-if="hasActiveFilters" class="mt-3 flex flex-wrap gap-2">
      <n-tag
        v-for="(value, key) in activeFilters"
        :key="key"
        closable
        @close="clearFilter(key)"
        size="small"
        type="info"
      >
        {{ getFilterLabel(key) }}: {{ getFilterDisplayValue(key, value) }}
      </n-tag>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { NSelect, NDatePicker, NButton, NIcon, NTag } from 'naive-ui'
import { supabase } from '@/lib/supabase'

interface FilterOptions {
  game?: string | string[]
  server?: string | string[]
  status?: string | string[]
  channel?: string | string[]
  dateFrom?: number
  dateTo?: number
  employee?: string | string[]
  purpose?: string | string[]
  accountType?: string | string[]
  shift?: string | string[]
}

interface Props {
  showGameFilter?: boolean
  showServerFilter?: boolean
  showStatusFilter?: boolean
  showChannelFilter?: boolean
  showDateFilter?: boolean
  showEmployeeFilter?: boolean
  showPurposeFilter?: boolean
  showAccountTypeFilter?: boolean
  showShiftFilter?: boolean
  showAdvancedSearch?: boolean
  gameCodes?: string[]
}

const props = withDefaults(defineProps<Props>(), {
  showGameFilter: false,
  showServerFilter: false,
  showStatusFilter: false,
  showChannelFilter: false,
  showDateFilter: false,
  showEmployeeFilter: false,
  showPurposeFilter: false,
  showAccountTypeFilter: false,
  showShiftFilter: false,
  gameCodes: () => []
})

const emit = defineEmits<{
  'filter-change': [filters: FilterOptions]
}>()

// State
const filters = ref<FilterOptions>({})
const games = ref<any[]>([])
const servers = ref<any[]>([])
const channels = ref<any[]>([])
const employees = ref<any[]>([])
const shifts = ref<any[]>([])

// Options
const gameOptions = computed(() => [
  { label: 'Tất cả game', value: null },
  ...games.value.map(game => ({
    label: game.name || game.code,
    value: game.code
  }))
])

const serverOptions = computed(() => [
  { label: 'Tất cả server', value: null },
  ...servers.value.map(server => ({
    label: server.name || server.code,
    value: server.code
  }))
])

const channelOptions = computed(() => [
  { label: 'Tất cả kênh', value: null },
  ...channels.value.map(channel => ({
    label: channel.name,
    value: channel.id
  }))
])

const employeeOptions = computed(() => [
  { label: 'Tất cả nhân viên', value: null },
  ...employees.value.map(employee => ({
    label: employee.display_name || employee.name,
    value: employee.id
  }))
])

const statusOptions = [
  { label: 'Hoạt động', value: 'active' },
  { label: 'Không hoạt động', value: 'inactive' }
]

const purposeOptions = [
  { label: 'Inventory', value: 'INVENTORY' },
  { label: 'Stock', value: 'STOCK' },
  { label: 'Customer', value: 'CUSTOMER' }
]

const accountTypeOptions = [
  { label: 'Global Account', value: 'global' },
  { label: 'League Account', value: 'league' }
]

const shiftOptions = computed(() => [
  { label: 'Tất cả ca', value: null },
  ...shifts.value.map(shift => ({
    label: shift.name,
    value: shift.id
  }))
])

// Computed
const hasActiveFilters = computed(() => {
  return Object.values(filters.value).some(value => {
    if (Array.isArray(value)) {
      return value.length > 0
    }
    return value !== null && value !== undefined && value !== ''
  })
})

const activeFilters = computed(() => {
  const result: Record<string, any> = {}
  Object.entries(filters.value).forEach(([key, value]) => {
    if (Array.isArray(value)) {
      if (value.length > 0) {
        result[key] = value
      }
    } else if (value !== null && value !== undefined && value !== '') {
      result[key] = value
    }
  })
  return result
})

// Methods
const handleFilterChange = () => {
  emit('filter-change', { ...filters.value })
}

// Cache for filter styles to reduce ResizeObserver loops
const filterStyleCache = ref<Record<string, any>>({})

// Debounced style calculation to reduce ResizeObserver loops
const debouncedStyleUpdate = (() => {
  let timeoutId: ReturnType<typeof setTimeout> | null = null
  return (callback: () => void) => {
    if (timeoutId) clearTimeout(timeoutId)
    timeoutId = setTimeout(callback, 16) // ~60fps
  }
})()

// Dynamic width functions for multi-select filters (optimized)
const getGameFilterStyle = () => {
  const cacheKey = `game-${Array.isArray(filters.value.game) ? filters.value.game.length : 0}`
  if (!filterStyleCache.value[cacheKey]) {
    const gameCount = Array.isArray(filters.value.game) ? filters.value.game.length : 0
    if (gameCount === 0) filterStyleCache.value[cacheKey] = { width: '240px', height: '32px', minWidth: '200px' }
    else if (gameCount === 1) filterStyleCache.value[cacheKey] = { width: '220px', height: '32px', minWidth: '180px' }
    else filterStyleCache.value[cacheKey] = { width: '200px', height: '32px', minWidth: '170px' }
  }
  return filterStyleCache.value[cacheKey]
}

const getServerFilterStyle = () => {
  const cacheKey = `server-${Array.isArray(filters.value.server) ? filters.value.server.length : 0}`
  if (!filterStyleCache.value[cacheKey]) {
    const serverCount = Array.isArray(filters.value.server) ? filters.value.server.length : 0
    if (serverCount === 0) filterStyleCache.value[cacheKey] = { width: '220px', height: '32px', minWidth: '190px' }
    else if (serverCount === 1) filterStyleCache.value[cacheKey] = { width: '200px', height: '32px', minWidth: '170px' }
    else filterStyleCache.value[cacheKey] = { width: '190px', height: '32px', minWidth: '160px' }
  }
  return filterStyleCache.value[cacheKey]
}

const getStatusFilterStyle = () => {
  const cacheKey = `status-${Array.isArray(filters.value.status) ? filters.value.status.length : 0}`
  if (!filterStyleCache.value[cacheKey]) {
    const statusCount = Array.isArray(filters.value.status) ? filters.value.status.length : 0
    if (statusCount === 0) filterStyleCache.value[cacheKey] = { width: '190px', height: '32px', minWidth: '160px' }
    else if (statusCount === 1) filterStyleCache.value[cacheKey] = { width: '170px', height: '32px', minWidth: '140px' }
    else filterStyleCache.value[cacheKey] = { width: '160px', height: '32px', minWidth: '140px' }
  }
  return filterStyleCache.value[cacheKey]
}

const getChannelFilterStyle = () => {
  const cacheKey = `channel-${Array.isArray(filters.value.channel) ? filters.value.channel.length : 0}`
  if (!filterStyleCache.value[cacheKey]) {
    const channelCount = Array.isArray(filters.value.channel) ? filters.value.channel.length : 0
    if (channelCount === 0) filterStyleCache.value[cacheKey] = { width: '200px', height: '32px', minWidth: '170px' }
    else if (channelCount === 1) filterStyleCache.value[cacheKey] = { width: '180px', height: '32px', minWidth: '150px' }
    else filterStyleCache.value[cacheKey] = { width: '170px', height: '32px', minWidth: '140px' }
  }
  return filterStyleCache.value[cacheKey]
}

const getEmployeeFilterStyle = () => {
  const cacheKey = `employee-${Array.isArray(filters.value.employee) ? filters.value.employee.length : 0}`
  if (!filterStyleCache.value[cacheKey]) {
    const employeeCount = Array.isArray(filters.value.employee) ? filters.value.employee.length : 0
    if (employeeCount === 0) filterStyleCache.value[cacheKey] = { width: '200px', height: '32px', minWidth: '170px' }
    else if (employeeCount === 1) filterStyleCache.value[cacheKey] = { width: '180px', height: '32px', minWidth: '150px' }
    else filterStyleCache.value[cacheKey] = { width: '170px', height: '32px', minWidth: '140px' }
  }
  return filterStyleCache.value[cacheKey]
}

const getPurposeFilterStyle = () => {
  const cacheKey = `purpose-${Array.isArray(filters.value.purpose) ? filters.value.purpose.length : 0}`
  if (!filterStyleCache.value[cacheKey]) {
    const purposeCount = Array.isArray(filters.value.purpose) ? filters.value.purpose.length : 0
    if (purposeCount === 0) filterStyleCache.value[cacheKey] = { width: '200px', height: '32px', minWidth: '170px' }
    else if (purposeCount === 1) filterStyleCache.value[cacheKey] = { width: '180px', height: '32px', minWidth: '150px' }
    else filterStyleCache.value[cacheKey] = { width: '170px', height: '32px', minWidth: '140px' }
  }
  return filterStyleCache.value[cacheKey]
}

const getAccountTypeFilterStyle = () => {
  const cacheKey = `accountType-${Array.isArray(filters.value.accountType) ? filters.value.accountType.length : 0}`
  if (!filterStyleCache.value[cacheKey]) {
    const accountTypeCount = Array.isArray(filters.value.accountType) ? filters.value.accountType.length : 0
    if (accountTypeCount === 0) filterStyleCache.value[cacheKey] = { width: '220px', height: '32px', minWidth: '190px' }
    else if (accountTypeCount === 1) filterStyleCache.value[cacheKey] = { width: '200px', height: '32px', minWidth: '170px' }
    else filterStyleCache.value[cacheKey] = { width: '190px', height: '32px', minWidth: '160px' }
  }
  return filterStyleCache.value[cacheKey]
}

const getShiftFilterStyle = () => {
  const cacheKey = `shift-${Array.isArray(filters.value.shift) ? filters.value.shift.length : 0}`
  if (!filterStyleCache.value[cacheKey]) {
    const shiftCount = Array.isArray(filters.value.shift) ? filters.value.shift.length : 0
    if (shiftCount === 0) filterStyleCache.value[cacheKey] = { width: '180px', height: '32px', minWidth: '160px' }
    else if (shiftCount === 1) filterStyleCache.value[cacheKey] = { width: '160px', height: '32px', minWidth: '140px' }
    else filterStyleCache.value[cacheKey] = { width: '150px', height: '32px', minWidth: '130px' }
  }
  return filterStyleCache.value[cacheKey]
}

const clearFilter = (key: string) => {
  // Clear related cache entries
  Object.keys(filterStyleCache.value).forEach(cacheKey => {
    if (cacheKey.startsWith(key)) {
      delete filterStyleCache.value[cacheKey]
    }
  })

  filters.value[key as keyof FilterOptions] = undefined
  handleFilterChange()
}

const clearAllFilters = () => {
  // Clear all cache entries
  filterStyleCache.value = {}

  Object.keys(filters.value).forEach(key => {
    filters.value[key as keyof FilterOptions] = undefined
  })
  handleFilterChange()
}

const getFilterLabel = (key: string) => {
  const labels: Record<string, string> = {
    game: 'Game',
    server: 'Server',
    status: 'Trạng thái',
    channel: 'Kênh',
    dateFrom: 'Từ ngày',
    dateTo: 'Đến ngày',
    employee: 'Nhân viên',
    purpose: 'Mục đích',
    accountType: 'Loại tài khoản',
    shift: 'Ca'
  }
  return labels[key] || key
}

const getFilterDisplayValue = (key: string, value: any) => {
  if (key === 'dateFrom' || key === 'dateTo') {
    return new Date(value).toLocaleDateString('vi-VN')
  }

  // Handle multi-select values (arrays)
  if (Array.isArray(value)) {
    const getOptions = (key: string) => {
      switch (key) {
        case 'game': return gameOptions.value
        case 'server': return serverOptions.value
        case 'channel': return channelOptions.value
        case 'employee': return employeeOptions.value
        case 'status': return statusOptions
        case 'purpose': return purposeOptions
        case 'accountType': return accountTypeOptions
        case 'shift': return shiftOptions.value
        default: return []
      }
    }

    const options = getOptions(key)
    return value.map(v => options.find(opt => opt.value === v)?.label || v).join(', ')
  }

  // Handle single values
  if (key === 'game') {
    return gameOptions.value.find(opt => opt.value === value)?.label || value
  }

  if (key === 'server') {
    return serverOptions.value.find(opt => opt.value === value)?.label || value
  }

  if (key === 'channel') {
    return channelOptions.value.find(opt => opt.value === value)?.label || value
  }

  if (key === 'employee') {
    return employeeOptions.value.find(opt => opt.value === value)?.label || value
  }

  if (key === 'status') {
    return statusOptions.find(opt => opt.value === value)?.label || value
  }

  if (key === 'purpose') {
    return purposeOptions.find(opt => opt.value === value)?.label || value
  }

  if (key === 'accountType') {
    return accountTypeOptions.find(opt => opt.value === value)?.label || value
  }

  if (key === 'shift') {
    return shiftOptions.value.find(opt => opt.value === value)?.label || value
  }

  return value
}

const loadGames = async () => {
  try {
    let query = supabase
      .from('attributes')
      .select('id, code, name')
      .eq('type', 'GAME')
      .eq('is_active', true)
      .order('sort_order')

    if (props.gameCodes.length > 0) {
      query = query.in('code', props.gameCodes)
    }

    const { data, error } = await query

    if (!error && data) {
      games.value = data
    }
  } catch (error) {
    console.error('Error loading games:', error)
  }
}

const loadServers = async () => {
  try {
    const { data, error } = await supabase
      .from('attributes')
      .select('id, code, name')
      .in('type', ['SERVER', 'GAME_SERVER'])
      .eq('is_active', true)
      .order('sort_order')

    if (!error && data) {
      servers.value = data
    }
  } catch (error) {
    console.error('Error loading servers:', error)
  }
}

const loadChannels = async () => {
  try {
    const { data, error } = await supabase
      .from('channels')
      .select('id, name, code')
      .eq('is_active', true)
      .order('name')

    if (!error && data) {
      channels.value = data
    }
  } catch (error) {
    console.error('Error loading channels:', error)
  }
}

const loadEmployees = async () => {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('id, display_name') // Remove 'name' column - doesn't exist
      .eq('status', 'active') // Only filter by 'active' status
      .order('display_name')

    if (!error && data) {
      employees.value = data
    }
  } catch (error) {
    console.error('Error loading employees:', error)
  }
}

const loadShifts = async () => {
  try {
    const { data, error } = await supabase
      .from('work_shifts')
      .select('id, name, start_time, end_time, is_active')
      .eq('is_active', true)
      .order('start_time')

    if (!error && data) {
      shifts.value = data
    }
  } catch (error) {
    console.error('Error loading shifts:', error)
  }
}

// Lifecycle
onMounted(() => {
  loadGames()
  if (props.showServerFilter) loadServers()
  if (props.showChannelFilter) loadChannels()
  if (props.showEmployeeFilter) loadEmployees()
  if (props.showShiftFilter) loadShifts()
})
</script>

<style scoped>
.filter-panel {
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border: 1px solid #e2e8f0;
  contain: layout style; /* CSS containment for better performance */
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 2px;
  flex-shrink: 0;
  contain: layout style; /* CSS containment to reduce reflows */
}

.filter-label {
  font-size: 10px;
  font-weight: 500;
  color: #64748b;
  margin-bottom: 1px;
  white-space: nowrap;
}

:deep(.n-form-item) {
  margin-bottom: 0;
}

:deep(.n-form-item-label) {
  font-weight: 500;
  color: #475569;
  font-size: 12px;
}

/* Custom select styling for small size - optimized for ResizeObserver */
:deep(.n-base-selection .n-base-selection-label) {
  font-size: 12px;
  padding: 4px 8px;
  transition: none; /* Disable transitions to reduce ResizeObserver triggers */
}

:deep(.n-base-selection.n-base-selection--small .n-base-selection-label) {
  height: 32px;
  line-height: 24px;
  transition: none;
}

:deep(.n-base-selection .n-base-selection-tags) {
  height: 32px;
  min-height: 32px;
  display: flex;
  align-items: center;
  flex-wrap: nowrap;
  overflow: hidden;
  transition: none;
}

:deep(.n-base-selection .n-base-selection-tag) {
  font-size: 11px;
  height: 18px;
  line-height: 16px;
  padding: 1px 6px;
  margin: 1px;
  flex-shrink: 0;
  transition: none;
  contain: layout style; /* CSS containment to reduce reflows */
}

/* Add contain property to filter items for better performance */
.filter-item {
  contain: layout style;
}

/* Date picker styling */
:deep(.n-date-picker .n-input) {
  font-size: 12px;
}

:deep(.n-date-picker .n-input .n-input__input-el) {
  height: 32px;
  padding: 4px 8px;
  font-size: 12px;
}

/* Scrollbar styling for horizontal scroll */
:deep(.filter-panel::-webkit-scrollbar) {
  height: 4px;
}

:deep(.filter-panel::-webkit-scrollbar-track) {
  background: #f1f5f9;
  border-radius: 2px;
}

:deep(.filter-panel::-webkit-scrollbar-thumb) {
  background: #cbd5e1;
  border-radius: 2px;
}

:deep(.filter-panel::-webkit-scrollbar-thumb:hover) {
  background: #94a3b8;
}
</style>