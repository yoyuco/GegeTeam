<!-- path: src/components/admin/BusinessProcessesManagement.vue -->
<template>
  <div class="business-processes-management">
    <!-- Header Actions -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-semibold">Quản lý Quy trình Kinh doanh</h2>
        <n-tag type="info" size="small">{{ filteredProcesses.length }} quy trình</n-tag>
        <n-tag type="info" size="small">Stock Pools</n-tag>
      </div>
      <div class="flex items-center gap-2">
        <n-button type="primary" @click="openCreateModal">
          <template #icon>
            <n-icon><PlusIcon /></n-icon>
          </template>
          Thêm quy trình mới
        </n-button>
      </div>
    </div>

    <!-- Filter Panel -->
    <FilterPanel
      :show-status-filter="true"
      :show-date-filter="true"
      @filter-change="handleFilterChange"
    />

    <!-- Data Table -->
    <n-card>
      <n-data-table
        :columns="columns"
        :data="filteredProcesses"
        :loading="loading"
        :pagination="{ pageSize: 15 }"
        :bordered="false"
        :single-line="false"
        :row-key="(row: any) => row.id"
        striped
      />
    </n-card>

    <!-- Create/Edit Modal -->
    <n-modal
      v-model:show="modalOpen"
      :mask-closable="false"
      :style="{ width: '900px' }"
      preset="card"
      :title="editingProcess ? 'Chỉnh sửa Quy trình Kinh doanh' : 'Thêm Quy trình Kinh doanh mới'"
      size="large"
    >
      <div class="process-form">
        <n-form
          ref="formRef"
          :model="formData"
          :rules="formRules"
          label-placement="top"
          label-width="auto"
          require-mark-placement="right-hanging"
          size="large"
        >
          <!-- Main Content in 2 Columns -->
          <n-grid :cols="12" :x-gap="24" :y-gap="20">

            <!-- Left Column (8/12) -->
            <n-gi :span="8">
              <!-- Basic Information Section -->
              <div class="form-section mb-6">
                <div class="section-title mb-4">
                  <n-icon size="18" color="#2080f0">
                    <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                  </n-icon>
                  <span class="font-medium">Thông tin cơ bản</span>
                </div>

                <n-grid :cols="2" :x-gap="16">
                  <n-gi>
                    <n-form-item label="Mã quy trình" path="code">
                      <n-input
                        v-model:value="formData.code"
                        placeholder="⚙️ P_SAN_A_SAN_B"
                        size="medium"
                      />
                    </n-form-item>
                  </n-gi>
                  <n-gi>
                    <n-form-item label="Trạng thái" path="is_active">
                      <n-switch
                        v-model:value="formData.is_active"
                        :checked-value="true"
                        :unchecked-value="false"
                        size="medium"
                      >
                        <template #checked>
                          <span class="text-green-600">🟢 Hoạt động</span>
                        </template>
                        <template #unchecked>
                          <span class="text-red-600">🔴 Ngừng</span>
                        </template>
                      </n-switch>
                    </n-form-item>
                  </n-gi>
                </n-grid>

                <n-form-item label="Tên quy trình" path="name">
                  <n-input
                    v-model:value="formData.name"
                    placeholder="📝 Tên quy trình kinh doanh"
                    size="medium"
                  />
                </n-form-item>

                <n-form-item label="Mô tả" path="description">
                  <n-input
                    v-model:value="formData.description"
                    type="textarea"
                    placeholder="📋 Mô tả chi tiết về quy trình"
                    :rows="3"
                    size="medium"
                  />
                </n-form-item>
              </div>

              <!-- Channel and Currency Section -->
              <div class="form-section">
                <div class="section-title mb-4">
                  <n-icon size="18" color="#2080f0">
                    <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 22L12 18.56L5.82 22L7 14.14l-5-4.87l6.91-1.01L12 2z"/></svg>
                  </n-icon>
                  <span class="font-medium">Kênh và Tiền tệ</span>
                </div>

                <n-grid :cols="2" :x-gap="16" :y-gap="12">
                  <n-gi>
                    <n-form-item label="Kênh bán" path="sale_channel_id">
                      <n-select
                        v-model:value="formData.sale_channel_id"
                        :options="channelOptions"
                        placeholder="📡 Chọn kênh bán"
                        clearable
                        filterable
                        size="medium"
                      />
                    </n-form-item>
                  </n-gi>
                  <n-gi>
                    <n-form-item label="Tiền tệ bán" path="sale_currency">
                      <n-input
                        v-model:value="formData.sale_currency"
                        placeholder="💱 VD: VND, USD"
                        size="medium"
                      />
                    </n-form-item>
                  </n-gi>
                  <n-gi>
                    <n-form-item label="Kênh mua" path="purchase_channel_id">
                      <n-select
                        v-model:value="formData.purchase_channel_id"
                        :options="channelOptions"
                        placeholder="📡 Chọn kênh mua"
                        clearable
                        filterable
                        size="medium"
                      />
                    </n-form-item>
                  </n-gi>
                  <n-gi>
                    <n-form-item label="Tiền tệ mua" path="purchase_currency">
                      <n-input
                        v-model:value="formData.purchase_currency"
                        placeholder="💱 VD: VND, USD"
                        size="medium"
                      />
                    </n-form-item>
                  </n-gi>
                </n-grid>
              </div>
            </n-gi>

            <!-- Right Column (4/12) -->
            <n-gi :span="4">
              <!-- Fee Management Section -->
              <div class="form-section">
                <div class="section-title mb-4">
                  <n-icon size="18" color="#2080f0">
                    <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                  </n-icon>
                  <span class="font-medium">Phí áp dụng</span>
                </div>

                <div class="space-y-3">
                  <!-- Assigned Fees List -->
                  <div class="max-h-48 overflow-y-auto space-y-2 border rounded-lg p-3 bg-gray-50">
                    <div
                      v-for="(assignedFee, index) in assignedFees"
                      :key="assignedFee.fee_id"
                      class="bg-white p-2 rounded border border-gray-200 hover:border-gray-300 transition-colors"
                    >
                      <div class="flex items-start justify-between">
                        <div class="flex-1 min-w-0">
                          <div class="font-medium text-sm truncate">{{ assignedFee.fee_name }}</div>
                          <div class="text-xs text-gray-500 mt-1">
                            {{ assignedFee.fee_direction }} • {{ assignedFee.fee_amount }} {{ assignedFee.fee_currency }}
                          </div>
                        </div>
                        <n-button
                          size="tiny"
                          type="error"
                          text
                          @click="removeAssignedFee(assignedFee.fee_id)"
                          class="ml-2"
                        >
                          <template #icon>
                            <n-icon size="14"><TrashIcon /></n-icon>
                          </template>
                        </n-button>
                      </div>
                    </div>

                    <div v-if="assignedFees.length === 0" class="text-center text-gray-400 text-sm py-4">
                      Chưa có phí nào được áp dụng
                    </div>
                  </div>

                  <!-- Add Fee Section -->
                  <div class="space-y-2">
                    <n-select
                      v-model:value="selectedFeeId"
                      :options="availableFeeOptions"
                      placeholder="Chọn phí để thêm..."
                      filterable
                      size="medium"
                    />
                    <n-button
                      type="primary"
                      :disabled="!selectedFeeId"
                      @click="addAssignedFee"
                      size="medium"
                      block
                    >
                      <template #icon>
                        <n-icon><PlusIcon /></n-icon>
                      </template>
                      Thêm phí
                    </n-button>
                  </div>

                  <!-- Fee Count -->
                  <div class="text-center text-sm text-gray-500 pt-2 border-t">
                    Đã áp dụng <span class="font-medium text-blue-600">{{ assignedFees.length }}</span> phí
                  </div>
                </div>
              </div>
            </n-gi>
          </n-grid>
        </n-form>
      </div>

        <!-- Modal Actions -->
        <template #footer>
          <div class="flex justify-between items-center">
            <div class="text-sm text-gray-500" v-if="editingProcess">
              ID: {{ editingProcess.id }}
            </div>
            <div class="flex gap-2">
              <n-button @click="closeModal" size="medium">
                Hủy
              </n-button>
              <n-button
                type="primary"
                @click="handleSubmit"
                :loading="submitting"
                size="medium"
              >
                {{ editingProcess ? 'Cập nhật' : 'Tạo mới' }}
              </n-button>
            </div>
          </div>
        </template>
    </n-modal>

    <!-- Delete Confirmation Modal -->
    <n-modal
      v-model:show="deleteModalOpen"
      :mask-closable="false"
      :style="{ width: '450px' }"
      preset="card"
      title="Xác nhận xóa quy trình kinh doanh"
      size="medium"
    >
      <div class="delete-confirmation">
        <div class="warning-icon">
          <n-icon size="48" color="#d03050">
            <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg>
          </n-icon>
        </div>

        <div class="confirmation-content">
          <p class="main-question">
            Bạn có chắc chắn muốn xóa quy trình kinh doanh <strong>{{ deletingProcess?.name }}</strong> không?
          </p>
          <p class="warning-text">
            ⚠️ Hành động này không thể hoàn tác và có thể ảnh hưởng đến các tồn kho và giao dịch hiện có.
          </p>

          <div v-if="deletingProcess" class="process-details">
            <div class="detail-item">
              <span class="label">Mã quy trình:</span>
              <span class="value">{{ deletingProcess.code }}</span>
            </div>
            <div class="detail-item">
              <span class="label">Tên quy trình:</span>
              <span class="value">{{ deletingProcess.name }}</span>
            </div>
            <div class="detail-item">
              <span class="label">Số phí áp dụng:</span>
              <span class="value">
                <n-tag type="info" size="small">
                  {{ getProcessFeeCount(deletingProcess.id) }} phí
                </n-tag>
              </span>
            </div>
            <div class="detail-item">
              <span class="label">Trạng thái:</span>
              <span class="value">
                <n-tag :type="deletingProcess.is_active ? 'success' : 'error'" size="small">
                  {{ deletingProcess.is_active ? 'Hoạt động' : 'Không hoạt động' }}
                </n-tag>
              </span>
            </div>
          </div>
        </div>
      </div>

      <template #action>
        <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
          <div style="font-size: 13px; color: #909399;">
            Hãy chắc chắn về quyết định của bạn
          </div>
          <n-space>
            <n-button size="medium" @click="closeDeleteModal">
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 6.41L17.59 5L12 10.59L6.41 5L5 6.41L10.59 12L5 17.59L6.41 19L12 13.41L17.59 19L19 17.59L13.41 12L19 6.41z"/></svg>
                </n-icon>
              </template>
              Hủy
            </n-button>
            <n-button
              type="error"
              size="medium"
              :loading="deleting"
              @click="handleDelete"
            >
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>
                </n-icon>
              </template>
              Xóa quy trình
            </n-button>
          </n-space>
        </div>
      </template>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, h } from 'vue'
