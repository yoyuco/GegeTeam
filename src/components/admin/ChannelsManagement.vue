<!-- path: src/components/admin/ChannelsManagement.vue -->
<template>
  <div class="channels-management">
    <!-- Header Actions -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-semibold">Quản lý Kênh giao dịch</h2>
        <n-tag type="info" size="small">{{ filteredChannels.length }} kênh</n-tag>
      </div>
      <div class="flex items-center gap-2">
        <n-button type="primary" @click="openCreateModal">
          <template #icon>
            <n-icon><PlusIcon /></n-icon>
          </template>
          Thêm kênh mới
        </n-button>
      </div>
    </div>

    <!-- Filter Panel -->
    <FilterPanel
      :show-status-filter="true"
      :show-channel-filter="true"
      @filter-change="handleFilterChange"
    />

    <!-- Data Table -->
    <n-card>
      <n-data-table
        :columns="columns"
        :data="filteredChannels"
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
      :title="editingChannel ? 'Chỉnh sửa Kênh giao dịch' : 'Thêm Kênh giao dịch mới'"
      size="large"
    >
      <div class="channel-form">
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

            <n-form-item label="Mã kênh" path="code">
              <n-input
                v-model:value="formData.code"
                placeholder="🏷️ Nhập mã kênh (ví dụ: FACEBOOK_MAIN)"
                :disabled="!!editingChannel && !auth.hasPermission('admin')"
                size="large"
              />
            </n-form-item>

            <n-form-item label="Tên kênh" path="name">
              <n-input
                v-model:value="formData.name"
                placeholder="📡 Nhập tên kênh giao dịch"
                size="large"
              />
            </n-form-item>

            <n-form-item label="Mô tả" path="description">
              <n-input
                v-model:value="formData.description"
                type="textarea"
                placeholder="📝 Mô tả chi tiết về kênh giao dịch"
                :rows="3"
                size="large"
              />
            </n-form-item>
          </div>

          <!-- Channel Configuration Section -->
          <div class="form-section">
            <div class="section-title">
              <n-icon size="20" color="#2080f0">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 22L12 18.56L5.82 22L7 14.14l-5-4.87l6.91-1.01L12 2z"/></svg>
              </n-icon>
              <span>Cấu hình kênh</span>
            </div>

            <n-form-item label="Website URL" path="website_url">
              <n-input
                v-model:value="formData.website_url"
                placeholder="🌐 https://example.com"
                size="large"
              />
            </n-form-item>

            <n-form-item label="Loại kênh" path="direction">
              <n-select
                v-model:value="formData.direction"
                :options="directionOptions"
                placeholder="🔄 Chọn loại kênh"
                size="large"
              />
            </n-form-item>
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
              :disabled="!formData.code || !formData.name || !formData.direction"
              @click="handleSubmit"
            >
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19L21 7l-1.41-1.41L9 16.17z"/></svg>
                </n-icon>
              </template>
              {{ editingChannel ? 'Cập nhật' : 'Tạo mới' }}
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
      title="Xác nhận xóa kênh giao dịch"
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
            Bạn có chắc chắn muốn xóa kênh giao dịch <strong>{{ deletingChannel?.name }}</strong> không?
          </p>
          <p class="warning-text">
            ⚠️ Hành động này không thể hoàn tác và có thể ảnh hưởng đến các giao dịch hiện có.
          </p>

          <div v-if="deletingChannel" class="channel-details">
            <div class="detail-item">
              <span class="label">Mã kênh:</span>
              <span class="value">{{ deletingChannel.code }}</span>
            </div>
            <div class="detail-item">
              <span class="label">Loại kênh:</span>
              <span class="value">
                <n-tag :type="deletingChannel.direction === 'BUY' ? 'success' : deletingChannel.direction === 'SELL' ? 'error' : 'info'" size="small">
                  {{ getDirectionDisplayName(deletingChannel.direction) }}
                </n-tag>
              </span>
            </div>
            <div class="detail-item">
              <span class="label">Trạng thái:</span>
              <span class="value">
                <n-tag :type="deletingChannel.is_active ? 'success' : 'error'" size="small">
                  {{ deletingChannel.is_active ? 'Hoạt động' : 'Không hoạt động' }}
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
              Xóa kênh
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
  NDataTable, NCard, NInput, NFormItem,
  NSelect, NForm, NModal, NSpace
} from 'naive-ui'
import FilterPanel from './FilterPanel.vue'
import {
  CreateOutline as EditIcon,
  TrashOutline as TrashIcon,
  AddOutline as PlusIcon,
  LinkOutline as ExternalLinkIcon
} from '@vicons/ionicons5'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/auth'
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
const auth = useAuth()

