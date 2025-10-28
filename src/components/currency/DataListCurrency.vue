<!-- path: src/components/currency/DataListCurrency.vue -->
<template>
  <div class="data-list-currency">
    <!-- Header with Actions -->
    <div class="flex items-center justify-between mb-6">
      <div class="flex items-center gap-3">
      </div>

      <div class="flex items-center gap-3">
        <!-- Search -->
        <n-input
          v-model:value="searchQuery"
          placeholder="Tìm kiếm..."
          clearable
          class="w-64"
          @input="onSearch"
        >
          <template #prefix>
            <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
          </template>
        </n-input>

        <!-- Filter -->
        <n-button quaternary @click="showFilters = !showFilters">
          <template #icon>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
              />
            </svg>
          </template>
          Bộ lọc
        </n-button>

        <!-- Export -->
        <n-button quaternary @click="onExport">
          <template #icon>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
          </template>
          Xuất file
        </n-button>
      </div>
    </div>

    <!-- Filters Panel -->
    <div v-if="showFilters" class="mb-6 p-4 bg-gray-50 rounded-lg">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Trạng thái</label>
          <n-select
            v-model:value="filters.status"
            :options="statusOptions"
            placeholder="Chọn trạng thái"
            clearable
            @update:value="onFilterChange"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Loại giao dịch</label>
          <n-select
            v-model:value="filters.type"
            :options="typeOptions"
            placeholder="Chọn loại giao dịch"
            clearable
            @update:value="onFilterChange"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Khoảng thời gian</label>
          <n-date-picker
            v-model:value="filters.dateRange"
            type="daterange"
            clearable
            @update:value="onFilterChange"
          />
        </div>
      </div>
    </div>

    <!-- Statistics Cards -->
    <!-- Different layouts for delivery vs history tabs -->
    <div v-if="modelType === 'delivery'" class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
      <!-- Delivery Tab Stats: Only show assigned and in-progress -->
      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Tổng đơn đang xử lý</p>
            <p class="text-2xl font-bold text-gray-800">{{ stats.total }}</p>
          </div>
          <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
              />
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Đã phân công</p>
            <p class="text-2xl font-bold text-blue-600">{{ stats.assigned }}</p>
          </div>
          <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Đang xử lý</p>
            <p class="text-2xl font-bold text-purple-600">{{ stats.inProgress }}</p>
          </div>
          <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M13 10V3L4 14h7v7l9-11h-7z"
              />
            </svg>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
      <!-- History Tab Stats: Only show completed and cancelled -->
      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Tổng lịch sử</p>
            <p class="text-2xl font-bold text-gray-800">{{ stats.total }}</p>
          </div>
          <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
              />
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Hoàn thành</p>
            <p class="text-2xl font-bold text-green-600">{{ stats.completed }}</p>
          </div>
          <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white p-4 rounded-lg border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600">Hủy bỏ</p>
            <p class="text-2xl font-bold text-red-600">{{ stats.cancelled }}</p>
          </div>
          <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </div>
        </div>
      </div>
    </div>

    <!-- Data Table -->
    <div class="bg-white rounded-lg border border-gray-200">
      <n-data-table
        :columns="tableColumns"
        :data="filteredData"
        :loading="loading"
        :pagination="pagination"
        :row-key="rowKey"
        striped
        size="medium"
        @update:page="onPageChange"
        @update:page-size="onPageSizeChange"
      />
    </div>

    <!-- Detail Modal -->
    <n-modal v-model:show="showDetailModal" preset="card" style="width: 600px;" title="Chi tiết giao dịch">
      <div v-if="selectedItem" class="space-y-4">
        <div v-for="(value, key) in displayDetails" :key="key" class="flex justify-between py-2 border-b">
          <span class="text-sm text-gray-600">{{ key }}:</span>
          <span class="text-sm font-medium text-gray-800">{{ value }}</span>
        </div>
      </div>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { NInput, NButton, NSelect, NDatePicker, NDataTable, NModal } from 'naive-ui'
