<!-- path: src/pages/CurrencyCreateOrders.vue -->
<template>
  <div class="min-h-0 bg-gray-50 p-6" :style="{ marginRight: isInventoryOpen ? '380px' : '0' }">
    <!-- Header -->
    <div class="mb-6">
      <div class="bg-gradient-to-r from-blue-600 to-indigo-600 text-white p-6 rounded-xl shadow-lg">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4">
            <div
              class="w-14 h-14 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm"
            >
              <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <div>
              <h1 class="text-2xl font-bold">Tạo đơn Currency</h1>
              <p class="text-blue-100 text-sm mt-1">{{ contextString }}</p>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <n-button
              type="primary"
              size="medium"
              class="bg-white/20 hover:bg-white/30 text-white border-white/30 backdrop-blur-sm"
              @click="isInventoryOpen = !isInventoryOpen"
            >
              <template #icon>
                <svg
                  v-if="!isInventoryOpen"
                  class="w-5 h-5"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                  />
                </svg>
                <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </template>
              {{ isInventoryOpen ? 'Đóng Inventory' : 'Xem Inventory' }}
            </n-button>
          </div>
        </div>
      </div>
    </div>

    <div class="mb-6">
      <GameLeagueSelector
        :initial-game="currentGame?.value"
        :initial-league="currentLeague?.value"
        @game-changed="onGameChanged"
        @league-changed="onLeagueChanged"
        @context-changed="onContextChanged"
      />
    </div>

    <div class="bg-white border border-gray-200 rounded-xl">
      <div class="flex">
        <button
          :class="[
            'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
            activeTab === 'sell'
              ? 'tab-active text-blue-600'
              : 'tab-inactive text-gray-500 hover:text-gray-700',
          ]"
          @click="activeTab = 'sell'"
        >
          <svg class="w-4 h-4 tab-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          Bán Currency
        </button>
        <button
          :class="[
            'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
            activeTab === 'purchase'
              ? 'tab-active text-green-600'
              : 'tab-inactive text-gray-500 hover:text-gray-700',
          ]"
          @click="activeTab = 'purchase'"
        >
          <svg class="w-4 h-4 tab-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          Mua Currency
        </button>
      </div>
    </div>

    <!-- Tab Content -->
    <div class="flex-1">
      <!-- Tab Bán Currency -->
      <div v-if="activeTab === 'sell'" class="tab-pane">
        <!-- Main Form Container with Border -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <!-- Main Content Grid - 2 Column Layout -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 p-6">
            <!-- Left Column - Customer Information -->
            <div class="space-y-6">
              <!-- Customer Information Card (no outer styling since parent has border) -->
              <div class="space-y-4">
                <div class="flex items-center gap-2">
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
                      d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                    />
                  </svg>
                  <h2 class="text-lg font-semibold text-gray-800">Thông tin khách hàng</h2>
                </div>
                <CustomerForm
                  v-model="customerFormData"
                  :channels="salesChannels"
                  :initial-channel-id="customerFormData.channelId"
                  @customer-changed="onCustomerChanged"
                  @game-tag-changed="onGameTagChanged"
                />
              </div>
            </div>

            <!-- Right Column - Currency Information -->
            <div class="space-y-6">
              <!-- Currency Information Card (no outer styling since parent has border) -->
              <div class="space-y-4">
                <div class="flex items-center gap-2">
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
                  <h2 class="text-lg font-semibold text-gray-800">Thông tin Currency</h2>
                </div>
                <CurrencyForm
                  ref="currencyFormRef"
                  :key="`${currentGame?.value}-${currentLeague?.value}`"
                  transaction-type="sale"
                  :game-code="currentGame?.value"
                  :league-id="currentLeague?.value"
                  :currencies="filteredCurrencies"
                  :loading="currenciesLoading"
                  :show-account-field="false"
                  :initial-currency-id="saleData.currencyId"
                  @currency-changed="onCurrencyChanged"
                  @quantity-changed="onQuantityChanged"
                  @price-changed="onPriceChanged"
                />
              </div>
            </div>
          </div>

          <!-- Exchange Information Section - Only for Sell Tab -->
          <div v-if="activeTab === 'sell'" class="border-t border-gray-200">
            <div class="p-6">
              <div class="flex items-center gap-2 mb-4">
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
                    d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"
                  />
                </svg>
                <h2 class="text-lg font-semibold text-gray-800">Loại hình chuyển đổi</h2>
              </div>
              <div class="grid grid-cols-1 lg:grid-cols-12 gap-4">
                <!-- Radio Buttons -->
                <div class="lg:col-span-1">
                  <label class="block text-sm font-medium text-gray-700 mb-3">Hình thức</label>
                  <n-radio-group
                    v-model:value="exchangeData.type"
                    name="exchangeType"
                    class="space-y-2"
                  >
                    <div class="flex flex-col gap-2">
                      <n-radio value="none" class="flex items-center">
                        <span class="font-medium">Không</span>
                      </n-radio>
                      <n-radio value="items" class="flex items-center">
                        <span class="font-medium">Items</span>
                      </n-radio>
                      <n-radio value="service" class="flex items-center">
                        <span class="font-medium">Service</span>
                      </n-radio>
                      <n-radio value="farmer" class="flex items-center">
                        <span class="font-medium">Farmer</span>
                      </n-radio>
                    </div>
                  </n-radio-group>
                </div>

                <!-- Exchange Type Input -->
                <div class="lg:col-span-9">
                  <label class="block text-sm font-medium text-gray-700 mb-2"
                    >Loại chuyển đổi</label
                  >
                  <n-input
                    v-model:value="exchangeData.exchangeType"
                    :placeholder="getExchangeTypePlaceholder()"
                    :disabled="exchangeData.type === 'none'"
                    size="large"
                    type="textarea"
                    :rows="2"
                    resize="none"
                  />
                  <p class="text-xs text-gray-500 mt-1">
                    {{ getExchangeTypeExample() }}
                  </p>
                </div>

                <!-- Image Upload -->
                <div class="lg:col-span-2">
                  <label class="block text-sm font-medium text-gray-700 mb-2">Hình ảnh</label>
                  <n-upload
                    v-model:file-list="fileList"
                    :max="10"
                    multiple
                    list-type="image-card"
                    :default-upload="false"
                    :on-remove="handleFileRemove"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab Mua Currency -->
      <div v-if="activeTab === 'purchase'" class="tab-pane">
        <!-- Main Form Container with Border -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <!-- Main Content Grid - 2 Column Layout -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 p-6">
            <!-- Left Column - Supplier Information -->
            <div class="space-y-6">
              <!-- Supplier Information Card (no outer styling since parent has border) -->
              <div class="space-y-4">
                <div class="flex items-center gap-2">
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
                      d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                    />
                  </svg>
                  <h2 class="text-lg font-semibold text-gray-800">Thông tin Nhà cung cấp</h2>
                </div>
                <CustomerForm
                  v-model="supplierFormData"
                  :channels="purchaseChannels"
                  :form-mode="'supplier'"
                  :initial-channel-id="supplierFormData.channelId"
                  @customer-changed="onSupplierChanged"
                  @game-tag-changed="onSupplierGameTagChanged"
                />
              </div>
            </div>

            <!-- Right Column - Currency Information -->
            <div class="space-y-6">
              <!-- Currency Information Card (no outer styling since parent has border) -->
              <div class="space-y-4">
                <div class="flex items-center gap-2">
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
                  <h2 class="text-lg font-semibold text-gray-800">Thông tin Currency</h2>
                </div>
                <CurrencyForm
                  ref="purchaseCurrencyFormRef"
                  :key="`${currentGame?.value}-${currentLeague?.value}`"
                  transaction-type="purchase"
                  :game-code="currentGame?.value"
                  :league-id="currentLeague?.value"
                  :currencies="filteredCurrencies"
                  :loading="currenciesLoading"
                  :show-account-field="false"
                  :initial-currency-id="purchaseData.currencyId"
                  @currency-changed="onPurchaseCurrencyChanged"
                  @quantity-changed="onPurchaseQuantityChanged"
                  @price-changed="onPurchasePriceChanged"
                />
              </div>
            </div>
          </div>

          <!-- Evidence Upload Section - Only for Purchase Tab -->
          <div v-if="activeTab === 'purchase'" class="border-t border-gray-200 p-6">
            <div class="flex items-center gap-2 mb-4">
              <svg
                class="w-5 h-5 text-blue-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                />
              </svg>
              <h2 class="text-lg font-semibold text-gray-800">Bằng chứng mua hàng</h2>
            </div>
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <!-- Upload Evidence -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-3"
                  >Upload bằng chứng</label
                >
                <n-upload
                  v-model:file-list="purchaseFileList"
                  :max="10"
                  multiple
                  list-type="image-card"
                  :default-upload="false"
                  :on-remove="handlePurchaseFileRemove"
                  class="w-full"
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Form Control Buttons -->
      <div class="mt-4 flex justify-end gap-3">
        <n-button size="large" class="px-6" @click="handleCurrencyFormReset">
          <template #icon>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
              />
            </svg>
          </template>
          Làm mới
        </n-button>
        <n-button
          type="primary"
          size="large"
          :class="[
            'px-8',
            activeTab === 'purchase'
              ? 'bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800'
              : 'bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800',
          ]"
          :loading="saving"
          @click="handleCurrencyFormSubmit"
        >
          <template #icon>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M5 13l4 4L19 7"
              />
            </svg>
          </template>
          {{ activeTab === 'sell' ? 'Tạo Đơn Bán' : 'Tạo Đơn Mua' }}
        </n-button>
      </div>

      <!-- Inventory Panel as true sidebar -->
      <CurrencyInventoryPanel
        v-if="isInventoryOpen"
        :is-open="isInventoryOpen"
        :inventory-data="inventoryByCurrency"
        @close="isInventoryOpen = false"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch, nextTick } from 'vue'
