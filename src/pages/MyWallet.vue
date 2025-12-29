<script setup lang="ts">
import { ref, onMounted, computed, h } from 'vue'
import { useMessage, NCard, NButton, NModal, NInput, NInputNumber, NSelect, NSpin, NTag, NDataTable, type DataTableColumns, type DataTableRowKey } from 'naive-ui'
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
  sender_name: string
  receiver_name: string
  amount: number
  currency_code: string
  status: string
  description: string
  created_at: string
}

// Composables
const message = useMessage()
const loading = ref(false)
const accounts = ref<TradingAccount[]>([])
const pendingRequests = ref<TransferRequest[]>([])

// Modal state
const showTransferModal = ref(false)
const showTransferToCompanyModal = ref(false)
const transferForm = ref({
  amount: null as number | null,
  currency_code: 'VND',
  description: '',
  receiver_id: null as string | null
})

// Currency options
const currencyOptions = [
  { label: 'VND', value: 'VND' },
  { label: 'USD', value: 'USD' },
  { label: 'CNY', value: 'CNY' }
]

// Employees for transfer
const employees = ref<Array<{id: string, name: string}>>([])

// Calculate totals
const purchaseBalance = computed(() => {
  const vnd = accounts.value.find(a => a.account_type === 'purchase' && a.currency_code === 'VND')
  return vnd?.current_balance || 0
})

const salesBalance = computed(() => {
  const vnd = accounts.value.find(a => a.account_type === 'sales' && a.currency_code === 'VND')
  return vnd?.current_balance || 0
})

// Table columns
const requestColumns: DataTableColumns<TransferRequest> = [
  { key: 'request_number', title: 'Mã', width: 150 },
  { key: 'transfer_type', title: 'Loại', width: 150 },
  { key: 'other_party', title: 'Đối tác', width: 200 },
  { key: 'amount', title: 'Số tiền', width: 150, render: (row) => `${row.amount.toLocaleString()} ${row.currency_code}` },
  { key: 'status', title: 'Trạng thái', width: 120, render: (row) => {
    const statusMap: Record<string, {type: 'success' | 'warning' | 'error' | 'info', label: string}> = {
      PENDING: { type: 'warning', label: 'Chờ xác nhận' },
      APPROVED: { type: 'success', label: 'Đã duyệt' },
      REJECTED: { type: 'error', label: 'Từ chối' },
      CANCELLED: { type: 'info', label: 'Hủy' }
    }
    const s = statusMap[row.status] || { type: 'info', label: row.status }
    return h(NTag, { type: s.type }, { default: () => s.label })
  }},
  { key: 'description', title: 'Mô tả' },
  { key: 'actions', title: '', width: 150, render: (row) => {
    if (row.status !== 'PENDING') return null
    return h(NButton, {
      size: 'small',
      onClick: () => handleConfirm(row.id),
      disabled: !canConfirm(row)
    }, { default: () => 'Xác nhận' })
  }}
]

// Load data
async function loadAccounts() {
  loading.value = true
  try {
    const { data: profileId } = await supabase.rpc('get_current_profile_id')
    if (!profileId) return

    const { data } = await supabase
      .from('employee_trading_accounts_view')
      .select('*')
      .eq('employee_id', profileId)

    accounts.value = data || []
  } catch (err) {
    console.error('Failed to load accounts:', err)
    message.error('Không thể tải thông tin tài khoản')
  } finally {
    loading.value = false
  }
}

async function loadPendingRequests() {
  try {
    const { data: profileId } = await supabase.rpc('get_current_profile_id')
    if (!profileId) return

    const { data } = await supabase
      .from('transfer_requests')
      .select('*')
      .eq('status', 'PENDING')
      .or(`sender_id.eq.${profileId},receiver_id.eq.${profileId}`)
      .order('created_at', { ascending: false })

    pendingRequests.value = data || []
  } catch (err) {
    console.error('Failed to load requests:', err)
  }
}

async function loadEmployees() {
  const { data } = await supabase
    .from('profiles')
    .select('id, display_name')
    .eq('status', 'active')
    .order('display_name')

  employees.value = (data || []).map(p => ({ id: p.id, name: p.display_name }))
}

function canConfirm(row: TransferRequest): boolean {
  // Simple check - can be enhanced
  return row.status === 'PENDING'
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
    await Promise.all([loadAccounts(), loadPendingRequests()])
  }
}

async function handleTransferToCompany() {
  const { data: profileId } = await supabase.rpc('get_current_profile_id')
  if (!profileId || !transferForm.value.amount) return

  const { data, error } = await supabase.rpc('create_transfer_request', {
    p_transfer_type: 'EMPLOYEE_TO_COMPANY',
    p_sender_id: profileId,
    p_sender_account_type: 'sales',
    p_receiver_id: profileId, // Use accountant's ID in production
    p_receiver_account_type: 'company',
    p_amount: transferForm.value.amount,
    p_currency_code: transferForm.value.currency_code,
    p_description: transferForm.value.description || 'Nộp tiền về công ty',
    p_notes: null,
    p_reference_type: 'manual',
    p_reference_id: null,
    p_created_by: profileId
  })

  if (error) {
    message.error('Không thể tạo yêu cầu: ' + error.message)
  } else {
    message.success('Đã tạo yêu cầu nộp tiền. Chờ kế toán xác nhận.')
    showTransferToCompanyModal.value = false
    transferForm.value = { amount: null, currency_code: 'VND', description: '', receiver_id: null }
    await loadPendingRequests()
  }
}