// Types
interface Channel {
  id: string
  code: string
  name: string
  description: string | null
  website_url: string | null
  direction: 'BUY' | 'SELL' | 'BOTH'
  is_active: boolean
  created_at: string
  updated_at: string
  created_by: string | null
  updated_by: string | null
}


interface FormData {
  code: string
  name: string
  description: string
  website_url: string
  direction: 'BUY' | 'SELL' | 'BOTH'
  is_active: boolean
}

// State
const loading = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const modalOpen = ref(false)
const deleteModalOpen = ref(false)
const channels = ref<Channel[]>([])
const editingChannel = ref<Channel | null>(null)
const deletingChannel = ref<Channel | null>(null)
const formRef = ref<FormInst | null>(null)
const currentFilters = ref<Record<string, any>>({})

// Form data
const formData = ref<FormData>({
  code: '',
  name: '',
  description: '',
  website_url: '',
  direction: 'BOTH',
  is_active: true
})

// Form validation rules
const formRules: FormRules = {
  code: [
    { required: true, message: 'Vui lòng nhập mã kênh', trigger: 'blur' },
    { min: 2, message: 'Mã kênh phải có ít nhất 2 ký tự', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9_]+$/, message: 'Mã kênh chỉ chứa chữ (hoa/thường), số và dấu gạch dưới', trigger: 'blur' }
  ],
  name: [
    { required: true, message: 'Vui lòng nhập tên kênh', trigger: 'blur' },
    { min: 2, message: 'Tên kênh phải có ít nhất 2 ký tự', trigger: 'blur' }
  ],
  direction: [
    { required: true, message: 'Vui lòng chọn loại kênh', trigger: 'change' }
  ],
  website_url: [
    { type: 'url', message: 'URL không hợp lệ', trigger: 'blur' }
  ]
}

// Options
const directionOptions = [
  { label: 'BUY - Chỉ mua', value: 'BUY' },
  { label: 'SELL - Chỉ bán', value: 'SELL' },
  { label: 'BOTH - Mua và bán', value: 'BOTH' }
]


// Computed
const filteredChannels = computed(() => {
  let result = channels.value

  // Apply search query
  if (props.searchQuery) {
    const query = props.searchQuery.toLowerCase()
    result = result.filter(channel =>
      channel.code.toLowerCase().includes(query) ||
      channel.name.toLowerCase().includes(query) ||
      channel.description?.toLowerCase().includes(query) ||
      channel.direction.toLowerCase().includes(query) ||
      channel.website_url?.toLowerCase().includes(query)
    )
  }

  // Apply FilterPanel filters
  if (currentFilters.value.status) {
    if (Array.isArray(currentFilters.value.status) && currentFilters.value.status.length > 0) {
      result = result.filter(channel =>
        currentFilters.value.status.some((status: string) =>
          channel.is_active === (status === 'active')
        )
      )
    }
  }

  if (currentFilters.value.channel) {
    if (Array.isArray(currentFilters.value.channel) && currentFilters.value.channel.length > 0) {
      result = result.filter(channel =>
        currentFilters.value.channel.some((channelId: string) =>
          channel.id === channelId
        )
      )
    }
  }

  return result
})

