<!-- path: src/components/admin/GameAccountsManagement.vue -->
<template>
  <div class="game-accounts-management">
    <!-- Header Actions -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-semibold">Quản lý Tài khoản Game</h2>
        <n-tag type="info" size="small">{{ filteredGameAccounts.length }} tài khoản</n-tag>
      </div>
      <div class="flex items-center gap-2">
        <n-button type="primary" @click="openCreateModal">
          <template #icon>
            <n-icon><PlusIcon /></n-icon>
          </template>
          Thêm tài khoản mới
        </n-button>
      </div>
    </div>

    <!-- Filter Panel -->
    <FilterPanel
      :show-game-filter="true"
      :show-server-filter="true"
      :show-status-filter="true"
      :show-purpose-filter="true"
      :show-account-type-filter="true"
      :game-codes="['POE_1', 'POE_2', 'DIABLO_4']"
      @filter-change="handleFilterChange"
    />

    <!-- Data Table -->
    <n-card>
      <n-data-table
        :columns="columns"
        :data="filteredGameAccounts"
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
      :title="editingGameAccount ? 'Chỉnh sửa Tài khoản Game' : 'Thêm Tài khoản Game mới'"
      size="large"
    >
      <div class="game-account-form">
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

            <n-form-item label="Tên tài khoản" path="account_name">
              <n-input
                v-model:value="formData.account_name"
                placeholder="🎮 Nhập tên tài khoản game"
                size="large"
              />
            </n-form-item>

            <n-grid :cols="2" :x-gap="16">
              <n-gi>
                <n-form-item label="Game" path="game_code">
                  <n-select
                    v-model:value="formData.game_code"
                    :options="gameOptions"
                    placeholder="🎯 Chọn game"
                    filterable
                    clearable
                    size="large"
                    :loading="gameOptions.length === 0"
                  />
                </n-form-item>
              </n-gi>

              <n-gi>
                <n-form-item label="Mục đích" path="purpose">
                  <n-select
                    v-model:value="formData.purpose"
                    :options="purposeOptions"
                    placeholder="📋 Chọn mục đích sử dụng"
                    size="large"
                  />
                </n-form-item>
              </n-gi>
            </n-grid>
          </div>

          <!-- Server Configuration Section -->
          <div class="form-section">
            <div class="section-title">
              <n-icon size="20" color="#2080f0">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 22L12 18.56L5.82 22L7 14.14l-5-4.87l6.91-1.01L12 2z"/></svg>
              </n-icon>
              <span>Cấu hình Server</span>
            </div>

            <n-form-item label="Server" path="server_attribute_code">
              <n-select
                v-model:value="formData.server_attribute_code"
                :options="serverOptions"
                :placeholder="formData.game_code ? '🖥️ Chọn server (để trống = global account)' : '🚫 Vui lòng chọn game trước'"
                filterable
                clearable
                :disabled="!formData.game_code"
                size="large"
                :loading="!!formData.game_code && serverOptions.length === 0"
              />
              <div v-if="formData.game_code" class="text-xs text-gray-500 mt-1">
                💡 <strong>Global Account:</strong> Để trống server field để tạo tài khoản dùng cho tất cả servers của {{ getGameDisplayName(formData.game_code) }}
              </div>
            </n-form-item>
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
              :disabled="!formData.account_name || !formData.game_code || !formData.purpose"
              @click="handleSubmit"
            >
              <template #icon>
                <n-icon>
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19L21 7l-1.41-1.41L9 16.17z"/></svg>
                </n-icon>
              </template>
              {{ editingGameAccount ? 'Cập nhật' : 'Tạo mới' }}
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
  NDataTable, NInput, NFormItem, NSelect, NModal,
  NCard, NForm, NGrid, NGi, NSpace
} from 'naive-ui'
import {
  CreateOutline as EditIcon,
  TrashOutline as TrashIcon,
  AddOutline as PlusIcon,
  EyeOutline as EyeIcon
} from '@vicons/ionicons5'
import { supabase } from '@/lib/supabase'
import type { FormInst, FormRules } from 'naive-ui'
import FilterPanel from './FilterPanel.vue'

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
interface GameAccount {
  id: string
  game_code: string
  account_name: string
  purpose: 'FARM' | 'INVENTORY' | 'TRADE'
  is_active: boolean
  server_attribute_code: string | null
  created_at: string
  updated_at: string
}

