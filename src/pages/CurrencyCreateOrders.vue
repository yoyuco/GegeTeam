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
      <GameServerSelector
        ref="gameServerSelectorRef"
        :key="`game-server-${currentGame?.value}-${currentServer?.value}`"
        @game-changed="onGameChanged"
        @server-changed="onServerChanged"
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
                  :customer-model-value="customerFormData"
                  :channels="salesChannels"
                  :game-code="gameCodeForForm"
                  :form-mode="'customer'"
                  @update:customerModelValue="handleCustomerFormUpdate"
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
                  :key="`${currentGame?.value}-${currentServer?.value}`"
                  transaction-type="sale"
                  :currencies="filteredCurrencies"
                  :currency-code-options="currencyCodes"
                  :loading="currenciesLoading"
                  :active-tab="'sell'"
                  :sell-model-value="saleData"
                  :game-code="currentGame?.value || 'POE_2'"
                  :server-code="currentServer?.value || 'STANDARD_ROTA_POE2'"
                  :channel-id="customerFormData.channelId"
                  @update:sell-model-value="(value) => { if (value) Object.assign(saleData, value) }"
                  @currency-changed="onCurrencyChanged"
                  @quantity-changed="(quantity: number | null) => onQuantityChanged(quantity || 0)"
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
                  <label class="flex items-center gap-2 text-sm font-medium text-gray-700 mb-3">
                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                    </svg>
                    Hình thức
                  </label>
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
                  <label class="flex items-center gap-2 text-sm font-medium text-gray-700 mb-2">
                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                    </svg>
                    Loại chuyển đổi
                  </label>
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
                  <label class="flex items-center gap-2 text-sm font-medium text-gray-700 mb-2">
                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    Hình ảnh (nếu có)
                  </label>
                      <SimpleProofUpload
                    ref="sellProofUploadRef"
                    :max-files="10"
                    :auto-upload="false"
                    :upload-path="'currency/sale'"
                    :sub-path="'exchange'"
                    :bucket="'work-proofs'"
                    @upload-complete="handleSellProofUploadComplete"
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
                  ref="supplierFormRef"
                  :supplier-model-value="supplierFormData"
                  :channels="purchaseChannels"
                  :form-mode="'supplier'"
                  :game-code="currentGame?.value"
                  @update:supplierModelValue="handleSupplierFormUpdate"
                  @supplier-changed="onSupplierChanged"
                  @supplier-game-tag-changed="onSupplierGameTagChanged"
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
                  :key="`${currentGame?.value}-${currentServer?.value}`"
                  transaction-type="purchase"
                  :currencies="filteredCurrencies"
                  :currency-code-options="currencyCodes"
                  :loading="currenciesLoading"
                  :active-tab="'buy'"
                  :buy-model-value="purchaseData"
                  :game-code="currentGame?.value || 'POE_2'"
                  :server-code="currentServer?.value || 'STANDARD_ROTA_POE2'"
                  :channel-id="supplierFormData.channelId"
                  @update:buy-model-value="(value) => {
                    if (value) {
                      purchaseData.currencyId = value.currencyId;
                      purchaseData.quantity = value.quantity;
                      purchaseData.totalPrice = value.totalPrice;
                      purchaseData.currencyCode = value.currencyCode;
                      purchaseData.notes = value.notes || '';
                    }
                  }"
                  @currency-changed="onPurchaseCurrencyChanged"
                  @quantity-changed="(quantity: number | null) => onPurchaseQuantityChanged(quantity || 0)"
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
              <!-- Ảnh đàm phán (Bắt buộc) - Bên trái -->
              <div>
                <label class="flex items-center gap-2 text-sm font-medium text-gray-700 mb-2">
                  <svg class="w-4 h-4 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                  </svg>
                  Ảnh đàm phán
                  <span class="text-red-500 font-medium">*</span>
                </label>
                <SimpleProofUpload
                  ref="purchaseNegotiationProofRef"
                  v-model="purchaseNegotiationFiles"
                  :max-files="5"
                  :auto-upload="false"
                  :upload-path="'currency/purchase'"
                  :sub-path="'negotiation'"
                  :bucket="'work-proofs'"
                  @upload-complete="handlePurchaseNegotiationProofUploadComplete"
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
          :loading="activeTab === 'purchase' ? purchaseSaving : saving"
        :disabled="activeTab === 'purchase' ? purchaseSaving : saving"
          @click="activeTab === 'purchase' ? _handlePurchaseSubmit() : handleCurrencyFormSubmit()"
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
        :game-code="currentGame"
        :server-code="currentServer"
        @close="isInventoryOpen = false"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
import CurrencyForm from '@/components/currency/CurrencyForm.vue'
import CurrencyInventoryPanel from '@/components/currency/CurrencyInventoryPanel.vue'
import GameServerSelector from '@/components/currency/GameServerSelector.vue'
import CustomerForm from '@/components/CustomerForm.vue'
import SimpleProofUpload from '@/components/SimpleProofUpload.vue'
import { useCurrency } from '@/composables/useCurrency.js'
import { useGameContext } from '@/composables/useGameContext.js'
import { loadPartyByNameType, createSupplierOrCustomer } from '@/composables/useSupplierCustomer'
import { useAuth } from '@/stores/auth'
import { NButton, NInput, NRadio, NRadioGroup, useMessage } from 'naive-ui'
import { computed, nextTick, onMounted, reactive, ref, watch } from 'vue'
import { supabase, uploadFile } from '@/lib/supabase'
import type { Currency } from '@/types/composables.d'

// Load currencies for current game
const loadCurrenciesForCurrentGame = async () => {
  if (!currentGame.value) {
    // No game selected
    return
  }
  try {
    // Get game attribute ID
    const { data: gameData, error: gameError } = await supabase
      .from('attributes')
      .select('id')
      .eq('code', currentGame.value)
      .eq('type', 'GAME')
      .single()

    if (gameError || !gameData) {
            throw new Error(`Game ${currentGame.value} not found`)
    }

    // Then load GAME_CURRENCY type currencies linked to this game via attribute_relationships
    // Use a different approach - query from attribute_relationships directly
    const { data: relationshipData, error: relationshipError } = await supabase
      .from('attribute_relationships')
      .select(`
        child_attribute_id
      `)
      .eq('parent_attribute_id', gameData.id)

    if (relationshipError) {
            throw relationshipError
    }

    // Get the currency attribute IDs
    const currencyIds = relationshipData?.map(rel => rel.child_attribute_id) || []

    if (currencyIds.length === 0) {
          return
    }

    // Now load the actual currency attributes
    const { error } = await supabase
      .from('attributes')
      .select('*')
      .in('id', currencyIds)
      .eq('type', 'GAME_CURRENCY')
      .eq('is_active', true)
      .order('sort_order', { ascending: true })

    if (error) {
      
      // Fallback to previous method
      const gameInfo = currentGame.value === 'POE_2' ? { currencyPrefix: 'CURRENCY_POE2' } :
                       currentGame.value === 'POE_1' ? { currencyPrefix: 'CURRENCY_POE1' } :
                       currentGame.value === 'DIABLO_4' ? { currencyPrefix: 'CURRENCY_D4' } : null
      if (!gameInfo) {
                return
      }

      const { error: fallbackError } = await supabase
        .from('attributes')
        .select('*')
        .eq('type', gameInfo.currencyPrefix)
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      if (fallbackError) {
                throw fallbackError
      }
    }

    // The currencies are already loaded into useCurrency.allCurrencies via initializeCurrency
    // We need to ensure they're properly loaded

  } catch (err) {
        throw err
  }
}
// Game context
const { currentGame, currentServer, contextString, initializeFromStorage } = useGameContext()
const {
  salesChannels,
  purchaseChannels,
  allCurrencies,
  initialize: initializeCurrency,
  loadCurrencyCodes,
  loading: currenciesLoading,
} = useCurrency()