import { useMessage } from 'naive-ui'
import {
  NButton, NTag, NIcon, NPopconfirm, NSwitch, NDivider, NSelect,
  NCard, NDataTable, NForm, NFormItem, NInput, NModal, NGrid, NGi, NSpace
} from 'naive-ui'
import FilterPanel from './FilterPanel.vue'
import {
  CreateOutline as EditIcon,
  TrashOutline as TrashIcon,
  AddOutline as PlusIcon,
  GitNetworkOutline as AccountTreeIcon
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
interface BusinessProcess {
  id: string
  code: string
  name: string
  description: string | null
  is_active: boolean
  created_at: string
  created_by: string | null
  sale_channel_id: string | null
  sale_currency: string
  purchase_channel_id: string | null
  purchase_currency: string | null
  sale_channel_name?: string | null
  purchase_channel_name?: string | null
}

interface Fee {
  id: string
  code: string
  name: string
  direction: string
  fee_type: string
  amount: number
  currency: string
}

interface AssignedFee {
  fee_id: string
  fee_name: string
  fee_direction: string
  fee_amount: number
  fee_currency: string
}

interface Channel {
  id: string
  name: string
  code: string
  is_active: boolean
}

interface FormData {
  code: string
  name: string
  description: string
  is_active: boolean
  sale_channel_id: string
  sale_currency: string
  purchase_channel_id: string
  purchase_currency: string | null
}

interface ProcessFeeCountItem {
  process_id: string
  fee_count: number
}

interface ProcessFeeMapItem {
  process_id: string
}

// State
const loading = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const modalOpen = ref(false)
const deleteModalOpen = ref(false)
const processes = ref<BusinessProcess[]>([])
const fees = ref<Fee[]>([])
const channels = ref<Channel[]>([])
const assignedFees = ref<AssignedFee[]>([])
const availableFeeOptions = ref<Array<{ label: string; value: string }>>([])
const channelOptions = ref<Array<{ label: string; value: string; type: 'default' }>>([])
const selectedFeeId = ref<string>('')
const editingProcess = ref<BusinessProcess | null>(null)
const deletingProcess = ref<BusinessProcess | null>(null)
const formRef = ref<FormInst | null>(null)
const processFeeCounts = ref<Record<string, number>>({})
const currentFilters = ref<Record<string, any>>({})

// Form data
const formData = ref<FormData>({
  code: '',
  name: '',
  description: '',
  is_active: true,
  sale_channel_id: '',
  sale_currency: 'VND',
  purchase_channel_id: '',
  purchase_currency: 'VND'
})

// Form validation rules
const formRules: FormRules = {
  code: [
    { required: true, message: 'Vui lòng nhập mã quy trình', trigger: 'blur' },
    { min: 2, message: 'Mã quy trình phải có ít nhất 2 ký tự', trigger: 'blur' },
    { pattern: /^[A-Z0-9_]+$/, message: 'Mã quy trình chỉ chứa chữ hoa, số và dấu gạch dưới', trigger: 'blur' }
  ],
  name: [
    { required: true, message: 'Vui lòng nhập tên quy trình', trigger: 'blur' },
    { min: 2, message: 'Tên quy trình phải có ít nhất 2 ký tự', trigger: 'blur' }
  ]
}

// Computed
const filteredProcesses = computed(() => {
  let result = processes.value

  // Apply search query
  if (props.searchQuery) {
    const query = props.searchQuery.toLowerCase()
    result = result.filter(process =>
      process.code.toLowerCase().includes(query) ||
      process.name.toLowerCase().includes(query) ||
      process.description?.toLowerCase().includes(query)
    )
  }

  // Apply FilterPanel filters
  if (currentFilters.value.status) {
    if (Array.isArray(currentFilters.value.status) && currentFilters.value.status.length > 0) {
      result = result.filter(process =>
        currentFilters.value.status.some((status: string) =>
          process.is_active === (status === 'active')
        )
      )
    }
  }

  if (currentFilters.value.dateFrom) {
    result = result.filter(process => {
      const processDate = new Date(process.created_at).getTime()
      return processDate >= currentFilters.value.dateFrom
    })
  }

  if (currentFilters.value.dateTo) {
    result = result.filter(process => {
      const processDate = new Date(process.created_at).getTime()
      return processDate <= currentFilters.value.dateTo
    })
  }

  return result
})

// Table columns
const columns = [
  {
    title: 'Mã quy trình',
    key: 'code',
    render: (row: BusinessProcess) => h('div', { class: 'font-mono font-medium' }, row.code)
  },
  {
    title: 'Tên quy trình',
    key: 'name',
    render: (row: BusinessProcess) => h('div', { class: 'flex items-center gap-2' }, [
      h('div', { class: 'font-medium' }, row.name),
      h(NIcon, { size: 16, class: 'text-gray-500' }, () => h(AccountTreeIcon))
    ])
  },
  {
    title: 'Kênh bán hàng',
    key: 'sale_channel_name',
    render: (row: BusinessProcess) => {
      if (row.sale_channel_name) {
        return h('div', { class: 'space-y-1' }, [
          h('div', { class: 'font-medium text-blue-600' }, row.sale_channel_name),
          h('div', { class: 'text-xs text-gray-500' }, row.sale_currency)
        ])
      }
      return h('div', { class: 'space-y-1' }, [
        h('span', { class: 'text-gray-400' }, 'Chưa chọn'),
        h('div', { class: 'text-xs text-gray-500' }, row.sale_currency)
      ])
    }
  },
  {
    title: 'Kênh mua hàng',
    key: 'purchase_channel_name',
    render: (row: BusinessProcess) => {
      if (row.purchase_channel_name) {
        return h('div', { class: 'space-y-1' }, [
          h('div', { class: 'font-medium text-green-600' }, row.purchase_channel_name),
          h('div', { class: 'text-xs text-gray-500' }, row.purchase_currency || 'N/A')
        ])
      }
      return h('div', { class: 'space-y-1' }, [
        h('span', { class: 'text-gray-400' }, 'Chưa chọn'),
        h('div', { class: 'text-xs text-gray-500' }, row.purchase_currency || 'N/A')
      ])
    }
  },
  {
    title: 'Mô tả',
    key: 'description',
    render: (row: BusinessProcess) => {
      if (!row.description) {
        return h('span', { class: 'text-gray-400' }, 'Chưa có mô tả')
      }
      return h('div', { class: 'max-w-xs' }, row.description)
    }
  },
  {
    title: 'Số phí áp dụng',
    key: 'fee_count',
    render: (row: BusinessProcess) => h(
      NTag,
      { type: 'info', size: 'small' },
      () => `${getProcessFeeCount(row.id)} phí`
    )
  },
  {
    title: 'Trạng thái',
    key: 'is_active',
    render: (row: BusinessProcess) => h(
      NTag,
      {
        type: row.is_active ? 'success' : 'error',
        size: 'small'
      },
      () => row.is_active ? 'Hoạt động' : 'Không hoạt động'
    )
  },
  {
    title: 'Ngày tạo',
    key: 'created_at',
    render: (row: BusinessProcess) => new Date(row.created_at).toLocaleDateString('vi-VN')
  },
  {
    title: 'Thao tác',
    key: 'actions',
    width: 120,
    render: (row: BusinessProcess) => h('div', { class: 'flex gap-2' }, [
      h(
        NButton,
        {
          size: 'small',
          type: 'primary',
          tertiary: true,
          style: { padding: '4px 8px' },
          onClick: () => openEditModal(row)
        },
        () => h(NIcon, { size: 14 }, () => h(EditIcon))
      ),
      h(
        NPopconfirm,
        {
          onPositiveClick: () => confirmDelete(row),
          positiveText: 'Xóa',
          negativeText: 'Hủy',
          positiveButtonProps: { type: 'error', size: 'small' }
        },
        {
          trigger: () => h(
            NButton,
            {
              size: 'small',
              type: 'error',
              tertiary: true,
              style: { padding: '4px 8px' }
            },
            () => h(NIcon, { size: 14 }, () => h(TrashIcon))
          ),
          default: () => 'Bạn có chắc chắn muốn xóa quy trình kinh doanh này?'
        }
      )
    ])
  }
]

// Methods
const getProcessFeeCount = (processId: string) => {
  return processFeeCounts.value[processId] || 0
}

const loadProcessFeeCounts = async () => {
  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_all_process_fee_counts_direct')

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('process_fees_map')
        .select('process_id')

      if (fallbackError) throw fallbackError

      const counts: Record<string, number> = {}
      ;(fallbackData || []).forEach((item: ProcessFeeMapItem) => {
        counts[item.process_id] = (counts[item.process_id] || 0) + 1
      })

      processFeeCounts.value = counts
    } else {
      const counts: Record<string, number> = {}
      ;(data || []).forEach((item: ProcessFeeCountItem) => {
        counts[item.process_id] = item.fee_count
      })

      processFeeCounts.value = counts
    }
  } catch (error) {
    console.error('Error loading process fee counts:', error)
  }
}