import { h } from 'vue'

// Props
interface Props {
  modelType: 'delivery' | 'history' // Determines which data model to use
  title?: string
  description?: string
  data?: Array<any>
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelType: 'delivery',
  title: 'Danh sách giao dịch',
  description: 'Quản lý các giao dịch currency',
  data: () => [],
  loading: false
})

// Emits
interface Emits {
  (e: 'search', query: string): void
  (e: 'filter', filters: any): void
  (e: 'export'): void
  (e: 'view-detail', item: any): void
  (e: 'update-status', item: any, status: string): void
}

const emit = defineEmits<Emits>()

// State
const searchQuery = ref('')
const showFilters = ref(false)
const showDetailModal = ref(false)
const selectedItem = ref<any>(null)

const filters = ref<{
  status: string | null
  type: string | null
  dateRange: [number, number] | null
}>({
  status: null,
  type: null,
  dateRange: null
})

const pagination = ref({
  page: 1,
  pageSize: 10,
  itemCount: 0,
  showSizePicker: true,
  pageSizes: [10, 20, 50, 100]
})

// Statistics
const stats = computed(() => {
  const total = props.data.length

  // Stats differ based on model type
  if (props.modelType === 'delivery') {
    // For delivery tab: only show assigned and in-progress orders
    const assigned = props.data.filter(item => item.status === 'assigned').length
    const inProgress = props.data.filter(item => item.status === 'in_progress').length
    return { total, assigned, inProgress }
  } else {
    // For history tab: only show completed and cancelled
    const completed = props.data.filter(item => item.status === 'completed').length
    const cancelled = props.data.filter(item => item.status === 'cancelled').length
    return { total, completed, cancelled }
  }
})

// Filter options based on model type
const statusOptions = computed(() => {
  if (props.modelType === 'delivery') {
    return [
      { label: 'Chờ xử lý', value: 'pending' },
      { label: 'Đang giao', value: 'delivering' },
      { label: 'Đã giao', value: 'delivered' },
      { label: 'Hủy bỏ', value: 'cancelled' }
    ]
  } else {
    return [
      { label: 'Hoàn thành', value: 'completed' },
      { label: 'Hủy bỏ', value: 'cancelled' }
    ]
  }
})

const typeOptions = computed(() => {
  if (props.modelType === 'delivery') {
    return [
      { label: 'Mua currency', value: 'purchase' },
      { label: 'Bán currency', value: 'sell' },
      { label: 'Đổi currency', value: 'exchange' }
    ]
  } else {
    return [
      { label: 'Mua currency', value: 'purchase' },
      { label: 'Bán currency', value: 'sell' },
      { label: 'Đổi currency', value: 'exchange' },
      { label: 'Nạp tiền', value: 'deposit' },
      { label: 'Rút tiền', value: 'withdraw' }
    ]
  }
})