// Currency codes for price dropdown
const currencyCodes = ref<any[]>([])
const currencyCodesLoading = ref(false)

// Load currency codes for price dropdown
const loadCurrencyCodesData = async () => {
  currencyCodesLoading.value = true
  try {
    const codes = await loadCurrencyCodes()
    currencyCodes.value = codes
  } catch (err) {
    console.error('Error loading currency codes:', err)
    currencyCodes.value = []
  } finally {
    currencyCodesLoading.value = false
  }
}

// Filtered currencies for current game
const filteredCurrencies = computed(() => {
  // Wait for currencies to load
  if (areCurrenciesLoading.value || !allCurrencies.value || !currentGame?.value) {
    return []
  }
  const filtered = allCurrencies.value.filter((currency: Currency) => {
    // Filter active GAME_CURRENCY types (already filtered by game)
    return currency.type === 'GAME_CURRENCY' && currency.is_active !== false
  })
  return filtered.map((currency: Currency) => ({
    // Safe property access with fallbacks
    label: currency.name || currency.code || `Currency ${currency.id.slice(0, 8)}...`,
    value: currency.id,
    data: currency,
  }))
})
// UI State
const message = useMessage()
const auth = useAuth()
const isInventoryOpen = ref(false)
const saving = ref(false)
const currencyFormRef = ref()
const supplierFormRef = ref()
const activeTab = ref<'sell' | 'purchase'>('sell')
const purchaseSaving = ref(false)
const isDataLoading = ref(false)
const areCurrenciesLoading = ref(false)
const customerFormData = ref({
  channelId: null as string | null,
  customerName: '',
  gameTag: '',
  deliveryInfo: '',
})
const saleData = reactive({
  currencyId: null as string | null,
  quantity: null as number | null,
  totalPrice: null as number | null,
  currencyCode: 'VND',
  notes: '',
})
// Purchase data
const supplierFormData = ref({
  channelId: null as string | null,
  supplierName: '',      // ← Supplier name (was customerName)
  supplierContact: '',   // ← Supplier contact info (was deliveryInfo)
  deliveryLocation: '',  // ← Delivery location (was gameTag)
})
const purchaseData = reactive({
  currencyId: null as string | null,
  quantity: null as number | null,
  totalPrice: null as number | null, // ← Total cost amount - goes to cost_amount field
  currencyCode: 'VND', // ← Currency code (VND, USD, etc.)
  notes: '',
})
const purchaseCurrencyFormRef = ref()
const sellProofUploadRef = ref()
const purchaseNegotiationProofRef = ref()
const sellProofFiles = ref<Array<{ url: string; path: string; filename: string }>>([])
interface FileInfo {
  id: string
  file?: File
  name: string
  url?: string
  path?: string
  status: 'pending' | 'uploading' | 'finished' | 'error'
  error?: string
}

const purchaseNegotiationFiles = ref<FileInfo[]>([])

// SimpleProofUpload paths - will be updated after order creation
const currentOrderId = ref<string | null>(null)


// NOTE: Purchase upload paths are now handled directly in _handlePurchaseSubmit
// Temporary paths are used in the template for initial upload

const purchaseFormValid = computed(() => {
  const hasValidPrice = purchaseData.totalPrice !== null && purchaseData.totalPrice >= 0
  const hasValidQuantity = (purchaseData.quantity || 0) > 0
  const hasValidCurrency = purchaseData.currencyCode && purchaseData.currencyCode.length > 0
  // For purchase orders, only negotiation proof is required
  const hasProofFiles = purchaseNegotiationFiles.value && purchaseNegotiationFiles.value.length > 0

  return (
    supplierFormData.value.channelId &&
    supplierFormData.value.supplierName &&
    supplierFormData.value.supplierContact &&
    purchaseData.currencyId &&
    hasValidPrice &&
    hasValidQuantity &&
    hasValidCurrency &&
    hasProofFiles
  )
})
// Purchase cost display
const purchaseCostAmount = computed(() => {
  return purchaseData.totalPrice || 0
})

const purchaseCostCurrency = computed(() => {
  if (!supplierFormData.value.channelId) {
    return 'VND'
  }

  const selectedChannel = purchaseChannels.value.find((channel: any) => channel.id === supplierFormData.value.channelId)

  if (purchaseData.currencyCode) {
    return purchaseData.currencyCode
  }

  if (!selectedChannel) {
    return 'VND'
  }

  const isWeChatChannel = (selectedChannel as any).name?.toLowerCase().includes('wechat') ||
                        (selectedChannel as any).code?.toLowerCase().includes('wechat') ||
                        (selectedChannel as any).displayName?.toLowerCase().includes('wechat')

  return isWeChatChannel ? 'CNY' : 'VND'
})
// Purchase evidence data
const purchaseEvidenceData = reactive({
  notes: '',
  images: [] as string[],
})
// Exchange data for sell tab
const exchangeData = reactive({
  type: 'none',
  exchangeType: '',
  exchangeImages: [] as string[],
})
onMounted(async () => {
  try {
    await initializeFromStorage()
    if (currentGame.value && currentServer.value) {
      await loadData()
    }
  } catch {
    message.error('Không thể khởi tạo dữ liệu')
  }
})
// Handle tab changes
watch(activeTab, (newTab) => {
  // Only handle when data is available and not loading
  if (isDataLoading.value) return

  if (newTab === 'sell' && salesChannels.value.length > 0) {
    // Auto-select G2G channel when switching to sell tab
    if (!customerFormData.value.channelId) {
      const g2gChannel = salesChannels.value.find(
        (channel: any) =>
          channel.name?.toLowerCase().includes('g2g') ||
          channel.displayName?.toLowerCase().includes('g2g') ||
          channel.code?.toLowerCase().includes('g2g')
      )
      if (g2gChannel) {
        customerFormData.value.channelId = (g2gChannel as any).id
        // G2G is a USD channel, so set currency to USD
        saleData.currencyCode = 'USD'
      }
    }
    // Auto-select first currency if not already selected
    if (!saleData.currencyId && filteredCurrencies.value.length > 0) {
      saleData.currencyId = filteredCurrencies.value[0].value
    }
  } else if (newTab === 'purchase' && purchaseChannels.value.length > 0) {
    // Auto-select Facebook channel when switching to purchase tab
    if (!supplierFormData.value.channelId) {
      const facebookChannel = purchaseChannels.value.find(
        (channel: any) =>
          channel.name?.toLowerCase().includes('facebook') ||
          channel.displayName?.toLowerCase().includes('facebook') ||
          channel.code?.toLowerCase().includes('facebook')
      )
      if (facebookChannel) {
        supplierFormData.value.channelId = (facebookChannel as any).id
      }
    }
    // Auto-select first currency if not already selected
    if (!purchaseData.currencyId && filteredCurrencies.value.length > 0) {
      purchaseData.currencyId = filteredCurrencies.value[0].value
    }
  }
})
// Load all necessary data
const loadData = async () => {
  try {
    isDataLoading.value = true
    areCurrenciesLoading.value = true // Start currency loading
  
    // First ensure game context is initialized
  
    await initializeFromStorage()
    // Wait for game context to be available
    let retries = 0
    while ((!currentGame.value || !currentServer.value) && retries < 10) {

      await new Promise(resolve => setTimeout(resolve, 500))
      retries++
    }
    if (!currentGame.value || !currentServer.value) {
            throw new Error('Game context not available')
    }
  
    // Now initialize currency composable properly (same pattern as GameLeagueSelector)

    await initializeCurrency()
    // Manual currency loading to ensure currencies are loaded

    await loadCurrenciesForCurrentGame()
    // Load currency codes for price dropdown (VND, USD, etc.)
    await loadCurrencyCodesData()
    // Give a moment for reactive updates to propagate
    await new Promise(resolve => setTimeout(resolve, 100))
    // Ensure currencies are loaded before proceeding
    // await debugChannels()
  
    // Load remaining data (temporarily disabled inventory loading due to schema errors)
    // await Promise.all([loadInventory()])
    // Use nextTick to ensure DOM updates happen smoothly
    await nextTick()
  
    // Set default selections immediately after data is loaded
    await setDefaultSelectionsAsync()
    // Log auto-selection results after setting
    // Auto-selection completed successfully
  } catch (error) {
    console.error('Error loading data:', error)
    message.error('Không thể tải dữ liệu')
  } finally {
    isDataLoading.value = false
    areCurrenciesLoading.value = false // Currency loading complete
  }
}
// Watch for currency availability to auto-select when currencies are loaded
watch(
  () => filteredCurrencies.value.length,
  (newLength) => {
    if (newLength > 0 && !isDataLoading.value) {
      setDefaultSelectionsAsync()
    }
  }
)

