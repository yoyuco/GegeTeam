<script setup lang="ts">
import { ref, computed, onMounted, h } from 'vue'
import { useMessage, NCard, NButton, NModal, NInput, NInputNumber, NSelect, NSpin, NTag, NDataTable, NInputGroup, NFormItem, type DataTableColumns, NCollapse, NCollapseItem, NStatistic } from 'naive-ui'
import { useAuth } from '@/stores/auth'
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

interface CompanyAccount {
  id: string
  currency_code: string
  current_balance: number
  is_active: boolean
  deposit_count: number
  deposit_total: number
  withdrawal_count: number
  withdrawal_total: number
}

interface ExternalTransaction {
  id: string
  transaction_number: string
  transaction_type: 'DEPOSIT' | 'WITHDRAWAL'
  amount: number
  currency_code: string
  external_source: string
  external_account_name: string
  external_account_number: string
  description: string
  status: string
  created_at: string
  created_by_name: string
}

// Composables
const auth = useAuth()
const message = useMessage()
const loading = ref(false)
const activeTab = ref('overview')

// Data
const allAccounts = ref<TradingAccount[]>([])
const myAccounts = ref<TradingAccount[]>([])
const allRequests = ref<TransferRequest[]>([])
const myPendingRequests = ref<TransferRequest[]>([])
const companyAccounts = ref<CompanyAccount[]>([])
const externalTransactions = ref<ExternalTransaction[]>([])

// Modal state
const showAllocateModal = ref(false)
const showTransferModal = ref(false)
const showTransferToCompanyModal = ref(false)
const showDepositModal = ref(false)
const showWithdrawModal = ref(false)

const allocateForm = ref({
  employee_id: null as string | null,
  amount: null as number | null,
  currency_code: 'VND',
  description: ''
})

const transferForm = ref({
  amount: null as number | null,
  currency_code: 'VND',
  description: '',
  receiver_id: null as string | null
})

const depositForm = ref({
  amount: null as number | null,
  currency_code: 'VND',
  description: '',
  external_source: 'bank_transfer',
  external_account_name: '',
  external_account_number: '',
  external_transaction_id: ''
})

const withdrawForm = ref({
  amount: null as number | null,
  currency_code: 'VND',
  description: '',
  external_source: 'bank_transfer',
  external_account_name: '',
  external_account_number: ''
})

// Currency options
const currencyOptions = [
  { label: 'VND', value: 'VND' },
  { label: 'USD', value: 'USD' },
  { label: 'CNY', value: 'CNY' }
]

// External source options
const externalSourceOptions = [
  { label: 'Chuyển khoản ngân hàng', value: 'bank_transfer' },
  { label: 'MoMo', value: 'momo' },
  { label: 'ZaloPay', value: 'zalopay' },
  { label: 'USDT (TRC20)', value: 'usdt_trc20' },
  { label: 'USDT (ERC20)', value: 'usdt_erc20' },
  { label: 'Khác', value: 'other' }
]

// Employees
const employees = ref<Array<{id: string, name: string}>>([])

// User role check
const userRoleCodes = computed(() => {
  return auth.assignments.map(a => a.role_code)
})

const isAccountant = computed(() => {
  return userRoleCodes.value.includes('accountant')
})

const isManager = computed(() => {
  return userRoleCodes.value.some(r => ['admin', 'mod', 'manager'].includes(r))
})

const isTrader = computed(() => {
  return userRoleCodes.value.some(r => ['trader1', 'trader2'].includes(r))
})

// Determine default tab based on role
const defaultTab = computed(() => {
  if (isAccountant.value) return 'overview'
  if (isTrader.value) return 'my-wallet'
  return 'overview'
})

