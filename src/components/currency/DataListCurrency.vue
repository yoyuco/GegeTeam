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
        v-if="props.data && props.data.length >= 0"
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
    <n-modal v-model:show="showDetailModal" :style="{ width: '900px' }" preset="card">
      <template #header>
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <div>
            <h2 class="text-xl font-bold text-gray-900">Chi tiết giao dịch</h2>
            <p class="text-sm text-gray-500">{{ selectedItem?.order_number || '#' + selectedItem?.id?.slice(0, 8) }}</p>
          </div>
        </div>
      </template>

      <div v-if="selectedItem" class="space-y-6">
        <!-- Status Badge Section -->
        <div class="flex items-center justify-between p-4 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl border border-blue-200">
          <div class="flex items-center gap-3">
            <div :class="getStatusBadgeClass(selectedItem.status)" class="px-4 py-2 rounded-full font-semibold text-sm">
              {{ getStatusLabel(selectedItem.status, selectedItem.order_type) }}
            </div>
            <div v-if="selectedItem.order_type" class="px-3 py-1 bg-white rounded-full text-sm font-medium text-gray-700 border">
              {{ selectedItem.order_type === 'PURCHASE' ? '📥 Mua hàng' : '📤 Bán hàng' }}
            </div>
          </div>
          <div class="text-right">
            <p class="text-xs text-gray-500">Ngày tạo</p>
            <p class="text-sm font-medium text-gray-900">{{ new Date(selectedItem.created_at || selectedItem.createdAt).toLocaleString('vi-VN') }}</p>
          </div>
        </div>

        <!-- Main Information Grid -->
        <div class="grid grid-cols-2 gap-6">
          <!-- Left Column -->
          <div class="space-y-4">
            <!-- Order Information -->
            <div class="bg-white rounded-lg border border-gray-200 p-5">
              <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                </svg>
                Thông tin đơn hàng
              </h3>
              <div class="space-y-3">
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600">Mã đơn hàng:</span>
                  <span class="text-sm font-medium text-gray-900 bg-gray-100 px-2 py-1 rounded">{{ selectedItem?.order_number || '#' + selectedItem?.id?.slice(0, 8) }}</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600">Loại currency:</span>
                  <span class="text-sm font-medium text-gray-900">{{ selectedItem?.currency_attribute?.name || selectedItem?.currencyName || selectedItem?.currency?.name || '-' }}</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600">Số lượng:</span>
                  <span class="font-bold text-blue-600 text-lg">{{ selectedItem?.quantity || selectedItem?.amount || 0 }}</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600">Chi phí:</span>
                  <span class="text-sm font-bold text-green-600">{{ selectedItem?.cost_amount || 0 }} {{ selectedItem?.cost_currency_code || 'VND' }}</span>
                </div>
              </div>
            </div>

            <!-- Assignment Information -->
            <div class="bg-white rounded-lg border border-gray-200 p-5">
              <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
                Phân công xử lý
              </h3>
              <div class="space-y-3">
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600">Nhân viên:</span>
                  <span class="text-sm font-medium text-gray-900">{{ selectedItem?.assigned_employee?.display_name || selectedItem?.assignedEmployeeName || '-' }}</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600">Game Account:</span>
                  <span class="text-sm font-medium text-blue-600 font-mono">{{ selectedItem?.game_account?.account_name || selectedItem?.gameAccountName || '-' }}</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600">Kênh:</span>
                  <span class="text-sm font-medium text-gray-900">{{ selectedItem?.channel?.name || selectedItem?.channelName || '-' }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Right Column -->
          <div class="space-y-4">
            <!-- Customer/Supplier Information -->
            <div class="bg-white rounded-lg border border-gray-200 p-5">
              <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                Thông tin {{ selectedItem?.order_type === 'PURCHASE' ? 'Nhà cung cấp' : 'Khách hàng' }}
              </h3>
              <div class="space-y-3">
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600">{{ selectedItem?.order_type === 'PURCHASE' ? 'Nhà cung cấp:' : 'Khách hàng:' }}</span>
                  <span class="text-sm font-medium text-gray-900">{{
                    selectedItem?.party?.name ||
                    (selectedItem?.order_type === 'PURCHASE' ? selectedItem?.supplier_name || selectedItem?.customer_name : selectedItem?.customer_name || selectedItem?.customerName) ||
                    '-'
                  }}</span>
                </div>
                <div v-if="props.modelType === 'delivery'">
                  <div class="flex justify-between items-center">
                    <span class="text-sm text-gray-600">Game:</span>
                    <span class="text-sm font-medium text-gray-900">{{ selectedItem?.game_name || selectedItem?.game_code || selectedItem?.gameCode || '-' }}</span>
                  </div>
                  <div class="flex justify-between items-center">
                    <span class="text-sm text-gray-600">Server:</span>
                    <span class="text-sm font-medium text-gray-900">{{ selectedItem?.server_name || selectedItem?.server_attribute_code || selectedItem?.serverCode || '-' }}</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Additional Information -->
            <div v-if="props.modelType === 'delivery'" class="bg-white rounded-lg border border-gray-200 p-5">
              <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <svg class="w-5 h-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Thông tin bổ sung
              </h3>
              <div class="space-y-3">
                <div>
                  <div class="flex justify-between items-center mb-1">
                    <span class="text-sm text-gray-600">Thông tin giao hàng:</span>
                    <n-button
                      v-if="selectedItem?.delivery_info || selectedItem?.deliveryInfo"
                      size="tiny"
                      type="primary"
                      ghost
                      @click="handleCopyDeliveryInfo"
                      class="text-xs"
                    >
                      <template #icon>
                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                        </svg>
                      </template>
                      Copy
                    </n-button>
                  </div>
                  <p class="text-sm font-medium text-gray-900 mt-1 bg-gray-50 p-2 rounded">{{ selectedItem?.delivery_info || selectedItem?.deliveryInfo || '-' }}</p>
                </div>
                <div>
                  <span class="text-sm text-gray-600">Ghi chú:</span>
                  <p class="text-sm font-medium text-gray-900 mt-1 bg-gray-50 p-2 rounded">{{ selectedItem?.notes || '-' }}</p>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600">Độ ưu tiên:</span>
                  <span :class="getPriorityBadgeClass(selectedItem?.priority_level)" class="px-2 py-1 rounded-full text-xs font-medium">
                    {{ getPriorityLabel(selectedItem?.priority_level) }}
                  </span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600">Deadline:</span>
                  <span class="text-sm font-medium text-red-600">{{ selectedItem?.deadline_at ? new Date(selectedItem.deadline_at).toLocaleString('vi-VN') : '-' }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Proof Upload Section for Delivery Tab -->
        <div v-if="props.modelType === 'delivery'" class="bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl border border-green-200 p-5">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center gap-3">
              <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <h4 class="text-lg font-semibold text-gray-900">
                  {{ selectedItem?.order_type === 'PURCHASE' ? 'Bằng chứng nhận hàng' : 'Bằng chứng giao hàng' }}
                </h4>
              </div>
            </div>
          </div>

          <!-- SimpleProofUpload Component -->
          <div class="mt-4">
            <SimpleProofUpload
              ref="simpleProofUploadRef"
              :max-files="5"
              v-model="selectedProofFiles"
              :auto-upload="false"
            />
          </div>

          <!-- Confirmation Button -->
          <div class="mt-4">
            <n-button
              type="primary"
              size="large"
              :disabled="!selectedProofFiles.length"
              :loading="uploading"
              @click="handleConfirmDelivery"
              block
            >
              <template #icon>
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </template>
              {{ selectedItem?.order_type === 'PURCHASE' ? 'Xác nhận đã nhận hàng' : 'Xác nhận đã giao hàng' }}
            </n-button>
          </div>

          </div>
      </div>
    </n-modal>

    </div>
</template>

<script setup lang="ts">
import SimpleProofUpload from '@/components/SimpleProofUpload.vue'
import { supabase } from '@/lib/supabase'
import { NButton, NDataTable, NDatePicker, NInput, NModal, NSelect, useMessage } from 'naive-ui'
import { computed, h, onMounted, ref, watch } from 'vue'

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
  (e: 'finalize-order', item: any): void
  (e: 'proof-uploaded', data: { orderId: string; proofs: any }): void
}

const emit = defineEmits<Emits>()

// Composables
const message = useMessage()

// State
const searchQuery = ref('')
const showFilters = ref(false)
const showDetailModal = ref(false)
const selectedItem = ref<any>(null)
const selectedProofFiles = ref<any[]>([])
const uploading = ref(false)

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
  const data = props.data || []
  const total = data.length

  // Stats differ based on model type
  if (props.modelType === 'delivery') {
    // For delivery tab: only show assigned and in-progress orders
    const assigned = data.filter(item => item.status === 'assigned').length
    const inProgress = data.filter(item => item.status === 'in_progress').length
    return { total, assigned, inProgress }
  } else {
    // For history tab: only show completed and cancelled
    const completed = data.filter(item => item.status === 'completed').length
    const cancelled = data.filter(item => item.status === 'cancelled').length
    return { total, completed, cancelled }
  }
})

