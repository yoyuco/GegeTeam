<!-- path: src/pages/CurrencySell.vue -->
<template>
  <div
    class="min-h-screen bg-gray-50 p-6"
    :style="{ marginRight: isInventoryOpen ? '380px' : '0' }"
  >
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
              <h1 class="text-2xl font-bold">Tạo đơn bán Currency</h1>
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

    <!-- Game & League Selector -->
    <div class="mb-6">
      <GameLeagueSelector
        @game-changed="onGameChanged"
        @league-changed="onLeagueChanged"
        @context-changed="onContextChanged"
      />
    </div>

    <!-- Main Content Grid - 2 Column Layout -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Left Column - Customer Information -->
      <div class="space-y-6">
        <!-- Customer Information Card -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div
            class="bg-gradient-to-r from-blue-50 to-indigo-50 px-6 py-4 border-b border-gray-200"
          >
            <h2 class="text-lg font-semibold text-gray-800 flex items-center gap-2">
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
              Thông tin khách hàng
            </h2>
          </div>
          <div class="p-6">
            <CustomerForm
              v-model="customerFormData"
              :channels="salesChannels"
              @customer-changed="onCustomerChanged"
              @game-tag-changed="onGameTagChanged"
            />
          </div>
        </div>
      </div>

      <!-- Right Column - Currency Information -->
      <div class="space-y-6">
        <!-- Currency Information Card -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div
            class="bg-gradient-to-r from-blue-50 to-indigo-50 px-6 py-4 border-b border-gray-200"
          >
            <h2 class="text-lg font-semibold text-gray-800 flex items-center gap-2">
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
              Thông tin Currency
            </h2>
          </div>
          <div class="p-6">
            <CurrencyForm
              ref="currencyFormRef"
              :league-id="currentLeague?.value"
              :currencies="filteredCurrencies"
              :loading="currenciesLoading"
              @currency-changed="onCurrencyChanged"
              @account-changed="onAccountChanged"
              @quantity-changed="onQuantityChanged"
              @price-changed="onPriceChanged"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Exchange Information Section -->
    <div class="mt-6 bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
      <div class="bg-gradient-to-r from-blue-50 to-indigo-50 px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-semibold text-gray-800 flex items-center gap-2">
          <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"
            />
          </svg>
          Loại hình chuyển đổi
        </h2>
      </div>
      <div class="p-6">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-4">
          <!-- Radio Buttons -->
          <div class="lg:col-span-1">
            <label class="block text-sm font-medium text-gray-700 mb-3">Hình thức</label>
            <n-radio-group v-model:value="exchangeData.type" name="exchangeType" class="space-y-2">
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
              </div>
            </n-radio-group>
          </div>

          <!-- Exchange Type Input -->
          <div class="lg:col-span-9">
            <label class="block text-sm font-medium text-gray-700 mb-2"> Loại chuyển đổi </label>
            <n-input
              v-model:value="exchangeData.exchangeType"
              :placeholder="exchangeData.type === 'items' ? 'Ring name' : 'Ascendancy 4th'"
              :disabled="exchangeData.type === 'none'"
              size="large"
              type="textarea"
              :rows="2"
              resize="none"
            />
            <p class="text-xs text-gray-500 mt-1">
              {{ exchangeData.type === 'items' ? 'VD: Ring name' : 'VD: Ascendancy 4th' }}
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

    <!-- Form Control Buttons -->
    <div class="mt-6 flex justify-end gap-3">
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
        class="px-8 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800"
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
        Tạo Đơn Bán
      </n-button>
    </div>
  </div>

  <!-- Inventory Panel as true sidebar -->
  <CurrencyInventoryPanel
    v-if="isInventoryOpen"
    :is-open="isInventoryOpen"
    :inventory-data="inventoryByCurrency"
    @close="isInventoryOpen = false"
  />
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useMessage } from 'naive-ui'
import { NButton, NInput, NRadioGroup, NRadio, NUpload } from 'naive-ui'
import CustomerForm from '@/components/CustomerForm.vue'
import CurrencyForm from '@/components/currency/CurrencyForm.vue'
import GameLeagueSelector from '@/components/currency/GameLeagueSelector.vue'
import CurrencyInventoryPanel from '@/components/currency/CurrencyInventoryPanel.vue'
import { useGameContext } from '@/composables/useGameContext.js'
import { useCurrency } from '@/composables/useCurrency.js'
import { useInventory } from '@/composables/useInventory.js'
import { usePoeCurrencies } from '@/composables/usePoeCurrencies.js'

// Game context
const { currentGame, currentLeague, contextString, initializeFromStorage } = useGameContext()

// Currency composable
const { loadChannels, salesChannels } = useCurrency()

// Inventory composable
const { loadInventory, inventoryByCurrency } = useInventory()

// POE currencies composable
const { poeCurrencies, loadPoeCurrencies, loading: currenciesLoading } = usePoeCurrencies()

// Filtered currencies based on current game
const filteredCurrencies = computed(() => {
  if (!poeCurrencies.value || !currentGame?.value) return []

  const filtered = poeCurrencies.value.filter((currency) => {
    // Filter by current game code
    if (currentGame.value === 'POE_2') {
      return currency.gameVersion === 'POE2' // Only POE_2 currencies
    }
    if (currentGame.value === 'POE_1') {
      return currency.gameVersion === 'POE1'
    }
    if (currentGame.value.includes('DIABLO') || currentGame.value === 'D4') {
      return currency.gameVersion === 'D4'
    }
    return true
  })

  
  return filtered.map((currency) => ({
    label: currency.name, // Only show name, not code
    value: currency.id,
    data: currency,
  }))
})

