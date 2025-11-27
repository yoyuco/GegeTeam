<!-- path: src/components/admin/FeesManagement.vue -->
<template>
  <div class="fees-management">
    <!-- Header Actions -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-semibold">Quản lý Phí dịch vụ</h2>
        <n-tag type="info" size="small">{{ filteredFees.length }} phí</n-tag>
      </div>
      <div class="flex items-center gap-2">
        <n-button type="primary" @click="openCreateModal">
          <template #icon>
            <n-icon><PlusIcon /></n-icon>
          </template>
          Thêm phí mới
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
        :data="filteredFees"
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
      :style="{ width: '600px' }"
      preset="card"
      :title="editingFee ? 'Chỉnh sửa Phí dịch vụ' : 'Thêm Phí dịch vụ mới'"
      size="large"
    >
      <div class="fee-form">
        <n-form
          ref="formRef"
          :model="formData"
          :rules="formRules"
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

            <n-form-item label="Mã phí" path="code">
              <n-input
                v-model:value="formData.code"
                placeholder="💰 Nhập mã phí (ví dụ: FEE_PLATFORM_10)"
                size="large"
              />
            </n-form-item>

            <n-form-item label="Tên phí" path="name">
              <n-input
                v-model:value="formData.name"
                placeholder="📝 Nhập tên phí dịch vụ"
                size="large"
              />
            </n-form-item>

            <n-form-item label="Mô tả" path="description">
              <n-input
                v-model:value="formData.description"
                type="textarea"
                placeholder="📋 Mô tả chi tiết về loại phí"
                :rows="3"
                size="large"
              />
            </n-form-item>
          </div>

          <!-- Fee Configuration Section -->
          <div class="form-section">
            <div class="section-title">
              <n-icon size="20" color="#2080f0">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 22L12 18.56L5.82 22L7 14.14l-5-4.87l6.91-1.01L12 2z"/></svg>
              </n-icon>
              <span>Cấu hình phí</span>
            </div>

            <n-form-item label="Loại phí" path="direction">
              <n-select
                v-model:value="formData.direction"
                :options="directionOptions"
                placeholder="🔄 Chọn loại phí"
                size="large"
              />
            </n-form-item>

            <n-form-item label="Kiểu tính phí" path="fee_type">
              <n-select
                v-model:value="formData.fee_type"
                :options="feeTypeOptions"
                placeholder="📊 Chọn kiểu tính phí"
                size="large"
              />
            </n-form-item>

            <n-grid :cols="2" :x-gap="16">
              <n-gi>
                <n-form-item :label="formData.fee_type === 'RATE' ? 'Phần trăm (%)' : 'Số tiền'" path="amount">
                  <n-input-number
                    v-model:value="formData.amount"
                    :min="0"
                    :precision="formData.fee_type === 'RATE' ? 4 : 2"
                    :placeholder="formData.fee_type === 'RATE' ? '📊 Ví dụ: 2% nhập 0.02, 5% nhập 0.05' : '💵 Số tiền'"
                    style="width: 100%"
                    size="large"
                  />
                  <template #feedback>
                    <span v-if="formData.fee_type === 'RATE'" style="font-size: 12px; color: #666;">
                      💡 Nhập dạng số thập phân: 2% = 0.02, 5% = 0.05
                    </span>
                  </template>
                </n-form-item>
              </n-gi>
              <n-gi>
                <n-form-item label="Tiền tệ" path="currency">
                  <n-select
                    v-model:value="formData.currency"
                    :options="currencyOptions"
                    placeholder="🌐 Loại tiền tệ"
                    size="large"
                  />
                </n-form-item>
              </n-gi>
            </n-grid>
          </div>

          <!-- Status Section -->
          <div class="form-section">
            <div class="section-title">
              <n-icon size="20" color="#2080f0">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
              </n-icon>
              <span>Trạng thái</span>
            </div>

            <n-form-item label="Trạng thái hoạt động" path="is_active">
              <n-switch
                v-model:value="formData.is_active"
                :checked-value="true"
                :unchecked-value="false"
                size="large"
              >
                <template #checked>
                  <span style="display: flex; align-items: center; gap: 4px;">
                    <n-icon color="#52c41a">
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
            <n-button size="large" @click="closeModal">
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
              :loading="submitting"
              :disabled="!formData.code || !formData.name || !formData.direction || !formData.fee_type"
              @click="handleSubmit"
            >
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19L21 7l-1.41-1.41L9 16.17z"/></svg>
                </n-icon>
              </template>
              {{ editingFee ? 'Cập nhật' : 'Tạo mới' }}
            </n-button>
          </n-space>
        </div>
      </template>
    </n-modal>

    <!-- Delete Confirmation Modal -->
    <n-modal
      v-model:show="deleteModalOpen"
      :mask-closable="false"
      :style="{ width: '450px' }"
      preset="card"
      title="Xác nhận xóa phí dịch vụ"
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
            Bạn có chắc chắn muốn xóa phí dịch vụ <strong>{{ deletingFee?.name }}</strong> không?
          </p>
          <p class="warning-text">
            ⚠️ Hành động này không thể hoàn tác và có thể ảnh hưởng đến các kênh đang sử dụng phí này.
          </p>

          <div v-if="deletingFee" class="fee-details">
            <div class="detail-item">
              <span class="label">Mã phí:</span>
              <span class="value">{{ deletingFee.code }}</span>
            </div>
            <div class="detail-item">
              <span class="label">Loại phí:</span>
              <span class="value">
                <n-tag :type="deletingFee.direction === 'BUY' ? 'success' : deletingFee.direction === 'SELL' ? 'error' : 'info'" size="small">
                  {{ getDirectionDisplayName(deletingFee.direction) }}
                </n-tag>
              </span>
            </div>
            <div class="detail-item">
              <span class="label">Số tiền:</span>
              <span class="value">{{ formatAmountWithFeeType(deletingFee.amount, deletingFee.currency, deletingFee.fee_type) }}</span>
            </div>
            <div class="detail-item">
              <span class="label">Trạng thái:</span>
              <span class="value">
                <n-tag :type="deletingFee.is_active ? 'success' : 'error'" size="small">
                  {{ deletingFee.is_active ? 'Hoạt động' : 'Không hoạt động' }}
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
              Xóa phí
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
  NButton, NTag, NIcon, NPopconfirm, NSwitch, NInputNumber,
  NCard, NDataTable, NForm, NFormItem, NInput, NSelect,
  NModal, NGrid, NGi, NSpace
} from 'naive-ui'
import FilterPanel from './FilterPanel.vue'
import {
  CreateOutline as EditIcon,
  TrashOutline as TrashIcon,
  AddOutline as PlusIcon
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
interface Fee {
  id: string
  code: string
  name: string
  description: string | null
  direction: 'BUY' | 'SELL' | 'WITHDRAW' | 'TAX' | 'OTHER'
  fee_type: 'RATE' | 'FIXED'
  amount: number
  currency: string
  is_active: boolean
  created_at: string
  created_by: string | null
}

interface FormData {
  code: string
  name: string
  description: string | null
  direction: 'BUY' | 'SELL' | 'WITHDRAW' | 'TAX' | 'OTHER'
  fee_type: 'RATE' | 'FIXED'
  amount: number
  currency: string
  is_active: boolean
}

// State
const loading = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const modalOpen = ref(false)
const deleteModalOpen = ref(false)
const fees = ref<Fee[]>([])
const editingFee = ref<Fee | null>(null)
const deletingFee = ref<Fee | null>(null)
const formRef = ref<FormInst | null>(null)
const currentFilters = ref<Record<string, any>>({})

// Form data
const formData = ref<FormData>({
  code: '',
  name: '',
  description: null,
  direction: 'BUY',
  fee_type: 'FIXED',
  amount: 0,
  currency: 'VND',
  is_active: true
})

// Form validation rules
const formRules: FormRules = {
  code: [
    { required: true, message: 'Vui lòng nhập mã phí', trigger: 'blur' },
    { min: 3, message: 'Mã phí phải có ít nhất 3 ký tự', trigger: 'blur' },
    { pattern: /^[A-Z0-9_]+$/, message: 'Mã phí chỉ chứa chữ hoa, số và dấu gạch dưới', trigger: 'blur' }
  ],
  name: [
    { required: true, message: 'Vui lòng nhập tên phí', trigger: 'blur' },
    { min: 2, message: 'Tên phí phải có ít nhất 2 ký tự', trigger: 'blur' }
  ],
  direction: [
    { required: true, message: 'Vui lòng chọn loại phí', trigger: 'change' }
  ],
  fee_type: [
    { required: true, message: 'Vui lòng chọn kiểu tính phí', trigger: 'change' }
  ],
  amount: [
    {
      required: true,
      validator: (rule, value) => {
        if (value === null || value === undefined || value === '') {
          return new Error('Vui lòng nhập số tiền')
        }
        if (typeof value !== 'number' || value < 0) {
          return new Error('Số tiền phải lớn hơn hoặc bằng 0')
        }
        return true
      },
      trigger: 'blur'
    }
  ],
  currency: [
    { required: true, message: 'Vui lòng chọn loại tiền tệ', trigger: 'change' }
  ]
}

// Options
const directionOptions = [
  { label: 'BUY - Phí mua hàng', value: 'BUY' },
  { label: 'SELL - Phí bán hàng', value: 'SELL' },
  { label: 'WITHDRAW - Phí rút tiền', value: 'WITHDRAW' },
  { label: 'TAX - Thuế', value: 'TAX' },
  { label: 'OTHER - Khác', value: 'OTHER' }
]

const feeTypeOptions = [
  { label: 'RATE - Theo phần trăm (%)', value: 'RATE' },
  { label: 'FIXED - Cố định', value: 'FIXED' }
]

const currencyOptions = ref<Array<{label: string, value: string}>>([])

// Computed
const filteredFees = computed(() => {
  let result = fees.value

  // Apply search query
  if (props.searchQuery) {
    const query = props.searchQuery.toLowerCase()
    result = result.filter(fee =>
      fee.code.toLowerCase().includes(query) ||
      fee.name.toLowerCase().includes(query) ||
      fee.direction.toLowerCase().includes(query) ||
      fee.fee_type.toLowerCase().includes(query) ||
      fee.currency.toLowerCase().includes(query)
    )
  }

  // Apply FilterPanel filters
  if (currentFilters.value.status) {
    if (Array.isArray(currentFilters.value.status) && currentFilters.value.status.length > 0) {
      result = result.filter(fee =>
        currentFilters.value.status.some((status: string) =>
          fee.is_active === (status === 'active')
        )
      )
    }
  }

  if (currentFilters.value.dateFrom) {
    result = result.filter(fee => {
      const feeDate = new Date(fee.created_at).getTime()
      return feeDate >= currentFilters.value.dateFrom
    })
  }

  if (currentFilters.value.dateTo) {
    result = result.filter(fee => {
      const feeDate = new Date(fee.created_at).getTime()
      return feeDate <= currentFilters.value.dateTo
    })
  }

  return result
})

// Table columns
const columns = [
  {
    title: 'Mã phí',
    key: 'code',
    render: (row: Fee) => h('div', { class: 'font-mono font-medium' }, row.code)
  },
  {
    title: 'Tên phí',
    key: 'name',
    render: (row: Fee) => h('div', { class: 'font-medium' }, row.name)
  },
  {
    title: 'Loại phí',
    key: 'direction',
    render: (row: Fee) => h(
      NTag,
      {
        type: row.direction === 'BUY' ? 'success' :
              row.direction === 'SELL' ? 'info' :
              row.direction === 'WITHDRAW' ? 'warning' :
              row.direction === 'TAX' ? 'error' : 'default',
        size: 'small'
      },
      () => getDirectionDisplayName(row.direction)
    )
  },
  {
    title: 'Kiểu tính',
    key: 'fee_type',
    render: (row: Fee) => h(
      NTag,
      { type: row.fee_type === 'RATE' ? 'warning' : 'info', size: 'small' },
      () => row.fee_type === 'RATE' ? 'Theo %' : 'Cố định'
    )
  },
  {
    title: 'Số tiền',
    key: 'amount',
    render: (row: Fee) => h('div', { class: 'text-right font-mono' }, [
      h('div', formatAmountWithFeeType(row.amount, row.currency, row.fee_type))
    ])
  },
  {
    title: 'Tiền tệ',
    key: 'currency',
    render: (row: Fee) => h('div', { class: 'font-mono' }, row.currency)
  },
  {
    title: 'Trạng thái',
    key: 'is_active',
    render: (row: Fee) => h(
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
    render: (row: Fee) => new Date(row.created_at).toLocaleDateString('vi-VN')
  },
  {
    title: 'Thao tác',
    key: 'actions',
    width: 120,
    render: (row: Fee) => h('div', { class: 'flex gap-2' }, [
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
          default: () => 'Bạn có chắc chắn muốn xóa phí dịch vụ này?'
        }
      )
    ])
  }
]

