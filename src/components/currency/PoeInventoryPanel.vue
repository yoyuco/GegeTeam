<!-- path: src/components/currency/PoeInventoryPanel.vue -->
<template>
  <div class="space-y-4">
    <!-- Search and Filter -->
    <div class="flex flex-col sm:flex-row gap-3">
      <n-input
        v-model:value="searchText"
        placeholder="Tìm kiếm currency..."
        class="flex-1"
        clearable
        @input="onSearchInput"
      >
        <template #prefix>
          <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
        </template>
      </n-input>
      <n-select
        v-model:value="sortBy"
        :options="sortOptions"
        placeholder="Sắp xếp"
        style="width: 150px"
        @update:value="onSortChange"
      />
    </div>

    <!-- Inventory Grid -->
    <div v-if="loading" class="flex justify-center py-8">
      <n-spin size="large" />
    </div>

    <div v-else-if="filteredInventory.length === 0" class="text-center py-8 text-gray-500">
      <svg
        class="w-12 h-12 mx-auto mb-3 text-gray-300"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293H9.414a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006 13H4"
        />
      </svg>
      <p>Không tìm thấy currency nào</p>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div
        v-for="item in filteredInventory"
        :key="item.currency"
        class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow cursor-pointer"
        @click="selectCurrency(item)"
      >
        <!-- Header -->
        <div class="bg-gradient-to-r from-blue-50 to-indigo-50 px-6 py-4 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                <svg
                  class="w-5 h-5 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              </div>
              <div>
                <h3 class="text-lg font-semibold text-gray-800">{{ item.currency }}</h3>
                <p class="text-sm text-blue-600 font-medium">Tổng: {{ item.total }} coins</p>
              </div>
            </div>
            <div class="text-right">
              <div class="text-xl font-bold text-blue-600">{{ item.total }}</div>
              <div class="text-sm text-gray-500">available</div>
            </div>
          </div>
        </div>

        <!-- Content -->
        <div class="p-6 space-y-4">
          <!-- Price Information -->
          <div class="grid grid-cols-2 gap-4">
            <div
              class="bg-gradient-to-r from-purple-50 to-pink-50 rounded-xl p-4 border border-purple-100"
            >
              <div class="flex items-center gap-2 mb-1">
                <div class="w-4 h-4 bg-purple-100 rounded flex items-center justify-center">
                  <svg class="w-2.5 h-2.5 text-purple-600" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M8.433 7.418c.155-.103.346-.196.567-.267v1.698a2.305 2.305 0 01-.567-.267C8.07 8.34 8 8.114 8 8c0-.114.07-.34.433-.582zM11 12.849v-1.698c.22.071.412.164.567.267.364.243.433.468.433.582 0 .114-.07.34-.433.582a2.305 2.305 0 01-.567.267z"
                    />
                    <path
                      fill-rule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-13a1 1 0 10-2 0v.092a4.535 4.535 0 00-1.676.662C6.602 6.234 6 7.009 6 8c0 .99.602 1.765 1.324 2.246.48.32 1.054.545 1.676.662v1.941c-.391-.127-.68-.317-.843-.504a1 1 0 10-1.51 1.31c.562.649 1.413 1.076 2.353 1.253V15a1 1 0 102 0v-.092a4.535 4.535 0 001.676-.662C13.398 13.766 14 12.991 14 12c0-.99-.602-1.765-1.324-2.246A4.535 4.535 0 0011 9.092V7.151c.391.127.68.317.843.504a1 1 0 101.511-1.31c-.563-.649-1.413-1.076-2.354-1.253V5z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </div>
                <div class="text-sm font-medium text-purple-700">Giá USD</div>
              </div>
              <div class="text-xl font-bold text-purple-900">${{ item.avgUSD }}</div>
            </div>
            <div
              class="bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl p-4 border border-green-100"
            >
              <div class="flex items-center gap-2 mb-1">
                <div class="w-4 h-4 bg-green-100 rounded flex items-center justify-center">
                  <svg class="w-2.5 h-2.5 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M8.433 7.418c.155-.103.346-.196.567-.267v1.698a2.305 2.305 0 01-.567-.267C8.07 8.34 8 8.114 8 8c0-.114.07-.34.433-.582zM11 12.849v-1.698c.22.071.412.164.567.267.364.243.433.468.433.582 0 .114-.07.34-.433.582a2.305 2.305 0 01-.567.267z"
                    />
                    <path
                      fill-rule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-13a1 1 0 10-2 0v.092a4.535 4.535 0 00-1.676.662C6.602 6.234 6 7.009 6 8c0 .99.602 1.765 1.324 2.246.48.32 1.054.545 1.676.662v1.941c-.391-.127-.68-.317-.843-.504a1 1 0 10-1.51 1.31c.562.649 1.413 1.076 2.353 1.253V15a1 1 0 102 0v-.092a4.535 4.535 0 001.676-.662C13.398 13.766 14 12.991 14 12c0-.99-.602-1.765-1.324-2.246A4.535 4.535 0 0011 9.092V7.151c.391.127.68.317.843.504a1 1 0 101.511-1.31c-.563-.649-1.413-1.076-2.354-1.253V5z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </div>
                <div class="text-sm font-medium text-green-700">Giá VND</div>
              </div>
              <div class="text-xl font-bold text-green-900">{{ formatVND(item.avgVND) }}</div>
            </div>
          </div>

          <!-- Stock Status -->
          <div
            class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl p-4 border border-blue-100"
          >
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 bg-blue-100 rounded-xl flex items-center justify-center">
                  <div class="w-3 h-3 rounded-full" :class="getStockStatus(item.total)"></div>
                </div>
                <div>
                  <div class="text-sm font-medium text-blue-700">Tồn kho</div>
                  <div class="text-lg font-bold text-blue-900">{{ item.total }} coins</div>
                </div>
              </div>
              <div class="text-right">
                <div class="text-sm text-gray-600">Sẵn sàng</div>
                <div class="text-lg font-bold text-green-600">{{ item.total - item.reserved }}</div>
              </div>
            </div>
            <div
              v-if="item.reserved > 0"
              class="flex items-center gap-2 mt-3 text-amber-600 bg-amber-50 rounded-lg p-2"
            >
              <svg
                class="w-4 h-4 text-amber-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
                />
              </svg>
              <span class="text-sm font-medium">{{ item.reserved }} coins đang được giữ</span>
            </div>
          </div>

          <!-- Account Details -->
          <div
            v-if="item.accounts && item.accounts.length > 0"
            class="bg-gradient-to-r from-gray-50 to-slate-50 rounded-xl p-4 border border-gray-200"
          >
            <div class="flex items-center gap-2 mb-3">
              <div class="w-4 h-4 bg-gray-100 rounded flex items-center justify-center">
                <svg class="w-2.5 h-2.5 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
                  <path
                    d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"
                  />
                </svg>
              </div>
              <div class="text-sm font-medium text-gray-700">Phân bố tài khoản</div>
            </div>
            <div class="space-y-2">
              <div
                v-for="acc in item.accounts.slice(0, 3)"
                :key="acc.name"
                class="flex items-center justify-between bg-white rounded-lg px-3 py-2 border border-gray-100"
              >
                <div class="flex items-center gap-2">
                  <div class="w-2 h-2 bg-blue-500 rounded-full"></div>
                  <span class="text-sm font-medium text-gray-800 truncate">{{ acc.name }}</span>
                </div>
                <span class="text-sm font-bold text-blue-600">{{ acc.amount }}</span>
              </div>
              <div
                v-if="item.accounts.length > 3"
                class="text-center text-sm text-gray-500 bg-white rounded-lg px-3 py-2 border border-gray-100"
              >
                +{{ item.accounts.length - 3 }} tài khoản khác
              </div>
            </div>
          </div>

          <!-- Select Button -->
          <n-button
            type="primary"
            size="medium"
            class="w-full bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 shadow-lg"
            :disabled="item.total - item.reserved === 0"
            @click.stop="selectCurrency(item)"
          >
            <template #icon>
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
                />
              </svg>
            </template>
            Chọn Currency
          </n-button>
        </div>
      </div>
    </div>

    <!-- Loading More -->
    <div v-if="hasMore && !loading" class="text-center py-4">
      <n-button :loading="loadingMore" @click="loadMore"> Tải thêm </n-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useMessage } from 'naive-ui'