const loadProcesses = async () => {
  loading.value = true
  emit('loadingChange', true)

  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_all_business_processes_direct')

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('business_processes')
        .select(`
          *,
          sale_channel:channels!business_processes_sale_channel_id_fkey(
            id,
            name,
            code,
            is_active
          ),
          purchase_channel:channels!business_processes_purchase_channel_id_fkey(
            id,
            name,
            code,
            is_active
          )
        `)
        .order('created_at', { ascending: false })

      if (fallbackError) throw fallbackError

      const processedData = (fallbackData || []).map((process: any) => ({
        ...process,
        sale_channel_name: process.sale_channel?.name,
        purchase_channel_name: process.purchase_channel?.name
      }))

      processes.value = processedData
    } else {
      // Use RPC data with joined channel information
      processes.value = (data || [])
    }

    // Load fee counts for all processes
    await loadProcessFeeCounts()
  } catch (error) {
    console.error('Error loading business processes:', error)
    message.error('Không thể tải danh sách quy trình kinh doanh')
  } finally {
    loading.value = false
    emit('loadingChange', false)
  }
}

const loadChannels = async () => {
  try {
    const { data, error } = await supabase
      .from('channels')
      .select('*')
      .eq('is_active', true)
      .order('name')

    if (error) throw error
    channels.value = data || []

    // Update channel options for selects
    channelOptions.value = [
      { label: 'Chưa chọn kênh', value: '', type: 'default' as const },
      ...channels.value.map(channel => ({
        label: `${channel.name} (${channel.code})`,
        value: channel.id,
        type: 'default' as const
      }))
    ]
  } catch (error) {
    console.error('Error loading channels:', error)
  }
}