// Available tabs based on role
const availableTabs = computed(() => {
  const tabs = []

  if (isAccountant.value || isManager.value) {
    tabs.push({ key: 'overview', label: '📊 Tổng quan' })
  }

  if (isAccountant.value) {
    tabs.push({ key: 'accounting', label: '💰 Quản lý Tài chính' })
    tabs.push({ key: 'external', label: '🏦 Thu Chi Ngoại tuyến' })
  }

  if (isTrader.value) {
    tabs.push({ key: 'my-wallet', label: '👛 Ví của tôi' })
  }

  return tabs
})

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
  { key: 'confirmations', title: 'Xác nhận', width: 150, render: (row) => {
    if (row.receiver_confirmed_at) return 'Người nhận ✓'
    if (row.status === 'PENDING') return 'Chờ người nhận'
    return '-'
  }},
  { key: 'actions', title: '', width: 150, render: (row) => {
    if (row.status !== 'PENDING') return null
    return h(NButton, {
      size: 'small',
      onClick: () => handleConfirm(row.id)
    }, { default: () => 'Xác nhận' })
  }}
]

const externalTransactionColumns: DataTableColumns<ExternalTransaction> = [
  { key: 'transaction_number', title: 'Mã', width: 150 },
  { key: 'transaction_type', title: 'Loại', width: 120, render: (row) => {
    const typeMap: Record<string, {label: string, color: string}> = {
      DEPOSIT: { label: 'Nạp tiền', color: 'success' },
      WITHDRAWAL: { label: 'Rút tiền', color: 'warning' }
    }
    const t = typeMap[row.transaction_type] || { label: row.transaction_type, color: 'gray' }
    return h(NTag, { type: t.color as any }, { default: () => t.label })
  }},
  { key: 'amount', title: 'Số tiền', width: 150, render: (row) => `${row.amount.toLocaleString()} ${row.currency_code}` },
  { key: 'external_source', title: 'Nguồn', width: 150 },
  { key: 'external_account_name', title: 'Tên tài khoản', width: 200 },
  { key: 'description', title: 'Mô tả' },
  { key: 'status', title: 'Trạng thái', width: 120, render: (row) => {
    const statusMap: Record<string, {type: 'success' | 'warning' | 'error' | 'info', label: string}> = {
      PENDING: { type: 'warning', label: 'Chờ duyệt' },
      CONFIRMED: { type: 'info', label: 'Đã xác nhận' },
      COMPLETED: { type: 'success', label: 'Hoàn thành' },
      REJECTED: { type: 'error', label: 'Từ chối' },
      CANCELLED: { type: 'info', label: 'Hủy' }
    }
    const s = statusMap[row.status] || { type: 'info', label: row.status }
    return h(NTag, { type: s.type as any }, { default: () => s.label })
  }},
  { key: 'created_at', title: 'Ngày tạo', width: 180, render: (row) => new Date(row.created_at).toLocaleString('vi-VN') }
]

// Computed totals
const companyBalances = computed(() => {
  const balances: Record<string, number> = { VND: 0, USD: 0, CNY: 0 }
  companyAccounts.value.forEach(acc => {
    balances[acc.currency_code] = acc.current_balance
  })
  return balances
})

const totalPurchaseBalance = computed(() => {
  return allAccounts.value
    .filter(a => a.account_type === 'purchase' && a.currency_code === 'VND')
    .reduce((sum, a) => sum + a.current_balance, 0)
})

const totalSalesBalance = computed(() => {
  return allAccounts.value
    .filter(a => a.account_type === 'sales' && a.currency_code === 'VND')
    .reduce((sum, a) => sum + a.current_balance, 0)
})

const pendingRequestsCount = computed(() => {
  return allRequests.value.filter(r => r.status === 'PENDING').length
})

const myPurchaseBalance = computed(() => {
  const vnd = myAccounts.value.find(a => a.account_type === 'purchase' && a.currency_code === 'VND')
  return vnd?.current_balance || 0
})

const mySalesBalance = computed(() => {
  const vnd = myAccounts.value.find(a => a.account_type === 'sales' && a.currency_code === 'VND')
  return vnd?.current_balance || 0
})