// Table columns
const columns = [
  {
    title: 'Mã kênh',
    key: 'code',
    render: (row: Channel) => h('div', { class: 'font-mono font-medium' }, row.code)
  },
  {
    title: 'Tên kênh',
    key: 'name',
    render: (row: Channel) => h('div', { class: 'font-medium' }, row.name)
  },
  {
    title: 'Mô tả',
    key: 'description',
    render: (row: Channel) => row.description || h('span', { class: 'text-gray-400' }, 'Chưa có mô tả')
  },
  {
    title: 'Loại kênh',
    key: 'direction',
    render: (row: Channel) => h(
      NTag,
      {
        type: row.direction === 'BUY' ? 'success' :
              row.direction === 'SELL' ? 'error' : 'info',
        size: 'small'
      },
      () => getDirectionDisplayName(row.direction)
    )
  },
  {
    title: 'Website',
    key: 'website_url',
    render: (row: Channel) => {
      if (!row.website_url) {
        return h('span', { class: 'text-gray-400' }, 'Chưa có')
      }
      return h(
        'a',
        {
          href: row.website_url,
          target: '_blank',
          rel: 'noopener noreferrer',
          class: 'text-blue-600 hover:text-blue-800 flex items-center gap-1'
        },
        [
          h('span', { class: 'truncate max-w-xs' }, row.website_url),
          h(NIcon, { size: 14 }, () => h(ExternalLinkIcon))
        ]
      )
    }
  },
  {
    title: 'Trạng thái',
    key: 'is_active',
    render: (row: Channel) => h(
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
    render: (row: Channel) => new Date(row.created_at).toLocaleDateString('vi-VN')
  },
  {
    title: 'Thao tác',
    key: 'actions',
    width: 120,
    render: (row: Channel) => h('div', { class: 'flex gap-2' }, [
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
          default: () => 'Bạn có chắc chắn muốn xóa kênh giao dịch này?'
        }
      )
    ])
  }
]

// Methods
const getDirectionDisplayName = (direction: string) => {
  const names: Record<string, string> = {
    'BUY': 'BUY - Chỉ mua',
    'SELL': 'SELL - Chỉ bán',
    'BOTH': 'BOTH - Mua và bán'
  }
  return names[direction] || direction
}

const loadChannels = async () => {
  loading.value = true
  emit('loadingChange', true)

  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_all_channels_direct')

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('channels')
        .select('*')
        .order('created_at', { ascending: false })

      if (fallbackError) throw fallbackError
      channels.value = fallbackData || []
    } else {
      channels.value = data || []
    }
  } catch (error) {
    console.error('Error loading channels:', error)
    message.error('Không thể tải danh sách kênh giao dịch')
  } finally {
    loading.value = false
    emit('loadingChange', false)
  }
}

const openCreateModal = () => {
  editingChannel.value = null
  formData.value = {
    code: '',
    name: '',
    description: '',
    website_url: '',
    direction: 'BOTH',
    is_active: true
  }
  modalOpen.value = true
}

const openEditModal = (channel: Channel) => {
  editingChannel.value = channel
  formData.value = {
    code: channel.code,
    name: channel.name,
    description: channel.description || '',
    website_url: channel.website_url || '',
    direction: channel.direction,
    is_active: channel.is_active
  }
  modalOpen.value = true
}

const closeModal = () => {
  modalOpen.value = false
  editingChannel.value = null
  formRef.value?.restoreValidation()
}

const openDeleteModal = (channel: Channel) => {
  deletingChannel.value = channel
  deleteModalOpen.value = true
}

const closeDeleteModal = () => {
  deleteModalOpen.value = false
  deletingChannel.value = null
}