// Methods
const getDirectionDisplayName = (direction: string) => {
  const names: Record<string, string> = {
    'BUY': 'BUY - Phí mua hàng',
    'SELL': 'SELL - Phí bán hàng',
    'WITHDRAW': 'WITHDRAW - Phí rút tiền',
    'TAX': 'TAX - Thuế',
    'OTHER': 'OTHER - Khác'
  }
  return names[direction] || direction
}

const formatAmount = (amount: number, currency: string) => {
  if (currency === 'VND') {
    return new Intl.NumberFormat('vi-VN').format(amount)
  }
  return new Intl.NumberFormat('en-US').format(amount)
}

const formatAmountWithFeeType = (amount: number, currency: string, feeType: string) => {
  if (feeType === 'RATE') {
    // Convert 0.02 to 2% for display
    const percentage = amount * 100
    return `${percentage.toFixed(2)}%`
  } else {
    // FIXED fee: only show amount, currency is in separate column
    return formatAmount(amount, currency)
  }
}

const loadCurrencies = async () => {
  try {
    const { data, error } = await supabase
      .from('currencies')
      .select('code, name')
      .eq('is_active', true)
      .order('code')

    if (error) throw error
    currencyOptions.value = (data || []).map((currency: any) => ({
      label: `${currency.code} - ${currency.name}`,
      value: currency.code
    }))
  } catch (error: any) {
    console.error('Error loading currencies:', error)
    message.error('Không thể tải danh sách tiền tệ')
  }
}