// Table columns based on model type
const tableColumns = computed(() => {
  const baseColumns = [
    {
      title: 'Mã đơn',
      key: 'order_number',
      width: 120,
      render: (row: any) => row.order_number || `#${row.id?.slice(0, 8)}...`
    },
    {
      title: 'Loại',
      key: 'order_type',
      width: 120,
      render: (row: any) => {
        const orderType = row.order_type || row.type
        const colors: { [key: string]: string } = {
          PURCHASE: 'blue',
          SELL: 'green',
          purchase: 'blue',
          sell: 'green',
          exchange: 'purple',
          deposit: 'orange',
          withdraw: 'red'
        }
        const labels: { [key: string]: string } = {
          PURCHASE: 'Mua',
          SELL: 'Bán',
          purchase: 'Mua',
          sell: 'Bán',
          exchange: 'Đổi',
          deposit: 'Nạp',
          withdraw: 'Rút'
        }
        const colorKey = (orderType as string) in colors ? orderType as string : 'gray'
        return h('span', {
          class: `px-2 py-1 text-xs rounded-full bg-${colors[colorKey]}-100 text-${colors[colorKey]}-800`
        }, labels[orderType as string] || orderType)
      }
    },
    {
      title: 'Khách hàng',
      key: 'customer',
      width: 150,
      render: (row: any) => row.customer_name || row.customerName || row.customer?.name || '-'
    },
    {
      title: 'Currency',
      key: 'currency',
      width: 120,
      render: (row: any) => row.currency_attribute?.name || row.currencyName || row.currency?.name || '-'
    },
    {
      title: 'Số lượng',
      key: 'quantity',
      width: 120,
      render: (row: any) => {
        const quantity = row.quantity || row.amount || 0
        const currencyName = row.currency_attribute?.name || row.currencyName || ''
        return `${quantity.toLocaleString()} ${currencyName || ''}`
      }
    },
    {
      title: 'Tổng giá',
      key: 'total_price',
      width: 120,
      render: (row: any) => {
        const totalVND = row.total_price_vnd || 0
        const totalUSD = row.total_price_usd || 0
        if (totalUSD > 0) {
          return `$${totalUSD.toLocaleString()}`
        } else if (totalVND > 0) {
          return `${totalVND.toLocaleString()}₫`
        }
        return '-'
      }
    },
    {
      title: 'Kênh',
      key: 'channel',
      width: 100,
      render: (row: any) => row.channel?.name || row.channelName || '-'
    }
  ]

  // Add specific columns based on model type
  if (props.modelType === 'delivery') {
    baseColumns.push(
      {
        title: 'Trạng thái',
        key: 'status',
        width: 120,
        render: (row: any) => {
          const statusColors: { [key: string]: string } = {
            pending: 'yellow',
            assigned: 'blue',
            in_progress: 'purple',
            completed: 'green',
            cancelled: 'red',
            delivering: 'blue',
            delivered: 'green'
          }
          const statusLabels: { [key: string]: string } = {
            pending: 'Chờ xử lý',
            assigned: 'Đã phân công',
            in_progress: 'Đang xử lý',
            completed: 'Hoàn thành',
            cancelled: 'Hủy bỏ',
            delivering: 'Đang giao',
            delivered: 'Đã giao'
          }
          const statusKey = (row.status as string) in statusColors ? row.status as string : 'gray'
          return h('span', {
            class: `px-2 py-1 text-xs rounded-full bg-${statusColors[statusKey]}-100 text-${statusColors[statusKey]}-800`
          }, statusLabels[row.status as string] || row.status)
        }
      },
      {
        title: 'Thao tác',
        key: 'actions',
        width: 200,
        render: (row: any) => {
          return h('div', { class: 'flex gap-2' }, [
            h(NButton, {
              size: 'small',
              type: 'primary',
              ghost: true,
              onClick: () => onViewDetail(row)
            }, () => 'Xem'),
            h(NButton, {
              size: 'small',
              type: 'success',
              ghost: true,
              disabled: row.status === 'delivered' || row.status === 'cancelled',
              onClick: () => onUpdateStatus(row, 'delivered')
            }, () => 'Xác nhận'),
            h(NButton, {
              size: 'small',
              type: 'error',
              ghost: true,
              disabled: row.status === 'delivered' || row.status === 'cancelled',
              onClick: () => onUpdateStatus(row, 'cancelled')
            }, () => 'Hủy')
          ])
        }
      }
    )
  } else {
    baseColumns.push(
      {
        title: 'Trạng thái',
        key: 'status',
        width: 120,
        render: (row: any) => {
          const statusColors: { [key: string]: string } = {
            completed: 'green',
            failed: 'red',
            pending: 'yellow',
            cancelled: 'gray'
          }
          const statusLabels: { [key: string]: string } = {
            completed: 'Thành công',
            failed: 'Thất bại',
            pending: 'Đang chờ',
            cancelled: 'Hủy bỏ'
          }
          const statusKey = (row.status as string) in statusColors ? row.status as string : 'gray'
          return h('span', {
            class: `px-2 py-1 text-xs rounded-full bg-${statusColors[statusKey]}-100 text-${statusColors[statusKey]}-800`
          }, statusLabels[row.status as string] || row.status)
        }
      },
      {
        title: 'Ngày tạo',
        key: 'createdAt',
        width: 150,
        render: (row: any) => new Date(row.createdAt).toLocaleDateString('vi-VN')
      },
      {
        title: 'Thao tác',
        key: 'actions',
        width: 100,
        render: (row: any) => {
          return h(NButton, {
            size: 'small',
            type: 'primary',
            ghost: true,
            onClick: () => onViewDetail(row)
          }, () => 'Xem')
        }
      }
    )
  }

  return baseColumns
})