interface FormData {
  account_name: string
  game_code: string
  purpose: 'FARM' | 'INVENTORY' | 'TRADE'
  server_attribute_code: string | null
  is_active: boolean
}

// State
const loading = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const modalOpen = ref(false)
const gameAccounts = ref<GameAccount[]>([])
const allGameAccounts = ref<GameAccount[]>([])
const editingGameAccount = ref<GameAccount | null>(null)
const formRef = ref<FormInst | null>(null)
const gameOptions = ref<Array<{ label: string; value: string }>>([])
const serverOptions = ref<Array<{ label: string; value: string }>>([])

// Filter state
const currentFilters = ref<any>({})

// Form data
const formData = ref<FormData>({
  account_name: '',
  game_code: '',
  purpose: 'INVENTORY',
  server_attribute_code: null,
  is_active: true
})

// Form validation rules
const formRules: FormRules = {
  account_name: [
    { required: true, message: 'Vui lòng nhập tên tài khoản', trigger: 'blur' },
    { min: 2, message: 'Tên tài khoản phải có ít nhất 2 ký tự', trigger: 'blur' }
  ],
  game_code: [
    { required: true, message: 'Vui lòng chọn game', trigger: 'change' }
  ],
  purpose: [
    { required: true, message: 'Vui lòng chọn mục đích sử dụng', trigger: 'change' }
  ]
}

// Options for purpose dropdown
const purposeOptions = [
  { label: 'FARM - Đào tạo', value: 'FARM' },
  { label: 'INVENTORY - Tồn kho', value: 'INVENTORY' },
  { label: 'TRADE - Giao dịch', value: 'TRADE' }
]

// Server name cache for all servers
const allServersCache = ref<Record<string, string>>({})

// Helper function to get server display name
const getServerDisplayName = (serverCode: string | null): string => {
  if (!serverCode) return 'Chưa có'

  // First try to find in current game-specific server options
  const serverOption = serverOptions.value.find(option => option.value === serverCode)
  if (serverOption) {
    return serverOption.label
  }

  // Then try to find in all servers cache
  if (allServersCache.value[serverCode]) {
    return allServersCache.value[serverCode]
  }

  // Fallback to code if not found
  return serverCode
}

// Function to load all servers into cache
const loadAllServersCache = async () => {
  try {
    const { data, error } = await supabase
      .from('attributes')
      .select('code, name')
      .eq('type', 'GAME_SERVER')
      .eq('is_active', true)
      .order('sort_order', { ascending: true })

    if (error) throw error

    // Create cache map
    const cache: Record<string, string> = {}
    ;(data || []).forEach(attr => {
      cache[attr.code] = attr.name
    })

    allServersCache.value = cache
  } catch (error) {
    console.error('Error loading all servers cache:', error)
  }
}