// Get current user's profile ID using existing Supabase function
const get_current_profile_id = async (): Promise<string | null> => {
  try {
    const { data, error } = await supabase.rpc('get_current_profile_id')

    if (error) {
      console.error('Error getting user profile ID:', error)
      return null
    }

    return data || null
  } catch (error) {
    console.error('Error getting user profile ID:', error)
    return null
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
    submitting.value = true

    // Get current user's profile ID
    const profileId = await get_current_profile_id()

    const channelData = {
      code: formData.value.code.trim(),
      name: formData.value.name.trim(),
      description: formData.value.description.trim() || null,
      website_url: formData.value.website_url.trim() || null,
      direction: formData.value.direction,
      is_active: formData.value.is_active
    }

    let error: any

    if (editingChannel.value) {
      // Use RPC function to bypass RLS
      const { error: updateError } = await supabase.rpc('update_channel_direct', {
        p_channel_id: editingChannel.value.id,
        p_code: channelData.code,
        p_name: channelData.name,
        p_description: channelData.description,
        p_website_url: channelData.website_url,
        p_direction: channelData.direction,
        p_is_active: channelData.is_active,
        p_updated_by: profileId
      })
      error = updateError
    } else {
      // Use RPC function to bypass RLS
      const { error: createError } = await supabase.rpc('create_channel_direct', {
        p_code: channelData.code,
        p_name: channelData.name,
        p_description: channelData.description,
        p_website_url: channelData.website_url,
        p_direction: channelData.direction,
        p_is_active: channelData.is_active,
        p_created_by: profileId
      })
      error = createError
    }

    if (error) throw error

    message.success(editingChannel.value ? 'Cập nhật kênh giao dịch thành công' : 'Tạo kênh giao dịch thành công')
    closeModal()
    await loadChannels()
    emit('refreshed', 'channels')
  } catch (error) {
    console.error('Error saving channel:', error)
    message.error('Không thể lưu kênh giao dịch')
  } finally {
    submitting.value = false
  }
}

const confirmDelete = async (channel: Channel) => {
  deleting.value = true

  try {
    // Use RPC function to bypass RLS
    const { error } = await supabase.rpc('delete_channel_direct', {
      p_channel_id: channel.id
    })

    if (error) throw error

    message.success('Xóa kênh giao dịch thành công')
    await loadChannels()
    emit('refreshed', 'channels')
  } catch (error) {
    console.error('Error deleting channel:', error)
    message.error('Không thể xóa kênh giao dịch')
  } finally {
    deleting.value = false
  }
}

const handleDelete = async () => {
  if (!deletingChannel.value) return
  await confirmDelete(deletingChannel.value)
  closeDeleteModal()
}

const handleFilterChange = (filters: any) => {
  currentFilters.value = filters
}

// Lifecycle
onMounted(() => {
  loadChannels()
})

// Watch for refresh trigger
watch(() => props.refreshTrigger, () => {
  loadChannels()
})
</script>

<style scoped>
.channels-management > * {
  margin-bottom: 1rem;
}

.channels-management > *:last-child {
  margin-bottom: 0;
}