const loadFees = async () => {
  try {
    const { data, error } = await supabase
      .from('fees')
      .select('*')
      .eq('is_active', true)
      .order('name')

    if (error) throw error
    fees.value = data || []
    updateAvailableFeeOptions()
  } catch (error) {
    console.error('Error loading fees:', error)
  }
}

const loadProcessFees = async (processId: string) => {
  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_process_fee_mappings_direct', {
      p_process_id: processId
    })

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('process_fees_map')
        .select(`
          fee_id,
          fees!inner(name, direction, amount, currency)
        `)
        .eq('process_id', processId)

      if (fallbackError) throw fallbackError

      assignedFees.value = (fallbackData || []).map((item: any) => ({
        fee_id: item.fee_id,
        fee_name: (item.fees as any)?.name,
        fee_direction: (item.fees as any)?.direction,
        fee_amount: (item.fees as any)?.amount,
        fee_currency: (item.fees as any)?.currency
      }))
    } else {
      assignedFees.value = (data || []).map((item: any) => ({
        fee_id: item.fee_id,
        fee_name: item.fee_name,
        fee_direction: item.fee_direction,
        fee_amount: item.fee_amount,
        fee_currency: item.fee_currency
      }))
    }

    updateAvailableFeeOptions()
  } catch (error) {
    console.error('Error loading process fees:', error)
  }
}