import { useMessage } from 'naive-ui'
import { NButton, NInput, NUpload, NRadioGroup, NRadio } from 'naive-ui'
import CustomerForm from '@/components/CustomerForm.vue'
import CurrencyForm from '@/components/currency/CurrencyForm.vue'
import GameLeagueSelector from '@/components/currency/GameLeagueSelector.vue'
import CurrencyInventoryPanel from '@/components/currency/CurrencyInventoryPanel.vue'
import { useGameContext } from '@/composables/useGameContext.js'
import { useCurrency } from '@/composables/useCurrency.js'
import { useInventory } from '@/composables/useInventory.js'
import { supabase } from '@/lib/supabase'
import { uploadFile } from '@/utils/supabase.js'
import type { Currency, Channel } from '@/types/composables.d'

// Game context
const { currentGame, currentLeague, contextString, initializeFromStorage } = useGameContext()

// Currency composable - now unified with all functionality
const {
  loadChannels,
  salesChannels,
  purchaseChannels,
  allCurrencies,
  loadAllCurrencies,
  loading: currenciesLoading,
} = useCurrency()

// Inventory composable
const { loadInventory, inventoryByCurrency } = useInventory()

// Filtered currencies based on current game - now using the unified composable
const filteredCurrencies = computed(() => {
  // Don't show any options if currencies are still loading
  if (areCurrenciesLoading.value || !allCurrencies.value || !currentGame?.value) {
    return []
  }

  const filtered = allCurrencies.value.filter((currency: Currency) => {
    // Filter by current game code - use exact matching
    if (currentGame.value === 'POE_2') {
      return currency.gameVersion === 'POE2' // Only POE_2 currencies
    }
    if (currentGame.value === 'POE_1') {
      return currency.gameVersion === 'POE1'
    }
    if (currentGame.value === 'DIABLO_4') {
      return currency.gameVersion === 'D4'
    }
    return true
  })

  return filtered.map((currency: Currency) => ({
    // Use safe property access with fallbacks to prevent undefined/null values
    label: currency.name || currency.code || `Currency ${currency.id.slice(0, 8)}...`,
    value: currency.id,
    data: currency,
  }))
})

