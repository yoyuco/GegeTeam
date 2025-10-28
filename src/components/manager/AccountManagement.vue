<template>
  <div class="space-y-6">
    <!-- Game Accounts Management -->
    <n-card title="Danh sách Tài khoản Game" :bordered="false">
      <template #header-extra>
        <div class="flex gap-2">
          <n-select
            v-model:value="filterGame"
            :options="gameOptions"
            placeholder="Lọc theo Game"
            clearable
            style="width: 150px"
            @update:value="loadAccounts"
          />
          <n-button type="primary" @click="openAccountModal()">
            <template #icon>
              <n-icon :component="AddIcon" />
            </template>
            Thêm Account
          </n-button>
        </div>
      </template>

      <n-data-table
        :columns="accountColumns"
        :data="filteredAccounts"
        :loading="loading"
        :bordered="false"
        :single-line="false"
        :pagination="{ pageSize: 15 }"
      />
    </n-card>

    <!-- Add/Edit Account Modal -->
    <n-modal v-model:show="accountModal.open">
      <n-card
        style="width: 600px"
        :title="accountModal.editingAccount ? 'Sửa Tài khoản Game' : 'Thêm Tài khoản Game mới'"
        :bordered="false"
        size="huge"
      >
        <n-form :model="accountModal.form" :rules="accountRules" ref="accountFormRef">
          <n-form-item label="Game" path="game_code">
            <n-select
              v-model:value="accountModal.form.game_code"
              :options="gameCodeOptions"
              placeholder="Chọn game"
            />
          </n-form-item>
          <n-form-item label="Tên tài khoản" path="account_name">
            <n-input v-model:value="accountModal.form.account_name" placeholder="Tên đăng nhập game" />
          </n-form-item>
          <n-form-item label="Mục đích" path="purpose">
            <n-select
              v-model:value="accountModal.form.purpose"
              :options="purposeOptions"
              placeholder="Chọn mục đích sử dụng"
            />
          </n-form-item>
          <n-form-item>
            <n-switch v-model:value="accountModal.form.is_active">
              <template #checked>Đang hoạt động</template>
              <template #unchecked>Không hoạt động</template>
            </n-switch>
          </n-form-item>
        </n-form>

        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="accountModal.open = false">Hủy</n-button>
            <n-button type="primary" :loading="accountModal.saving" @click="saveAccount">
              Lưu
            </n-button>
          </div>
        </template>
      </n-card>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, computed, h } from 'vue'
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
  NSelect,
  NSwitch,
  NTag,
  createDiscreteApi,
} from 'naive-ui'
import { Add as AddIcon, CreateOutline as EditIcon, Trash as TrashIcon } from '@vicons/ionicons5'

const { message } = createDiscreteApi(['message'])

// Types
type GameAccount = {
  id: string
  game_code: string
  account_name: string
  purpose: 'FARM' | 'INVENTORY' | 'TRADE'
  is_active: boolean
  created_at: string
  updated_at: string
}

// State
const loading = ref(false)
const accounts = ref<GameAccount[]>([])
const filterGame = ref<string>('')
const accountFormRef = ref()

// Options
const gameOptions = ref<{ label: string; value: string }[]>([])
const gameCodeOptions = ref<{ label: string; value: string }[]>([])
const purposeOptions = [
  { label: 'Farm (Làm ruộng)', value: 'FARM' },
  { label: 'Inventory (Kho bãi)', value: 'INVENTORY' },
  { label: 'Trade (Giao dịch)', value: 'TRADE' },
]

const accountModal = reactive({
  open: false,
  saving: false,
  editingAccount: null as GameAccount | null,
  form: {
    game_code: '',
    account_name: '',
    purpose: 'INVENTORY' as 'FARM' | 'INVENTORY' | 'TRADE',
    is_active: true,
  },
})

// Form validation rules
const accountRules = {
  game_code: [
    { required: true, message: 'Vui lòng chọn game', trigger: 'change' },
  ],
  account_name: [
    { required: true, message: 'Vui lòng nhập tên tài khoản', trigger: 'blur' },
    { min: 2, message: 'Tên tài khoản phải có ít nhất 2 ký tự', trigger: 'blur' },
  ],
  purpose: [
    { required: true, message: 'Vui lòng chọn mục đích', trigger: 'change' },
  ],
}