// UI State
const message = useMessage()
const isInventoryOpen = ref(false)
const saving = ref(false)
const currencyFormRef = ref()

// Form data
const customerFormData = reactive({
  channelId: null as string | null,
  customerName: '',
  gameTag: '',
  deliveryInfo: '',
})

// Exchange data
const exchangeData = reactive({
  type: 'none' as 'none' | 'items' | 'service',
  exchangeType: '',
  exchangeImages: [] as string[],
})

const saleData = reactive({
  currencyId: null as string | null,
  gameAccountId: null as string | null,
  quantity: null as number | null,
  pricePerUnit: null as number | null,
  totalPrice: null as number | null,
})

// Initialize game context
onMounted(async () => {
  try {
    await initializeFromStorage()
    if (currentGame.value && currentLeague.value) {
      await loadData()
    }
  } catch (error) {
    console.error('CurrencySell: initialization error:', error)
    message.error('Không thể khởi tạo dữ liệu')
  }
})

// Load all necessary data
const loadData = async () => {
  try {
    await Promise.all([loadChannels(), loadInventory(), loadPoeCurrencies()])
  } catch (error) {
    console.error('Error loading data:', error)
    message.error('Không thể tải dữ liệu')
  }
}

// Event handlers
const onCustomerChanged = (customer: { name: string } | null) => {
  if (customer) {
    customerFormData.customerName = customer.name
  } else {
    customerFormData.customerName = ''
  }
}

const onGameTagChanged = (gameTag: string) => {
  customerFormData.gameTag = gameTag
}

const onCurrencyChanged = (currencyId: string | null) => {
  saleData.currencyId = currencyId
}

const onAccountChanged = (accountId: string) => {
  saleData.gameAccountId = accountId
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
const onGameChanged = async (gameCode: string) => {
  console.log('Game changed to:', gameCode)
  // Data will be reloaded automatically by useGameContext
}

const onLeagueChanged = async (leagueId: string) => {
  console.log('League changed to:', leagueId)
  // Data will be reloaded automatically by useGameContext
}

const onContextChanged = async (context: { hasContext: boolean }) => {
  console.log('Context changed:', context)
  if (context.hasContext) {
    await loadData()
  }
}

// Calculate total price
const calculateTotal = () => {
  if (saleData.quantity && saleData.pricePerUnit) {
    saleData.totalPrice = saleData.quantity * saleData.pricePerUnit
  } else {
    saleData.totalPrice = null
  }
}

// Currency form methods
const handleCurrencyFormSubmit = async () => {
  if (!currencyFormRef.value) return

  try {
    // Validate form first
    const errors = currencyFormRef.value.validateForm()
    if (errors.length > 0) {
      message.error(errors.join(', '))
      return
    }

    // Validate customer data
    if (!customerFormData.customerName || !customerFormData.gameTag) {
      message.error('Vui lòng điền đầy đủ thông tin khách hàng')
      return
    }

    // Save the sale
    await saveSale()
  } catch (error) {
    console.error('Error submitting currency form:', error)
    message.error('Đã có lỗi xảy ra khi tạo đơn bán')
  }
}

const handleCurrencyFormReset = () => {
  if (!currencyFormRef.value) return

  currencyFormRef.value.resetForm()
  // Also reset sale data related to currency
  saleData.currencyId = null
  saleData.quantity = null
  saleData.pricePerUnit = null
  saleData.totalPrice = null
}

// Save sale
const saveSale = async () => {
  if (!currencyFormRef.value) return

  const formData = currencyFormRef.value.formData

  if (!formData.currencyId || !formData.quantity) {
    message.warning('Vui lòng điền đầy đủ thông tin currency')
    return
  }

  if (!customerFormData.customerName || !customerFormData.gameTag) {
    message.warning('Vui lòng nhập thông tin khách hàng')
    return
  }

  saving.value = true
  try {
    // Prepare payload for API call
    const payload = {
      p_currency_attribute_id: formData.currencyId,
      p_quantity: formData.quantity,
      p_unit_price_vnd: formData.unitPriceVnd || 0,
      p_unit_price_usd: formData.unitPriceUsd || 0,
      p_channel_id: customerFormData.channelId,
      p_customer_name: customerFormData.customerName,
      p_game_tag: customerFormData.gameTag,
      p_delivery_info: customerFormData.deliveryInfo,
      p_notes: formData.notes || '',
    }

    // Include exchange data in payload
    if (exchangeData.type !== 'none') {
      const exchangeText = `Loại hình: ${exchangeData.type === 'items' ? 'Items' : 'Service'} - ${exchangeData.exchangeType}`
      payload.p_notes = payload.p_notes ? `${payload.p_notes}\n${exchangeText}` : exchangeText
    }

    console.log('Creating sell order with payload:', payload)

    // TODO: Call the actual API to create sell order
    // await createSellOrder(payload)

    message.success('Tạo đơn bán thành công!')

    // Reset form after successful submission
    handleCurrencyFormReset()
    Object.assign(customerFormData, {
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
  } catch (error) {
    console.error('Error saving sale:', error)
    message.error('Không thể tạo đơn bán')
  } finally {
    saving.value = false
  }
}

// Image upload handlers for n-upload
const fileList = ref([])

const handleFileRemove = ({ file }: { file: { name: string } }) => {
  // File is automatically removed from fileList by n-upload
  // Just sync with exchangeData if needed
  console.log('File removed:', file.name)
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
</style>