// UI State
const message = useMessage()
const isInventoryOpen = ref(false)
const saving = ref(false)
const currencyFormRef = ref()
const activeTab = ref<'sell' | 'purchase'>('sell')
const purchaseSaving = ref(false)
const isDataLoading = ref(false)
const areCurrenciesLoading = ref(false)

// Form data
const customerFormData = ref({
  channelId: null as string | null,
  customerName: '',
  gameTag: '',
  deliveryInfo: '',
})

const saleData = reactive({
  currencyId: null as string | null,
  quantity: null as number | null,
  pricePerUnit: null as number | null,
  totalPrice: null as number | null,
})

// Purchase data
const supplierFormData = ref({
  channelId: null as string | null,
  customerName: '',
  gameTag: '',
  deliveryInfo: '',
})

const purchaseData = reactive({
  currencyId: null as string | null,
  quantity: null as number | null,
  pricePerUnit: null as number | null,
  totalPrice: null as number | null,
  totalPriceVND: null as number | null, // ← Total cost amount - goes to cost_amount field
  totalPriceUSD: null as number | null, // ← Option cho USD (nếu cần trong tương lai)
  notes: null as string | null,
})

// Supplier information for purchase orders
const supplierData = reactive({
  supplierId: null as string | null, // UUID from parties table
  supplierName: null as string | null,
  supplierContact: null as string | null, // Contact info from "Thông tin liên hệ" field
  supplierCharacterName: null as string | null, // Character name from "Tên nhân vật / ID" field
  isExistingSupplier: true,
})

const purchaseCurrencyFormRef = ref()

// Computed properties for purchase form
const purchaseTotalValue = computed(() => {
  return purchaseData.totalPriceVND || 0
})

// Calculate unit price from total price and quantity
const purchaseUnitPrice = computed(() => {
  if (!purchaseData.quantity || !purchaseData.totalPriceVND) return 0
  return purchaseData.totalPriceVND / purchaseData.quantity
})

const purchaseFormValid = computed(() => {
  return (
    supplierFormData.value.channelId &&
    purchaseData.currencyId &&
    purchaseData.quantity &&
    purchaseData.quantity > 0 &&
    purchaseData.totalPriceVND &&
    purchaseData.totalPriceVND > 0
  )
})

// Computed property for formatted currency display
const formattedPurchaseTotal = computed(() => {
  return formatCurrency(purchaseTotalValue.value)
})

// Detect which currency is being used for cost
const purchaseCostCurrency = computed(() => {
  if (purchaseData.totalPriceUSD && purchaseData.totalPriceUSD > 0) {
    return 'USD'
  }
  return 'VND' // Default to VND
})

// Get cost amount based on selected currency
const purchaseCostAmount = computed(() => {
  if (purchaseCostCurrency.value === 'USD' && purchaseData.totalPriceUSD) {
    return purchaseData.totalPriceUSD
  }
  return purchaseData.totalPriceVND || 0 // Default to VND
})

// Purchase evidence data
const purchaseEvidenceData = reactive({
  notes: '',
  images: [] as string[],
})

// Purchase file upload
const purchaseFileList = ref([])

// Exchange data for sell tab
const exchangeData = reactive({
  type: 'none',
  exchangeType: '',
  exchangeImages: [] as string[],
})

// Exchange file upload
const fileList = ref([])

// Initialize game context
onMounted(async () => {
  try {
    await initializeFromStorage()

    if (currentGame.value && currentLeague.value) {
      await loadData()
    }
  } catch {
    message.error('Không thể khởi tạo dữ liệu')
  }
})

// Watch for tab changes to auto-select values - optimized for smooth transitions
watch(activeTab, (newTab) => {
  // Only handle when data is available and not loading
  if (isDataLoading.value) return

  if (newTab === 'purchase' && purchaseChannels.value.length > 0) {
    // Batch update to minimize reactivity triggers
    const updates: {
      channelId?: string
      currencyId?: string
    } = {}

    // Auto-select Facebook channel when switching to purchase tab
    if (!supplierFormData.value.channelId) {
      const facebookChannel = purchaseChannels.value.find(
        (channel: Channel) =>
          channel.name?.toLowerCase().includes('facebook') ||
          channel.displayName?.toLowerCase().includes('facebook') ||
          channel.code?.toLowerCase().includes('facebook')
      )

      if (facebookChannel) {
        updates.channelId = facebookChannel.id
      }
    }

    // Auto-select first currency if not already selected
    if (!purchaseData.currencyId && filteredCurrencies.value.length > 0) {
      updates.currencyId = filteredCurrencies.value[0].value
    }

    // Apply all updates at once
    if (updates.channelId) {
      supplierFormData.value.channelId = updates.channelId
    }
    if (updates.currencyId) {
      purchaseData.currencyId = updates.currencyId
    }
  }
})

// Load all necessary data
const loadData = async () => {
  try {
    isDataLoading.value = true
    areCurrenciesLoading.value = true // Start currency loading
    console.log('🔄 Loading all data...')

    await Promise.all([loadChannels(), loadInventory(), loadAllCurrencies()])

    // Use nextTick to ensure DOM updates happen smoothly
    await nextTick()

    console.log('✅ All data loaded successfully')
    console.log('📊 Sales channels available:', salesChannels.value.length)
    console.log('📊 Purchase channels available:', purchaseChannels.value.length)
    console.log('📋 Currencies available:', filteredCurrencies.value.length)

    // Set default selections immediately after data is loaded
    await setDefaultSelectionsAsync()

    // Log auto-selection results after setting
    if (supplierFormData.value.channelId) {
      const selectedChannel = purchaseChannels.value.find(
        (c: Channel) => c.id === supplierFormData.value.channelId
      )
      console.log('🎯 Auto-selected purchase channel:', selectedChannel?.name)
    }
    if (purchaseData.currencyId) {
      const selectedCurrency = filteredCurrencies.value.find(
        (c: { value: string; label: string }) => c.value === purchaseData.currencyId
      )
      console.log('🎯 Auto-selected purchase currency:', selectedCurrency?.label)
    }
  } catch {
    message.error('Không thể tải dữ liệu')
  } finally {
    isDataLoading.value = false
    areCurrenciesLoading.value = false // Currency loading complete
  }
}