// Computed
const filteredAccounts = computed(() => {
  if (!filterGame.value) return accounts.value
  return accounts.value.filter(account => account.game_code === filterGame.value)
})

// DataTable columns
const accountColumns: DataTableColumns<GameAccount> = [
  {
    title: 'Game',
    key: 'game_code',
    width: 120,
    render: (row) => {
      const gameInfo = gameCodeOptions.value.find(g => g.value === row.game_code)
      return gameInfo?.label || row.game_code
    },
  },
  {
    title: 'Tên tài khoản',
    key: 'account_name',
    width: 200,
  },
  {
    title: 'Mục đích',
    key: 'purpose',
    width: 120,
    render: (row) => {
      const purpose = purposeOptions.find(p => p.value === row.purpose)
      return purpose?.label || row.purpose
    },
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
    title: 'Ngày tạo',
    key: 'created_at',
    width: 150,
    render: (row) => new Date(row.created_at).toLocaleDateString('vi-VN'),
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
            onClick: () => openAccountModal(row),
          },
          { default: () => 'Sửa' }
        ),
        h(
          NButton,
          {
            size: 'small',
            type: 'error',
            onClick: () => deleteAccount(row.id),
          },
          { default: () => 'Xóa' }
        ),
      ]),
  },
]

// Methods
async function loadOptions() {
  try {
    // Load game codes
    const { data: gameData } = await supabase
      .from('attributes')
      .select('code, name')
      .eq('type', 'GAME')
      .eq('is_active', true)
      .order('sort_order')

    gameCodeOptions.value = (gameData || []).map(g => ({
      label: g.name,
      value: g.code,
    }))

    gameOptions.value = [...gameCodeOptions.value]
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách game/server')
  }
}


async function loadAccounts() {
  loading.value = true
  try {
    let query = supabase
      .from('game_accounts')
      .select('*')
      .order('created_at', { ascending: false })

    if (filterGame.value) {
      query = query.eq('game_code', filterGame.value)
    }

    const { data, error } = await query

    if (error) throw error
    accounts.value = data || []
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách tài khoản game')
  } finally {
    loading.value = false
  }
}

async function openAccountModal(account: GameAccount | null = null) {
  accountModal.editingAccount = account
  if (account) {
    // Edit mode
    accountModal.form = {
      game_code: account.game_code,
      account_name: account.account_name,
      purpose: account.purpose,
      is_active: account.is_active,
    }
  } else {
    // Add mode
    accountModal.form = {
      game_code: '',
      account_name: '',
      purpose: 'INVENTORY',
      is_active: true,
    }
  }
  accountModal.open = true
}


async function saveAccount() {
  try {
    await accountFormRef.value?.validate()
  } catch {
    return
  }

  accountModal.saving = true
  try {
    const formData = { ...accountModal.form }

    if (accountModal.editingAccount) {
      // Update existing account
      const { error } = await supabase
        .from('game_accounts')
        .update({
          game_code: formData.game_code,
          account_name: formData.account_name,
          purpose: formData.purpose,
          is_active: formData.is_active,
        })
        .eq('id', accountModal.editingAccount.id)

      if (error) throw error
      message.success('Cập nhật tài khoản game thành công!')
    } else {
      // Create new account
      const { error } = await supabase.from('game_accounts').insert({
        game_code: formData.game_code,
        account_name: formData.account_name,
        purpose: formData.purpose,
        is_active: formData.is_active,
      })

      if (error) throw error
      message.success('Thêm tài khoản game mới thành công!')
    }

    accountModal.open = false
    await loadAccounts()
  } catch (error: any) {
    message.error(error.message || 'Không thể lưu tài khoản game')
  } finally {
    accountModal.saving = false
  }
}

async function deleteAccount(accountId: string) {
  if (!confirm('Bạn có chắc chắn muốn xóa tài khoản game này?')) return

  try {
    const { error } = await supabase.from('game_accounts').delete().eq('id', accountId)
    if (error) throw error
    message.success('Xóa tài khoản game thành công!')
    await loadAccounts()
  } catch (error: any) {
    message.error(error.message || 'Không thể xóa tài khoản game')
  }
}

// Lifecycle
onMounted(async () => {
  await loadOptions()
  await loadAccounts()
})
</script>