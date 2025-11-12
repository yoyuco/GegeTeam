<!-- path: src/components/admin/ShiftsManagement.vue -->
<template>
  <div class="shifts-management">
    <!-- Header Actions -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-semibold">Quản lý Ca làm việc</h2>
        <n-tag type="info" size="small">{{ filteredShifts.length }} ca</n-tag>
      </div>
      <div class="flex items-center gap-2">
        <n-button type="primary" @click="openCreateModal">
          <template #icon>
            <n-icon><PlusIcon /></n-icon>
          </template>
          Thêm ca mới
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
        :data="filteredShifts"
        :loading="loading"
        :pagination="{ pageSize: 15 }"
        :bordered="false"
        :single-line="false"
        :row-key="(row) => row.id"
        striped
      />
    </n-card>

    <!-- Create/Edit Modal -->
    <n-modal
      v-model:show="modalOpen"
      :mask-closable="false"
      :style="{ width: '600px' }"
      preset="card"
      :title="editingShift ? 'Chỉnh sửa Ca làm việc' : 'Thêm Ca làm việc mới'"
      size="large"
    >
      <div class="shift-form">
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

            <n-form-item label="Tên ca" path="name">
              <n-input
                v-model:value="formData.name"
                placeholder="⏰ Nhập tên ca làm việc (ví dụ: Ca Sáng, Ca Tối)"
                size="large"
              />
            </n-form-item>

            <n-form-item label="Mô tả" path="description">
              <n-input
                v-model:value="formData.description"
                type="textarea"
                placeholder="📝 Mô tả chi tiết về ca làm việc"
                :rows="3"
                size="large"
              />
            </n-form-item>
          </div>

          <!-- Working Hours Section -->
          <div class="form-section">
            <div class="section-title">
              <n-icon size="20" color="#2080f0">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 22L12 18.56L5.82 22L7 14.14l-5-4.87l6.91-1.01L12 2z"/></svg>
              </n-icon>
              <span>Thời gian làm việc</span>
            </div>

            <n-grid :cols="2" :x-gap="16">
              <n-gi>
                <n-form-item label="Thời gian bắt đầu" path="start_time">
                  <n-time-picker
                    v-model:value="formData.start_time"
                    format="HH:mm"
                    placeholder="🌅 Chọn thời gian bắt đầu"
                    style="width: 100%"
                    size="large"
                  />
                </n-form-item>
              </n-gi>

              <n-gi>
                <n-form-item label="Thời gian kết thúc" path="end_time">
                  <n-time-picker
                    v-model:value="formData.end_time"
                    format="HH:mm"
                    placeholder="🌙 Chọn thời gian kết thúc"
                    style="width: 100%"
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
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
              </n-icon>
              <span>Trạng thái</span>
            </div>

            <n-form-item>
              <template #label>
                <div style="display: flex; align-items: center; gap: 8px;">
                  <span>Trạng thái hoạt động</span>
                  <n-tag :type="formData.is_active ? 'success' : 'default'" size="small">
                    {{ formData.is_active ? 'Hoạt động' : 'Không hoạt động' }}
                  </n-tag>
                </div>
              </template>
              <n-switch
                v-model:value="formData.is_active"
                :checked-value="true"
                :unchecked-value="false"
                size="large"
              >
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
              :disabled="!formData.name || !formData.start_time || !formData.end_time"
              @click="handleSubmit"
            >
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19L21 7l-1.41-1.41L9 16.17z"/></svg>
                </n-icon>
              </template>
              {{ editingShift ? 'Cập nhật' : 'Tạo mới' }}
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
      title="Xác nhận xóa ca làm việc"
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
            Bạn có chắc chắn muốn xóa ca làm việc <strong>{{ deletingShift?.name }}</strong> không?
          </p>
          <p class="warning-text">
            ⚠️ Hành động này không thể hoàn tác và có thể ảnh hưởng đến các phân công đã tồn tại.
          </p>

          <div v-if="deletingShift" class="shift-details">
            <div class="detail-item">
              <span class="label">Thời gian:</span>
              <span class="value">{{ deletingShift.start_time }} - {{ deletingShift.end_time }}</span>
            </div>
            <div class="detail-item">
              <span class="label">Trạng thái:</span>
              <span class="value">
                <n-tag :type="deletingShift.is_active ? 'success' : 'error'" size="small">
                  {{ deletingShift.is_active ? 'Hoạt động' : 'Không hoạt động' }}
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
              Xóa ca làm việc
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
  NButton, NTag, NIcon, NPopconfirm, NSwitch,
  NDataTable, NCard, NInput, NFormItem, NForm, NModal, NTimePicker,
  NGrid, NGi, NSpace
} from 'naive-ui'
import FilterPanel from './FilterPanel.vue'
import {
  Create as EditIcon,
  Trash as TrashIcon,
  Add as PlusIcon
} from '@vicons/ionicons5'
import { supabase } from '@/lib/supabase'
import { getShiftDurationDescription } from '@/utils/shiftUtils'
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

