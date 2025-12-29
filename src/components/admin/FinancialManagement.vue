<script setup lang="ts">
import { ref, onMounted, computed, watch, h } from 'vue'
import { NCard, NButton, NTag, NDataTable, type DataTableColumns } from 'naive-ui'
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

// Props
const props = defineProps<{
  searchQuery?: string
  refreshTrigger?: number
}>()

// Emits
const emit = defineEmits<{
  (e: 'refreshed'): void
  (e: 'loadingChange', value: boolean): void
}>()

// Composables
const loading = ref(false)
const allAccounts = ref<TradingAccount[]>([])

// Filtered data
const filteredAccounts = computed(() => {
  if (!props.searchQuery) return allAccounts.value
  const q = props.searchQuery.toLowerCase()
  return allAccounts.value.filter(a =>
    a.employee_name?.toLowerCase().includes(q) ||
    a.currency_code?.toLowerCase().includes(q)
  )
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

// Load data
async function loadAll() {
  loading.value = true
  emit('loadingChange', true)
  try {
    await loadAccounts()
  } finally {
    loading.value = false
    emit('loadingChange', false)
  }
  emit('refreshed')
}

async function loadAccounts() {
  const { data } = await supabase
    .from('employee_trading_accounts_view')
    .select('*')
    .order('employee_name')

  allAccounts.value = data || []
}

onMounted(() => {
  loadAll()
})

// Watch refresh trigger
watch(() => props.refreshTrigger, () => {
  loadAll()
})
</script>

<template>
  <div class="space-y-6">
    <!-- Summary Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
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
    </div>

    <!-- Actions -->
    <NCard>
      <div class="flex items-center justify-between">
        <h3 class="text-lg font-semibold">Danh sách tài khoản nhân viên</h3>
        <NButton @click="loadAll">
          🔄 Làm mới
        </NButton>
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
  </div>
</template>
