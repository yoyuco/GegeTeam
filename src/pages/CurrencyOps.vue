<template>
  <div
    class="min-h-screen bg-gray-50 p-6"
    :style="{ marginRight: isInventoryOpen ? '380px' : '0' }"
  >
    <div class="mb-6">
      <div
        class="bg-gradient-to-r from-green-600 to-emerald-600 text-white p-6 rounded-xl shadow-lg"
      >
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
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
                />
              </svg>
            </div>
            <div>
              <h1 class="text-2xl font-bold">Vận hành Currency</h1>
              <p class="text-green-100 text-sm mt-1">{{ contextString }}</p>
            </div>
          </div>
          <n-button
            type="primary"
            size="medium"
            class="bg-white/20 hover:bg-white/30 text-white border-white/30 backdrop-blur-sm"
            @click="isInventoryOpen = !isInventoryOpen"
          >
            <template #icon>
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                />
              </svg>
            </template>
            {{ isInventoryOpen ? 'Đóng Kho' : 'Xem Kho' }}
          </n-button>
        </div>
      </div>
    </div>

    <div class="mb-6">
      <GameLeagueSelector />
    </div>

    <n-tabs type="line" animated size="large" default-value="purchase">
      <n-tab-pane name="purchase" tab="Mua vào">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-4">
          <div class="bg-white p-6 rounded-xl shadow-sm">
            <h3 class="text-lg font-semibold mb-4 text-gray-800">Ghi nhận giao dịch mua vào</h3>
            <n-form ref="purchaseFormRef" :model="purchaseForm" label-placement="top">
              <n-form-item label="Nguồn mua (Đối tác)" path="partnerId">
                <n-input v-model:value="purchaseForm.partnerName" placeholder="Tên người bán" />
              </n-form-item>

              <div class="grid grid-cols-2 gap-4">
                <n-form-item label="Loại Currency" path="currencyId">
                  <n-select
                    v-model:value="purchaseForm.currencyId"
                    :options="currencyOptions"
                    placeholder="Chọn currency"
                    filterable
                    :loading="loadingCurrencies"
                  />
                </n-form-item>
                <n-form-item label="Số lượng" path="quantity">
                  <n-input-number v-model:value="purchaseForm.quantity" :min="0" class="w-full" />
                </n-form-item>
              </div>

              <n-form-item label="Đơn giá mua vào (VND / đơn vị)" path="unitPriceVnd">
                <n-input-number
                  v-model:value="purchaseForm.unitPriceVnd"
                  :min="0"
                  class="w-full"
                  placeholder="Giá mua bằng VND"
                />
              </n-form-item>

              <n-form-item label="Nhập kho vào tài khoản" path="gameAccountId">
                <n-select
                  v-model:value="purchaseForm.gameAccountId"
                  :options="accountOptions"
                  placeholder="Chọn tài khoản game để nhập kho"
                  filterable
                  :loading="loadingGameAccounts"
                />
              </n-form-item>

              <n-form-item label="Ghi chú" path="notes">
                <n-input v-model:value="purchaseForm.notes" type="textarea" />
              </n-form-item>

              <n-button
                type="primary"
                block
                size="large"
                :loading="isSubmitting"
                @click="handleRecordPurchase"
              >
                Ghi nhận
              </n-button>
            </n-form>
          </div>

          <ProfitCalculator
            :purchase-price-vnd="purchaseForm.unitPriceVnd"
            :quantity="purchaseForm.quantity"
          />
        </div>
      </n-tab-pane>

      <n-tab-pane name="delivery" tab="Giao hàng">
        <div class="mt-4 bg-white p-4 rounded-xl shadow-sm">
          <n-alert type="info" title="Đang phát triển">
            Tính năng hiển thị danh sách đơn hàng chờ giao sẽ được triển khai sớm.
          </n-alert>
        </div>
      </n-tab-pane>

      <n-tab-pane name="exchange" tab="Trao đổi">
        <div class="mt-4 bg-white p-4 rounded-xl shadow-sm">
          <n-alert type="info" title="Đang phát triển">
            Form trao đổi currency nội bộ sẽ được triển khai sớm.
          </n-alert>
        </div>
      </n-tab-pane>

      <n-tab-pane name="history" tab="Lịch sử Giao dịch">
        <div class="mt-4">
          <TransactionHistory />
        </div>
      </n-tab-pane>
    </n-tabs>
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
import { ref, reactive, onMounted, computed, watch } from 'vue'
import {
  NTabs,
  NTabPane,
  NForm,
  NFormItem,
  NInput,
  NInputNumber,
  NSelect,
  NButton,
  useMessage,
  NAlert,
  type FormInst,
} from 'naive-ui'