// State
const currentFilters = ref<Record<string, any>>({})

// Types
interface WorkShift {
  id: string
  name: string
  start_time: string
  end_time: string
  description: string | null
  is_active: boolean
  created_at: string
  updated_at: string
}

interface FormData {
  name: string
  start_time: number | null
  end_time: number | null
  description: string
  is_active: boolean
}

// State
const loading = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const modalOpen = ref(false)
const deleteModalOpen = ref(false)
const shifts = ref<WorkShift[]>([])
const editingShift = ref<WorkShift | null>(null)
const deletingShift = ref<WorkShift | null>(null)
const formRef = ref<FormInst | null>(null)

// Form data
const formData = ref<FormData>({
  name: '',
  start_time: null,
  end_time: null,
  description: '',
  is_active: true
})

// Form validation rules
const formRules: FormRules = {
  name: [
    { required: true, message: 'Vui lòng nhập tên ca làm việc', trigger: 'blur' },
    { min: 2, message: 'Tên ca phải có ít nhất 2 ký tự', trigger: 'blur' }
  ],
  start_time: [
    { required: true, message: 'Vui lòng chọn thời gian bắt đầu', trigger: 'change' }
  ],
  end_time: [
    { required: true, message: 'Vui lòng chọn thời gian kết thúc', trigger: 'change' }
  ]
}

// Computed
const filteredShifts = computed(() => {
  let result = shifts.value

  // Apply search query
  if (props.searchQuery) {
    const query = props.searchQuery.toLowerCase()
    result = result.filter(shift =>
      shift.name.toLowerCase().includes(query) ||
      shift.description?.toLowerCase().includes(query) ||
      formatTime(shift.start_time).includes(query) ||
      formatTime(shift.end_time).includes(query)
    )
  }

  // Apply filters
  if (currentFilters.value.status) {
    if (Array.isArray(currentFilters.value.status) && currentFilters.value.status.length > 0) {
      result = result.filter(shift =>
        currentFilters.value.status.some((status: string) =>
          shift.is_active === (status === 'active')
        )
      )
    }
  }


  if (currentFilters.value.dateFrom) {
    result = result.filter(shift => {
      const shiftDate = new Date(shift.created_at).getTime()
      return shiftDate >= currentFilters.value.dateFrom
    })
  }

  if (currentFilters.value.dateTo) {
    result = result.filter(shift => {
      const shiftDate = new Date(shift.created_at).getTime()
      return shiftDate <= currentFilters.value.dateTo
    })
  }

  return result
})

// Table columns
const columns = [
  {
    title: 'Tên ca',
    key: 'name',
    render: (row: WorkShift) => h('div', { class: 'font-medium' }, row.name)
  },
  {
    title: 'Thời gian',
    key: 'time_range',
    render: (row: WorkShift) => h('div', { class: 'text-sm' }, [
      h('div', `${formatTime(row.start_time)} - ${formatTime(row.end_time)}`),
      h('div', { class: 'text-gray-500' }, calculateDuration(row.start_time, row.end_time))
    ])
  },
  {
    title: 'Mô tả',
    key: 'description',
    render: (row: WorkShift) => row.description || h('span', { class: 'text-gray-400' }, 'Chưa có mô tả')
  },
  {
    title: 'Trạng thái',
    key: 'is_active',
    render: (row: WorkShift) => h(
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
    render: (row: WorkShift) => new Date(row.created_at).toLocaleDateString('vi-VN')
  },
  {
    title: 'Thao tác',
    key: 'actions',
    width: 120,
    render: (row: WorkShift) => h('div', { class: 'flex gap-2' }, [
      h(
        NButton,
        {
          size: 'small',
          type: 'primary',
          ghost: true,
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
            { size: 'small', type: 'error', ghost: true },
            () => h(NIcon, { size: 14 }, () => h(TrashIcon))
          ),
          default: () => 'Bạn có chắc chắn muốn xóa ca làm việc này?'
        }
      )
    ])
  }
]

// Methods
const formatTime = (time: string) => {
  return time.substring(0, 5) // Extract HH:mm from HH:mm:ss
}

const calculateDuration = (startTime: string, endTime: string) => {
  return getShiftDurationDescription(startTime, endTime)
}

const loadShifts = async () => {
  loading.value = true
  emit('loadingChange', true)

  try {
    const { data, error } = await supabase
      .from('work_shifts')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error
    shifts.value = data || []
  } catch (error) {
    console.error('Error loading shifts:', error)
    message.error('Không thể tải danh sách ca làm việc')
  } finally {
    loading.value = false
    emit('loadingChange', false)
  }
}

const openCreateModal = () => {
  editingShift.value = null
  formData.value = {
    name: '',
    start_time: null,
    end_time: null,
    description: '',
    is_active: true
  }
  modalOpen.value = true
}