// Computed data
const filteredData = computed(() => {
  let data = [...props.data]

  // Apply search
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    data = data.filter(item =>
      (item.id && item.id.toString().toLowerCase().includes(query)) ||
      (item.customerName && item.customerName.toLowerCase().includes(query)) ||
      (item.currencyName && item.currencyName.toLowerCase().includes(query))
    )
  }

  // Apply filters
  if (filters.value.status) {
    data = data.filter(item => item.status === filters.value.status)
  }
  if (filters.value.type) {
    data = data.filter(item => item.type === filters.value.type)
  }
  if (filters.value.dateRange && filters.value.dateRange.length === 2) {
    const [start, end] = filters.value.dateRange
    data = data.filter(item => {
      const itemDate = new Date(item.createdAt).getTime()
      return itemDate >= start && itemDate <= end
    })
  }

  pagination.value.itemCount = data.length
  return data
})

const displayDetails = computed(() => {
  if (!selectedItem.value) return {}

  const item = selectedItem.value
  const baseDetails = {
    'Mã đơn': `#${item.id}`,
    'Loại giao dịch': item.type,
    'Khách hàng': item.customerName || item.customer?.name || '-',
    'Currency': item.currencyName || item.currency?.name || '-',
    'Số lượng': `${item.amount || 0} ${item.currencyName || ''}`,
    'Trạng thái': item.status,
    'Ngày tạo': new Date(item.createdAt).toLocaleString('vi-VN')
  }

  // Add model-specific details
  if (props.modelType === 'delivery') {
    return {
      ...baseDetails,
      'Kênh liên lạc': item.channelName || item.channel?.name || '-',
      'Thông tin giao hàng': item.deliveryInfo || '-',
      'Ghi chú': item.notes || '-'
    }
  } else {
    return {
      ...baseDetails,
      'Tổng tiền': `${item.totalPrice || 0} ${item.currencyName || ''}`,
      'Phương thức thanh toán': item.paymentMethod || '-',
      'Ghi chú': item.notes || '-'
    }
  }
})

// Row key for table
const rowKey = (row: any) => row.id

// Event handlers
const onSearch = () => {
  emit('search', searchQuery.value)
}

const onFilterChange = () => {
  emit('filter', filters.value)
}

const onExport = () => {
  emit('export')
}

const onPageChange = (page: number) => {
  pagination.value.page = page
}

const onPageSizeChange = (pageSize: number) => {
  pagination.value.pageSize = pageSize
  pagination.value.page = 1
}

const onViewDetail = (item: any) => {
  selectedItem.value = item
  showDetailModal.value = true
  emit('view-detail', item)
}

const onUpdateStatus = (item: any, status: string) => {
  emit('update-status', item, status)
}

// Load data on mount
onMounted(() => {
  pagination.value.itemCount = props.data.length
})

// Watch data changes
watch(() => props.data, () => {
  pagination.value.itemCount = props.data.length
})
</script>

<style scoped>
.data-list-currency {
  width: 100%;
}

.n-data-table {
  --n-td-color: white;
  --n-th-color: #f8fafc;
}

.n-data-table :deep(.n-data-table-th) {
  background-color: #f8fafc;
  font-weight: 600;
  color: #374151;
}

.n-data-table :deep(.n-data-table-td) {
  padding: 12px 16px;
}

.n-data-table :deep(.n-data-table-tr:hover) {
  background-color: #f9fafb;
}
</style>