// Computed
const filteredGameAccounts = computed(() => {
  let filtered = [...allGameAccounts.value]

  // Search query filter
  if (props.searchQuery) {
    const query = props.searchQuery.toLowerCase()
    filtered = filtered.filter(account =>
      account.account_name.toLowerCase().includes(query) ||
      account.game_code.toLowerCase().includes(query) ||
      account.purpose.toLowerCase().includes(query) ||
      account.server_attribute_code?.toLowerCase().includes(query)
    )
  }

  // Game filter (handle both single string and array)
  if (currentFilters.value.game) {
    if (Array.isArray(currentFilters.value.game)) {
      if (currentFilters.value.game.length > 0) {
        filtered = filtered.filter(account =>
          currentFilters.value.game.includes(account.game_code)
        )
      }
    } else {
      filtered = filtered.filter(account =>
        account.game_code === currentFilters.value.game
      )
    }
  }

  // Server filter (handle both single string and array)
  if (currentFilters.value.server) {
    if (Array.isArray(currentFilters.value.server)) {
      if (currentFilters.value.server.length > 0) {
        filtered = filtered.filter(account =>
          currentFilters.value.server.includes(account.server_attribute_code)
        )
      }
    } else {
      filtered = filtered.filter(account =>
        account.server_attribute_code === currentFilters.value.server
      )
    }
  }

  // Status filter (handle both single string and array)
  if (currentFilters.value.status) {
    if (Array.isArray(currentFilters.value.status)) {
      if (currentFilters.value.status.length > 0) {
        filtered = filtered.filter(account => {
          const accountStatus = account.is_active ? 'active' : 'inactive'
          return currentFilters.value.status.includes(accountStatus)
        })
      }
    } else {
      const isActive = currentFilters.value.status === 'active'
      filtered = filtered.filter(account =>
        account.is_active === isActive
      )
    }
  }

  // Purpose filter (handle both single string and array)
  if (currentFilters.value.purpose) {
    if (Array.isArray(currentFilters.value.purpose)) {
      if (currentFilters.value.purpose.length > 0) {
        filtered = filtered.filter(account =>
          currentFilters.value.purpose.includes(account.purpose)
        )
      }
    } else {
      filtered = filtered.filter(account =>
        account.purpose === currentFilters.value.purpose
      )
    }
  }

  // Account type filter (handle both single string and array)
  if (currentFilters.value.accountType) {
    if (Array.isArray(currentFilters.value.accountType)) {
      if (currentFilters.value.accountType.length > 0) {
        filtered = filtered.filter(account => {
          const accountType = account.server_attribute_code ? 'league' : 'global'
          return currentFilters.value.accountType.includes(accountType)
        })
      }
    } else {
      const hasServer = currentFilters.value.accountType === 'league'
      filtered = filtered.filter(account => {
        if (hasServer) {
          return account.server_attribute_code && account.server_attribute_code !== null
        } else {
          return !account.server_attribute_code || account.server_attribute_code === null
        }
      })
    }
  }

  return filtered
})

// Filter functions
const handleFilterChange = (filters: any) => {
  currentFilters.value = filters
}

// Table columns
const columns = [
  {
    title: 'Tên tài khoản',
    key: 'account_name',
    render: (row: GameAccount) => h('div', { class: 'font-medium' }, row.account_name)
  },
  {
    title: 'Game',
    key: 'game_code',
    render: (row: GameAccount) => h(
      NTag,
      { type: 'info', size: 'small' },
      () => getGameDisplayName(row.game_code)
    )
  },
  {
    title: 'Mục đích',
    key: 'purpose',
    render: (row: GameAccount) => h(
      NTag,
      {
        type: row.purpose === 'FARM' ? 'warning' :
              row.purpose === 'INVENTORY' ? 'success' : 'info',
        size: 'small'
      },
      () => getPurposeDisplayName(row.purpose)
    )
  },
  {
    title: 'Server',
    key: 'server_attribute_code',
    render: (row: GameAccount) => {
      return h('span', { class: 'text-sm' }, getServerDisplayName(row.server_attribute_code))
    }
  },
  {
    title: 'Trạng thái',
    key: 'is_active',
    render: (row: GameAccount) => h(
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
    render: (row: GameAccount) => new Date(row.created_at).toLocaleDateString('vi-VN')
  },
  {
    title: 'Thao tác',
    key: 'actions',
    width: 120,
    render: (row: GameAccount) => h('div', { class: 'flex gap-2' }, [
      h(
        NButton,
        {
          size: 'small',
          type: 'info',
          ghost: true,
          onClick: () => viewAccountDetails(row)
        },
        () => h(NIcon, { size: 14 }, () => h(EyeIcon))
      ),
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
          default: () => 'Bạn có chắc chắn muốn xóa tài khoản game này?'
        }
      )
    ])
  }
]

// Methods
const getGameDisplayName = (gameCode: string) => {
  const gameNames: Record<string, string> = {
    'POE_1': 'Path of Exile 1',
    'POE_2': 'Path of Exile 2',
    'DIABLO_4': 'Diablo 4'
  }
  return gameNames[gameCode] || gameCode
}