// Watch for channel changes to load suppliers
watch(
  () => supplierFormData.value.channelId,
  async (newChannelId) => {
    if (newChannelId && currentGame.value) {
      const suppliers = await loadSuppliersForChannel()
      console.log('📋 Loaded suppliers for channel:', suppliers.length)
    }
  }
)

// Async version of setDefaultSelections with nextTick for smooth transitions
const setDefaultSelectionsAsync = async () => {
  // Only update if we have data available
  if (filteredCurrencies.value.length === 0) return

  const firstCurrency = filteredCurrencies.value[0].value

  // Use nextTick to ensure DOM is updated after state changes
  await nextTick()

  // Batch all updates to minimize reactivity triggers
  const updates: {
    saleCurrency?: string
    sellChannelId?: string
    purchaseChannelId?: string
    purchaseCurrencyId?: string
  } = {}

  // Sell tab updates
  if (filteredCurrencies.value.length > 0 && !saleData.currencyId) {
    updates.saleCurrency = firstCurrency
  }

  // Sell channel updates
  if (salesChannels.value.length > 0 && !customerFormData.value.channelId) {
    const g2gChannel = salesChannels.value.find(
      (channel: Channel) =>
        channel.name?.toLowerCase().includes('g2g') ||
        channel.displayName?.toLowerCase().includes('g2g') ||
        channel.code?.toLowerCase().includes('g2g')
    )
    updates.sellChannelId = g2gChannel?.id || (salesChannels.value[0] as Channel)?.id
  }

  // Purchase tab updates
  if (purchaseChannels.value.length > 0) {
    if (!supplierFormData.value.channelId) {
      const facebookChannel = purchaseChannels.value.find(
        (channel: Channel) =>
          channel.name?.toLowerCase().includes('facebook') ||
          channel.displayName?.toLowerCase().includes('facebook') ||
          channel.code?.toLowerCase().includes('facebook')
      )
      updates.purchaseChannelId = facebookChannel?.id || (purchaseChannels.value[0] as Channel)?.id
    }

    if (!purchaseData.currencyId) {
      updates.purchaseCurrencyId = firstCurrency
    }
  }

  // Apply all updates at once to minimize flickering
  if (updates.saleCurrency) saleData.currencyId = updates.saleCurrency
  if (updates.sellChannelId) customerFormData.value.channelId = updates.sellChannelId
  if (updates.purchaseChannelId) supplierFormData.value.channelId = updates.purchaseChannelId
  if (updates.purchaseCurrencyId) purchaseData.currencyId = updates.purchaseCurrencyId

  // Wait for one more tick to ensure DOM is fully updated
  await nextTick()
}

// Event handlers
const onCustomerChanged = (customer: { name: string } | null) => {
  if (customer) {
    customerFormData.value.customerName = customer.name
  } else {
    customerFormData.value.customerName = ''
  }
}

const onGameTagChanged = (gameTag: string) => {
  customerFormData.value.gameTag = gameTag
}

const onCurrencyChanged = (currencyId: string | null) => {
  saleData.currencyId = currencyId
}

const onQuantityChanged = (quantity: number) => {
  saleData.quantity = quantity
  calculateTotal()
}

const onPriceChanged = (price: { vnd?: number; usd?: number }) => {
  saleData.pricePerUnit = price.vnd || null
  calculateTotal()
}

// Game & League selector event handlers
const onGameChanged = async () => {
  // Reset all forms when game changes
  resetAllForms()
  // Data will be reloaded automatically by useGameContext
}

const onLeagueChanged = async () => {
  // Reset all forms when league changes
  resetAllForms()
  // Data will be reloaded automatically by useGameContext
}

const onContextChanged = async (context: { hasContext: boolean }) => {
  if (context.hasContext) {
    await loadData()
  } else {
    // Reset forms when no context
    resetAllForms()
  }
}

// Purchase event handlers
const onSupplierChanged = (supplier: { name: string } | null) => {
  if (supplier) {
    supplierData.supplierName = supplier.name
    // Also update customerFormData for CustomerForm component
    supplierFormData.value.customerName = supplier.name
  } else {
    supplierData.supplierName = null
    supplierFormData.value.customerName = ''
  }
}

const onSupplierGameTagChanged = (gameTag: string) => {
  // Map supplier character name to supplierData (for delivery_info field)
  supplierData.supplierCharacterName = gameTag // This is character name for p_delivery_info
  // Also update customerFormData for CustomerForm component
  supplierFormData.value.gameTag = gameTag
}

// Watch for delivery info changes in supplierFormData
watch(
  () => supplierFormData.value.deliveryInfo,
  (newDeliveryInfo) => {
    supplierData.supplierContact = newDeliveryInfo // This is contact info for p_supplier_contact
  }
)

const onPurchaseCurrencyChanged = (currencyId: string | null) => {
  purchaseData.currencyId = currencyId
}

const onPurchaseQuantityChanged = (quantity: number) => {
  purchaseData.quantity = quantity
  calculatePurchaseTotal(purchaseData.quantity, purchaseData.totalPriceVND)
  // Update pricePerUnit when quantity changes
  if (purchaseData.totalPriceVND && quantity) {
    purchaseData.pricePerUnit = purchaseData.totalPriceVND / quantity
  } else {
    purchaseData.pricePerUnit = null
  }
}

const onPurchasePriceChanged = (price: { vnd?: number; usd?: number }) => {
  purchaseData.totalPriceVND = price.vnd || null
  purchaseData.totalPriceUSD = price.usd || null
  // Update pricePerUnit for compatibility with existing components
  if (purchaseData.quantity && price.vnd) {
    purchaseData.pricePerUnit = price.vnd / purchaseData.quantity
  } else {
    purchaseData.pricePerUnit = null
  }
  calculatePurchaseTotal(purchaseData.quantity, purchaseData.totalPriceVND)
}

// Clear cache when game/league changes
const clearBuyOrdersCache = () => {
  buyOrdersCache = []
  lastCacheTime = 0
}