const loadFees = async () => {
  loading.value = true
  emit('loadingChange', true)

  try {
    const { data, error } = await supabase
      .from('fees')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      throw error
    }

    fees.value = data || []
  } catch (error) {
    console.error('Error loading fees:', error)
    message.error('Không thể tải danh sách phí dịch vụ')
  } finally {
    loading.value = false
    emit('loadingChange', false)
  }
}

const openCreateModal = () => {
  editingFee.value = null
  formData.value = {
    code: '',
    name: '',
    description: null,
    direction: 'BUY',
    fee_type: 'FIXED',
    amount: 0,
    currency: 'VND',
    is_active: true
  }
  modalOpen.value = true
}

const openEditModal = (fee: Fee) => {
  editingFee.value = fee
  formData.value = {
    code: fee.code,
    name: fee.name,
    description: fee.description,
    direction: fee.direction,
    fee_type: fee.fee_type,
    amount: fee.amount,
    currency: fee.currency,
    is_active: fee.is_active
  }
  modalOpen.value = true
}

const closeModal = () => {
  modalOpen.value = false
  editingFee.value = null
  formRef.value?.restoreValidation()
}

const closeDeleteModal = () => {
  deleteModalOpen.value = false
  deletingFee.value = null
}

const handleSubmit = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
    submitting.value = true

    const feeData = {
      code: formData.value.code.trim().toUpperCase(),
      name: formData.value.name.trim(),
      direction: formData.value.direction,
      fee_type: formData.value.fee_type,
      amount: formData.value.amount || 0,
      currency: formData.value.currency,
      is_active: formData.value.is_active
    }

    let error: any

    if (editingFee.value) {
      // Update existing fee
      const { error: updateError } = await supabase
        .from('fees')
        .update(feeData)
        .eq('id', editingFee.value.id)
      error = updateError
    } else {
      // Create new fee
      const { error: createError } = await supabase
        .from('fees')
        .insert(feeData)
      error = createError
    }

    if (error) throw error

    message.success(editingFee.value ? 'Cập nhật phí dịch vụ thành công' : 'Tạo phí dịch vụ thành công')
    closeModal()
    await loadFees()
    emit('refreshed', 'fees')
  } catch (error) {
    console.error('Error saving fee:', error)
    message.error('Không thể lưu phí dịch vụ')
  } finally {
    submitting.value = false
  }
}