// Filter options based on model type
const statusOptions = computed(() => {
  if (props.modelType === 'delivery') {
    return [
      { label: 'Chờ xử lý', value: 'pending' },
      { label: 'Đang giao / Đang nhận', value: 'delivering' },
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
  // For delivery tab, use the requested order
  if (props.modelType === 'delivery') {
    const deliveryColumns = [
      {
        title: 'Mã đơn',
        key: 'order_number',
        width: 120,
        render: (row: any) => row.order_number || `#${row.id?.slice(0, 8)}...`
      },
      {
        title: 'Loại',
        key: 'order_type',
        width: 100,
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
        title: 'Kênh',
        key: 'channel',
        width: 120,
        render: (row: any) => {
          const channelName = row.channel?.name || row.channelName || '-'
          const channelCode = row.channel?.code || row.channelCode || 'Other'

          if (channelName === '-') return channelName

          return h('span', {
            class: `inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getChannelTagClass(channelCode)}`
          }, channelName)
        }
      },
      {
        title: 'Customer/Supplier',
        key: 'customer',
        width: 150,
        render: (row: any) => {
          // For purchase orders, show supplier name, for sell orders show customer name
          const partyName = row.party?.name || (row.order_type === 'PURCHASE' ? row.supplier_name || row.customer_name : row.customer_name || row.customerName) || '-'
          return partyName
        }
      },
      {
        title: 'Currency',
        key: 'currency',
        width: 120,
        render: (row: any) => {
          const currencyName = row.currency_attribute?.name || row.currencyName || row.currency?.name || '-'
          const currencyCode = row.currency_attribute?.code || row.currencyCode || row.currency?.code || 'Other'

          if (currencyName === '-') return currencyName

          return h('span', {
            class: `inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getCurrencyTagClass(currencyCode)}`
          }, currencyName)
        }
      },
      {
        title: 'Số lượng',
        key: 'quantity',
        width: 120,
        render: (row: any) => {
          const quantity = row.quantity || row.amount || 0
          return `${quantity.toLocaleString()}`
        }
      },
      {
        title: 'Thông tin',
        key: 'delivery_info',
        width: 200,
        render: (row: any) => {
          const deliveryInfo = row.delivery_info || ''
          const notes = row.notes || ''
          const combinedInfo = deliveryInfo && notes ? `${deliveryInfo} | ${notes}` : deliveryInfo || notes || '-'
          return combinedInfo.length > 30 ? `${combinedInfo.substring(0, 30)}...` : combinedInfo
        }
      },
      {
        title: 'Bằng chứng',
        key: 'proofs',
        width: 120,
        render: (row: any) => {
          const proofs = row.proofs
          const hasProof = proofs && (proofs.images && proofs.images.length > 0 || proofs.files && proofs.files.length > 0)
          return h('div', { class: 'flex items-center gap-2' }, [
            hasProof
              ? h('span', { class: 'text-green-600 text-sm' }, '✓ Có')
              : h('span', { class: 'text-red-600 text-sm' }, '✗ Chưa')
          ])
        }
      },
      {
        title: 'Thao tác',
        key: 'actions',
        width: 200,
        render: (row: any) => {
          const buttons = []

          // Always show "Xem" button for all orders
          buttons.push(h(NButton, {
            size: 'small',
            type: 'primary',
            ghost: true,
            onClick: () => onViewDetail(row)
          }, () => 'Xem'))

          // For delivered status: show "Hoàn tất" button
          if (row.status === 'delivered') {
            buttons.push(h(NButton, {
              size: 'small',
              type: 'success',
              onClick: () => onFinalizeOrder(row)
            }, () => 'Hoàn tất'))
          }
          // For all other statuses (except completed/cancelled): show "Hủy bỏ" button
          else if (row.status !== 'completed' && row.status !== 'cancelled') {
            buttons.push(h(NButton, {
              size: 'small',
              type: 'error',
              ghost: true,
              onClick: () => onUpdateStatus(row, 'cancelled')
            }, () => 'Hủy bỏ'))
          }

          return h('div', { class: 'flex gap-1' }, buttons.filter(Boolean))
        }
      },
      {
        title: 'Trạng thái',
        key: 'status',
        width: 120,
        render: (row: any) => {
          const statusColors: { [key: string]: string } = {
            draft: 'gray',
            pending: 'yellow',
            assigned: 'blue',
            preparing: 'purple',
            ready: 'blue',
            delivering: 'blue',
            delivered: 'teal', // Delivered but waiting final confirmation
            completed: 'green',
            cancelled: 'red',
            failed: 'red'
          }
          const statusLabels: { [key: string]: string } = {
            draft: 'Nháp',
            pending: 'Chờ xử lý',
            assigned: 'Đã phân công',
            preparing: 'Đang chuẩn bị',
            ready: 'Sẵn sàng giao',
            delivering: row.order_type === 'PURCHASE' ? 'Đang nhận' : 'Đang giao',
            delivered: row.order_type === 'PURCHASE' ? 'Đã nhận hàng' : 'Đã giao hàng', // Different text based on order type
            completed: 'Hoàn thành',
            cancelled: 'Hủy bỏ',
            failed: 'Thất bại'
          }
          const statusKey = (row.status as string) in statusColors ? row.status as string : 'gray'
          return h('span', {
            class: `px-2 py-1 text-xs rounded-full bg-${statusColors[statusKey]}-100 text-${statusColors[statusKey]}-800`
          }, statusLabels[row.status as string] || row.status)
        }
      }
    ]
    return deliveryColumns
  }

  // For other tabs (history), keep the original structure
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
      render: (row: any) => {
        const currencyName = row.currency_attribute?.name || row.currencyName || row.currency?.name || '-'
        const currencyCode = row.currency_attribute?.code || row.currencyCode || row.currency?.code || 'Other'

        if (currencyName === '-') return currencyName

        return h('span', {
          class: `inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getCurrencyTagClass(currencyCode)}`
        }, currencyName)
      }
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
      width: 120,
      render: (row: any) => {
        const channelName = row.channel?.name || row.channelName || '-'
        const channelCode = row.channel?.code || row.channelCode || 'Other'

        if (channelName === '-') return channelName

        return h('span', {
          class: `inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getChannelTagClass(channelCode)}`
        }, channelName)
      }
    }
  ]

  // For history tab, add status and actions
  if (props.modelType === 'history') {
    baseColumns.push(
      {
        title: 'Trạng thái',
        key: 'status',
        width: 120,
        render: (row: any) => {
          const statusColors: { [key: string]: string } = {
            completed: 'green',
            cancelled: 'red'
          }
          const statusLabels: { [key: string]: string } = {
            completed: 'Hoàn thành',
            cancelled: 'Hủy bỏ'
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
        width: 120,
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
  let data = [...(props.data || [])]

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


// Helper functions for labels
const getStatusLabel = (status: string, orderType?: string) => {
  const statusLabels: { [key: string]: string } = {
    draft: 'Nháp',
    pending: 'Chờ xử lý',
    assigned: 'Đã phân công',
    preparing: 'Đang chuẩn bị',
    ready: 'Sẵn sàng giao',
    delivering: orderType === 'PURCHASE' ? 'Đang nhận' : 'Đang giao',
    delivered: orderType === 'PURCHASE' ? 'Đã nhận hàng' : 'Đã giao hàng', // Different text based on order type
    completed: 'Hoàn thành',
    cancelled: 'Hủy bỏ',
    failed: 'Thất bại'
  }
  return statusLabels[status] || status
}


const getPriorityLabel = (level: number) => {
  const priorityLabels: { [key: number]: string } = {
    1: 'Rất cao',
    2: 'Cao',
    3: 'Trung bình',
    4: 'Thấp',
    5: 'Rất thấp'
  }
  return priorityLabels[level] || `Độ ưu tiên ${level}`
}

// Badge styling functions for the modal
const getStatusBadgeClass = (status: string) => {
  const statusClasses: { [key: string]: string } = {
    draft: 'bg-gray-100 text-gray-800',
    pending: 'bg-yellow-100 text-yellow-800',
    assigned: 'bg-blue-100 text-blue-800',
    preparing: 'bg-purple-100 text-purple-800',
    ready: 'bg-indigo-100 text-indigo-800',
    delivering: 'bg-orange-100 text-orange-800',
    delivered: 'bg-teal-100 text-teal-800', // Delivered but waiting final confirmation
    completed: 'bg-green-100 text-green-800',
    cancelled: 'bg-red-100 text-red-800',
    failed: 'bg-red-100 text-red-800'
  }
  return statusClasses[status] || 'bg-gray-100 text-gray-800'
}

const getPriorityBadgeClass = (level: number) => {
  const priorityClasses: { [key: number]: string } = {
    1: 'bg-red-100 text-red-800',
    2: 'bg-orange-100 text-orange-800',
    3: 'bg-yellow-100 text-yellow-800',
    4: 'bg-green-100 text-green-800',
    5: 'bg-gray-100 text-gray-800'
  }
  return priorityClasses[level] || 'bg-gray-100 text-gray-800'
}

// Color-coded tag functions for channels and currencies
const getChannelTagClass = (channelCode: string) => {
  const channelColors: { [key: string]: string } = {
    'G2G': 'bg-blue-100 text-blue-800 border-blue-200',
    'Eldorado': 'bg-purple-100 text-purple-800 border-purple-200',
    'Facebook': 'bg-indigo-100 text-indigo-800 border-indigo-200',
    'Discord': 'bg-violet-100 text-violet-800 border-violet-200',
    'WeChat': 'bg-green-100 text-green-800 border-green-200',
    'PlayerAuctions': 'bg-orange-100 text-orange-800 border-orange-200',
    'Other': 'bg-gray-100 text-gray-800 border-gray-200'
  }
  return channelColors[channelCode] || channelColors['Other']
}

const getCurrencyTagClass = (currencyCode: string) => {
  // Comprehensive currency grouping rules based on game and rarity
  if (!currencyCode) return 'bg-gray-100 text-gray-800 border-gray-200'

  // Determine game and currency type from code
  const gameCode = currencyCode.includes('_POE1') ? 'POE1' :
                   currencyCode.includes('_POE2') ? 'POE2' :
                   currencyCode.includes('_NW') || currencyCode.includes('_NEW_WORLD') ? 'NEW_WORLD' :
                   currencyCode.includes('_D4') ? 'DIABLO_4' : 'UNKNOWN'

  const currencyType = getCurrencyType(currencyCode)

  // Path of Exile 1 - Red Family
  if (gameCode === 'POE1') {
    switch (currencyType) {
      // Premium Orbs - Dark red background, black border (most important)
      case 'DIVINE_ORB':
      case 'EXALTED_ORB':
      case 'MIRROR':
        return 'bg-red-900 text-white border-black'

      // Standard Orbs - Medium red background, dark red border
      case 'CHAOS_ORB':
      case 'ANCIENT_ORB':
      case 'AWAKENERS_ORB':
        return 'bg-red-700 text-white border-red-900'

      // Common Orbs - Light red background, red border
      case 'ORB':
        return 'bg-red-500 text-white border-red-700'

      // Eldritch Group - Orange tones with intensity levels
      case 'ELDRITCH':
        if (currencyCode.includes('GRAND_')) return 'bg-orange-600 text-white border-orange-800'
        if (currencyCode.includes('GREATER_')) return 'bg-orange-500 text-white border-orange-700'
        if (currencyCode.includes('EXCEPTIONAL_')) return 'bg-orange-400 text-white border-orange-600'
        return 'bg-orange-300 text-orange-900 border-orange-500' // LESSER

      // Lifeforce Group - Yellow-orange tones
      case 'LIFEFORCE':
        if (currencyCode.includes('PRIMAL_')) return 'bg-yellow-600 text-white border-yellow-800'
        if (currencyCode.includes('SACRED_')) return 'bg-yellow-500 text-white border-yellow-700'
        return 'bg-yellow-400 text-yellow-900 border-yellow-600' // VIVID, WILD

      // Utility Items - Light yellow tones
      case 'SEXTANT':
      case 'SCROLL':
      case 'PRISM':
      case 'BAUBLE':
      case 'CHISEL':
      case 'SCRAP':
      case 'WHETSTONE':
        return 'bg-yellow-200 text-yellow-900 border-yellow-400'

      // Miscellaneous
      case 'MISC':
      default:
        return 'bg-red-200 text-red-900 border-red-400'
    }
  }

  // Path of Exile 2 - Blue Family
  if (gameCode === 'POE2') {
    switch (currencyType) {
      // Premium Orbs - Dark blue background, black border
      case 'DIVINE_ORB':
      case 'EXALTED_ORB':
      case 'MIRROR':
        return 'bg-blue-900 text-white border-black'

      // Standard Orbs - Medium blue background, dark blue border
      case 'CHAOS_ORB':
      case 'ANCIENT_ORB':
      case 'AWAKENERS_ORB':
        return 'bg-blue-700 text-white border-blue-900'

      // Common Orbs - Light blue background, blue border
      case 'ORB':
        return 'bg-blue-500 text-white border-blue-700'

      // Eldritch Group - Cyan tones with intensity levels
      case 'ELDRITCH':
        if (currencyCode.includes('GRAND_')) return 'bg-cyan-600 text-white border-cyan-800'
        if (currencyCode.includes('GREATER_')) return 'bg-cyan-500 text-white border-cyan-700'
        if (currencyCode.includes('EXCEPTIONAL_')) return 'bg-cyan-400 text-white border-cyan-600'
        return 'bg-cyan-300 text-cyan-900 border-cyan-500' // LESSER

      // Lifeforce Group - Teal-green tones
      case 'LIFEFORCE':
        if (currencyCode.includes('PRIMAL_')) return 'bg-teal-600 text-white border-teal-800'
        if (currencyCode.includes('SACRED_')) return 'bg-teal-500 text-white border-teal-700'
        return 'bg-teal-400 text-teal-900 border-teal-600' // VIVID, WILD

      // Utility Items - Light sky blue tones
      case 'SEXTANT':
      case 'SCROLL':
      case 'PRISM':
      case 'BAUBLE':
      case 'CHISEL':
      case 'SCRAP':
      case 'WHETSTONE':
        return 'bg-sky-200 text-sky-900 border-sky-400'

      // Miscellaneous
      case 'MISC':
      default:
        return 'bg-blue-200 text-blue-900 border-blue-400'
    }
  }

  // New World - Green Family
  if (gameCode === 'NEW_WORLD') {
    switch (currencyType) {
      case 'GOLD':
        return 'bg-green-700 text-white border-green-900' // Premium currency
      default:
        return 'bg-green-500 text-white border-green-700'
    }
  }

  // Diablo 4 - Purple Family
  if (gameCode === 'DIABLO_4') {
    switch (currencyType) {
      case 'GOLD':
        return 'bg-purple-700 text-white border-purple-900' // Premium currency
      default:
        return 'bg-purple-500 text-white border-purple-700'
    }
  }

  // Default for unknown currencies
  return 'bg-gray-100 text-gray-800 border-gray-200'
}

// Helper function to determine currency type from code
const getCurrencyType = (code: string) => {
  if (code.includes('MIRROR')) return 'MIRROR'
  if (code.includes('DIVINE')) return 'DIVINE_ORB'
  if (code.includes('EXALTED')) return 'EXALTED_ORB'
  if (code.includes('CHAOS')) return 'CHAOS_ORB'
  if (code.includes('ANCIENT')) return 'ANCIENT_ORB'
  if (code.includes('AWAKENERS')) return 'AWAKENERS_ORB'
  if (code.includes('ELDRITCH')) return 'ELDRITCH'
  if (code.includes('SEXTANT')) return 'SEXTANT'
  if (code.includes('SCRAP')) return 'SCRAP'
  if (code.includes('WHETSTONE')) return 'WHETSTONE'
  if (code.includes('CHISEL')) return 'CHISEL'
  if (code.includes('PRISM')) return 'PRISM'
  if (code.includes('BAUBLE')) return 'BAUBLE'
  if (code.includes('GOLD')) return 'GOLD'
  if (code.includes('SCROLL')) return 'SCROLL'
  if (code.includes('SACRED') || code.includes('PRIMAL') || code.includes('VIVID') || code.includes('WILD')) return 'LIFEFORCE'
  if (code.includes('JEWELLERS')) return 'JEWELLERS_ORB'
  if (code.includes('CHROMATIC')) return 'CHROMATIC_ORB'
  if (code.includes('REGAL')) return 'REGAL_ORB'
  if (code.includes('ALCHEMY')) return 'ALCHEMY_ORB'
  if (code.includes('ALTERATION')) return 'ALTERATION_ORB'
  if (code.includes('AUGMENTATION')) return 'AUGMENTATION_ORB'
  if (code.includes('TRANSMUTATION')) return 'TRANSMUTATION_ORB'
  if (code.includes('CHANCE')) return 'CHANCE_ORB'
  if (code.includes('FUSING')) return 'FUSING_ORB'
  if (code.includes('ORB')) return 'ORB'
  return 'MISC'
}

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

const onFinalizeOrder = (item: any) => {
  emit('finalize-order', item)
}

const handleCopyDeliveryInfo = async () => {
  if (!selectedItem.value) return

  try {
    // Get delivery info text
    const deliveryInfo = selectedItem.value?.delivery_info || selectedItem.value?.deliveryInfo || ''

    // Copy to clipboard
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(deliveryInfo)
    } else {
      // Fallback for older browsers
      const textArea = document.createElement('textarea')
      textArea.value = deliveryInfo
      document.body.appendChild(textArea)
      textArea.focus()
      textArea.select()
      document.execCommand('copy')
      document.body.removeChild(textArea)
    }

    // Update order status to 'delivering' if current status allows it
    const allowedStatuses = ['preparing', 'ready']
    if (allowedStatuses.includes(selectedItem.value.status)) {
      emit('update-status', selectedItem.value, 'delivering')
    }

    // Show success message
    const deliveringText = selectedItem.value?.order_type === 'PURCHASE' ? 'Đang nhận' : 'Đang giao'
    message.success(`Đã copy thông tin giao hàng${allowedStatuses.includes(selectedItem.value.status) ? ` và chuyển sang trạng thái "${deliveringText}"` : ''}`)

  } catch (error) {
    console.error('Error copying delivery info:', error)
    message.error('Không thể copy thông tin giao hàng')
  }
}



// New handlers for integrated SimpleProofUpload component
const handleProofUploadComplete = async (uploadedFiles: any[]) => {
  console.log('Proof files uploaded via SimpleProofUpload:', uploadedFiles)
  console.log('Current selectedProofFiles:', selectedProofFiles.value)

  // Files are already uploaded by SimpleProofUpload component
  // The component should have updated selectedProofFiles automatically
  // Just log for debugging purposes
}

const handleConfirmDelivery = async () => {
  if (!selectedItem.value || selectedProofFiles.value.length === 0) {
    message.error('Vui lòng tải lên ít nhất một bằng chứng')
    return
  }

  try {
    uploading.value = true

    const order = selectedItem.value
    const orderNumber = order.order_number || `#${order.id?.slice(0, 8)}`

    console.log('Processing files for order:', order.id)
    console.log('Files to upload:', selectedProofFiles.value)

    // Upload files manually (work-proofs is bucket name, not part of path)
    const uploadPath = order.order_type === 'PURCHASE'
      ? `currency/purchase/${order.order_number}/delivery`
      : `currency/sale/${order.order_number}/delivery`

    // Import uploadFile function
    const { uploadFile } = await import('@/lib/supabase')

    // Upload all files
    const uploadPromises = selectedProofFiles.value.map(async (f, index) => {
      if (!f.file) {
        throw new Error(`File ${f.name} không có dữ liệu`)
      }

      // Create unique filename
      const timestamp = Date.now()
      const randomString = Math.random().toString(36).substring(2, 8)
      const filename = `${timestamp}-${randomString}-${f.file.name}`
      const filePath = `${uploadPath}/${filename}`

      console.log(`Uploading file ${index + 1}:`, f.name, 'to', filePath)

      const uploadResult = await uploadFile(f.file, filePath, 'work-proofs')

      if (!uploadResult.success) {
        throw new Error(uploadResult.error || 'Upload thất bại')
      }

      return {
        url: uploadResult.publicUrl,
        path: uploadResult.path,
        filename: f.name,
        type: order.order_type === 'PURCHASE' ? 'receiving' : 'delivery',
        uploaded_at: new Date().toISOString()
      }
    })

    const newProofFiles = await Promise.all(uploadPromises)

    // Prepare proof data for database - handle different proof formats
    let existingProofs: any[] = []

    if (order.proofs) {
      try {
        // Handle case where proofs is a stringified JSON
        if (typeof order.proofs === 'string') {
          existingProofs = JSON.parse(order.proofs)
        }
        // Handle case where proofs is an array but might be corrupted
        else if (Array.isArray(order.proofs)) {
          // Check if array contains corrupted character data
          if (order.proofs.length > 0 && typeof order.proofs[0] === 'string' && order.proofs[0].length === 1) {
            // Corrupted array - skip it and start fresh
            existingProofs = []
            console.warn('Found corrupted proofs array, starting fresh')
          } else {
            existingProofs = order.proofs
          }
        }
      } catch (error) {
        console.error('Error parsing existing proofs:', error)
        existingProofs = []
      }
    }

    // Merge proofs by type to preserve all proof types
    let mergedProofs = [...existingProofs]

    // Remove any existing proofs of the same type to avoid duplicates
    const newProofType = order.order_type === 'PURCHASE' ? 'receiving' : 'delivery'
    mergedProofs = mergedProofs.filter(proof => proof.type !== newProofType)

    // Add new proofs
    const newProofs = [...mergedProofs, ...newProofFiles]

    console.log('Upload completed successfully. Files uploaded:', newProofFiles.length)
    console.log('Proof types in existing proofs:', existingProofs.map(p => p.type))
    console.log('New proof type being added:', newProofType)
    console.log('Final proofs count:', newProofs.length)

    // Update the order in database with proofs and status
    const updateData: any = {
      proofs: newProofs,
      updated_at: new Date().toISOString()
    }

    // Auto-update status to 'delivered' after successful proof upload
    // Only if current status is 'assigned', 'delivering', 'ready', or 'preparing'
    let statusChanged = false
    if (['assigned', 'delivering', 'ready', 'preparing'].includes(order.status)) {
      updateData.status = 'delivered'
      statusChanged = true
      console.log('Status will be updated from', order.status, 'to delivered')
    } else {
      console.log('Status will NOT be updated. Current status:', order.status, 'is not in allowed list')
    }

    const { error: updateError } = await supabase
      .from('currency_orders')
      .update(updateData)
      .eq('id', order.id)

    if (updateError) {
      console.error('Error updating order with proofs:', updateError)
      throw updateError
    }

    // Process inventory and transactions if order status changed to 'delivered'
    let inventoryUpdateResult = null
    console.log('=== Starting inventory update process ===')
    console.log('Status changed:', statusChanged)
    console.log('Order ID:', order.id)
    console.log('Order Status:', order.status)
    console.log('Order Type:', order.order_type)
    console.log('Order Number:', order.order_number)

    if (statusChanged) {
      try {
        // Get current user ID from profiles - handle both array and single return types
        const { data: currentUserData, error: userError } = await supabase.rpc('get_current_profile_id')

        if (userError) {
          console.error('Error getting current user:', userError)
          throw new Error(`Không thể lấy thông tin user: ${userError.message}`)
        }

        // Handle case where function returns array or single value
        const currentUser = Array.isArray(currentUserData) ? currentUserData[0] : currentUserData

        if (!currentUser) {
          // Fallback: use assigned employee or create default system user
          const fallbackUserId = order.assigned_to || '3c6f63c0-6cc5-4e04-9ccc-c5b92a8868dc' // Bot (auto) profile
          console.log('Using fallback user ID:', fallbackUserId)
          console.log('Calling process_delivery_confirmation_v2 with fallback order ID:', order.id, 'and user ID:', fallbackUserId)

          // Call the process_delivery_confirmation_v2 function with fallback user
          const { data: processResult, error: processError } = await supabase.rpc('process_delivery_confirmation_v2', {
            p_order_id: order.id,
            p_user_id: fallbackUserId
          })

          if (processError) {
            console.error('Error processing delivery:', processError)
            throw new Error(`Không thể cập nhật kho: ${processError.message}`)
          }

          inventoryUpdateResult = processResult
        } else {
          // Call the process_delivery_confirmation_v2 function with current user
          console.log('Calling process_delivery_confirmation_v2 with order ID:', order.id, 'and user ID:', currentUser)
          const { data: processResult, error: processError } = await supabase.rpc('process_delivery_confirmation_v2', {
            p_order_id: order.id,
            p_user_id: currentUser
          })

          if (processError) {
            console.error('Error processing delivery:', processError)
            throw new Error(`Không thể cập nhật kho: ${processError.message}`)
          }

          inventoryUpdateResult = processResult
        }

        console.log('Inventory update result:', inventoryUpdateResult)

        // Show detailed debug information
        if (inventoryUpdateResult && inventoryUpdateResult.debug) {
          console.log('Debug info:', JSON.stringify(inventoryUpdateResult.debug, null, 2))
        }

      } catch (inventoryError: any) {
        console.error('Inventory update error:', inventoryError)
        // Don't fail the entire operation, but show warning
        message.warning(`Đã cập nhật bằng chứng nhưng không thể cập nhật kho: ${inventoryError.message}`)
        console.log('Full error details:', inventoryError)
      }
    }

    // Update local data
    if (selectedItem.value) {
      selectedItem.value.proofs = newProofs
      if (statusChanged) {
        selectedItem.value.status = 'delivered'
      }
    }

    // Reset files
    selectedProofFiles.value = []

    let successMessage = `✅ Đã tải lên ${newProofFiles.length} bằng chứng cho đơn ${orderNumber} thành công!`

    // Add status change notification if applicable
    if (statusChanged) {
      const statusText = order.order_type === 'PURCHASE' ? 'Đã nhận hàng' : 'Đã giao hàng'
      successMessage += ` Trạng thái đã được cập nhật thành "${statusText}".`

      // Add inventory update info if available
      if (inventoryUpdateResult && inventoryUpdateResult.success) {
        const transactionTypeText = order.order_type === 'PURCHASE' ? 'nhập kho' : 'xuất kho'
        const newQuantity = inventoryUpdateResult.data?.new_quantity || 0
        const avgCost = inventoryUpdateResult.data?.new_average_cost || 0

        successMessage += ` Đã ${transactionTypeText} ${order.quantity} currency (Tồn kho: ${newQuantity}, Giá TB: ${avgCost.toFixed(2)} ${order.cost_currency_code || 'VND'}).`
      }
    }

    message.success(successMessage)

    // Emit event to refresh parent data
    emit('proof-uploaded', { orderId: order.id, proofs: newProofs })

    // Also emit status update if status changed
    if (statusChanged) {
      emit('update-status', order, 'delivered')
    }

    // Close detail modal after successful confirmation
    showDetailModal.value = false

  } catch (error: any) {
    console.error('Error confirming delivery:', error)
    message.error(error.message || 'Không thể xác nhận giao/nhận hàng. Vui lòng thử lại.')
  } finally {
    uploading.value = false
  }
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