// Reset all forms when game/league changes
const resetAllForms = () => {
  // Clear cache
  clearBuyOrdersCache()

  // Reset both currency forms
  if (currencyFormRef.value) {
    currencyFormRef.value.resetForm()
  }
  if (purchaseCurrencyFormRef.value) {
    purchaseCurrencyFormRef.value.resetForm()
  }

  // Reset sale data
  Object.assign(saleData, {
    currencyId: null,
    quantity: null,
    pricePerUnit: null,
    totalPrice: null,
  })

  // Reset purchase data
  Object.assign(purchaseData, {
    currencyId: null,
    quantity: null,
    pricePerUnit: null,
    totalPrice: null,
  })

  // Reset customer form data
  Object.assign(customerFormData, {
    channelId: null,
    customerName: '',
    gameTag: '',
    deliveryInfo: '',
    notes: '',
  })

  // Reset supplier form data
  Object.assign(supplierFormData, {
    channelId: null,
    customerName: '',
    gameTag: '',
    deliveryInfo: '',
  })

  // Reset purchase evidence data
  Object.assign(purchaseEvidenceData, {
    notes: '',
    images: [],
  })

  // Reset exchange data
  Object.assign(exchangeData, {
    type: 'none',
    exchangeType: '',
    exchangeImages: [],
  })

  // Reset file lists
  fileList.value = []
  purchaseFileList.value = []
}

// Calculate total price
const calculateTotal = () => {
  if (saleData.quantity && saleData.pricePerUnit) {
    saleData.totalPrice = saleData.quantity * saleData.pricePerUnit
  } else {
    saleData.totalPrice = null
  }
}

// Get exchange type placeholder based on selected type
const getExchangeTypePlaceholder = () => {
  switch (exchangeData.type) {
    case 'items':
      return 'Ring name'
    case 'service':
      return 'Ascendancy 4th'
    case 'farmer':
      return 'Tên farmer, thời gian farm...'
    default:
      return 'Nhập loại chuyển đổi'
  }
}

// Get exchange type example based on selected type
const getExchangeTypeExample = () => {
  switch (exchangeData.type) {
    case 'items':
      return 'VD: Ring name'
    case 'service':
      return 'VD: Ascendancy 4th'
    case 'farmer':
      return 'VD: FarmerABC, 2 giờ'
    default:
      return 'VD: Ring name'
  }
}

// Currency form methods
const handleCurrencyFormSubmit = async () => {
  // Get the correct form ref based on active tab
  const currentFormRef =
    activeTab.value === 'purchase' ? purchaseCurrencyFormRef.value : currencyFormRef.value

  if (!currentFormRef) {
    console.error('Form ref not found for tab:', activeTab.value)
    return
  }

  try {
    // Validate form first
    const errors = currentFormRef.validateForm()
    if (errors.length > 0) {
      message.error(errors.join(', '))
      return
    }

    // Handle based on active tab
    if (activeTab.value === 'purchase') {
      // Purchase order submission
      if (!supplierFormData.value.channelId) {
        message.error('Vui lòng chọn kênh mua hàng')
        return
      }

      if (!supplierData.supplierName) {
        message.error('Vui lòng nhập tên nhà cung cấp')
        return
      }

      // Validate league/season selection - required for all games
      if (!currentLeague.value) {
        const leagueSeasonName = currentGame.value === 'DIABLO_4' ? 'season' : 'league'
        message.error(
          `Vui lòng chọn ${leagueSeasonName} cho ${currentGame.value === 'DIABLO_4' ? 'Diablo 4' : currentGame.value === 'POE_1' ? 'Path of Exile 1' : 'Path of Exile 2'}`
        )
        return
      }

      // Use the purchase submit logic
      await _handlePurchaseSubmit()
    } else {
      // Sale order submission (original logic)
      // Validate customer data
      if (!customerFormData.value.customerName || !customerFormData.value.gameTag) {
        message.error('Vui lòng điền đầy đủ thông tin khách hàng')
        return
      }

      // Validate league/season selection - required for all games
      if (!currentLeague.value) {
        const leagueSeasonName = currentGame.value === 'DIABLO_4' ? 'season' : 'league'
        message.error(
          `Vui lòng chọn ${leagueSeasonName} cho ${currentGame.value === 'DIABLO_4' ? 'Diablo 4' : currentGame.value === 'POE_1' ? 'Path of Exile 1' : 'Path of Exile 2'}`
        )
        return
      }

      // Save the sale
      await saveSale()
    }
  } catch {
    const errorMessage =
      activeTab.value === 'purchase'
        ? 'Đã có lỗi xảy ra khi tạo đơn mua'
        : 'Đã có lỗi xảy ra khi tạo đơn bán'
    message.error(errorMessage)
  }
}

const handleCurrencyFormReset = () => {
  // Get the correct form ref based on active tab
  const currentFormRef =
    activeTab.value === 'purchase' ? purchaseCurrencyFormRef.value : currencyFormRef.value

  if (!currentFormRef) return

  currentFormRef.resetForm()

  // Reset data based on active tab
  if (activeTab.value === 'purchase') {
    // Reset purchase data
    purchaseData.currencyId = null
    purchaseData.quantity = null
    purchaseData.pricePerUnit = null
    purchaseData.totalPrice = null
    purchaseData.totalPriceVND = null
    purchaseData.totalPriceUSD = null
    purchaseData.notes = null

    // Reset supplier data
    supplierData.supplierId = null
    supplierData.supplierName = null
    supplierData.supplierContact = null
    supplierData.supplierCharacterName = null
    supplierData.isExistingSupplier = true
  } else {
    // Reset sale data (original logic)
    saleData.currencyId = null
    saleData.quantity = null
    saleData.pricePerUnit = null
    saleData.totalPrice = null
  }
}