const confirmDelete = async (fee: Fee) => {
  deleting.value = true

  try {
    const { error } = await supabase
      .from('fees')
      .delete()
      .eq('id', fee.id)

    if (error) throw error

    message.success('Xóa phí dịch vụ thành công')
    await loadFees()
    emit('refreshed', 'fees')
  } catch (error) {
    console.error('Error deleting fee:', error)
    message.error('Không thể xóa phí dịch vụ')
  } finally {
    deleting.value = false
  }
}

const handleDelete = async () => {
  if (!deletingFee.value) return
  await confirmDelete(deletingFee.value)
  closeDeleteModal()
}

const handleFilterChange = (filters: any) => {
  currentFilters.value = filters
}

// Lifecycle
onMounted(() => {
  loadFees()
  loadCurrencies()
})

// Watch for refresh trigger
watch(() => props.refreshTrigger, () => {
  loadFees()
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

/* Fee code styling */
.fee-code {
  font-family: 'Monaco', 'Menlo', monospace;
  font-size: 0.875rem;
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
}

/* Amount styling */
.amount-display {
  font-family: 'Monaco', 'Menlo', monospace;
  font-weight: 600;
}

/* Form sections styling */
.fee-form .form-section {
  margin-bottom: 24px;
  padding: 20px;
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.fee-form .form-section:hover {
  border-color: #2080f0;
  box-shadow: 0 2px 8px rgba(32, 128, 240, 0.1);
}

.fee-form .section-title {
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

.fee-form :deep(.n-form-item-label) {
  font-weight: 500;
  color: #555;
}

.fee-form :deep(.n-input) {
  transition: all 0.2s ease;
}

.fee-form :deep(.n-input:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.fee-form :deep(.n-select) {
  transition: all 0.2s ease;
}

.fee-form :deep(.n-select:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.fee-form :deep(.n-input-number) {
  transition: all 0.2s ease;
}

.fee-form :deep(.n-input-number:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.fee-form :deep(.n-switch) {
  transition: all 0.2s ease;
}

.fee-form :deep(.n-switch:hover) {
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

.delete-confirmation .fee-details {
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
.fees-management :deep(.n-button) {
  transition: all 0.2s ease;
}

.fees-management :deep(.n-button:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.fees-management :deep(.n-button:active) {
  transform: translateY(0);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

/* Modal animations */
.fees-management :deep(.n-modal) {
  backdrop-filter: blur(8px);
}

.fees-management :deep(.n-modal .n-card) {
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
.fees-management :deep(.n-tag) {
  font-weight: 500;
  border-radius: 6px;
  transition: all 0.2s ease;
}
</style>