import { useInventory } from '@/composables/useInventory.js'

// Define custom type for the item structure used in filteredInventory
interface CurrencyDisplayItem {
  currency: string
  total: number
  reserved: number
  avgVND: number
  avgUSD: number
  accounts: Array<{
    name: string
    amount: number
  }>
}

// Props
const props = defineProps({
  game: {
    type: String,
    required: true,
  },
  league: {
    type: String,
    required: true,
  },
  pageSize: {
    type: Number,
    default: 20,
  },
})

// Emits
const emit = defineEmits(['currency-selected'])

// Composables
const message = useMessage()
const { inventoryByCurrency, loadInventory, loading } = useInventory()

// State
const searchText = ref('')
const sortBy = ref('total')
const loadingMore = ref(false)
const currentPage = ref(1)
const hasMore = ref(false)

// Sort options
const sortOptions = [
  { label: 'Tổng số lượng', value: 'total' },
  { label: 'Giá USD', value: 'price_usd' },
  { label: 'Giá VND', value: 'price_vnd' },
  { label: 'Tên A-Z', value: 'name' },
]

// Computed
const inventoryData = computed(() => {
  if (!inventoryByCurrency.value || !props.game || !props.league) {
    return []
  }

  // inventoryByCurrency is an array, not an object with string keys
  return inventoryByCurrency.value || []
})

