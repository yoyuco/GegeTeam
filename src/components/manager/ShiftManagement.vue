<template>
  <div class="space-y-6">
    <!-- Work Shifts Management -->
    <n-card title="Danh sách Ca làm việc" :bordered="false">
      <template #header-extra>
        <n-button type="primary" @click="openShiftModal()">
          <template #icon>
            <n-icon :component="AddIcon" />
          </template>
          Thêm Ca mới
        </n-button>
      </template>

      <n-data-table
        :columns="shiftColumns"
        :data="shifts"
        :loading="loading"
        :bordered="false"
        :single-line="false"
        :pagination="{ pageSize: 10 }"
      />
    </n-card>

    <!-- Add/Edit Shift Modal -->
    <n-modal v-model:show="shiftModal.open">
      <n-card
        style="width: 500px"
        :title="shiftModal.editingShift ? 'Sửa Ca làm việc' : 'Thêm Ca làm việc mới'"
        :bordered="false"
        size="huge"
      >
        <n-form :model="shiftModal.form" :rules="shiftRules" ref="shiftFormRef">
          <n-form-item label="Tên ca" path="name">
            <n-input v-model:value="shiftModal.form.name" placeholder="ví dụ: Ca Sáng, Ca Chiều, Ca Đêm" />
          </n-form-item>
          <n-form-item label="Thời gian bắt đầu" path="start_time">
            <n-time-picker v-model:value="shiftModal.form.start_time" type="time" format="HH:mm" />
          </n-form-item>
          <n-form-item label="Thời gian kết thúc" path="end_time">
            <n-time-picker v-model:value="shiftModal.form.end_time" type="time" format="HH:mm" />
          </n-form-item>
          <n-form-item label="Mô tả" path="description">
            <n-input
              v-model:value="shiftModal.form.description"
              type="textarea"
              placeholder="Mô tả về ca làm việc này"
              :rows="3"
            />
          </n-form-item>
          <n-form-item>
            <n-switch v-model:value="shiftModal.form.is_active">
              <template #checked>Đang hoạt động</template>
              <template #unchecked>Không hoạt động</template>
            </n-switch>
          </n-form-item>
        </n-form>

        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="shiftModal.open = false">Hủy</n-button>
            <n-button type="primary" :loading="shiftModal.saving" @click="saveShift">
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
  NInput,
  NTimePicker,
  NSwitch,
  NTag,
  createDiscreteApi,
} from 'naive-ui'
import { Add as AddIcon, CreateOutline as EditIcon, Trash as TrashIcon } from '@vicons/ionicons5'

const { message } = createDiscreteApi(['message'])

// Types
type WorkShift = {
  id: string
  name: string
  start_time: string
  end_time: string
  description: string | null
  is_active: boolean
  created_at: string
  updated_at: string
}

// State
const loading = ref(false)
const shifts = ref<WorkShift[]>([])
const shiftFormRef = ref()

const shiftModal = reactive({
  open: false,
  saving: false,
  editingShift: null as WorkShift | null,
  form: {
    name: '',
    start_time: '',
    end_time: '',
    description: '',
    is_active: true,
  },
})

// Form validation rules
const shiftRules = {
  name: [
    { required: true, message: 'Vui lòng nhập tên ca làm việc', trigger: 'blur' },
    { min: 2, message: 'Tên ca phải có ít nhất 2 ký tự', trigger: 'blur' },
  ],
  start_time: [
    { required: true, message: 'Vui lòng chọn thời gian bắt đầu', trigger: 'change' },
  ],
  end_time: [
    { required: true, message: 'Vui lòng chọn thời gian kết thúc', trigger: 'change' },
  ],
}

// DataTable columns
const shiftColumns: DataTableColumns<WorkShift> = [
  {
    title: 'Tên ca',
    key: 'name',
    sorter: 'default',
    width: 150,
  },
  {
    title: 'Thời gian',
    key: 'time_range',
    render: (row) => `${row.start_time} - ${row.end_time}`,
    width: 180,
  },
  {
    title: 'Mô tả',
    key: 'description',
    ellipsis: true,
    render: (row) => row.description || '-',
  },
  {
    title: 'Trạng thái',
    key: 'is_active',
    width: 120,
    render: (row) => {
      return row.is_active
        ? h('span', { class: 'text-green-600' }, 'Đang hoạt động')
        : h('span', { class: 'text-red-600' }, 'Không hoạt động')
    },
  },
  {
    title: 'Hành động',
    key: 'actions',
    align: 'right',
    width: 120,
    render: (row) =>
      h('div', { class: 'flex gap-2' }, [
        h(
          NButton,
          {
            size: 'small',
            onClick: () => openShiftModal(row),
          },
          { default: () => 'Sửa' }
        ),
        h(
          NButton,
          {
            size: 'small',
            type: 'error',
            onClick: () => deleteShift(row.id),
          },
          { default: () => 'Xóa' }
        ),
      ]),
  },
]

// Methods
async function loadShifts() {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('work_shifts')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error
    shifts.value = data || []
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách ca làm việc')
  } finally {
    loading.value = false
  }
}

function openShiftModal(shift: WorkShift | null = null) {
  shiftModal.editingShift = shift
  if (shift) {
    // Edit mode - convert time strings to proper format for time picker
    shiftModal.form = {
      name: shift.name,
      start_time: shift.start_time.substring(0, 5), // Convert "07:00:00" to "07:00"
      end_time: shift.end_time.substring(0, 5), // Convert "15:00:00" to "15:00"
      description: shift.description || '',
      is_active: shift.is_active,
    }
  } else {
    // Add mode
    shiftModal.form = {
      name: '',
      start_time: '',
      end_time: '',
      description: '',
      is_active: true,
    }
  }
  shiftModal.open = true
}

async function saveShift() {
  try {
    await shiftFormRef.value?.validate()
  } catch {
    return
  }

  shiftModal.saving = true
  try {
    const formData = { ...shiftModal.form }

    // Convert time format from "HH:mm" to "HH:mm:ss" for database
    const startTime = formData.start_time ? formData.start_time + ':00' : formData.start_time
    const endTime = formData.end_time ? formData.end_time + ':00' : formData.end_time

    if (shiftModal.editingShift) {
      // Update existing shift
      const { error } = await supabase
        .from('work_shifts')
        .update({
          name: formData.name,
          start_time: startTime,
          end_time: endTime,
          description: formData.description || null,
          is_active: formData.is_active,
        })
        .eq('id', shiftModal.editingShift.id)

      if (error) throw error
      message.success('Cập nhật ca làm việc thành công!')
    } else {
      // Create new shift
      const { error } = await supabase.from('work_shifts').insert({
        name: formData.name,
        start_time: startTime,
        end_time: endTime,
        description: formData.description || null,
        is_active: formData.is_active,
      })

      if (error) throw error
      message.success('Thêm ca làm việc mới thành công!')
    }

    shiftModal.open = false
    await loadShifts()
  } catch (error: any) {
    message.error(error.message || 'Không thể lưu ca làm việc')
  } finally {
    shiftModal.saving = false
  }
}

async function deleteShift(shiftId: string) {
  if (!confirm('Bạn có chắc chắn muốn xóa ca làm việc này?')) return

  try {
    const { error } = await supabase.from('work_shifts').delete().eq('id', shiftId)
    if (error) throw error
    message.success('Xóa ca làm việc thành công!')
    await loadShifts()
  } catch (error: any) {
    message.error(error.message || 'Không thể xóa ca làm việc')
  }
}

// Lifecycle
onMounted(() => {
  loadShifts()
})
</script>