// Group balances by currency (for multi-currency display)
const myBalancesByCurrency = computed(() => {
  const currencyMap = new Map<string, { purchase: number, sales: number }>()

  myAccounts.value.forEach(account => {
    const currency = account.currency_code
    if (!currencyMap.has(currency)) {
      currencyMap.set(currency, { purchase: 0, sales: 0 })
    }
    const balance = currencyMap.get(currency)!
    if (account.account_type === 'purchase') {
      balance.purchase = account.current_balance || 0
    } else if (account.account_type === 'sales') {
      balance.sales = account.current_balance || 0
    }
  })

  return Array.from(currencyMap.entries())
    .map(([currency, balances]) => ({ currency, ...balances }))
    .sort((a, b) => a.currency.localeCompare(b.currency))
})

// Load data
async function loadAll() {
  loading.value = true
  try {
    await Promise.all([
      isAccountant.value || isManager.value ? loadAllAccounts() : Promise.resolve(),
      isTrader.value ? loadMyAccounts() : Promise.resolve(),
      isAccountant.value ? loadAllRequests() : Promise.resolve(),
      isTrader.value ? loadMyPendingRequests() : Promise.resolve(),
      isAccountant.value ? loadCompanyAccounts() : Promise.resolve(),
      isAccountant.value ? loadExternalTransactions() : Promise.resolve(),
      loadEmployees()
    ])
  } finally {
    loading.value = false
  }
}

async function loadAllAccounts() {
  const { data } = await supabase
    .from('employee_trading_accounts_view')
    .select('*')
    .order('employee_name')

  allAccounts.value = data || []
}

async function loadMyAccounts() {
  const { data: profileId } = await supabase.rpc('get_current_profile_id')
  if (!profileId) return

  const { data } = await supabase
    .from('employee_trading_accounts_view')
    .select('*')
    .eq('employee_id', profileId)

  myAccounts.value = data || []
}

async function loadAllRequests() {
  const { data } = await supabase
    .from('transfer_requests_view')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(100)

  allRequests.value = data || []
}

async function loadMyPendingRequests() {
  const { data: profileId } = await supabase.rpc('get_current_profile_id')
  if (!profileId) return

  const { data } = await supabase
    .from('transfer_requests_view')
    .select('*')
    .eq('status', 'PENDING')
    .or(`sender_id.eq.${profileId},receiver_id.eq.${profileId}`)
    .order('created_at', { ascending: false })

  myPendingRequests.value = data || []
}

async function loadCompanyAccounts() {
  const { data, error } = await supabase
    .from('company_fund_accounts_view')
    .select('*')
    .order('currency_code')

  if (error) console.error('[Finance] loadCompanyAccounts error:', error)
  companyAccounts.value = data || []
}

async function loadExternalTransactions() {
  const { data } = await supabase
    .from('external_transactions_view')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(50)

  externalTransactions.value = data || []
}

async function loadEmployees() {
  const { data } = await supabase
    .from('profiles')
    .select('id, display_name')
    .eq('status', 'active')
    .order('display_name')

  employees.value = (data || []).map(p => ({ id: p.id, name: p.display_name }))
}

// Accounting functions
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

// External transactions
async function handleDeposit() {
  const { data: profileId } = await supabase.rpc('get_current_profile_id')
  if (!profileId || !depositForm.value.amount) return

  const { data, error } = await supabase.rpc('deposit_to_company_account', {
    p_amount: depositForm.value.amount,
    p_currency_code: depositForm.value.currency_code,
    p_description: depositForm.value.description,
    p_external_source: depositForm.value.external_source,
    p_external_account_name: depositForm.value.external_account_name,
    p_external_account_number: depositForm.value.external_account_number,
    p_external_transaction_id: depositForm.value.external_transaction_id,
    p_notes: null,
    p_attachment_urls: null,
    p_created_by: profileId
  })

  if (error) {
    message.error('Không thể nạp tiền: ' + error.message)
  } else {
    message.success('Đã ghi nhận nạp tiền thành công')
    showDepositModal.value = false
    depositForm.value = {
      amount: null,
      currency_code: 'VND',
      description: '',
      external_source: 'bank_transfer',
      external_account_name: '',
      external_account_number: '',
      external_transaction_id: ''
    }
    await loadAll()
  }
}