const updateAvailableFeeOptions = () => {
  const assignedFeeIds = new Set(assignedFees.value.map(f => f.fee_id))
  availableFeeOptions.value = fees.value
    .filter(fee => !assignedFeeIds.has(fee.id))
    .map(fee => ({
      label: `${fee.name} (${fee.code}) - ${fee.amount} ${fee.currency}`,
      value: fee.id
    }))
}

const openCreateModal = () => {
  editingProcess.value = null
  formData.value = {
    code: '',
    name: '',
    description: '',
    is_active: true,
    sale_channel_id: '',
    sale_currency: 'VND',
    purchase_channel_id: '',
    purchase_currency: 'VND'
  }
  assignedFees.value = []
  selectedFeeId.value = ''
  updateAvailableFeeOptions()
  modalOpen.value = true
}

const openEditModal = async (process: BusinessProcess) => {
  editingProcess.value = process
  formData.value = {
    code: process.code,
    name: process.name,
    description: process.description || '',
    is_active: process.is_active,
    sale_channel_id: process.sale_channel_id ?? '',
    sale_currency: process.sale_currency,
    purchase_channel_id: process.purchase_channel_id ?? '',
    purchase_currency: process.purchase_currency
  }
  await loadProcessFees(process.id)
  modalOpen.value = true
}

