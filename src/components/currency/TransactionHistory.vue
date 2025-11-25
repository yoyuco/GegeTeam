<!-- path: src/components/currency/TransactionHistory.vue -->
<!-- Transaction History Component -->
<template>
  <div class="bg-white rounded-lg shadow-sm">
    <div class="p-4 border-b flex items-center justify-between">
      <h3 class="text-lg font-semibold">Lịch sử giao dịch</h3>
      <div class="flex items-center gap-2">
        <n-input
          v-model:value="searchText"
          placeholder="Tìm kiếm..."
          clearable
          style="width: 200px"
        />
        <n-select
          v-model:value="filterType"
          :options="typeOptions"
          placeholder="Loại giao dịch"
          style="width: 150px"
          clearable
        />
        <n-button tertiary @click="refreshTransactions">
          <template #icon><n-icon :component="RefreshIcon" /></template>
        </n-button>
      </div>
    </div>

    <div class="p-4">
      <n-data-table
        :columns="columns"
        :data="filteredTransactions"
        :loading="loading"
        :pagination="{ pageSize: 20 }"
        :bordered="false"
        size="small"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, h } from 'vue'
import { NDataTable, NInput, NSelect, NButton, NIcon, NTag, type DataTableColumns } from 'naive-ui'
import { RefreshOutline as RefreshIcon } from '@vicons/ionicons5'
import { useGameContext } from '@/composables/useGameContext.js'
import { useCurrency } from '@/composables/useCurrency.js'
// mport type { Transaction } from '@/types/composables' / Imported via composables

// Composables
const { currentGame, currentServer } = useGameContext()
const { getTransactions } = useCurrency()

// Local state
const loading = ref(false)
const transactions = ref<
  Array<{
    id: string
    created_at: string
    transaction_type: string
    currency: { name: string; code: string } | null
    game_account: { account_name: string } | null
    quantity: number
    unit_price_vnd: number | null
    unit_price_usd: number | null
    creator: { display_name: string } | null
    notes: string | null
  }>
>([])
const searchText = ref('')
const filterType = ref<string | null>(null)

// Transaction type options
const typeOptions = [
  { label: 'Mua vào', value: 'purchase' },
  { label: 'Bán ra', value: 'sale_delivery' },
  { label: 'Đổi tiền', value: 'exchange_out' },
  { label: 'Chuyển ra', value: 'transfer_out' },
  { label: 'Chuyển vào', value: 'transfer_in' },
  { label: 'Điều chỉnh', value: 'manual_adjustment' },
  { label: 'Farm vào', value: 'farm_in' },
  { label: 'Farm trả', value: 'farm_payout' },
]

// Transaction type display mapping
const typeDisplayMap: Record<string, { label: string; type: string }> = {
  purchase: { label: 'Mua vào', type: 'info' },
  sale_delivery: { label: 'Bán ra', type: 'success' },
  exchange_out: { label: 'Đổi tiền', type: 'warning' },
  exchange_in: { label: 'Nhận đổi', type: 'success' },
  transfer_out: { label: 'Chuyển ra', type: 'default' },
  transfer_in: { label: 'Chuyển vào', type: 'default' },
  manual_adjustment: { label: 'Điều chỉnh', type: 'error' },
  farm_in: { label: 'Farm vào', type: 'info' },
  farm_payout: { label: 'Farm trả', type: 'warning' },
  league_archive: { label: 'Kết chuyển', type: 'default' },
}

// Computed
const filteredTransactions = computed(() => {
  let filtered = transactions.value

  // Filter by type
  if (filterType.value) {
    filtered = filtered.filter((t) => t.transaction_type === filterType.value)
  }

  // Filter by search text
  if (searchText.value) {
    const search = searchText.value.toLowerCase()
    filtered = filtered.filter(
      (t) =>
        t.currency?.name?.toLowerCase().includes(search) ||
        t.game_account?.account_name?.toLowerCase().includes(search) ||
        t.notes?.toLowerCase().includes(search) ||
        t.creator?.display_name?.toLowerCase().includes(search)
    )
  }

  return filtered
})

// Table columns
const columns: DataTableColumns<{
  id: string
  created_at: string
  transaction_type: string
  currency: { name: string; code: string } | null
  game_account: { account_name: string } | null
  quantity: number
  unit_price_vnd: number | null
  unit_price_usd: number | null
  creator: { display_name: string } | null
  notes: string | null
}> = [
  {
    title: 'Thời gian',
    key: 'created_at',
    width: 150,
    render: (row) => {
      const date = new Date(row.created_at)
      return date.toLocaleString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
      })
    },
  },
  {
    title: 'Loại',
    key: 'transaction_type',
    width: 100,
    render: (row) => {
      const display = typeDisplayMap[row.transaction_type] || {
        label: row.transaction_type,
        type: 'default',
      }
      return h(
        NTag,
        {
          type: display.type as 'info' | 'success' | 'warning' | 'error' | 'default',
          size: 'small',
        },
        { default: () => display.label }
      )
    },
  },
  {
    title: 'Currency',
    key: 'currency',
    width: 150,
    render: (row) => row.currency?.name || 'N/A',
  },
  {
    title: 'Số lượng',
    key: 'quantity',
    width: 100,
    align: 'right',
    render: (row) => {
      const isNegative = ['sale_delivery', 'exchange_out', 'farm_payout'].includes(
        row.transaction_type
      )
      const value = isNegative ? -Math.abs(row.quantity) : row.quantity
      return value.toLocaleString()
    },
  },
  {
    title: 'Giá (VND)',
    key: 'unit_price_vnd',
    width: 120,
    align: 'right',
    render: (row) =>
      row.unit_price_vnd ? Math.round(row.unit_price_vnd).toLocaleString('vi-VN') : 'N/A',
  },
  {
    title: 'Giá (USD)',
    key: 'unit_price_usd',
    width: 120,
    align: 'right',
    render: (row) => (row.unit_price_usd ? row.unit_price_usd.toFixed(2) : 'N/A'),
  },
  {
    title: 'Tổng giá trị',
    key: 'total_value',
    width: 150,
    align: 'right',
    render: (row) => {
      const totalVnd = row.quantity * (row.unit_price_vnd || 0)
      return totalVnd.toLocaleString('vi-VN') + ' VND'
    },
  },
  {
    title: 'Tài khoản',
    key: 'game_account',
    width: 150,
    render: (row) => row.game_account?.account_name || 'N/A',
  },
  {
    title: 'Người tạo',
    key: 'creator',
    width: 120,
    render: (row) => row.creator?.display_name || 'N/A',
  },
  {
    title: 'Ghi chú',
    key: 'notes',
    ellipsis: true,
    render: (row) => row.notes || '-',
  },
]

// Methods
const loadTransactions = async () => {
  if (!currentGame.value || !currentServer.value) {
    transactions.value = []
    return
  }

  loading.value = true
  try {
    transactions.value = await getTransactions({
      transactionType: filterType.value || undefined,
      limit: 100,
    })
  } catch (error) {
    console.error('Error loading transactions:', error)
    transactions.value = []
  } finally {
    loading.value = false
  }
}

const refreshTransactions = () => {
  loadTransactions()
}

// Watch for context changes
watch([currentGame, currentServer], () => {
  loadTransactions()
})

watch(filterType, () => {
  loadTransactions()
})

// Lifecycle
onMounted(() => {
  loadTransactions()
})
</script>