const filteredInventory = computed(() => {
  let data = [...inventoryData.value]

  // Filter by search text
  if (searchText.value) {
    const search = searchText.value.toLowerCase()
    data = data.filter((item) => item.currency.toLowerCase().includes(search))
  }

  // Sort
  data.sort((a, b) => {
    switch (sortBy.value) {
      case 'total':
        return b.total - a.total
      case 'price_usd':
        return b.avgUSD - a.avgUSD
      case 'price_vnd':
        return b.avgVND - a.avgVND
      case 'name':
        return a.currency.localeCompare(b.currency)
      default:
        return 0
    }
  })

  return data
})

// Methods
const getStockStatus = (total: number) => {
  if (total === 0) return 'bg-red-500'
  if (total < 10) return 'bg-amber-500'
  return 'bg-green-500'
}

const formatVND = (amount: number) => {
  return new Intl.NumberFormat('vi-VN').format(amount)
}

const selectCurrency = (item: CurrencyDisplayItem) => {
  if (item.total - item.reserved === 0) {
    message.warning('Currency này đã hết hàng')
    return
  }

  emit('currency-selected', {
    id: item.currency,
    name: item.currency,
    total: item.total,
    available: item.total - item.reserved,
    avgUSD: item.avgUSD,
    avgVND: item.avgVND,
    accounts: item.accounts,
  })
}

const onSearchInput = () => {
  currentPage.value = 1
}

const onSortChange = () => {
  currentPage.value = 1
}

const loadMore = async () => {
  loadingMore.value = true
  currentPage.value++

  try {
    // Load more data logic here
    hasMore.value = false // Update based on actual pagination
  } catch (error) {
    console.error('Error loading more inventory:', error)
    message.error('Không thể tải thêm dữ liệu')
  } finally {
    loadingMore.value = false
  }
}

// Watch for game/league changes
watch(
  [() => props.game, () => props.league],
  async ([newGame, newLeague]) => {
    if (newGame && newLeague) {
      currentPage.value = 1
      try {
        await loadInventory()
      } catch (error) {
        console.error('Error loading inventory:', error)
        message.error('Không thể tải dữ liệu inventory')
      }
    }
  },
  { immediate: true }
)

// Initialize
onMounted(async () => {
  if (props.game && props.league) {
    try {
      await loadInventory()
    } catch (error) {
      console.error('Error loading inventory on mount:', error)
      message.error('Không thể tải dữ liệu inventory')
    }
  }
})
</script>

<style scoped>
.inventory-panel {
  min-height: 400px;
}

/* Custom scrollbar for inventory grid */
.inventory-grid::-webkit-scrollbar {
  width: 6px;
}

.inventory-grid::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.inventory-grid::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.inventory-grid::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

/* Card hover effects */
.inventory-card {
  transition: all 0.2s ease;
}

.inventory-card:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

/* Stock status indicators */
.stock-high {
  background-color: #10b981;
}

.stock-medium {
  background-color: #f59e0b;
}

.stock-low {
  background-color: #ef4444;
}
</style>