const closeModal = () => {
  modalOpen.value = false
  editingProcess.value = null
  assignedFees.value = []
  selectedFeeId.value = ''
  formRef.value?.restoreValidation()
}


const closeDeleteModal = () => {
  deleteModalOpen.value = false
  deletingProcess.value = null
}

const addAssignedFee = () => {
  if (!selectedFeeId.value) return

  const fee = fees.value.find(f => f.id === selectedFeeId.value)
  if (!fee) return

  assignedFees.value.push({
    fee_id: fee.id,
    fee_name: fee.name,
    fee_direction: fee.direction,
    fee_amount: fee.amount,
    fee_currency: fee.currency
  })

  selectedFeeId.value = ''
  updateAvailableFeeOptions()
}

const removeAssignedFee = (feeId: string) => {
  assignedFees.value = assignedFees.value.filter(f => f.fee_id !== feeId)
  updateAvailableFeeOptions()
}

const handleSubmit = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
    submitting.value = true

    const processData = {
      p_code: formData.value.code.trim().toUpperCase(),
      p_name: formData.value.name.trim(),
      p_description: formData.value.description.trim() || null,
      p_is_active: formData.value.is_active,
      p_sale_channel_id: formData.value.sale_channel_id,
      p_sale_currency: formData.value.sale_currency.trim() || 'VND',
      p_purchase_channel_id: formData.value.purchase_channel_id,
      p_purchase_currency: formData.value.purchase_currency?.trim() || null
    }

    let processId: string | undefined
    let error: any

    if (editingProcess.value) {
      // Use RPC function to update existing process
      const { data, error: updateError } = await supabase.rpc('update_business_process_direct', {
        p_process_id: editingProcess.value.id,
        ...processData
      })
      error = updateError

      if (!error && data) {
        processId = editingProcess.value.id
        if (data && !data.success) {
          message.error(data.message || 'Không thể cập nhật quy trình kinh doanh')
          return
        }
      }
    } else {
      // Use RPC function to create new process
      const { data, error: createError } = await supabase.rpc('create_business_process_direct', processData)
      error = createError

      if (!error && data) {
        if (data && !data.success) {
          message.error(data.message || 'Không thể tạo quy trình kinh doanh')
          return
        }
        // For create, the process_id is returned in the response
        processId = data.process_id
      }
    }

    if (error) throw error

    // Update process fees using RPC functions to bypass RLS
    if (processId) {
      // Delete existing fee mappings using RPC
      const { error: deleteError } = await supabase.rpc('delete_process_fee_mappings_direct', {
        p_process_id: processId
      })

      if (deleteError) {
        console.warn('Delete fee mappings RPC failed, falling back to direct query:', deleteError)
        // Fallback to direct query
        await supabase
          .from('process_fees_map')
          .delete()
          .eq('process_id', processId)
      }

      // Insert new fee mappings using RPC if there are any
      if (assignedFees.value.length > 0) {
        const feeIds = assignedFees.value.map(fee => fee.fee_id)

        const { error: insertError } = await supabase.rpc('insert_process_fee_mappings_direct', {
          p_process_id: processId,
          p_fee_ids: feeIds
        })

        if (insertError) {
          console.warn('Insert fee mappings RPC failed, falling back to direct query:', insertError)
          // Fallback to direct query
          const feeMappings = assignedFees.value.map(fee => ({
            process_id: processId,
            fee_id: fee.fee_id
          }))

          const { error: fallbackError } = await supabase
            .from('process_fees_map')
            .insert(feeMappings)

          if (fallbackError) throw fallbackError
        }
      }
    }

    message.success(editingProcess.value ? 'Cập nhật quy trình kinh doanh thành công' : 'Tạo quy trình kinh doanh thành công')
    closeModal()
    await loadProcesses()
    emit('refreshed', 'businessProcesses')
  } catch (error) {
    console.error('Error saving business process:', error)
    message.error('Không thể lưu quy trình kinh doanh')
  } finally {
    submitting.value = false
  }
}