// Save sale
const saveSale = async () => {
  if (!currencyFormRef.value) return

  const formData = currencyFormRef.value.formData

  if (!formData.currencyId || !formData.quantity) {
    message.warning('Vui lòng điền đầy đủ thông tin currency')
    return
  }

  if (!customerFormData.value.customerName || !customerFormData.value.gameTag) {
    message.warning('Vui lòng nhập thông tin khách hàng')
    return
  }

  // Validate league/season selection - required for all games
  if (!currentLeague.value) {
    const leagueSeasonName = currentGame.value === 'DIABLO_4' ? 'season' : 'league'
    message.error(
      `Vui lòng chọn ${leagueSeasonName} cho ${currentGame.value === 'DIABLO_4' ? 'Diablo 4' : currentGame.value === 'POE_1' ? 'Path of Exile 1' : 'Path of Exile 2'}`
    )
    return
  }

  saving.value = true
  try {
    // Dynamic currency detection for sale
    const saleCostCurrency = formData.unitPriceUsd && formData.unitPriceUsd > 0 ? 'USD' : 'VND'
    const saleCostAmount =
      saleCostCurrency === 'USD' && formData.unitPriceUsd
        ? formData.unitPriceUsd
        : formData.unitPriceVnd || 0

    // Prepare payload for API call with new structure
    const payload = {
      p_currency_attribute_id: formData.currencyId,
      p_quantity: Number(formData.quantity),
      p_sale_amount: Number(saleCostAmount), // Total sale amount (not unit price)
      p_sale_currency_code: saleCostCurrency, // Dynamic currency code
      p_game_code: currentGame.value,
      p_league_attribute_id: currentLeague.value,
      p_channel_id: customerFormData.value.channelId,
      p_customer_name: customerFormData.value.customerName,
      p_customer_game_tag: customerFormData.value.gameTag,
      p_delivery_info: customerFormData.value.deliveryInfo,
      p_sales_notes: formData.notes || '',
    }

    // Include exchange data in payload
    if (exchangeData.type !== 'none') {
      const exchangeTypeText =
        exchangeData.type === 'items'
          ? 'Items'
          : exchangeData.type === 'service'
            ? 'Service'
            : exchangeData.type === 'farmer'
              ? 'Farmer'
              : exchangeData.type
      const exchangeText = `Loại hình: ${exchangeTypeText} - ${exchangeData.exchangeType}`
      payload.p_sales_notes = payload.p_sales_notes
        ? `${payload.p_sales_notes}\n${exchangeText}`
        : exchangeText
    }

    // Call the new RPC function to create sell order
    const { data, error } = await supabase.rpc('create_currency_sell_order', payload)

    if (error) {
      console.error('❌ Error creating SELL order:', error)
      throw new Error(`Không thể tạo đơn bán: ${error.message}`)
    }

    // Check if function returned success
    if (data && data.length > 0 && data[0].success) {
      console.log('✅ SELL order created successfully:', data[0])
      message.success(`Tạo đơn bán thành công! Order #${data[0].order_number}`)

      // Upload proof images if any
      const orderId = data[0].order_number || data[0].id
      if (fileList.value && fileList.value.length > 0) {
        try {
          console.log('📤 Uploading sell order proof images...')
          const uploadedImages = await uploadImages(fileList.value, orderId, 'sell')

          if (uploadedImages.length > 0) {
            // Update order with proof image URLs by updating the notes
            const proofUrls = uploadedImages.map((img) => img.publicUrl).join(', ')
            const proofText = `\n\n📎 Hình bằng chứng chuyển đổi:\n${proofUrls}`

            // Add proof URLs to existing notes
            const updatedNotes = payload.p_sales_notes
              ? `${payload.p_sales_notes}${proofText}`
              : proofText

            // Update the order with proof URLs in notes
            await supabase
              .from('currency_orders')
              .update({ notes: updatedNotes })
              .eq('order_number', orderId)

            console.log('✅ Proof images uploaded and order updated with proof URLs')
          }
        } catch (uploadError) {
          console.error('❌ Failed to upload proof images:', uploadError)
          // Don't fail the entire order creation, just log the error
          message.warning('Đơn đã được tạo nhưng không thể upload hình bằng chứng')
        }
      }
    } else {
      const errorMessage = data && data.length > 0 ? data[0].message : 'Unknown error'
      throw new Error(`Tạo đơn bán thất bại: ${errorMessage}`)
    }

    // Reset form after successful submission
    handleCurrencyFormReset()
    Object.assign(customerFormData.value, {
      channelId: null,
      customerName: '',
      gameTag: '',
      deliveryInfo: '',
    })

    // Reset exchange data
    Object.assign(exchangeData, {
      type: 'none',
      exchangeType: '',
      exchangeImages: [],
    })

    // Reset file lists after successful submission
    fileList.value = []
  } catch {
    message.error('Không thể tạo đơn bán')
  } finally {
    saving.value = false
  }
}

// Watch for game/league changes to reload inventory
watch([currentGame, currentLeague], async () => {
  // Only proceed if we have both game and league
  if (!currentGame.value || !currentLeague.value) return

  console.log('🔄 Game/League changed, resetting and reloading data...')

  // Reset forms - this will set currencyId to null briefly
  resetAllForms()

  // Immediately load new data to minimize flicker
  await loadData()
})

// Image upload handlers for n-upload
const handleFileRemove = () => {
  // File is automatically removed from fileList by n-upload
  // Just sync with exchangeData if needed
}

// Purchase file upload handlers
const handlePurchaseFileRemove = () => {
  // File is automatically removed from purchaseFileList by n-upload
  // Just sync with purchaseEvidenceData if needed
}

// Upload images to Supabase Storage
const uploadImages = async (
  files: Array<{ file?: File; name?: string }>,
  orderId: string,
  type: 'sell' | 'purchase' = 'sell'
) => {
  if (!files || files.length === 0) {
    return []
  }

  const uploadPromises = files.map(async (fileItem) => {
    try {
      // Get the actual file from n-upload file item
      const file = fileItem.file || fileItem
      if (!file) {
        console.warn('No file found in file item:', fileItem)
        return null
      }

      // Create unique filename with timestamp
      const timestamp = Date.now()
      const filename = `${timestamp}-${file.name}`
      const filePath = `currency-orders/${orderId}/${type}-proofs/${filename}`

      console.log(`📤 Uploading ${type} proof:`, filename)

      // Upload to work-proofs bucket
      const uploadResult = await uploadFile(file, filePath, 'work-proofs')

      if (uploadResult.success) {
        console.log(`✅ Uploaded ${type} proof successfully:`, uploadResult.publicUrl)
        return {
          path: uploadResult.path,
          publicUrl: uploadResult.publicUrl,
          filename: file.name,
          type: type,
        }
      } else {
        console.error(`❌ Failed to upload ${type} proof:`, uploadResult.error)
        throw new Error(`Upload failed: ${uploadResult.error}`)
      }
    } catch (error) {
      console.error(`❌ Error uploading ${type} proof:`, error)
      throw error
    }
  })

  try {
    const results = await Promise.all(uploadPromises)
    // Filter out null results from failed uploads
    return results.filter((result) => result !== null)
  } catch (error) {
    console.error(`❌ Batch upload failed for ${type} proofs:`, error)
    const errorMessage = error instanceof Error ? error.message : 'Unknown error'
    throw new Error(`Failed to upload ${type} proof images: ${errorMessage}`)
  }
}

