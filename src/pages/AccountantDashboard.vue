<script setup lang="ts">
import { ref, onMounted, computed, h } from 'vue'
import { useMessage, NCard, NButton, NModal, NInput, NInputNumber, NSelect, NTag, NDataTable, type DataTableColumns } from 'naive-ui'
import { supabase } from '@/lib/supabase'

// Types
interface TradingAccount {
  id: string
  employee_id: string
  employee_name: string
  account_type: 'purchase' | 'sales'
  currency_code: string
  current_balance: number
  credit_limit: number
  is_active: boolean
}

interface TransferRequest {
  id: string
  request_number: string
  transfer_type: string
  sender_id: string
  sender_name: string
  receiver_id: string
  receiver_name: string
  amount: number
  currency_code: string
  status: string
  description: string
  sender_confirmed_at: string | null
  receiver_confirmed_at: string | null
  created_at: string
}

// Composables
const message = useMessage()
const loading = ref(false)
const allAccounts = ref<TradingAccount[]>([])
const allRequests = ref<TransferRequest[]>([])

// Modal state
const showAllocateModal = ref(false)
const allocateForm = ref({
  employee_id: null as string | null,
  amount: null as number | null,
  currency_code: 'VND',
  description: ''
})

// Currency options
const currencyOptions = [
  { label: 'VND', value: 'VND' },
  { label: 'USD', value: 'USD' },
  { label: 'CNY', value: 'CNY' }
]

// Employees
const employees = ref<Array<{id: string, name: string}>>([])

// Filtered data
const filteredAccounts = computed(() => allAccounts.value)
const filteredRequests = computed(() => allRequests.value)

// Table columns
const accountColumns: DataTableColumns<TradingAccount> = [
  { key: 'employee_name', title: 'Nhân viên', width: 200 },
  { key: 'account_type', title: 'Loại tài khoản', width: 150, render: (row) => {
    const typeMap: Record<string, {label: string, color: string}> = {
      purchase: { label: 'Mua hàng', color: 'blue' },
      sales: { label: 'Bán hàng', color: 'green' }
    }
    const t = typeMap[row.account_type] || { label: row.account_type, color: 'gray' }
    return h(NTag, { type: t.color as any }, { default: () => t.label })
  }},
  { key: 'currency_code', title: 'Loại tiền', width: 100 },
  { key: 'current_balance', title: 'Số dư', width: 150, render: (row) => `${row.current_balance.toLocaleString()} ${row.currency_code}` },
  { key: 'credit_limit', title: 'Hạn mức', width: 150, render: (row) => `${row.credit_limit.toLocaleString()} ${row.currency_code}` },
  { key: 'available', title: 'Còn lại', width: 150, render: (row) => `${(row.credit_limit - row.current_balance).toLocaleString()} ${row.currency_code}` }
]

const requestColumns: DataTableColumns<TransferRequest> = [
  { key: 'request_number', title: 'Mã', width: 150 },
  { key: 'transfer_type', title: 'Loại', width: 200 },
  { key: 'from_to', title: 'Từ → Đến', width: 300, render: (row) => `${row.sender_name} → ${row.receiver_name}` },
  { key: 'amount', title: 'Số tiền', width: 150, render: (row) => `${row.amount.toLocaleString()} ${row.currency_code}` },
  { key: 'status', title: 'Trạng thái', width: 120, render: (row) => {
    const statusMap: Record<string, {type: 'success' | 'warning' | 'error' | 'info', label: string}> = {
      PENDING: { type: 'warning', label: 'Chờ xác nhận' },
      APPROVED: { type: 'success', label: 'Đã duyệt' },
      REJECTED: { type: 'error', label: 'Từ chối' },
      CANCELLED: { type: 'info', label: 'Hủy' }
    }
    const s = statusMap[row.status] || { type: 'info', label: row.status }
    return h(NTag, { type: s.type as any }, { default: () => s.label })
  }},
  { key: 'confirmations', title: 'Xác nhận', width: 200, render: (row) => {
    const parts = []
    if (row.sender_confirmed_at) parts.push('Người gửi ✓')
    if (row.receiver_confirmed_at) parts.push('Người nhận ✓')
    return parts.join(' + ') || 'Chưa có ai'
  }},
  { key: 'actions', title: '', width: 150, render: (row) => {
    if (row.status !== 'PENDING') return null
    return h(NButton, {
      size: 'small',
      onClick: () => handleConfirm(row.id)
    }, { default: () => 'Xác nhận' })
  }}
]

// Load data
async function loadAll() {
  loading.value = true
  try {
    await Promise.all([loadAccounts(), loadRequests(), loadEmployees()])
  } finally {
    loading.value = false
  }
}

async function loadAccounts() {
  const { data } = await supabase
    .from('employee_trading_accounts_view')
    .select('*')
    .order('employee_name')

  allAccounts.value = data || []
}

async function loadRequests() {
  const { data } = await supabase
    .from('transfer_requests_view')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(100)

  allRequests.value = data || []
}

async function loadEmployees() {
  const { data } = await supabase
    .from('profiles')
    .select('id, display_name')
    .eq('status', 'active')
    .order('display_name')

  employees.value = (data || []).map(p => ({ id: p.id, name: p.display_name }))
}