async function handleWithdraw() {
  const { data: profileId } = await supabase.rpc('get_current_profile_id')
  if (!profileId || !withdrawForm.value.amount) return

  const { data, error } = await supabase.rpc('withdraw_from_company_account', {
    p_amount: withdrawForm.value.amount,
    p_currency_code: withdrawForm.value.currency_code,
    p_description: withdrawForm.value.description,
    p_external_source: withdrawForm.value.external_source,
    p_external_account_name: withdrawForm.value.external_account_name,
    p_external_account_number: withdrawForm.value.external_account_number,
    p_notes: null,
    p_attachment_urls: null,
    p_created_by: profileId
  })

  if (error) {
    message.error('Không thể rút tiền: ' + error.message)
  } else {
    message.success('Đã ghi nhận rút tiền thành công')
    showWithdrawModal.value = false
    withdrawForm.value = {
      amount: null,
      currency_code: 'VND',
      description: '',
      external_source: 'bank_transfer',
      external_account_name: '',
      external_account_number: ''
    }
    await loadAll()
  }
}

// Trader functions
async function handleTransferToCompany() {
  const { data: profileId } = await supabase.rpc('get_current_profile_id')
  if (!profileId || !transferForm.value.amount) return

  const { data, error } = await supabase.rpc('create_transfer_request', {
    p_transfer_type: 'EMPLOYEE_TO_COMPANY',
    p_sender_id: profileId,
    p_sender_account_type: 'sales',
    p_receiver_id: profileId,
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
    await loadAll()
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
    await loadAll()
  }
}

// Initialize
onMounted(() => {
  activeTab.value = defaultTab.value
  loadAll()
})
</script>

<template>
  <div class="p-6 space-y-6">
    <div class="flex items-center justify-between">
      <h1 class="text-2xl font-bold">Tài chính</h1>
    </div>

    <!-- Tabs -->
    <div class="bg-white border border-gray-200 rounded-xl">
      <div class="flex">
        <button
          v-for="tab in availableTabs"
          :key="tab.key"
          :class="[
            'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
            activeTab === tab.key
              ? 'tab-active text-blue-600 border-b-2 border-blue-600 bg-blue-50'
              : 'tab-inactive text-gray-500 hover:text-gray-700 hover:bg-gray-50',
          ]"
          @click="activeTab = tab.key"
        >
          {{ tab.label }}
        </button>
      </div>
    </div>

    <!-- Tab: Tổng quan (Accountant/Manager/Admin/Mod) -->
    <div v-if="activeTab === 'overview'">
      <!-- Company Balance Section -->
      <NCard title="💼 Tài khoản Công ty" class="mb-4">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="bg-blue-50 p-4 rounded-lg border border-blue-200">
            <div class="text-sm text-blue-600 font-medium mb-1">VND</div>
            <div class="text-2xl font-bold text-blue-700">
              {{ companyBalances.VND.toLocaleString() }} đ
            </div>
          </div>
          <div class="bg-green-50 p-4 rounded-lg border border-green-200">
            <div class="text-sm text-green-600 font-medium mb-1">USD</div>
            <div class="text-2xl font-bold text-green-700">
              ${{ companyBalances.USD.toLocaleString() }}
            </div>
          </div>
          <div class="bg-orange-50 p-4 rounded-lg border border-orange-200">
            <div class="text-sm text-orange-600 font-medium mb-1">CNY</div>
            <div class="text-2xl font-bold text-orange-700">
              ¥{{ companyBalances.CNY.toLocaleString() }}
            </div>
          </div>
        </div>
      </NCard>

      <!-- Employee Accounts Summary -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <NCard>
          <div class="text-sm text-gray-500">Tổng tài khoản Purchase</div>
          <div class="text-2xl font-bold text-blue-600">
            {{ totalPurchaseBalance.toLocaleString() }} VND
          </div>
        </NCard>
        <NCard>
          <div class="text-sm text-gray-500">Tổng tài khoản Sales</div>
          <div class="text-2xl font-bold text-green-600">
            {{ totalSalesBalance.toLocaleString() }} VND
          </div>
        </NCard>
        <NCard>
          <div class="text-sm text-gray-500">Yêu cầu chờ xử lý</div>
          <div class="text-2xl font-bold text-orange-600">
            {{ pendingRequestsCount }}
          </div>
        </NCard>
      </div>

      <NCard title="Tài khoản nhân viên" class="mt-4">
        <NDataTable
          :columns="accountColumns"
          :data="allAccounts"
          :loading="loading"
          :row-key="(row: TradingAccount) => row.id"
          striped
          :pagination="{ pageSize: 20 }"
        />
      </NCard>
    </div>

    <!-- Tab: Quản lý Tài chính (Accountant only) -->
    <div v-if="activeTab === 'accounting'">
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

      <NCard title="Yêu cầu chuyển tiền" class="mt-4">
        <NDataTable
          :columns="requestColumns"
          :data="allRequests"
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
              placeholder="Nhập số tiền cấp vốn"
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

    <!-- Tab: Thu Chi Ngoại tuyến (Accountant only) -->
    <div v-if="activeTab === 'external'">
      <!-- Company Balance -->
      <NCard title="💼 Số dư tài khoản công ty" class="mb-4">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="bg-blue-50 p-4 rounded-lg border border-blue-200">
            <div class="text-sm text-blue-600 font-medium mb-1">VND</div>
            <div class="text-2xl font-bold text-blue-700">
              {{ companyBalances.VND.toLocaleString() }} đ
            </div>
          </div>
          <div class="bg-green-50 p-4 rounded-lg border border-green-200">
            <div class="text-sm text-green-600 font-medium mb-1">USD</div>
            <div class="text-2xl font-bold text-green-700">
              ${{ companyBalances.USD.toLocaleString() }}
            </div>
          </div>
          <div class="bg-orange-50 p-4 rounded-lg border border-orange-200">
            <div class="text-sm text-orange-600 font-medium mb-1">CNY</div>
            <div class="text-2xl font-bold text-orange-700">
              ¥{{ companyBalances.CNY.toLocaleString() }}
            </div>
          </div>
        </div>
      </NCard>

      <!-- Actions -->
      <NCard class="mb-4">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold">Giao dịch với nền tảng bên ngoài</h3>
          <div class="flex gap-3">
            <NButton type="success" @click="showDepositModal = true">
              💵 Nạp tiền vào công ty
            </NButton>
            <NButton type="warning" @click="showWithdrawModal = true">
              💸 Rút tiền từ công ty
            </NButton>
            <NButton @click="loadAll">
              🔄 Làm mới
            </NButton>
          </div>
        </div>
      </NCard>

      <!-- Transactions Table -->
      <NCard title="Lịch sử giao dịch bên ngoài">
        <NDataTable
          :columns="externalTransactionColumns"
          :data="externalTransactions"
          :loading="loading"
          :row-key="(row: ExternalTransaction) => row.id"
          striped
          :pagination="{ pageSize: 20 }"
        />
      </NCard>

      <!-- Deposit Modal -->
      <NModal
        v-model:show="showDepositModal"
        :mask-closable="false"
        :style="{ width: '600px' }"
        preset="card"
        title="Nạp tiền vào tài khoản công ty"
      >
        <div class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Số tiền</label>
              <NInputNumber
                v-model:value="depositForm.amount"
                placeholder="Nhập số tiền"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Loại tiền</label>
              <NSelect
                v-model:value="depositForm.currency_code"
                :options="currencyOptions"
              />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nguồn tiền</label>
            <NSelect
              v-model:value="depositForm.external_source"
              :options="externalSourceOptions"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Tên tài khoản người gửi</label>
            <NInput
              v-model:value="depositForm.external_account_name"
              placeholder="Tên người gửi / tên tài khoản"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Số tài khoản / Ví</label>
            <NInput
              v-model:value="depositForm.external_account_number"
              placeholder="Số tài khoản hoặc số ví"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Mã giao dịch (nếu có)</label>
            <NInput
              v-model:value="depositForm.external_transaction_id"
              placeholder="Mã giao dịch từ ngân hàng / nền tảng"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Mô tả</label>
            <NInput
              v-model:value="depositForm.description"
              type="textarea"
              placeholder="Nội dung chuyển tiền..."
            />
          </div>
          <div class="flex justify-end gap-2">
            <NButton @click="showDepositModal = false">Hủy</NButton>
            <NButton type="success" @click="handleDeposit" :disabled="!depositForm.amount">
              Xác nhận nạp tiền
            </NButton>
          </div>
        </div>
      </NModal>

      <!-- Withdraw Modal -->
      <NModal
        v-model:show="showWithdrawModal"
        :mask-closable="false"
        :style="{ width: '600px' }"
        preset="card"
        title="Rút tiền từ tài khoản công ty"
      >
        <div class="space-y-4">
          <div class="bg-yellow-50 p-3 rounded-lg border border-yellow-200 mb-4">
            <div class="text-sm text-yellow-700">
              <strong>Lưu ý:</strong> Số dư công ty hiện tại ({{ withdrawForm.currency_code }}):
              {{ companyBalances[withdrawForm.currency_code as keyof typeof companyBalances.value]?.toLocaleString() }}
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Số tiền</label>
              <NInputNumber
                v-model:value="withdrawForm.amount"
                placeholder="Nhập số tiền"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Loại tiền</label>
              <NSelect
                v-model:value="withdrawForm.currency_code"
                :options="currencyOptions"
              />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nền tảng nhận</label>
            <NSelect
              v-model:value="withdrawForm.external_source"
              :options="externalSourceOptions"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Tên tài khoản người nhận</label>
            <NInput
              v-model:value="withdrawForm.external_account_name"
              placeholder="Tên người nhận / tên tài khoản"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Số tài khoản / Ví</label>
            <NInput
              v-model:value="withdrawForm.external_account_number"
              placeholder="Số tài khoản hoặc số ví"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Mô tả</label>
            <NInput
              v-model:value="withdrawForm.description"
              type="textarea"
              placeholder="Lý do rút tiền..."
            />
          </div>
          <div class="flex justify-end gap-2">
            <NButton @click="showWithdrawModal = false">Hủy</NButton>
            <NButton type="warning" @click="handleWithdraw" :disabled="!withdrawForm.amount">
              Xác nhận rút tiền
            </NButton>
          </div>
        </div>
      </NModal>
    </div>

    <!-- Tab: Ví của tôi (Trader) -->
    <div v-if="activeTab === 'my-wallet'">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <NCard v-for="balance in myBalancesByCurrency" :key="balance.currency" :title="`Số dư ${balance.currency}`">
          <div class="space-y-3">
            <div>
              <div class="text-sm text-gray-500 mb-1">Mua hàng (Purchase)</div>
              <div class="text-2xl font-bold text-blue-600">
                {{ balance.purchase.toLocaleString() }}
              </div>
            </div>
            <div v-if="balance.sales !== 0" class="pt-3 border-t border-gray-200">
              <div class="text-sm text-gray-500 mb-1">Bán hàng (Sales)</div>
              <div class="text-2xl font-bold text-green-600">
                {{ balance.sales.toLocaleString() }}
              </div>
            </div>
          </div>
        </NCard>
      </div>

      <NCard title="Tài chính" class="mt-4">
        <div class="flex gap-3">
          <NButton type="success" @click="showTransferToCompanyModal = true">
            💰 Nộp tiền về công ty
          </NButton>
          <NButton type="info" @click="showTransferModal = true">
            👥 Chuyển tiền cho nhân viên khác
          </NButton>
          <NButton @click="loadAll">
            🔄 Làm mới
          </NButton>
        </div>
      </NCard>

      <NCard title="Yêu cầu chờ xác nhận" class="mt-4">
        <NDataTable
          :columns="requestColumns"
          :data="myPendingRequests"
          :loading="loading"
          :row-key="(row: TransferRequest) => row.id"
          striped
          :pagination="{ pageSize: 20 }"
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
  </div>
</template>

<style scoped>
.tab-active {
  font-weight: 600;
}
.tab-inactive:hover {
  background-color: rgba(0, 0, 0, 0.04);
}
</style>