const confirmDelete = async (process: BusinessProcess) => {
  deleting.value = true

  try {
    // Delete process fee mappings using RPC
    const { error: feeDeleteError } = await supabase.rpc('delete_process_fee_mappings_direct', {
      p_process_id: process.id
    })

    if (feeDeleteError) {
      console.warn('Delete fee mappings RPC failed, falling back to direct query:', feeDeleteError)
      // Fallback to direct query
      await supabase
        .from('process_fees_map')
        .delete()
        .eq('process_id', process.id)
    }

    // Use RPC function to delete the process
    const { data, error } = await supabase.rpc('delete_business_process_direct', {
      p_process_id: process.id
    })

    if (error) throw error

    // Check RPC response
    if (data && !data.success) {
      message.error(data.message || 'Không thể xóa quy trình kinh doanh')
      return
    }

    message.success('Xóa quy trình kinh doanh thành công')
    await loadProcesses()
    emit('refreshed', 'businessProcesses')
  } catch (error) {
    console.error('Error deleting business process:', error)
    message.error('Không thể xóa quy trình kinh doanh')
  } finally {
    deleting.value = false
  }
}

const handleDelete = async () => {
  if (!deletingProcess.value) return
  await confirmDelete(deletingProcess.value)
  closeDeleteModal()
}