// Debounced validation for performance
let validationTimeout: number | null = null

const debouncedValidation = () => {
  if (validationTimeout) {
    clearTimeout(validationTimeout)
  }

  validationTimeout = window.setTimeout(() => {
    const validation = validatePurchaseForm()
    if (!validation.isValid) {
      // You can show validation errors in UI here
      console.warn('Form validation errors:', validation.errors)
    }
  }, 300)
}

// Utility functions for purchase form
const calculatePurchaseTotal = (quantity: number | null, totalPrice: number | null) => {
  // Since we're now using total price directly, just store it
  purchaseData.totalPrice = totalPrice
  // Update pricePerUnit for display purposes
  if (quantity && totalPrice) {
    purchaseData.pricePerUnit = totalPrice / quantity
  } else {
    purchaseData.pricePerUnit = null
  }

  // Trigger debounced validation after calculation
  debouncedValidation()
}

const validatePurchaseForm = () => {
  const errors = []

  if (!supplierFormData.value.channelId) {
    errors.push('Vui lòng chọn kênh mua hàng')
  }
  if (!purchaseData.currencyId) {
    errors.push('Vui lòng chọn loại currency')
  }
  if (!purchaseData.quantity || purchaseData.quantity <= 0) {
    errors.push('Số lượng phải lớn hơn 0')
  }
  if (!purchaseData.totalPriceVND || purchaseData.totalPriceVND <= 0) {
    errors.push('Tổng giá trị phải lớn hơn 0')
  }
  if (purchaseData.totalPriceVND && purchaseData.totalPriceVND > 100000000) {
    errors.push('Tổng giá trị đơn hàng không được vượt quá 100 triệu VND')
  }

  return {
    isValid: errors.length === 0,
    errors,
  }
}

const formatCurrency = (amount: number | null) => {
  if (!amount) return '0'
  return new Intl.NumberFormat('vi-VN').format(amount)
}

// Simple cache for buy orders
interface BuyOrder {
  id: string
  channel: { id: string; name: string; code: string }
  currency_attribute: { id: string; code: string; name: string; type: string }
  customer?: { id: string; display_name: string }
  created_at: string
  [key: string]: unknown
}

let buyOrdersCache: BuyOrder[] = []
let lastCacheTime = 0
const CACHE_DURATION = 30000 // 30 seconds

// Load suppliers for selected channel and game
const loadSuppliersForChannel = async () => {
  try {
    if (!supplierFormData.value.channelId || !currentGame.value) {
      return []
    }

    // Temporarily use fallback logic until RPC function is fixed
    console.log('🔄 Loading suppliers (using fallback method)')
    const { data: fallbackData, error: fallbackError } = await supabase
      .from('parties')
      .select('*')
      .eq('type', 'supplier')
      .order('name')

    if (fallbackError) {
      console.error('Error loading suppliers:', fallbackError)
      return []
    }

    console.log('✅ Loaded suppliers:', fallbackData?.length || 0)
    return fallbackData || []
  } catch (error) {
    console.error('Error in loadSuppliersForChannel:', error)
    return []
  }
}

// Create or update supplier
const createOrUpdateSupplier = async (supplierInfo: {
  name: string
  contact?: string
  notes?: string
}) => {
  try {
    if (!supplierFormData.value.channelId || !currentGame.value) {
      throw new Error('Channel and game must be selected')
    }

    // Simple supplier creation - use basic insert until RPC function is fixed
    const { data, error } = await supabase
      .from('parties')
      .insert({
        name: supplierInfo.name,
        type: 'supplier',
        contact_info: supplierInfo.contact ? { phone: supplierInfo.contact } : {},
        notes: supplierInfo.notes || null,
      })
      .select()
      .single()

    if (error) {
      console.error('Error creating supplier:', error)
      throw error
    }

    console.log('✅ Created supplier:', data)
    return data
  } catch (error) {
    console.error('Error in createOrUpdateSupplier:', error)
    throw error
  }
}

// Load buy orders for history
const loadBuyOrders = async (forceRefresh = false) => {
  try {
    if (!currentGame.value || !currentLeague.value) {
      return
    }

    // Check cache first
    const now = Date.now()
    if (!forceRefresh && buyOrdersCache.length > 0 && now - lastCacheTime < CACHE_DURATION) {
      console.log('📋 Using cached buy orders:', buyOrdersCache.length)
      return buyOrdersCache
    }

    const { data, error } = await supabase
      .from('currency_orders')
      .select(
        `
        *,
        channel:channels(id, name, code),
        currency_attribute:attributes(id, code, name, type),
        customer:profiles(id, display_name)
        `
      )
      .eq('game_code', currentGame.value)
      .eq('league_attribute_id', currentLeague.value)
      .eq('order_type', 'BUY')
      .order('created_at', { ascending: false })
      .limit(10)

    if (error) {
      console.error('Error loading buy orders:', error)
      return
    }

    // Update cache
    buyOrdersCache = data || []
    lastCacheTime = now

    console.log('✅ Loaded buy orders:', data?.length || 0)
    return data
  } catch (error) {
    console.error('Error in loadBuyOrders:', error)
  }
}