async function handleTransferToEmployee() {
  const { data: profileId } = await supabase.rpc('get_current_profile_id')
  if (!profileId || !transferForm.value.amount || !transferForm.value.receiver_id) return

  const { data, error } = await supabase.rpc('create_transfer_request', {
    p_transfer_type: 'EMPLOYEE_TO_EMPLOYEE',
    p_sender_id: profileId,
    p_sender_account_type: 'sales',
    p_receiver_id: transferForm.value.receiver_id,
    p_receiver_account_type: 'purchase',
    p_amount: transferForm.value.amount,
    p_currency_code: transferForm.value.currency_code,
    p_description: transferForm.value.description || 'Chuyển tiền cho nhân viên khác',
    p_notes: null,
    p_reference_type: 'manual',
    p_reference_id: null,
    p_created_by: profileId
  })

  if (error) {
    message.error('Không thể tạo yêu cầu: ' + error.message)
  } else {
    message.success('Đã tạo yêu cầu chuyển tiền. Chờ người nhận xác nhận.')
    showTransferModal.value = false
    transferForm.value = { amount: null, currency_code: 'VND', description: '', receiver_id: null }
    await loadPendingRequests()
  }
}

onMounted(async () => {
  await Promise.all([loadAccounts(), loadPendingRequests(), loadEmployees()])
})
</script>

<template>
  <div class="p-6 space-y-6">
    <!-- Balance Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <NCard title="Tài khoản Mua hàng (Purchase)">
        <div class="text-3xl font-bold text-blue-600">
          {{ purchaseBalance.toLocaleString() }} VND
        </div>
        <p class="text-gray-500 mt-2">Tiền để mua coin từ supplier</p>
      </NCard>

      <NCard title="Tài khoản Bán hàng (Sales)">
        <div class="text-3xl font-bold text-green-600">
          {{ salesBalance.toLocaleString() }} VND
        </div>
        <p class="text-gray-500 mt-2">Tiền thu được từ việc bán coin</p>
      </NCard>
    </div>

    <!-- Actions -->
    <NCard title="Tài chính">
      <div class="flex gap-3">
        <NButton type="success" @click="showTransferToCompanyModal = true">
          💰 Nộp tiền về công ty
        </NButton>
        <NButton type="info" @click="showTransferModal = true">
          👥 Chuyển tiền cho nhân viên khác
        </NButton>
        <NButton type="warning" @click="loadAccounts">
          🔄 Làm mới
        </NButton>
      </div>
    </NCard>

    <!-- Pending Requests -->
    <NCard title="Yêu cầu chờ xác nhận">
      <NDataTable
        :columns="requestColumns"
        :data="pendingRequests"
        :loading="loading"
        :row-key="(row: TransferRequest) => row.id"
        striped
      />
    </NCard>

    <!-- Transfer to Company Modal -->
    <NModal
      v-model:show="showTransferToCompanyModal"
      :mask-closable="false"
      :style="{ width: '500px' }"
      preset="card"
      title="Nộp tiền về công ty"
    >
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Số tiền</label>
          <NInputNumber
            v-model:value="transferForm.amount"
            placeholder="Nhập số tiền"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Loại tiền</label>
          <NSelect
            v-model:value="transferForm.currency_code"
            :options="currencyOptions"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Mô tả</label>
          <NInput
            v-model:value="transferForm.description"
            type="textarea"
            placeholder="Lý do nộp tiền..."
          />
        </div>
        <div class="flex justify-end gap-2">
          <NButton @click="showTransferToCompanyModal = false">Hủy</NButton>
          <NButton type="success" @click="handleTransferToCompany" :disabled="!transferForm.amount">
            Tạo yêu cầu
          </NButton>
        </div>
      </div>
    </NModal>

    <!-- Transfer to Employee Modal -->
    <NModal
      v-model:show="showTransferModal"
      :mask-closable="false"
      :style="{ width: '500px' }"
      preset="card"
      title="Chuyển tiền cho nhân viên khác"
    >
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Người nhận</label>
          <NSelect
            v-model:value="transferForm.receiver_id"
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
            v-model:value="transferForm.amount"
            placeholder="Nhập số tiền"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Loại tiền</label>
          <NSelect
            v-model:value="transferForm.currency_code"
            :options="currencyOptions"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Ghi chú</label>
          <NInput
            v-model:value="transferForm.description"
            type="textarea"
            placeholder="Lý do chuyển tiền..."
          />
        </div>
        <div class="flex justify-end gap-2">
          <NButton @click="showTransferModal = false">Hủy</NButton>
          <NButton type="info" @click="handleTransferToEmployee" :disabled="!transferForm.amount || !transferForm.receiver_id">
            Tạo yêu cầu
          </NButton>
        </div>
      </div>
    </NModal>
  </div>
</template>