/* Form sections styling */
.form-section {
  margin-bottom: 24px;
  padding: 20px;
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.form-section:hover {
  border-color: #2080f0;
  box-shadow: 0 2px 8px rgba(32, 128, 240, 0.1);
}

.section-title {
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

.channel-form :deep(.n-form-item-label) {
  font-weight: 500;
  color: #555;
}

.channel-form :deep(.n-input) {
  transition: all 0.2s ease;
}

.channel-form :deep(.n-input:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.channel-form :deep(.n-select) {
  transition: all 0.2s ease;
}

.channel-form :deep(.n-select:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.channel-form :deep(.n-switch) {
  transition: all 0.2s ease;
}

.channel-form :deep(.n-switch:hover) {
  transform: scale(1.02);
}

/* Delete confirmation styling */
.delete-confirmation {
  text-align: center;
  padding: 20px 0;
}

.warning-icon {
  margin-bottom: 16px;
}

.confirmation-content {
  text-align: left;
}

.main-question {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 12px;
  color: #333;
}

.warning-text {
  font-size: 14px;
  color: #666;
  margin-bottom: 20px;
  line-height: 1.5;
}

.channel-details {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 16px;
  margin-top: 16px;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #e9ecef;
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-item .label {
  font-weight: 500;
  color: #666;
  font-size: 14px;
}

.detail-item .value {
  font-weight: 600;
  color: #333;
  font-size: 14px;
}

/* Button animations */
.channels-management :deep(.n-button) {
  transition: all 0.2s ease;
}

.channels-management :deep(.n-button:hover) {
  transform: translateY(-1px);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.channels-management :deep(.n-button:active) {
  transform: translateY(0);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

/* Enhanced action buttons styling */
.channels-management :deep(.n-button[data-type="primary"]) {
  position: relative;
  overflow: hidden;
}

.channels-management :deep(.n-button[data-type="primary"]:hover) {
  background: linear-gradient(135deg, #4096ff 0%, #1677ff 100%);
  border-color: #1677ff;
}

.channels-management :deep(.n-button[data-type="error"]:hover) {
  background: linear-gradient(135deg, #f56565 0%, #e53e3e 100%);
  border-color: #e53e3e;
}

/* Modal animations */
.channels-management :deep(.n-modal) {
  backdrop-filter: blur(8px);
}

.channels-management :deep(.n-modal .n-card) {
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

/* Data table styling */
.channels-management :deep(.n-data-table) {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.channels-management :deep(.n-data-table .n-data-table-th) {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #374151;
}

.channels-management :deep(.n-data-table .n-data-table-tr:hover) {
  background-color: #f0f9ff;
}

/* Tag styling improvements */
.channels-management :deep(.n-tag) {
  font-weight: 500;
  border-radius: 6px;
  transition: all 0.2s ease;
}

.channels-management :deep(.n-tag:hover) {
  transform: scale(1.05);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Channel code styling */
.font-mono {
  font-family: 'Monaco', 'Menlo', 'Courier New', monospace;
  font-size: 0.875rem;
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
  transition: all 0.2s ease;
}

.font-mono:hover {
  background: #e9ecef;
  transform: scale(1.05);
}

/* Website link styling */
.channels-management :deep(.n-data-table a) {
  color: #2563eb;
  text-decoration: none;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 4px;
}

.channels-management :deep(.n-data-table a:hover) {
  color: #1d4ed8;
  text-decoration: underline;
  transform: translateX(2px);
}

.truncate {
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* Switch styling improvements */
.channels-management :deep(.n-switch) {
  font-weight: 500;
}


/* Form validation styling */
.channels-management :deep(.n-form-item-feedback) {
  font-size: 12px;
  margin-top: 4px;
}

/* Responsive design */
@media (max-width: 768px) {
  .form-section {
    padding: 16px;
    margin-bottom: 16px;
  }

  .section-title {
    font-size: 14px;
  }

  .channel-details {
    padding: 12px;
  }

  .detail-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }

  .truncate {
    max-width: 120px;
  }
}

/* Loading states */
.channels-management :deep(.n-button[loading]) {
  position: relative;
}

.channels-management :deep(.n-button[loading]::before) {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  animation: loadingShimmer 1.5s infinite;
}

@keyframes loadingShimmer {
  0% { left: -100%; }
  100% { left: 100%; }
}

/* Hover effects for table rows */
.channels-management :deep(.n-data-table .n-data-table-td) {
  transition: all 0.2s ease;
}

.channels-management :deep(.n-data-table .n-data-table-tr:hover .n-data-table-td) {
  background-color: #f0f9ff;
}

/* Empty state styling */
.channels-management .empty-state {
  text-align: center;
  padding: 40px;
  color: #909399;
}

.channels-management .empty-state n-icon {
  margin-bottom: 12px;
}
</style>