// Handle purchase submit for purchase tab
const _handlePurchaseSubmit = async () => {
  try {
    purchaseSaving.value = true

    // Use computed validation first
    if (!purchaseFormValid.value) {
      throw new Error('Vui lòng điền đầy đủ thông tin bắt buộc')
    }

    // Additional validation
    if (!currentGame.value || !currentLeague.value) {
      throw new Error('Vui lòng chọn game và league')
    }

    // Use comprehensive validation
    const validation = validatePurchaseForm()
    if (!validation.isValid) {
      throw new Error(validation.errors.join(', '))
    }

    console.log('📊 Purchase form summary:', {
      currency: purchaseData.currencyId,
      quantity: purchaseData.quantity,
      totalPrice: formattedPurchaseTotal.value,
      unitPrice: formatCurrency(purchaseUnitPrice.value),
      supplier: supplierData.supplierName,
    })

    // Handle supplier creation or selection
    let supplierPartyId = supplierData.supplierId
    if (!supplierData.isExistingSupplier && supplierData.supplierName) {
      // Create new supplier if needed
      try {
        const newSupplier = await createOrUpdateSupplier({
          name: supplierData.supplierName,
          contact: supplierData.supplierContact || undefined,
          notes: `Created for ${currentGame.value} via ${supplierFormData.value.channelId}`,
        })
        supplierPartyId = newSupplier.id
        console.log('✅ Created new supplier:', newSupplier)
      } catch (supplierError) {
        console.error('❌ Error creating supplier:', supplierError)
        const errorMessage =
          supplierError instanceof Error ? supplierError.message : 'Unknown error'
        throw new Error(`Không thể tạo supplier: ${errorMessage}`)
      }
    }

    // Transform order data for API
    const purchaseOrderData = {
      channel_id: supplierFormData.value.channelId,
      currency_code: purchaseData.currencyId,
      quantity: Number(purchaseData.quantity),
      total_price_vnd: Number(purchaseData.totalPriceVND), // ← Sử dụng total price
      notes: purchaseData.notes || null,
      supplier_id: supplierPartyId, // ← Đúng field: supplier_party_id
      supplier_name: supplierData.supplierName || null,
      supplier_contact: supplierData.supplierContact || null,
    }

    console.log('🛒 Creating BUY order with data:', purchaseOrderData)

    // Call API to create purchase order with proper supplier management
    const { data, error } = await supabase.rpc('create_currency_purchase_order', {
      p_currency_attribute_id: purchaseOrderData.currency_code, // ← UUID của currency
      p_quantity: purchaseOrderData.quantity,
      p_cost_amount: purchaseCostAmount.value, // ← Dynamic cost amount (VND or USD)
      p_game_code: currentGame.value,
      p_channel_id: purchaseOrderData.channel_id, // ← ✅ Channel cho supplier management
      p_cost_currency_code: purchaseCostCurrency.value, // ← Dynamic currency code based on input
      p_league_attribute_id: currentLeague.value,
      p_supplier_name: supplierData.supplierName || 'Unknown Supplier',
      p_supplier_contact: supplierData.supplierContact || '', // ← Contact info from "Thông tin liên hệ" field
      p_notes: purchaseData.notes || null, // ← Notes from purchase form
      p_delivery_info: supplierData.supplierCharacterName || null, // ← Character name from "Tên nhân vật / ID" field
      p_priority_level: 3, // ← Default priority level
    })

    if (error) {
      console.error('❌ Error creating BUY order:', error)
      throw new Error(`Không thể tạo đơn mua: ${error.message}`)
    }

    // Check if function returned success
    if (data && data.length > 0 && data[0].success) {
      console.log('✅ BUY order created successfully:', data[0])
      message.success(`Tạo đơn mua thành công! Order #${data[0].order_number}`)

      // Upload proof images if any
      const orderId = data[0].order_number || data[0].id
      if (purchaseFileList.value && purchaseFileList.value.length > 0) {
        try {
          console.log('📤 Uploading purchase order proof images...')
          const uploadedImages = await uploadImages(purchaseFileList.value, orderId, 'purchase')

          if (uploadedImages.length > 0) {
            // Update purchase order with proof image URLs by updating the notes field
            const proofUrls = uploadedImages.map((img) => img.publicUrl).join(', ')
            const proofText = `\n\n📎 Hình bằng chứng mua hàng:\n${proofUrls}`

            // Add proof URLs to existing notes
            const updatedNotes = purchaseData.notes
              ? `${purchaseData.notes}${proofText}`
              : proofText

            // Update the currency transaction with proof URLs
            await supabase
              .from('currency_orders')
              .update({ notes: updatedNotes })
              .eq('order_number', orderId)

            console.log('✅ Purchase proof images uploaded and order updated with proof URLs')
          }
        } catch (uploadError) {
          console.error('❌ Failed to upload purchase proof images:', uploadError)
          // Don't fail the entire order creation, just log the error
          message.warning('Đơn mua đã được tạo nhưng không thể upload hình bằng chứng')
        }
      }
    } else {
      const errorMessage = data && data.length > 0 ? data[0].message : 'Unknown error'
      throw new Error(`Tạo đơn mua thất bại: ${errorMessage}`)
    }

    // Reset form after successful submission
    if (activeTab.value === 'purchase') {
      // Reset purchase form
      purchaseData.quantity = null
      purchaseData.totalPriceVND = null
      purchaseData.totalPriceUSD = null
      purchaseData.notes = null

      // Reset supplier data
      supplierData.supplierId = null
      supplierData.supplierName = null
      supplierData.supplierContact = null
      supplierData.isExistingSupplier = true

      // Keep channel and currency selections for convenience
    }

    // Reset purchase file list after successful submission
    purchaseFileList.value = []

    // Refresh data to show new order (force refresh cache)
    await loadBuyOrders(true)
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Không thể tạo đơn mua'
    message.error(errorMessage)
    console.error('Purchase submission error:', error)
  } finally {
    purchaseSaving.value = false
  }
}
</script>

<style scoped>
.layout-wrapper {
  transition: all 0.3s ease;
}

@media (min-width: 1024px) {
  .inventory-open {
    margin-right: 24rem;
  }
}

.tab-pane {
  animation: fadeInUp 0.3s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