// Import components
import GameLeagueSelector from '@/components/currency/GameLeagueSelector.vue'
import CurrencyInventoryPanel from '@/components/currency/CurrencyInventoryPanel.vue'
import ProfitCalculator from '@/components/currency/ProfitCalculator.vue'
import TransactionHistory from '@/components/currency/TransactionHistory.vue'

// Import composables
import { useGameContext } from '@/composables/useGameContext.js'
import { useCurrency } from '@/composables/useCurrency.js'
import { useInventory } from '@/composables/useInventory.js'
import type { Currency, GameAccount } from '@/types/composables'

// --- KHỞI TẠO ---
const message = useMessage()
const purchaseFormRef = ref<FormInst | null>(null)

// --- COMPOSABLES ---
const {
  currentGame,
  currentLeague,
  contextString,
  initializeFromStorage,
  loadCurrencies: loadCurrenciesFromContext,
} = useGameContext()

const { recordPurchase } = useCurrency()
const { inventoryByCurrency, gameAccounts, loadAccounts } = useInventory()

// --- TRẠNG THÁI (STATE) ---
const isInventoryOpen = ref(false)
const isSubmitting = ref(false)
const currencies = ref<Currency[]>([])
const loadingCurrencies = ref(false)
const loadingGameAccounts = ref(false)

const purchaseForm = reactive({
  partnerName: '', // Tạm thời dùng input, sẽ nâng cấp sau
  currencyId: null as string | null,
  quantity: null as number | null,
  unitPriceVnd: null as number | null,
  gameAccountId: null as string | null,
  notes: '',
})

// --- COMPUTED ---
const currencyOptions = computed(() =>
  currencies.value.map((c) => ({ label: c.name, value: c.id }))
)
const accountOptions = computed(() =>
  gameAccounts.value.map((acc: GameAccount) => ({ label: acc.name, value: acc.id }))
)

// --- METHODS ---
const loadDataForContext = async () => {
  if (!currentGame.value || !currentLeague.value) return

  loadingCurrencies.value = true
  loadingGameAccounts.value = true
  try {
    const [loadedCurrencies] = await Promise.all([
      loadCurrenciesFromContext(),
      loadAccounts(), // useInventory's loadAccounts is context-aware
    ])
    currencies.value = loadedCurrencies
  } catch (error) {
    message.error('Lỗi khi tải dữ liệu currencies hoặc accounts.')
    console.error(error)
  } finally {
    loadingCurrencies.value = false
    loadingGameAccounts.value = false
  }
}

const handleRecordPurchase = async () => {
  await purchaseFormRef.value?.validate()
  if (
    !purchaseForm.currencyId ||
    !purchaseForm.quantity ||
    !purchaseForm.unitPriceVnd ||
    !purchaseForm.gameAccountId
  ) {
    message.error('Vui lòng điền đầy đủ các trường bắt buộc.')
    return
  }

  isSubmitting.value = true
  try {
    const payload = {
      p_game_account_id: purchaseForm.gameAccountId,
      p_currency_attribute_id: purchaseForm.currencyId,
      p_quantity: purchaseForm.quantity,
      p_unit_price_vnd: purchaseForm.unitPriceVnd,
      p_notes: `Mua từ đối tác: ${purchaseForm.partnerName || 'N/A'}. ${purchaseForm.notes || ''}`,
      // Các trường khác RPC sẽ tự điền hoặc có giá trị default
    }

    await recordPurchase(payload)
    message.success('Ghi nhận giao dịch mua vào thành công!')

    // Reset form
    Object.assign(purchaseForm, {
      partnerName: '',
      currencyId: null,
      quantity: null,
      unitPriceVnd: null,
      gameAccountId: null,
      notes: '',
    })
  } catch (error: unknown) {
    console.error('Lỗi khi ghi nhận mua vào:', error)
    const errorMessage = error instanceof Error ? error.message : 'Đã có lỗi xảy ra.'
    message.error(errorMessage)
  } finally {
    isSubmitting.value = false
  }
}

// --- LIFECYCLE ---
onMounted(async () => {
  message.loading('Đang tải dữ liệu vận hành...')
  await initializeFromStorage()
  await loadDataForContext()
  message.destroyAll()
})

watch([currentGame, currentLeague], () => {
  loadDataForContext()
})
</script>