const handleFilterChange = (filters: any) => {
  currentFilters.value = filters
}

// Lifecycle
onMounted(() => {
  loadProcesses()
  loadFees()
  loadChannels()
})

// Watch for refresh trigger
watch(() => props.refreshTrigger, () => {
  loadProcesses()
})
</script>

<style scoped>

:deep(.n-data-table) {
  .n-data-table-th {
    font-weight: 600;
  }
}

:deep(.n-form-item-label) {
  font-weight: 500;
}

/* Process code styling */
.process-code {
  font-family: 'Monaco', 'Menlo', monospace;
  font-size: 0.875rem;
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
}

/* Fee assignment styling */
.fee-assignment {
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 12px;
}

.fee-item {
  transition: all 0.2s ease;
}

.fee-item:hover {
  background-color: #f9fafb;
}

/* Form sections styling */
.process-form .form-section {
  margin-bottom: 24px;
  padding: 20px;
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.process-form .form-section:hover {
  border-color: #2080f0;
  box-shadow: 0 2px 8px rgba(32, 128, 240, 0.1);
}

.process-form .section-title {
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

.process-form :deep(.n-form-item-label) {
  font-weight: 500;
  color: #555;
}

.process-form :deep(.n-input) {
  transition: all 0.2s ease;
}

.process-form :deep(.n-input:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.process-form :deep(.n-select) {
  transition: all 0.2s ease;
}

.process-form :deep(.n-select:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.process-form :deep(.n-switch) {
  transition: all 0.2s ease;
}

.process-form :deep(.n-switch:hover) {
  transform: scale(1.02);
}

/* Delete confirmation styling */
.delete-confirmation {
  text-align: center;
  padding: 20px 0;
}

.delete-confirmation .warning-icon {
  margin-bottom: 16px;
}

.delete-confirmation .confirmation-content {
  text-align: left;
}

.delete-confirmation .main-question {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 12px;
  color: #333;
}

.delete-confirmation .warning-text {
  font-size: 14px;
  color: #666;
  margin-bottom: 20px;
  line-height: 1.5;
}

.delete-confirmation .process-details {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 16px;
  margin-top: 16px;
}

.delete-confirmation .detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #e9ecef;
}

.delete-confirmation .detail-item:last-child {
  border-bottom: none;
}

.delete-confirmation .detail-item .label {
  font-weight: 500;
  color: #666;
  font-size: 14px;
}

.delete-confirmation .detail-item .value {
  font-weight: 600;
  color: #333;
  font-size: 14px;
}

/* Button animations */
.business-processes-management :deep(.n-button) {
  transition: all 0.2s ease;
}

.business-processes-management :deep(.n-button:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.business-processes-management :deep(.n-button:active) {
  transform: translateY(0);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

/* Modal animations */
.business-processes-management :deep(.n-modal) {
  backdrop-filter: blur(8px);
}

.business-processes-management :deep(.n-modal .n-card) {
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

/* Tag styling */
.business-processes-management :deep(.n-tag) {
  font-weight: 500;
  border-radius: 6px;
  transition: all 0.2s ease;
}

/* Form sections styling */
.form-section {
  background: #fafafa;
  border-radius: 8px;
  padding: 16px;
  border: 1px solid #f0f0f0;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #2080f0;
  font-weight: 600;
  margin-bottom: 12px;
}

/* Fee list styling */
.fee-item {
  transition: all 0.2s ease;
}

.fee-item:hover {
  background-color: #f5f5f5;
  transform: translateY(-1px);
}

/* Responsive adjustments */
@media (max-width: 1200px) {
  .business-processes-management :deep(.n-modal .n-card) {
    width: 95vw !important;
    max-width: 800px !important;
  }
}

@media (max-width: 768px) {
  .business-processes-management :deep(.n-modal .n-card) {
    width: 98vw !important;
    margin: 1vh auto;
  }

  .process-form :deep(.n-grid) {
    grid-template-columns: 1fr !important;
    gap: 16px !important;
  }
}
</style>