const syncCurrencyWithChannel = async (channelId: string) => {
  if (!channelId) return

  const selectedChannel = purchaseChannels.value.find((channel: any) => channel.id === channelId)
  if (!selectedChannel) return

  const isWeChatChannel = (selectedChannel as any).name?.toLowerCase().includes('wechat') ||
                        (selectedChannel as any).code?.toLowerCase().includes('wechat') ||
                        (selectedChannel as any).displayName?.toLowerCase().includes('wechat')

  if (isWeChatChannel && purchaseData.currencyCode === 'VND') {
    purchaseData.currencyCode = 'CNY'
  } else if (!isWeChatChannel && purchaseData.currencyCode === 'CNY') {
    purchaseData.currencyCode = 'VND'
  }
}

// Watch for channel changes to load suppliers and sync currency
watch(
  () => supplierFormData.value.channelId,
  async (newChannelId) => {
    if (newChannelId && currentGame.value) {
      await loadSuppliersForChannel()
      await syncCurrencyWithChannel(newChannelId)

      // Reset supplier form data when channel changes
      supplierFormData.value = {
        channelId: newChannelId,
        supplierName: '',
        supplierContact: '',
        deliveryLocation: ''
      }

      // Auto-select currency type for purchase orders (similar to sell orders)
      if (!purchaseChannels.value.length) return

      const selectedChannel = purchaseChannels.value.find((channel: any) => channel.id === newChannelId)
      if (!selectedChannel) return

      const channelName = (selectedChannel as any).name?.toLowerCase() ||
                         (selectedChannel as any).code?.toLowerCase() ||
                         (selectedChannel as any).displayName?.toLowerCase() || ''

      // Set currency code based on channel
      const isUSDChannel = channelName.includes('eldorado') ||
                          channelName.includes('g2g') ||
                          channelName.includes('playerauctions')

      const isWeChatChannel = channelName.includes('wechat') || channelName.includes('alipay') || channelName.includes('taobao')

      // Always set currency code based on channel type
      if (isUSDChannel) {
        purchaseData.currencyCode = 'USD'
      } else if (isWeChatChannel) {
        purchaseData.currencyCode = 'CNY'
      } else {
        purchaseData.currencyCode = 'VND'
      }
    }
  }
)
const setDefaultSelectionsAsync = async () => {
  if (salesChannels.value.length === 0 && purchaseChannels.value.length === 0) {
    return
  }

  const firstCurrency = filteredCurrencies.value.length > 0 ? filteredCurrencies.value[0].value : null
  await nextTick()
  const updates: {
    saleCurrency?: string
    sellChannelId?: string
    purchaseChannelId?: string
    purchaseCurrencyId?: string
  } = {}
  if (firstCurrency) {
    updates.saleCurrency = firstCurrency
  }
  if (salesChannels.value.length > 0) {
    const g2gChannel = salesChannels.value.find(
      (channel: any) =>
        channel.name?.toLowerCase().includes('g2g') ||
        channel.displayName?.toLowerCase().includes('g2g') ||
        channel.code?.toLowerCase().includes('g2g')
    )
    // Always set sell channel default since activeTab defaults to 'sell'
    updates.sellChannelId = (g2gChannel as any)?.id || (salesChannels.value[0] as any)?.id
  }
  // Purchase tab updates
  if (purchaseChannels.value.length > 0) {
    if (!supplierFormData.value.channelId) {
      const facebookChannel = purchaseChannels.value.find(
        (channel: any) =>
          channel.name?.toLowerCase().includes('facebook') ||
          channel.displayName?.toLowerCase().includes('facebook') ||
          channel.code?.toLowerCase().includes('facebook')
      )
      updates.purchaseChannelId = (facebookChannel as any)?.id || (purchaseChannels.value[0] as any)?.id
    }
    if (!purchaseData.currencyId && firstCurrency) {
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
  // For backward compatibility - convert old price format to new format
  if (price.vnd !== undefined) {
    saleData.totalPrice = price.vnd || null
    saleData.currencyCode = 'VND'
  } else if (price.usd !== undefined) {
    saleData.totalPrice = price.usd || null
    saleData.currencyCode = 'USD'
  }
  calculateTotal()
}
// Calculate total price (sell orders use direct input)
const calculateTotal = () => {
  // Total price is set directly by user input
}
// Game context handlers
const onGameChanged = async (gameCode: string) => {
  currentGame.value = gameCode
  currentServer.value = null

  resetAllForms() // Data reloaded automatically by useGameContext
}
const onServerChanged = async (serverCode: string) => {
  currentServer.value = serverCode
  resetAllForms() // Data reloaded automatically by useGameContext
}
const onContextChanged = async (context: { hasContext: boolean }) => {
  if (context.hasContext) {
    await loadData()
  } else {
    // Reset forms when no context
    resetAllForms()
  }
}
// Supplier handlers
const onSupplierChanged = (supplier: { name: string } | null) => {
  if (supplier) {
    // Update supplier name
    supplierFormData.value.supplierName = supplier.name
  } else {
    supplierFormData.value.supplierName = ''
  }
}
const onSupplierGameTagChanged = (gameTag: string) => {
  // Update game tag
  supplierFormData.value.deliveryLocation = gameTag
}

// Customer event handlers
const handleCustomerFormUpdate = (value: any) => {
  customerFormData.value = value || {
    channelId: null,
    customerName: '',
    gameTag: '',
    deliveryInfo: ''
  }
}

// Purchase form handlers
const handleSupplierFormUpdate = (value: any) => {
  supplierFormData.value = value || {
    channelId: null,
    supplierName: '',
    supplierContact: '',
    deliveryLocation: ''
  }
}
const onPurchaseCurrencyChanged = (currencyId: string | null) => {
  purchaseData.currencyId = currencyId
}
const onPurchaseQuantityChanged = (quantity: number) => {
  purchaseData.quantity = quantity
  // Keep user input intact (don't override totalPrice)
}
const onPurchasePriceChanged = (price: { [currency: string]: number | undefined }) => {
  // Extract currency and amount from price
  const currencies = Object.keys(price)
  if (currencies.length > 0) {
    const currency = currencies[0] // Take the first currency
    const amount = price[currency]

    purchaseData.totalPrice = amount || null
    purchaseData.currencyCode = currency || 'VND'
  }
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
    totalPrice: null,
    currencyCode: 'VND',
  })
  // Reset purchase data
  Object.assign(purchaseData, {
    currencyId: null,
    quantity: null,
    totalPrice: null,
    currencyCode: 'VND',
    notes: '',
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
  sellProofFiles.value = []
  purchaseNegotiationFiles.value = []
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
// Get exchange type label in Vietnamese
const getExchangeTypeLabel = (type: string) => {
  switch (type) {
    case 'items':
      return 'Vật phẩm'
    case 'service':
      return 'Dịch vụ'
    case 'farmer':
      return 'Farmer'
    case 'currency':
      return 'Tiền tệ'
    default:
      return type
  }
}
// Currency form methods
const handleCurrencyFormSubmit = async () => {
  
  // Prevent double-click / multiple submissions
  if (saving.value) {
    return
  }

  try {
    // Upload files first before submitting form
    if (activeTab.value === 'purchase') {
      const allUploadResults = []

      // Upload negotiation proofs (required)
      if (purchaseNegotiationProofRef.value) {
        const uploadResults = await purchaseNegotiationProofRef.value.uploadFiles()
        allUploadResults.push(...uploadResults)
      }

      // Only negotiation proof is required for purchase orders
      if (purchaseNegotiationFiles.value.length === 0) {
        throw new Error('Vui lòng upload ít nhất một hình ảnh bằng chứng đàm phán')
      }
    }

    // Get the correct form ref based on active tab
    const currentFormRef =
      activeTab.value === 'purchase' ? purchaseCurrencyFormRef.value : currencyFormRef.value
    if (!currentFormRef) {
      return
    }

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
      if (!supplierFormData.value.supplierName) {
        message.error('Vui lòng nhập tên nhà cung cấp')
        return
      }
      // Validate currency selection
      if (!purchaseData.currencyId) {
        message.error('Vui lòng chọn loại currency')
        return
      }
      // Validate currency amount
      if (purchaseData.totalPrice === null || purchaseData.totalPrice < 0) {
        message.error('Vui lòng nhập tổng tiền hợp lệ')
        return
      }
      if (!purchaseData.currencyCode) {
        message.error('Vui lòng chọn đơn vị tiền tệ')
        return
      }
      // Validate server selection - required for all games
      if (!currentServer.value) {
        message.error(
          `Vui lòng chọn server cho ${currentGame.value === 'DIABLO_4' ? 'Diablo 4' : currentGame.value === 'POE_1' ? 'Path of Exile 1' : 'Path of Exile 2'}`
        )
        return
      }
      // Use the purchase submit logic
      await _handlePurchaseSubmit()
    } else {
      // Sale order submission (original logic)

      // Validate customer data
      if (!customerFormData.value.customerName || !customerFormData.value.gameTag) {
        console.error('Missing customer data in handleCurrencyFormSubmit:', customerFormData.value)
        message.error('Vui lòng điền đầy đủ thông tin khách hàng')
        return
      }

      // Validate server selection - required for all games
      if (!currentServer.value) {
        console.error('Missing server selection in handleCurrencyFormSubmit:', currentServer.value)
        message.error(
          `Vui lòng chọn server cho ${currentGame.value === 'DIABLO_4' ? 'Diablo 4' : currentGame.value === 'POE_1' ? 'Path of Exile 1' : 'Path of Exile 2'}`
        )
        return
      }

      // Save the sale
      await saveSale()
    }
  } catch (error) {
    console.error('Error in handleCurrencyFormSubmit:', error)

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

  // Reset current order ID
  currentOrderId.value = null

  // Reset data based on active tab
  if (activeTab.value === 'purchase') {
    // Reset purchase data
    purchaseData.currencyId = null
    purchaseData.quantity = null
    purchaseData.totalPrice = null
    purchaseData.currencyCode = 'VND'
    purchaseData.notes = ''
    // Supplier data is now handled directly by supplierFormData

    // Auto-select first currency if available
    if (!purchaseData.currencyId && filteredCurrencies.value.length > 0) {
      purchaseData.currencyId = filteredCurrencies.value[0].value
    }

    // Auto-select Facebook channel when switching to purchase tab
    if (!supplierFormData.value.channelId && purchaseChannels.value.length > 0) {
      const facebookChannel = purchaseChannels.value.find(
        (channel: any) =>
          channel.name?.toLowerCase().includes('facebook') ||
          channel.displayName?.toLowerCase().includes('facebook') ||
          channel.code?.toLowerCase().includes('facebook')
      )
      if (facebookChannel) {
        supplierFormData.value.channelId = (facebookChannel as any).id
      }
    }
  } else {
    // Reset sale data (original logic)
    saleData.currencyId = null
    saleData.quantity = null
    saleData.totalPrice = null
    saleData.currencyCode = 'VND'

    // Auto-select first currency if available
    if (!saleData.currencyId && filteredCurrencies.value.length > 0) {
      saleData.currencyId = filteredCurrencies.value[0].value
    }

    // Auto-select G2G channel when switching to sale tab
    if (!customerFormData.value.channelId && salesChannels.value.length > 0) {
      const g2gChannel = salesChannels.value.find(
        (channel: any) =>
          channel.name?.toLowerCase().includes('g2g') ||
          channel.displayName?.toLowerCase().includes('g2g') ||
          channel.code?.toLowerCase().includes('g2g')
      )
      if (g2gChannel) {
        customerFormData.value.channelId = (g2gChannel as any).id
        // G2G is a USD channel, so set currency to USD
        saleData.currencyCode = 'USD'
      }
    }
  }
}
// Save sale
const saveSale = async () => {
  if (!currencyFormRef.value) {
    return
  }

  const formData = currencyFormRef.value.sellFormData

  if (!formData || !formData.currencyId || !formData.quantity) {
    message.warning('Vui lòng điền đầy đủ thông tin currency')
    return
  }

  if (!customerFormData.value.customerName || !customerFormData.value.gameTag) {
    message.warning('Vui lòng nhập thông tin khách hàng')
    return
  }

  // Validate server selection - required for all games
  if (!currentServer.value) {
    message.error(
      `Vui lòng chọn server cho ${currentGame.value === 'DIABLO_4' ? 'Diablo 4' : currentGame.value === 'POE_1' ? 'Path of Exile 1' : 'Path of Exile 2'}`
    )
    return
  }

  // Basic validation only - backend handles comprehensive validation and auto-assignment

    saving.value = true
  try {
    // Handle customer party - create or update customer information
    let customerPartyId = null
    const customerName = customerFormData.value.customerName?.trim()

    if (customerName) {
      try {
        // Create/get customer party - createSupplierOrCustomer will handle existing check and update if needed
        const customerParty = await createSupplierOrCustomer(
          customerName,
          'customer',
          customerFormData.value.channelId || '',
          '', // contact field - delivery info should go to deliveryInfo field, not contact
          undefined,
          currentGame.value,
          customerFormData.value.gameTag, // gameTag field
          customerFormData.value.deliveryInfo // deliveryInfo field
        )

        if (customerParty && customerParty.id) {
          customerPartyId = customerParty.id
          // Customer party processed successfully
        } else {
          console.warn('Failed to create or retrieve customer party for:', customerName)
        }
      } catch (error) {
        console.error('Error processing customer party:', error)
        throw new Error(`Không thể xử lý thông tin khách hàng: ${error instanceof Error ? error.message : 'Unknown error'}`)
      }
    }

    // Dynamic currency detection for sale
    const saleCostCurrency = formData.unitPriceUsd && formData.unitPriceUsd > 0 ? 'USD' : 'VND'
    const saleCostAmount =
      saleCostCurrency === 'USD' && formData.unitPriceUsd
        ? formData.unitPriceUsd
        : formData.unitPriceVnd || 0
    // Prepare payload for create_currency_sell_order_draft
    // Note: Function parameters order was changed to fix stock validation
    const payload: any = {
      // New parameter order for fixed function
      p_game_code: currentGame.value,
      p_server_attribute_code: currentServer.value,
      p_currency_attribute_id: formData.currencyId,
      p_quantity: Number(formData.quantity),
      p_character_id: customerFormData.value.gameTag, // Game tag
      p_character_name: customerFormData.value.gameTag, // Customer name (using gameTag for now)
      p_channel_id: customerFormData.value.channelId,
      p_delivery_info: customerFormData.value.deliveryInfo
        ? `${customerFormData.value.gameTag} | ${customerFormData.value.deliveryInfo}`
        : customerFormData.value.gameTag, // game tag | thông tin giao hàng
      p_notes: (() => {
        const parts = []
        // Add exchange type with details if not 'none'
        if (exchangeData.type && exchangeData.type !== 'none') {
          const exchangeTypeText = exchangeData.type === 'items' ? 'Items' :
                                  exchangeData.type === 'service' ? 'Service' :
                                  exchangeData.type === 'farmer' ? 'Farmer' : exchangeData.type
          parts.push(`Loại hình: ${exchangeTypeText} - ${exchangeData.exchangeType || ''}`)
        }
        // Add user notes
        if (formData.notes) {
          parts.push(formData.notes)
        }
        return parts.join('\n')
      })(), // Loại hình chuyển đổi (nếu có) | note người dùng
      // Add customer party info
      p_party_id: customerPartyId, // Customer party ID (from existing or newly created)
      // Add sale details
      p_sale_amount: formData.totalPrice,
      p_sale_currency_code: formData.currencyCode,
      // Add priority and deadline
      p_priority_level: 3, // Default priority level
      p_deadline_at: new Date(Date.now() + 30 * 60 * 1000).toISOString(), // 30 minutes from now
    }
    // Include exchange data in payload
    if (exchangeData.type !== 'none') {
      // Ensure the exchange type matches the enum values in database
      // Valid enum values: 'currency', 'farmer', 'items', 'none', 'service'
      const exchangeTypeValue = exchangeData.type
      // Verify it's a valid enum value
      const validExchangeTypes = ['currency', 'farmer', 'items', 'service']
      if (validExchangeTypes.includes(exchangeTypeValue)) {
        payload.p_exchange_type = exchangeTypeValue
      } else {
        console.warn(`Invalid exchange type: ${exchangeTypeValue}, defaulting to 'items'`)
        payload.p_exchange_type = 'items'
      }
      payload.p_exchange_details = {
        exchangeType: exchangeData.exchangeType,
        exchangeImages: exchangeData.exchangeImages
      }
    }
    // Get current profile ID
    const { data: profileData, error: profileError } = await supabase.rpc('get_current_profile_id')

    if (profileError) {
      console.error('Profile RPC error:', profileError)
      throw new Error(`Lỗi khi lấy profile ID: ${profileError.message}`)
    }

    if (!profileData) {
      throw new Error('Không thể lấy profile ID của người dùng. Vui lòng đảm bảo bạn đã đăng nhập và có profile hợp lệ.')
    }

    // Add user_id to payload (function expects p_user_id parameter)
    payload.p_user_id = profileData

    // Step 1: Create sell order draft
    // Note: Inventory validation will be handled by backend during assignment phase
        const { data, error } = await supabase.rpc('create_currency_sell_order_draft', payload)
    if (error) {
      console.error('Backend error:', error)
      throw new Error(`Không thể tạo đơn bán draft: ${error.message}`)
    }

    // Check if draft was created successfully
    if (data && data.length > 0) {
      // Debug: Log response to see actual structure
      console.log('Function response:', data[0])

      // Extract order info from response structure
      let orderId, orderNumber

      // New structure: {success, order_id, order_number, message}
      if (data[0].success && data[0].order_id && data[0].order_number) {
        orderId = data[0].order_id
        orderNumber = data[0].order_number
      } else if (data[0].success === false && data[0].message) {
        // Function returned an error message - throw it
        throw new Error(data[0].message)
      } else {
        // Unexpected response structure
        throw new Error(`Response không mong đợi: ${JSON.stringify(data[0])}`)
      }

      
      // Set current order ID for proof uploads
      currentOrderId.value = orderNumber || orderId

      // Initial success message will be shown after processing is complete

      // Step 2: Upload proof images if any
      let proofUrls: string[] = []

      // Check if upload component has files (regardless of sellProofFiles state)
      const uploadComponent = sellProofUploadRef.value as any
      const hasFiles = uploadComponent?.fileList?.length > 0

      if (uploadComponent && hasFiles) {
        // Update the upload path with order ID using setter method
        uploadComponent.setOrderId(orderNumber)

        const uploadResults = await uploadComponent.uploadFiles()
        proofUrls = uploadResults.map((result: any) => result)

        // Silently handle proof uploads without additional messages
      }

      // Validate orderId before proceeding
      if (!orderId) {
        throw new Error('Order ID is undefined, cannot update order status')
      }

      // Step 3: Update order with proofs and set status to pending using RPC (same as purchase)
      if (proofUrls.length > 0) {
        const { data: updateResult, error: updateError } = await supabase.rpc('update_currency_order_proofs', {
          p_order_id: orderId,
          p_proofs: proofUrls
        })

        if (updateError) {
          throw new Error(`Không thể cập nhật bằng chứng: ${updateError.message}`)
        }

        if (updateResult && updateResult.length > 0 && !updateResult[0].success) {
          throw new Error(`Cập nhật bằng chứng thất bại: ${updateResult[0].message}`)
        }
      } else {
        // If no proofs, just update status to pending
        const { error: updateError } = await supabase
          .from('currency_orders')
          .update({
            status: 'pending',
            submitted_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          })
          .eq('id', orderId)

        if (updateError) {
          throw new Error(`Không thể cập nhật trạng thái đơn hàng: ${updateError.message}`)
        }
      }

      // Step 4: Auto-assign sell order using 3-level rotation approach
      try {
                const { data: assignmentResult, error: assignmentError } = await supabase.rpc('assign_sell_order_with_inventory_v2', {
          p_order_id: orderId,
          p_user_id: profileData,
          p_rotation_type: 'account_first'
        })

        if (assignmentError) {
          console.error('Assignment error:', assignmentError)
          message.warning(`⚠️ Đơn #${orderNumber} cần phân công thủ công: ${assignmentError.message}`)
        }

        // Check assignment result
        if (assignmentResult && assignmentResult.length > 0 && !assignmentResult[0].success) {
          console.error('Assignment failed:', assignmentResult[0].message)

          // Check if it's an inventory-related error
          const errorMsg = assignmentResult[0].message.toLowerCase()
          if (errorMsg.includes('no suitable inventory') || errorMsg.includes('inventory pool')) {
            // This is an inventory availability error - show more user-friendly message
            message.error(`❌ Không tìm thấy inventory phù hợp cho đơn #${orderNumber}. Vui lòng kiểm tra lại kho hàng hoặc thêm inventory mới.`)

            // Optionally, we could delete the draft order here if inventory is not available
            // await supabase.from('currency_orders').delete().eq('id', orderId)
            // message.info(`Đơn draft #${orderNumber} đã bị xóa do không có inventory phù hợp`)
          } else {
            message.warning(`⚠️ Đơn #${orderNumber} cần phân công thủ công: ${assignmentResult[0].message}`)
          }
        }
      } catch (assignError: any) {
        console.error('Assignment failed:', assignError)
        message.error(`❌ Lỗi khi phân công đơn #${orderNumber}: ${assignError.message}`)
      }

      // Single success message at the end
      message.success(`✅ Đơn bán #${orderNumber} đã được tạo thành công!`)

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
    sellProofFiles.value = []

    // Reset upload component to clear UI
    if (sellProofUploadRef.value) {
      sellProofUploadRef.value.resetFiles()
    }

    // Auto-select first currency if available
    if (!saleData.currencyId && filteredCurrencies.value.length > 0) {
      saleData.currencyId = filteredCurrencies.value[0].value
    }

    // Auto-select G2G channel when switching to sale tab
    if (!customerFormData.value.channelId && salesChannels.value.length > 0) {
      const g2gChannel = salesChannels.value.find(
        (channel: any) =>
          channel.name?.toLowerCase().includes('g2g') ||
          channel.displayName?.toLowerCase().includes('g2g') ||
          channel.code?.toLowerCase().includes('g2g')
      )
      if (g2gChannel) {
        customerFormData.value.channelId = (g2gChannel as any).id
        // G2G is a USD channel, so set currency to USD
        saleData.currencyCode = 'USD'
      }
    }
  }
  } catch (error) {
    console.error('Sell order creation error:', error)
    message.error(`Đã có lỗi xảy ra khi tạo đơn bán: ${error instanceof Error ? error.message : 'Lỗi không xác định'}`)
  } finally {
    saving.value = false
  }
}
// Watch for channel changes to set default currency code for sell orders
watch(
  () => customerFormData.value.channelId,
  (newChannelId) => {

    if (!newChannelId || !salesChannels.value.length) return

    const selectedChannel = salesChannels.value.find((channel: any) => channel.id === newChannelId)
    if (!selectedChannel) return

    const channelName = (selectedChannel as any).name?.toLowerCase() ||
                       (selectedChannel as any).code?.toLowerCase() ||
                       (selectedChannel as any).displayName?.toLowerCase() || ''


    // Reset customer form data when channel changes
    customerFormData.value = {
      channelId: newChannelId,
      customerName: '',
      gameTag: '',
      deliveryInfo: ''
    }

    // Set currency code based on channel
    const isUSDChannel = channelName.includes('eldorado') ||
                        channelName.includes('g2g') ||
                        channelName.includes('playerauctions')

    // Always set currency code based on channel type
    if (isUSDChannel) {
      saleData.currencyCode = 'USD'
    } else {
      saleData.currencyCode = 'VND'
    }

  }
)

// Computed property for game code to ensure reactivity
const gameCodeForForm = computed(() => {
  const gameCode = currentGame?.value
  return gameCode || ''
})

// Watch for game/server changes to reload inventory
watch([currentGame, currentServer], async () => {
  // Only proceed if we have both game and server
  if (!currentGame.value || !currentServer.value) return

  
  // Store old channel before reset
  const oldChannelId = customerFormData.value.channelId

    // Reset forms - this will set currencyId to null briefly
  resetAllForms()

  // Check if old channel is still valid for new game and restore if valid
  if (oldChannelId && salesChannels.value.some((ch: any) => ch.id === oldChannelId)) {
        customerFormData.value.channelId = oldChannelId

    // Force trigger currency type update based on restored channel
    const selectedChannel = salesChannels.value.find((ch: any) => ch.id === oldChannelId)
    if (selectedChannel) {
      const channelName = (selectedChannel as any).name?.toLowerCase() ||
                         (selectedChannel as any).code?.toLowerCase() ||
                         (selectedChannel as any).displayName?.toLowerCase() || ''

      const isUSDChannel = channelName.includes('eldorado') ||
                          channelName.includes('g2g') ||
                          channelName.includes('playerauctions')

      saleData.currencyCode = isUSDChannel ? 'USD' : 'VND'

    }
  }

  // Immediately load new data to minimize flicker
  await loadData()
})
// Image upload handlers for n-upload
// SimpleProofUpload handlers
const handleSellProofUploadComplete = (uploadedFiles: Array<{ url: string; path: string; filename: string }>) => {
  sellProofFiles.value = uploadedFiles
  // Files are stored and will be included when order is created
}

const handlePurchaseNegotiationProofUploadComplete = (uploadedFiles: FileInfo[]) => {
  purchaseNegotiationFiles.value = uploadedFiles
}




// updateOrderWithProofs function removed - proofs are now handled during order creation
// Upload images to Supabase Storage - Now handled by SimpleProofUpload component
// Debounced validation removed - was not being used
// calculatePurchaseTotal removed - was causing user input to be overridden
const validatePurchaseForm = () => {
  const errors = []
  if (!supplierFormData.value.channelId) {
    errors.push('Vui lòng chọn kênh mua hàng')
  }
  if (!supplierFormData.value.supplierName) {
    errors.push('Vui lòng nhập tên nhà cung cấp')
  }
  if (!supplierFormData.value.supplierContact) {
    errors.push('Vui lòng nhập thông tin liên hệ của nhà cung cấp')
  }
  if (!purchaseData.currencyId) {
    errors.push('Vui lòng chọn loại currency')
  }
  if (!purchaseData.quantity || purchaseData.quantity <= 0) {
    errors.push('Số lượng phải lớn hơn 0')
  }
  // Check if price is provided and greater than 0
  if (!purchaseData.totalPrice || purchaseData.totalPrice <= 0) {
    errors.push('Tổng giá trị phải lớn hơn 0')
  }

  // Validate currency code
  if (!purchaseData.currencyCode) {
    errors.push('Vui lòng chọn đơn vị tiền tệ')
  }

  // Validate maximum limits based on currency
  if (purchaseData.currencyCode === 'VND' && (purchaseData.totalPrice || 0) > 100000000) {
    errors.push('Tổng giá trị đơn hàng không được vượt quá 100 triệu VND')
  }

  if (purchaseData.currencyCode === 'USD' && (purchaseData.totalPrice || 0) > 5000) {
    errors.push('Tổng giá trị đơn hàng không được vượt quá 5000 USD')
  }
  
  return {
    isValid: errors.length === 0,
    errors,
  }
}



// Auto assign purchase order to employee
const autoAssignPurchaseOrder = async (orderId: string): Promise<void> => {
  try {
    const { error } = await supabase.rpc('assign_purchase_order', {
      p_purchase_order_id: orderId
    })

    if (error) {
      throw new Error(`Failed to auto-assign purchase order: ${error.message}`)
    }
  } catch (err) {
    console.error('Error auto-assigning purchase order:', err)
    throw err
  }
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
    const { data: fallbackData, error: fallbackError } = await supabase
      .from('parties')
      .select('*')
      .eq('type', 'supplier')
      .order('name')
    if (fallbackError) {
      return []
    }
    return fallbackData || []
  } catch (error) {
    return []
  }
}
// Supplier creation is now handled automatically by the backend function
// Load buy orders for history
const loadBuyOrders = async (forceRefresh = false) => {
  try {
    if (!currentGame.value || !currentServer.value) {
      return
    }
    // Check cache first
    const now = Date.now()
    if (!forceRefresh && buyOrdersCache.length > 0 && now - lastCacheTime < CACHE_DURATION) {
  
      return buyOrdersCache
    }
    const { data, error } = await supabase
      .from('currency_orders')
      .select('*')
      .eq('game_code', currentGame.value)
      .eq('server_attribute_code', currentServer.value)
      .eq('order_type', 'PURCHASE')
      .order('created_at', { ascending: false })
      .limit(10)
    if (error) {
      return
    }
    // Update cache
    buyOrdersCache = data || []
    lastCacheTime = now
    return data
  } catch (error) {
    // Silently handle error
  }
}

// Check server availability and employee shift before creating order
const checkOrderFeasibility = async (
  gameCode: string,
  serverCode: string,
  channelId: string,
  currencyCode: string // Add currency type parameter
): Promise<{
  feasible: boolean,
  serverAvailable: boolean,
  employeeAvailable: boolean,
  message: string
}> => {
  try {
    // Database is already GMT+7, no conversion needed
    const currentTime = new Date().toTimeString().slice(0, 5)

    const { data: activeShifts, error: shiftError } = await supabase
      .from('work_shifts')
      .select('*')
      .eq('is_active', true)

    if (shiftError) {
      return {
        feasible: false,
        serverAvailable: false,
        employeeAvailable: false,
        message: `Lỗi hệ thống khi kiểm tra giờ làm việc. Vui lòng thử lại hoặc liên hệ admin.`
      }
    }

    if (!activeShifts || activeShifts.length === 0) {
      return {
        feasible: false,
        serverAvailable: false,
        employeeAvailable: false,
        message: `Không có ca làm việc nào đang active tại thời gian hiện tại. Vui lòng thử lại sau.`
      }
    }

    let activeShift = null
    for (const shift of activeShifts) {
      const shiftStart = shift.start_time.slice(0, 5)
      const shiftEnd = shift.end_time.slice(0, 5)

      let isOnShift = false
      if (shift.start_time <= shift.end_time) {
        isOnShift = currentTime >= shiftStart && currentTime <= shiftEnd
      } else {
        isOnShift = currentTime >= shiftStart || currentTime <= shiftEnd
      }

      if (isOnShift) {
        activeShift = shift
        break
      }
    }

    if (!activeShift) {
      return {
        feasible: false,
        serverAvailable: false,
        employeeAvailable: false,
        message: `Hiện tại đang ngoài giờ làm việc (${currentTime}). Ca làm việc: ${activeShift.name} (${activeShift.start_time} - ${activeShift.end_time}).`
      }
    }

    
    const { data: availableAccounts, error: serverError } = await supabase.rpc('get_available_game_accounts', {
      p_game_code: gameCode,
      p_server_attribute_code: serverCode,
      p_limit: 10
    })

    if (serverError || !availableAccounts || availableAccounts.length === 0) {
      const serverText = serverCode ? `server: ${serverCode}` : 'global accounts'
      return {
        feasible: false,
        serverAvailable: false,
        employeeAvailable: false,
        message: `Hiện tại không có tài khoản game nào available cho ${gameCode} ${serverText === 'global accounts' ? '' : '(' + serverText + ')'}.`
      }
    }

    const { data: shiftAssignments, error: assignmentError } = await supabase
      .from('shift_assignments')
      .select(`
        *,
        profiles!inner (
          display_name,
          status
        ),
        game_accounts!inner (
          account_name,
          game_code,
          server_attribute_code
        ),
        work_shifts!inner (
          name,
          start_time,
          end_time
        )
      `)
      .eq('channels_id', channelId)
      .eq('currency_code', currencyCode)
      .eq('shift_id', activeShift.id)
      .eq('is_active', true)
      .eq('profiles.status', 'active')
      .eq('game_accounts.is_active', true)

    if (assignmentError || !shiftAssignments || shiftAssignments.length === 0) {
      return {
        feasible: false,
        serverAvailable: true,
        employeeAvailable: false,
        message: `Hiện tại không có nhân viên nào phù hợp để xử lý đơn hàng này (Loại currency: ${currencyCode}). Vui lòng thử lại sau hoặc liên hệ admin để được hỗ trợ.`
      }
    }

    const assignment = shiftAssignments[0]
    return {
      feasible: true,
      serverAvailable: true,
      employeeAvailable: true,
      message: `✅ Sẵn sàng tạo đơn! Đơn hàng sẽ được tự động phân công cho ${assignment.profiles.display_name}.`
    }

  } catch (error) {
    return {
      feasible: false,
      serverAvailable: false,
      employeeAvailable: false,
      message: `Lỗi hệ thống khi kiểm tra điều kiện tạo đơn. Vui lòng thử lại hoặc liên hệ admin.`
    }
  }
}

// Handle purchase submit for purchase tab
const _handlePurchaseSubmit = async () => {
  // Prevent double-click / multiple submissions
  if (purchaseSaving.value) {
        return
  }

  try {
    purchaseSaving.value = true

    // Use computed validation first
        if (!purchaseFormValid.value) {
      throw new Error('Vui lòng điền đầy đủ thông tin bắt buộc')
    }
    // Additional validation
    if (!currentGame.value || !currentServer.value) {
      throw new Error('Vui lòng chọn game và server')
    }

    // NEW: Comprehensive feasibility check (server + employee shift)

    if (!supplierFormData.value.channelId) {
      throw new Error('Vui lòng chọn kênh mua hàng')
    }

    const feasibilityCheck = await checkOrderFeasibility(
      currentGame.value,
      currentServer.value,
      supplierFormData.value.channelId,
      purchaseCostCurrency.value // Add currency type parameter
    )

    if (!feasibilityCheck.feasible) {
      throw new Error(feasibilityCheck.message)
    }
    
    // Use comprehensive validation
    const validation = validatePurchaseForm()
    if (!validation.isValid) {
      throw new Error(validation.errors.join(', '))
    }

    // Handle supplier party
    const supplierName = supplierFormData.value.supplierName?.trim()

    if (supplierName) {
      try {
        // Create/get supplier party
        const supplierParty = await createSupplierOrCustomer(
          supplierName,
          'supplier',
          supplierFormData.value.channelId || '',
          supplierFormData.value.supplierContact,
          undefined,
          currentGame.value,
          supplierFormData.value.deliveryLocation, // gameTag field (character name)
          '' // deliveryInfo field - suppliers don't need delivery info
        )

        if (supplierParty && supplierParty.id) {
          // Supplier party processed successfully
        } else {
          console.warn('Failed to create or retrieve supplier party for:', supplierName)
        }
      } catch (error) {
        console.error('Error processing supplier party:', error)
        throw new Error(`Không thể xử lý thông tin nhà cung cấp: ${error instanceof Error ? error.message : 'Unknown error'}`)
      }
    }

    // NEW WORKFLOW: Create order draft first
    const { data: orderDraftData, error: draftError } = await supabase.rpc('create_currency_purchase_order_draft', {
      p_currency_attribute_id: purchaseData.currencyId,
      p_quantity: Number(purchaseData.quantity),
      p_cost_amount: purchaseCostAmount.value,
      p_cost_currency_code: purchaseCostCurrency.value,
      p_game_code: currentGame.value,
      p_channel_id: supplierFormData.value.channelId,
      p_server_attribute_code: currentServer.value,
      p_supplier_name: supplierFormData.value.supplierName || 'Unknown Supplier',
      p_supplier_contact: supplierFormData.value.supplierContact || '',
      p_delivery_info: supplierFormData.value.deliveryLocation || '', // Game tag for purchase orders (deliveryLocation = game tag)
      p_notes: (() => {
        const parts = []
        // Add user notes
        if (purchaseData.notes) {
          parts.push(purchaseData.notes)
        }
        // Add supplier contact if available
        if (supplierFormData.value.supplierContact) {
          parts.push(`Liên hệ: ${supplierFormData.value.supplierContact}`)
        }
        return parts.join(' | ')
      })(), // Notes | Thông tin liên hệ nếu có
      p_priority_level: 3, // Default priority level
      p_user_id: auth.profile?.id // Proper authentication: pass profiles.id from frontend
    })

    if (draftError) {
      throw new Error(`Không thể tạo đơn mua draft: ${draftError.message}`)
    }

    if (!orderDraftData || !orderDraftData[0]?.success) {
      throw new Error('Tạo đơn mua draft thất bại')
    }

    const orderUuid = orderDraftData[0].order_id  // Use UUID for database operations
    const orderNumber = orderDraftData[0].order_number  // Use order number for display and file paths
    currentOrderId.value = orderNumber  // Keep current behavior for UI

        
    // Upload negotiation proofs using SimpleProofUpload component
    const allProofFiles = []

    if (purchaseNegotiationProofRef.value) {
      // Set order ID using setter method
      purchaseNegotiationProofRef.value.setOrderId(orderNumber)

      const negotiationUploadResults = await purchaseNegotiationProofRef.value.uploadFiles()
      allProofFiles.push(...negotiationUploadResults)
    }

  
    // Use RPC function to update order with proofs and set status to pending in one atomic operation
    const { data: updateResult, error: updateError } = await supabase.rpc('update_currency_order_proofs', {
      p_order_id: orderUuid,
      p_proofs: allProofFiles
    })

    if (updateError) {
      throw new Error(`Không thể cập nhật bằng chứng: ${updateError.message}`)
    }

    if (updateResult && updateResult.length > 0 && !updateResult[0].success) {
      throw new Error(`Cập nhật bằng chứng thất bại: ${updateResult[0].message}`)
    }

    
    // Auto assign purchase order to suitable employee (should succeed based on pre-check)
    try {
            await autoAssignPurchaseOrder(orderUuid)
    } catch (assignError) {
            console.error('Assignment error:', assignError)
      // This should rarely happen due to pre-check, but handle gracefully
      message.warning(`⚠️ Đơn #${orderNumber} cần phân công thủ công`)
    }

    // Single success message
    message.success(`✅ Đơn mua #${orderNumber} đã được tạo thành công!`)

    // Reset form after successful submission
    resetPurchaseForm()

    
    // Refresh data to show new order (force refresh cache)
    await loadBuyOrders(true)
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Không thể tạo đơn mua'
    message.error(errorMessage)
  } finally {
    purchaseSaving.value = false
  }
}

// Reset purchase form function
const resetPurchaseForm = () => {
  // Reset purchase form
  purchaseData.quantity = null
  purchaseData.totalPrice = null
  purchaseData.currencyCode = 'VND'
  purchaseData.currencyId = null
  purchaseData.notes = ''

  // Reset supplier form
  supplierFormData.value.channelId = null
  supplierFormData.value.supplierName = ''
  supplierFormData.value.supplierContact = ''
  supplierFormData.value.deliveryLocation = ''

  // Reset file references
  purchaseNegotiationFiles.value = []

  // Reset file upload components
  if (purchaseNegotiationProofRef.value) {
    purchaseNegotiationProofRef.value.resetFiles()
  }

  // Reset current order ID
  currentOrderId.value = null

  // Auto-select first currency if available
  if (!purchaseData.currencyId && filteredCurrencies.value.length > 0) {
    purchaseData.currencyId = filteredCurrencies.value[0].value
  }

  // Auto-select Facebook channel when switching to purchase tab
  if (!supplierFormData.value.channelId && purchaseChannels.value.length > 0) {
    const facebookChannel = purchaseChannels.value.find(
      (channel: any) =>
        channel.name?.toLowerCase().includes('facebook') ||
        channel.displayName?.toLowerCase().includes('facebook') ||
        channel.code?.toLowerCase().includes('facebook')
    )
    if (facebookChannel) {
      supplierFormData.value.channelId = (facebookChannel as any).id
    }
  }
}

// New function to upload local files directly with order ID
const uploadFilesDirectly = async (files: FileInfo[], orderNumber: string, proofType: string) => {
  const uploadResults = []

  for (const file of files) {
    try {
      // Check if file has actual File object (not already uploaded)
      if (file.file instanceof File) {
        const timestamp = Date.now()
        const randomString = Math.random().toString(36).substring(2, 8)
        const filename = `${timestamp}-${randomString}-${file.name}`

        // Upload to correct order folder path
        const filePath = `currency/purchase/${orderNumber}/${proofType}/${filename}`

        
        const uploadResult = await uploadFile(file.file, filePath, 'work-proofs')

        if (uploadResult.success) {
          uploadResults.push({
            url: uploadResult.publicUrl,
            path: uploadResult.path,
            filename: file.name,
            type: proofType,
            uploaded_at: new Date().toISOString()
          })
        } else {
          throw new Error(uploadResult.error || 'Upload failed')
        }
      } else {
        // File is not a File object, skip
      }
    } catch (error) {
      throw new Error(`Failed to upload ${proofType} file: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  return uploadResults
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