const getPurposeDisplayName = (purpose: string) => {
  const purposeNames: Record<string, string> = {
    'FARM': 'FARM - Đào tạo',
    'INVENTORY': 'INVENTORY - Tồn kho',
    'TRADE': 'TRADE - Giao dịch'
  }
  return purposeNames[purpose] || purpose
}

const loadGameAccounts = async () => {
  loading.value = true
  emit('loadingChange', true)

  try {
    // Try RPC function first to bypass RLS issues
    const { data, error } = await supabase.rpc('get_all_game_accounts_direct')

    if (error) {
      // Fallback to direct query
      console.warn('RPC failed, falling back to direct query:', error)
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('game_accounts')
        .select('*')
        .order('created_at', { ascending: false })

      if (fallbackError) throw fallbackError
      allGameAccounts.value = fallbackData || []
      gameAccounts.value = fallbackData || []
    } else {
      allGameAccounts.value = data || []
      gameAccounts.value = data || []
    }
  } catch (error) {
    console.error('Error loading game accounts:', error)
    message.error('Không thể tải danh sách tài khoản game')
  } finally {
    loading.value = false
    emit('loadingChange', false)
  }
}

const loadGameOptions = async () => {
  try {
    const { data, error } = await supabase
      .from('attributes')
      .select('code, name')
      .eq('type', 'GAME')
      .eq('is_active', true)
      .order('sort_order', { ascending: true })

    if (error) throw error
    gameOptions.value = (data || []).map(attr => ({
      label: `${attr.name} (${attr.code})`,
      value: attr.code
    }))
  } catch (error) {
    console.error('Error loading game options:', error)
  }
}

const loadServerOptions = async (gameCode?: string) => {
  try {
    if (!gameCode) {
      // If no game specified, clear server options
      serverOptions.value = []
      return
    }

    // First get the game attribute ID
    const { data: gameData, error: gameError } = await supabase
      .from('attributes')
      .select('id')
      .eq('code', gameCode)
      .eq('type', 'GAME')
      .single()

    if (gameError || !gameData) {
      console.error('❌ Game not found:', gameError)
      serverOptions.value = []
      return
    }

    // Then load GAME_SERVER type servers linked to this game via attribute_relationships
    const { data: relationshipData, error: relationshipError } = await supabase
      .from('attribute_relationships')
      .select('child_attribute_id')
      .eq('parent_attribute_id', gameData.id)

    if (relationshipError) {
      console.error('❌ Error loading attribute relationships:', relationshipError)
      serverOptions.value = []
      return
    }

    // Get the server attribute IDs
    const serverIds = relationshipData?.map(rel => rel.child_attribute_id) || []

    if (serverIds.length === 0) {
      serverOptions.value = []
      return
    }

    // Now load the actual server attributes
    const { data, error } = await supabase
      .from('attributes')
      .select('code, name')
      .in('id', serverIds)
      .eq('type', 'GAME_SERVER')
      .eq('is_active', true)
      .order('sort_order', { ascending: true })

    if (error) throw error

    serverOptions.value = (data || []).map(attr => ({
      label: attr.name,
      value: attr.code
    }))
  } catch (error) {
    console.error('Error loading server options:', error)
    message.error('Không thể tải danh sách server')
    serverOptions.value = []
  }
}

const openCreateModal = () => {
  editingGameAccount.value = null
  formData.value = {
    account_name: '',
    game_code: '',
    purpose: 'INVENTORY',
    server_attribute_code: null,
    is_active: true
  }
  modalOpen.value = true
}

const openEditModal = (account: GameAccount) => {
  editingGameAccount.value = account
  formData.value = {
    account_name: account.account_name,
    game_code: account.game_code,
    purpose: account.purpose,
    server_attribute_code: account.server_attribute_code,
    is_active: account.is_active
  }
  // Load servers for the selected game
  loadServerOptions(account.game_code)
  modalOpen.value = true
}

const viewAccountDetails = (account: GameAccount) => {
  message.info(`Xem chi tiết tài khoản: ${account.account_name}`)
  // TODO: Implement detailed view modal
}