const openEditModal = (shift: WorkShift) => {
  editingShift.value = shift

  // Convert time strings to milliseconds for n-time-picker
  const [startHours, startMinutes] = shift.start_time.split(':').map(Number)
  const [endHours, endMinutes] = shift.end_time.split(':').map(Number)

  formData.value = {
    name: shift.name,
    start_time: (startHours * 60 + startMinutes) * 60 * 1000,
    end_time: (endHours * 60 + endMinutes) * 60 * 1000,
    description: shift.description || '',
    is_active: shift.is_active
  }
  modalOpen.value = true
}

const closeModal = () => {
  modalOpen.value = false
  editingShift.value = null
  formRef.value?.restoreValidation()
}

const openDeleteModal = (shift: WorkShift) => {
  deletingShift.value = shift
  deleteModalOpen.value = true
}

const closeDeleteModal = () => {
  deleteModalOpen.value = false
  deletingShift.value = null
}

const handleSubmit = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
    submitting.value = true

    // Convert milliseconds back to time strings
    const startTime = formData.value.start_time
      ? new Date(formData.value.start_time).toTimeString().substring(0, 8)
      : ''
    const endTime = formData.value.end_time
      ? new Date(formData.value.end_time).toTimeString().substring(0, 8)
      : ''

    const shiftData = {
      name: formData.value.name.trim(),
      start_time: startTime,
      end_time: endTime,
      description: formData.value.description.trim() || null,
      is_active: formData.value.is_active
    }

    let error: any

    if (editingShift.value) {
      // Update existing shift
      const { error: updateError } = await supabase
        .from('work_shifts')
        .update(shiftData)
        .eq('id', editingShift.value.id)
      error = updateError
    } else {
      // Create new shift
      const { error: createError } = await supabase
        .from('work_shifts')
        .insert(shiftData)
      error = createError
    }

    if (error) throw error

    message.success(editingShift.value ? 'Cập nhật ca làm việc thành công' : 'Tạo ca làm việc thành công')
    closeModal()
    await loadShifts()
    emit('refreshed', 'shifts')
  } catch (error) {
    console.error('Error saving shift:', error)
    message.error('Không thể lưu ca làm việc')
  } finally {
    submitting.value = false
  }
}

const confirmDelete = async (shift: WorkShift) => {
  deleting.value = true

  try {
    const { error } = await supabase
      .from('work_shifts')
      .delete()
      .eq('id', shift.id)

    if (error) throw error

    message.success('Xóa ca làm việc thành công')
    await loadShifts()
    emit('refreshed', 'shifts')
  } catch (error) {
    console.error('Error deleting shift:', error)
    message.error('Không thể xóa ca làm việc')
  } finally {
    deleting.value = false
  }
}

const handleDelete = async () => {
  if (!deletingShift.value) return
  await confirmDelete(deletingShift.value)
  closeDeleteModal()
}

const handleFilterChange = (filters: any) => {
  currentFilters.value = filters
}

// Lifecycle
onMounted(() => {
  loadShifts()
})

// Watch for refresh trigger
watch(() => props.refreshTrigger, () => {
  loadShifts()
})
</script>

<style scoped>

/* Form Styling */
.shift-form {
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

.form-section :deep(.n-input .n-input__input-el) {
  border-radius: 8px;
  transition: all 0.2s ease;
}

.form-section :deep(.n-input .n-input__input-el:focus) {
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
}

.form-section :deep(.n-time-picker) {
  border-radius: 8px;
  transition: all 0.2s ease;
}

.form-section :deep(.n-time-picker:hover) {
  border-color: #60a5fa;
}

.form-section :deep(.n-time-picker.n-time-picker--focus) {
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

/* Delete Confirmation Modal Styling */
.delete-confirmation {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 20px 0;
}

.warning-icon {
  margin-bottom: 16px;
}

.confirmation-content {
  width: 100%;
}

.main-question {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 12px;
  line-height: 1.5;
}

.warning-text {
  font-size: 14px;
  color: #d97706;
  background-color: #fef3c7;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #f59e0b;
  margin-bottom: 20px;
  line-height: 1.4;
}

.shift-details {
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 16px;
  margin-top: 16px;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #f3f4f6;
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-item .label {
  font-weight: 500;
  color: #6b7280;
  font-size: 14px;
}

.detail-item .value {
  font-weight: 600;
  color: #1f2937;
  font-size: 14px;
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

/* Data Table styling */
:deep(.n-data-table) {
  .n-data-table-th {
    font-weight: 600;
    background-color: #f8fafc;
  }
}

:deep(.n-data-table .n-data-table-td) {
  border-bottom: 1px solid #f1f5f9;
}

/* Time display styling */
.time-display {
  font-family: 'Monaco', 'Menlo', 'Courier New', monospace;
  font-size: 0.875rem;
  background: #f1f5f9;
  padding: 2px 6px;
  border-radius: 4px;
  border: 1px solid #e2e8f0;
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

  .delete-confirmation {
    padding: 16px 0;
  }

  .shift-details {
    padding: 12px;
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
:deep(.n-input__placeholder) {
  color: #9ca3af;
  font-style: italic;
}

:deep(.n-time-picker .n-base-selection-placeholder) {
  color: #9ca3af;
  font-style: italic;
}
</style>