async function handleAllocateFunds() {
  const { data: profileId } = await supabase.rpc('get_current_profile_id')
  if (!profileId || !allocateForm.value.employee_id || !allocateForm.value.amount) return

  const { data, error } = await supabase.rpc('create_transfer_request', {
    p_transfer_type: 'COMPANY_TO_EMPLOYEE',
    p_sender_id: profileId,
    p_sender_account_type: 'company',
    p_receiver_id: allocateForm.value.employee_id,
    p_receiver_account_type: 'purchase',
    p_amount: allocateForm.value.amount,
    p_currency_code: allocateForm.value.currency_code,
    p_description: allocateForm.value.description || 'Cấp vốn từ công ty',
    p_notes: null,
    p_reference_type: 'fund_allocation',
    p_reference_id: null,
    p_created_by: profileId
  })

  if (error) {
    message.error('Không thể tạo yêu cầu: ' + error.message)
  } else {
    message.success('Đã tạo yêu cầu cấp vốn. Nhân viên cần xác nhận.')
    showAllocateModal.value = false
    allocateForm.value = { employee_id: null, amount: null, currency_code: 'VND', description: '' }
    await loadAll()
  }
}

async function handleConfirm(requestId: string) {
  const { data: profileId } = await supabase.rpc('get_current_profile_id')
  if (!profileId) return

  const { data, error } = await supabase.rpc('confirm_transfer_request', {
    p_request_id: requestId,
    p_confirmer_id: profileId
  })

  if (error) {
    message.error('Không thể xác nhận: ' + error.message)
  } else {
    message.success('Đã xác nhận yêu cầu')
    await loadAll()
  }
}

onMounted(() => {
  loadAll()
})
</script>

<template>
  <div class="p-6 space-y-6">
    <div class="flex items-center justify-between">
      <h1 class="text-2xl font-bold">Dashboard Kế toán</h1>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <NCard>
        <div class="text-sm text-gray-500">Tổng tài khoản Purchase</div>
        <div class="text-2xl font-bold text-blue-600">
          {{ filteredAccounts.filter(a => a.account_type === 'purchase').reduce((sum, a) => sum + a.current_balance, 0).toLocaleString() }} VND
        </div>
      </NCard>
      <NCard>
        <div class="text-sm text-gray-500">Tổng tài khoản Sales</div>
        <div class="text-2xl font-bold text-green-600">
          {{ filteredAccounts.filter(a => a.account_type === 'sales').reduce((sum, a) => sum + a.current_balance, 0).toLocaleString() }} VND
        </div>
      </NCard>
      <NCard>
        <div class="text-sm text-gray-500">Yêu cầu chờ xử lý</div>
        <div class="text-2xl font-bold text-orange-600">
          {{ filteredRequests.filter(r => r.status === 'PENDING').length }}
        </div>
      </NCard>
    </div>

    <!-- Actions -->
    <NCard>
      <div class="flex items-center justify-between">
        <h3 class="text-lg font-semibold">Quản lý tài chính</h3>
        <div class="flex gap-3">
          <NButton type="primary" @click="showAllocateModal = true">
            💰 Cấp vốn cho nhân viên
          </NButton>
          <NButton @click="loadAll">
            🔄 Làm mới
          </NButton>
        </div>
      </div>
    </NCard>

    <!-- Employee Accounts -->
    <NCard title="Tài khoản nhân viên">
      <NDataTable
        :columns="accountColumns"
        :data="filteredAccounts"
        :loading="loading"
        :row-key="(row: TradingAccount) => row.id"
        striped
        :pagination="{ pageSize: 20 }"
      />
    </NCard>

    <!-- Transfer Requests -->
    <NCard title="Yêu cầu chuyển tiền">
      <NDataTable
        :columns="requestColumns"
        :data="filteredRequests"
        :loading="loading"
        :row-key="(row: TransferRequest) => row.id"
        striped
        :pagination="{ pageSize: 20 }"
      />
    </NCard>

    <!-- Allocate Funds Modal -->
    <NModal
      v-model:show="showAllocateModal"
      :mask-closable="false"
      :style="{ width: '500px' }"
      preset="card"
      title="Cấp vốn cho nhân viên"
    >
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Nhân viên</label>
          <NSelect
            v-model:value="allocateForm.employee_id"
            :options="employees"
            label-field="name"
            value-field="id"
            placeholder="Chọn nhân viên..."
            filterable
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Số tiền</label>
          <NInputNumber
            v-model:value="allocateForm.amount"
            :min="0"
            placeholder="Nhập số tiền cấp vốn"
            class="w-full"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Loại tiền</label>
          <NSelect
            v-model:value="allocateForm.currency_code"
            :options="currencyOptions"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Mô tả</label>
          <NInput
            v-model:value="allocateForm.description"
            type="textarea"
            placeholder="Lý do cấp vốn..."
          />
        </div>
        <div class="flex justify-end gap-2">
          <NButton @click="showAllocateModal = false">Hủy</NButton>
          <NButton type="primary" @click="handleAllocateFunds" :disabled="!allocateForm.employee_id || !allocateForm.amount">
            Tạo yêu cầu
          </NButton>
        </div>
      </div>
    </NModal>
  </div>
</template>