const closeModal = () => {
  modalOpen.value = false
  editingGameAccount.value = null
  // Reset form validation using a safe approach
  try {
    formRef.value?.restoreValidation()
  } catch (error) {
    // If restoreValidation doesn't exist or fails, just ignore
    console.debug('Form validation reset skipped:', error)
  }
}


const handleSubmit = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
    submitting.value = true

    const accountData = {
      account_name: formData.value.account_name.trim(),
      game_code: formData.value.game_code,
      purpose: formData.value.purpose,
      server_attribute_code: formData.value.server_attribute_code,
      is_active: formData.value.is_active
    }

    let error: any

    if (editingGameAccount.value) {
      // Use RPC function to bypass RLS
      const { error: updateError } = await supabase.rpc('update_game_account_direct', {
        p_account_id: editingGameAccount.value.id,
        p_game_code: accountData.game_code,
        p_account_name: accountData.account_name,
        p_purpose: accountData.purpose,
        p_server_attribute_code: accountData.server_attribute_code,
        p_is_active: accountData.is_active
      })
      error = updateError
    } else {
      // Use RPC function to bypass RLS
      const { error: createError } = await supabase.rpc('create_game_account_direct', {
        p_game_code: accountData.game_code,
        p_account_name: accountData.account_name,
        p_purpose: accountData.purpose,
        p_server_attribute_code: accountData.server_attribute_code,
        p_is_active: accountData.is_active
      })
      error = createError
    }

    if (error) throw error

    message.success(editingGameAccount.value ? 'Cập nhật tài khoản game thành công' : 'Tạo tài khoản game thành công')
    closeModal()
    await loadGameAccounts()
    emit('refreshed', 'gameAccounts')
  } catch (error) {
    console.error('Error saving game account:', error)
    message.error('Không thể lưu tài khoản game')
  } finally {
    submitting.value = false
  }
}

const confirmDelete = async (account: GameAccount) => {
  deleting.value = true

  try {
    // Since currency_inventory is now a view, we only need to check inventory_pools
    const { data: poolData, error: poolError } = await supabase
      .from('inventory_pools')
      .select('quantity')
      .eq('game_account_id', account.id)
      .limit(1)

    if (!poolError && poolData && poolData.length > 0) {
      const hasPoolInventory = poolData.some(item =>
        parseFloat(item.quantity || 0) > 0
      )

      if (hasPoolInventory) {
        message.warning('Không thể xóa tài khoản game vì vẫn còn tồn kho trong inventory pools. Vui lòng xóa hết tồn kho trước.')
        return
      }
    }

    // Use RPC function to bypass RLS
    const { data, error } = await supabase.rpc('delete_game_account_direct', {
      p_account_id: account.id
    })

    if (error) {
      console.error('Delete failed:', error)
      message.error(`Không thể xóa tài khoản: ${error.message}`)
      return
    }

    // Check RPC response
    if (data && !data.success) {
      message.error(data.message || 'Không thể xóa tài khoản game')
      return
    }

    message.success('Xóa tài khoản game thành công')
    await loadGameAccounts()
    emit('refreshed', 'gameAccounts')
  } catch (error) {
    console.error('Error deleting game account:', error)
    if (error instanceof Error) {
      message.error(error.message)
    } else {
      message.error('Không thể xóa tài khoản game. Vui lòng thử lại hoặc liên hệ admin.')
    }
  } finally {
    deleting.value = false
  }
}


// Lifecycle
onMounted(() => {
  loadGameAccounts()
  loadGameOptions()
  loadAllServersCache() // Load all servers into cache for table display
  // loadServerOptions() removed - will be loaded when game is selected
})

// Watch for refresh trigger
watch(() => props.refreshTrigger, () => {
  loadGameAccounts()
})

// Watch for game changes to load corresponding servers
watch(() => formData.value.game_code, (newGameCode) => {
  // Clear server selection when game changes
  formData.value.server_attribute_code = null
  // Load servers for the selected game
  loadServerOptions(newGameCode)
})
</script>

<style scoped>

/* Form Styling */
.game-account-form {
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

/* Account name styling */
.account-name {
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

  .account-details {
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

:deep(.n-base-selection-placeholder) {
  color: #9ca3af;
  font-style: italic;
}
</style>