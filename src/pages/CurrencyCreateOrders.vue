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
                  :game-code="currentGame?.value"
                  @update:customerModelValue="(value) => { customerFormData = value || { channelId: null, customerName: '', gameTag: '', deliveryInfo: '' } }"
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
                  :loading="currenciesLoading"
                  :active-tab="'sell'"
                  :sell-model-value="saleData"
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
                  @update:supplierModelValue="(value) => { supplierFormData = value || { channelId: null, customerName: '', gameTag: '', deliveryInfo: '' } }"
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
                  :loading="currenciesLoading"
                  :active-tab="'buy'"
                  :buy-model-value="purchaseData"
                  @update:buy-model-value="(value) => { if (value) { purchaseData.currencyId = value.currencyId; purchaseData.quantity = value.quantity; purchaseData.notes = value.notes || ''; } }"
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
                  @upload-complete="handlePurchaseNegotiationProofUploadComplete"
                />
              </div>

              <!-- Ảnh thanh toán (Bắt buộc) - Bên phải -->
              <div>
                <label class="flex items-center gap-2 text-sm font-medium text-gray-700 mb-2">
                  <svg class="w-4 h-4 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
                  </svg>
                  Ảnh thanh toán
                  <span class="text-red-500 font-medium">*</span>
                </label>
                <SimpleProofUpload
                  ref="purchasePaymentProofRef"
                  v-model="purchasePaymentFiles"
                  :max-files="5"
                  :auto-upload="false"
                  @upload-complete="handlePurchasePaymentProofUploadComplete"
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
        :inventory-data="[]"
        @close="isInventoryOpen = false"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
import CustomerForm from '@/components/CustomerForm.vue'
import CurrencyForm from '@/components/currency/CurrencyForm.vue'
import CurrencyInventoryPanel from '@/components/currency/CurrencyInventoryPanel.vue'
import GameServerSelector from '@/components/currency/GameServerSelector.vue'
import SimpleProofUpload from '@/components/SimpleProofUpload.vue'
import { useCurrency } from '@/composables/useCurrency.js'
import { useGameContext } from '@/composables/useGameContext.js'
import { NButton, NInput, NRadio, NRadioGroup, useMessage } from 'naive-ui'
import { computed, nextTick, onMounted, reactive, ref, watch } from 'vue'
// import { useInventory } from '@/composables/useInventory.js' // Temporarily disabled due to schema errors
import { supabase, uploadFile } from '@/lib/supabase'
import type { Currency } from '@/types/composables.d'
// Manual currency loading function using attribute_relationships
const loadCurrenciesForCurrentGame = async () => {
  if (!currentGame.value) {
    // No current game, cannot load currencies
    return
  }
  try {
    // First get the game attribute ID
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
// Currency composable - now unified with all functionality
const {
  salesChannels,
  purchaseChannels,
  allCurrencies,
  initialize: initializeCurrency,
  loading: currenciesLoading,
} = useCurrency()
// Inventory composable (temporarily disabled due to schema errors)
// const { loadInventory, inventoryByCurrency } = useInventory()
// Filtered currencies based on current game - now using GAME_CURRENCY type via attribute_relationships
const filteredCurrencies = computed(() => {
  // Don't show any options if currencies are still loading
  if (areCurrenciesLoading.value || !allCurrencies.value || !currentGame?.value) {
    return []
  }
  const filtered = allCurrencies.value.filter((currency: Currency) => {
    // All currencies should now be GAME_CURRENCY type loaded via attribute_relationships
    // No need to filter by type since they're already filtered by game
    return currency.type === 'GAME_CURRENCY' && currency.is_active !== false
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
const supplierFormRef = ref()
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
  totalPriceVnd: null as number | null,
  totalPriceUsd: null as number | null,
  notes: '',
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
  totalPriceVnd: null as number | null, // ← Total cost amount - goes to cost_amount field
  totalPriceUsd: null as number | null, // ← Option cho USD (nếu cần trong tương lai)
  notes: '',
})
// Supplier information for purchase orders is now handled directly by supplierFormData
const purchaseCurrencyFormRef = ref()
const sellProofUploadRef = ref()
const purchaseNegotiationProofRef = ref()
const purchasePaymentProofRef = ref()
// SimpleProofUpload data
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
const purchasePaymentFiles = ref<FileInfo[]>([])

// SimpleProofUpload paths - will be updated after order creation
const currentOrderId = ref<string | null>(null)


// NOTE: Purchase upload paths are now handled directly in _handlePurchaseSubmit
// Temporary paths are used in the template for initial upload

const purchaseFormValid = computed(() => {
  const hasVndPrice = purchaseData.totalPriceVnd !== null && purchaseData.totalPriceVnd >= 0
  const hasUsdPrice = purchaseData.totalPriceUsd !== null && purchaseData.totalPriceUsd >= 0
  const hasValidQuantity = (purchaseData.quantity || 0) > 0
  // For purchase orders, both negotiation AND payment proofs are required
  const hasProofFiles = (purchaseNegotiationFiles.value && purchaseNegotiationFiles.value.length > 0) &&
                       (purchasePaymentFiles.value && purchasePaymentFiles.value.length > 0)
  // Currency validation: must have exactly ONE of VND or USD, not both
  const hasValidCurrency = (hasVndPrice && !hasUsdPrice) || (!hasVndPrice && hasUsdPrice)

  
  return (
    supplierFormData.value.channelId &&
    supplierFormData.value.customerName &&
    supplierFormData.value.gameTag &&
    purchaseData.currencyId &&
    hasValidQuantity &&
    hasValidCurrency &&
    hasProofFiles
  )
})
// Computed property for formatted currency display
// Detect which currency is being used for cost
const purchaseCostCurrency = computed(() => {
  return (purchaseData.totalPriceUsd || 0) > 0 ? 'USD' : 'VND'
})
// Get cost amount based on selected currency
const purchaseCostAmount = computed(() => {
  return purchaseCostCurrency.value === 'USD'
    ? (purchaseData.totalPriceUsd || 0)
    : (purchaseData.totalPriceVnd || 0)
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
// Initialize game context
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
// Watch for tab changes to auto-select values - optimized for smooth transitions
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
  } catch {
    message.error('Không thể tải dữ liệu')
  } finally {
    isDataLoading.value = false
    areCurrenciesLoading.value = false // Currency loading complete
  }
}
// Watch for currency availability to auto-select when currencies are loaded
watch(
  () => filteredCurrencies.value.length,
  async (newLength) => {
    if (newLength > 0 && !isDataLoading.value) {
      await setDefaultSelectionsAsync()
    }
  }
)

// Watch for channel changes to load suppliers
watch(
  () => supplierFormData.value.channelId,
  async (newChannelId) => {
    if (newChannelId && currentGame.value) {
      await loadSuppliersForChannel()
    }
  }
)
// Async version of setDefaultSelections with nextTick for smooth transitions
const setDefaultSelectionsAsync = async () => {
  // Continue even if currencies are not loaded yet - channels can be selected independently
  if (salesChannels.value.length === 0 && purchaseChannels.value.length === 0) {
    return
  }

  const firstCurrency = filteredCurrencies.value.length > 0 ? filteredCurrencies.value[0].value : null
  // Use nextTick to ensure DOM is updated after state changes
  await nextTick()
  // Batch all updates to minimize reactivity triggers
  const updates: {
    saleCurrency?: string
    sellChannelId?: string
    purchaseChannelId?: string
    purchaseCurrencyId?: string
  } = {}
  // Sell tab updates - always set default for sell tab since activeTab defaults to 'sell'
  if (firstCurrency) {
    updates.saleCurrency = firstCurrency
  }
  // Sell channel updates - always set default for sell tab
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
  saleData.totalPriceVnd = price.vnd || null
  calculateTotal()
}
// Calculate total price for sell orders
const calculateTotal = () => {
  // For sell orders, totalPrice is directly set by user input, not calculated
  // This function is kept for compatibility but doesn't perform calculations
  // as the form now handles total price directly instead of unit price
}
// Game & League selector event handlers
const onGameChanged = async (gameCode: string) => {
  // Update useGameContext state
  currentGame.value = gameCode
  currentServer.value = null // Reset server when game changes

  // Reset all forms when game changes
  resetAllForms()
  // Data will be reloaded automatically by useGameContext
}
const onServerChanged = async (serverCode: string) => {
  // Update useGameContext state
  currentServer.value = serverCode

  // Reset all forms when server changes
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
    // Update customerFormData for CustomerForm component
    supplierFormData.value.customerName = supplier.name
  } else {
    supplierFormData.value.customerName = ''
  }
}
const onSupplierGameTagChanged = (gameTag: string) => {
  // Update customerFormData for CustomerForm component
  supplierFormData.value.gameTag = gameTag
}
// Contact info is now handled directly by supplierFormData
const onPurchaseCurrencyChanged = (currencyId: string | null) => {
  purchaseData.currencyId = currencyId
}
const onPurchaseQuantityChanged = (quantity: number) => {
  purchaseData.quantity = quantity
  // Don't modify totalPriceVnd when quantity changes - keep user input intact
  // calculatePurchaseTotal is no longer needed as it was overriding user input
}
const onPurchasePriceChanged = (price: { vnd?: number; usd?: number }) => {
  purchaseData.totalPriceVnd = price.vnd || null
  purchaseData.totalPriceUsd = price.usd || null
  // No calculation here - the component now handles total price directly
  // calculatePurchaseTotal is no longer needed for basic price updates
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
    totalPriceVnd: null,
    totalPriceUsd: null,
  })
  // Reset purchase data
  Object.assign(purchaseData, {
    currencyId: null,
    quantity: null,
    totalPriceVnd: null,
    totalPriceUsd: null,
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
  purchasePaymentFiles.value = []
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
  try {
    // Upload files first before submitting form
    if (activeTab.value === 'purchase') {
      const allUploadResults = []

      // Upload negotiation proofs (required)
      if (purchaseNegotiationProofRef.value) {
        const uploadResults = await purchaseNegotiationProofRef.value.uploadFiles()
        allUploadResults.push(...uploadResults)
      }

      // Upload payment proofs (optional)
      if (purchasePaymentProofRef.value) {
        const uploadResults = await purchasePaymentProofRef.value.uploadFiles()
        allUploadResults.push(...uploadResults)
      }

  
      // Both negotiation and payment proofs are required for purchase orders
      if (purchaseNegotiationFiles.value.length === 0) {
        throw new Error('Vui lòng upload ít nhất một hình ảnh bằng chứng đàm phán')
      }
      if (purchasePaymentFiles.value.length === 0) {
        throw new Error('Vui lòng upload ít nhất một hình ảnh thanh toán')
      }
    } else if (activeTab.value === 'sell' && sellProofUploadRef.value) {
      const uploadResults = await sellProofUploadRef.value.uploadFiles()
      
      if (uploadResults.length === 0) {
        throw new Error('Vui lòng upload ít nhất một hình ảnh bằng chứng')
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
      if (!supplierFormData.value.customerName) {
        message.error('Vui lòng nhập tên nhà cung cấp')
        return
      }
      // Validate currency selection
      if (!purchaseData.currencyId) {
        message.error('Vui lòng chọn loại currency')
        return
      }
      // Validate currency amount: must have exactly ONE of VND or USD
      const hasVndPrice = purchaseData.totalPriceVnd !== null && purchaseData.totalPriceVnd >= 0
      const hasUsdPrice = purchaseData.totalPriceUsd !== null && purchaseData.totalPriceUsd >= 0
      if (!hasVndPrice && !hasUsdPrice) {
        message.error('Vui lòng nhập tổng tiền (VND hoặc USD)')
        return
      }
      if (hasVndPrice && hasUsdPrice) {
        message.error('Chỉ được nhập một loại tiền tệ: VND hoặc USD, không được nhập cả hai')
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
        message.error('Vui lòng điền đầy đủ thông tin khách hàng')
        return
      }
      // Validate server selection - required for all games
      if (!currentServer.value) {
        message.error(
          `Vui lòng chọn server cho ${currentGame.value === 'DIABLO_4' ? 'Diablo 4' : currentGame.value === 'POE_1' ? 'Path of Exile 1' : 'Path of Exile 2'}`
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

  // Reset current order ID
  currentOrderId.value = null
  
  // Reset data based on active tab
  if (activeTab.value === 'purchase') {
    // Reset purchase data
    purchaseData.currencyId = null
    purchaseData.quantity = null
    purchaseData.totalPriceVnd = null
    purchaseData.totalPriceUsd = null
    purchaseData.notes = ''
    // Supplier data is now handled directly by supplierFormData
  } else {
    // Reset sale data (original logic)
    saleData.currencyId = null
    saleData.quantity = null
    saleData.totalPriceVnd = null
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
  if (!sellProofFiles.value || sellProofFiles.value.length === 0) {
    message.warning('Vui lòng upload hình bằng chứng')
    return
  }
  // Validate server selection - required for all games
  if (!currentServer.value) {
    message.error(
      `Vui lòng chọn server cho ${currentGame.value === 'DIABLO_4' ? 'Diablo 4' : currentGame.value === 'POE_1' ? 'Path of Exile 1' : 'Path of Exile 2'}`
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
      p_server_attribute_code: currentServer.value,
      p_channel_id: customerFormData.value.channelId,
      p_customer_name: customerFormData.value.customerName,
      // Combine game tag and delivery info for complete delivery information
      p_customer_game_tag: customerFormData.value.gameTag,
      p_delivery_info: customerFormData.value.deliveryInfo
        ? `${customerFormData.value.gameTag} - ${customerFormData.value.deliveryInfo}`
        : customerFormData.value.gameTag,
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
      throw new Error(`Không thể tạo đơn bán: ${error.message}`)
    }
    // Check if function returned success
    if (data && data.length > 0 && data[0].success) {
      // Set current order ID for proof uploads
      currentOrderId.value = data[0].order_number || data[0].id
      
      message.success(`Tạo đơn bán thành công! Order #${data[0].order_number}`)
      // Upload proof images if any
      const orderId = data[0].order_number || data[0].id
      if (sellProofFiles.value && sellProofFiles.value.length > 0) {
        try {

          // Use files already uploaded by SimpleProofUpload
          const uploadedImages = sellProofFiles.value.map(img => ({
            ...img,
            type: 'sell'
          }))
          if (uploadedImages.length > 0) {
            // Create structured proof data for sell order creation
            const proofData = {
              order_creation: {
                sell: {
                  proofs: uploadedImages.map(img => ({
                    url: img.url,
                    path: img.path,
                    filename: img.filename,
                    type: img.type,
                    uploaded_at: new Date().toISOString()
                  }))
                }
              }
            }

            // Update the currency order with structured proof data
            
            const { error: updateError } = await supabase
              .from('currency_orders')
              .update({
                proofs: proofData,
                // Keep sales notes separate from proof data
                notes: payload.p_sales_notes || null
              })
              .eq('order_number', orderId)
              .select()

            if (updateError) {
              throw updateError
            }

                      }
        } catch (uploadError) {
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
    sellProofFiles.value = []

    // Reset upload component to clear UI
    if (sellProofUploadRef.value) {
      sellProofUploadRef.value.resetFiles()
    }
  } catch {
    message.error('Không thể tạo đơn bán')
  } finally {
    saving.value = false
  }
}
// Watch for game/server changes to reload inventory
watch([currentGame, currentServer], async () => {
  // Only proceed if we have both game and server
  if (!currentGame.value || !currentServer.value) return
    // Reset forms - this will set currencyId to null briefly
  resetAllForms()
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

const handlePurchasePaymentProofUploadComplete = (uploadedFiles: FileInfo[]) => {
  purchasePaymentFiles.value = uploadedFiles
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
  if (!supplierFormData.value.customerName) {
    errors.push('Vui lòng nhập tên nhà cung cấp')
  }
  if (!supplierFormData.value.gameTag) {
    errors.push('Vui lòng nhập tên nhân vật/ID của nhà cung cấp')
  }
  if (!purchaseData.currencyId) {
    errors.push('Vui lòng chọn loại currency')
  }
  if (!purchaseData.quantity || purchaseData.quantity <= 0) {
    errors.push('Số lượng phải lớn hơn 0')
  }
  // Check if at least one price is provided and greater than 0
  const hasVndPrice = purchaseData.totalPriceVnd && purchaseData.totalPriceVnd > 0
  const hasUsdPrice = purchaseData.totalPriceUsd && purchaseData.totalPriceUsd > 0

  if (!hasVndPrice && !hasUsdPrice) {
    errors.push('Tổng giá trị phải lớn hơn 0 (VND hoặc USD)')
  }

  // Validate maximum limits
  if (hasVndPrice && (purchaseData.totalPriceVnd || 0) > 100000000) {
    errors.push('Tổng giá trị đơn hàng không được vượt quá 100 triệu VND')
  }

  if (hasUsdPrice && (purchaseData.totalPriceUsd || 0) > 5000) {
    errors.push('Tổng giá trị đơn hàng không được vượt quá 5000 USD')
  }
  
  return {
    isValid: errors.length === 0,
    errors,
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
// Handle purchase submit for purchase tab
const _handlePurchaseSubmit = async () => {
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
    // Use comprehensive validation
    const validation = validatePurchaseForm()
    if (!validation.isValid) {
      throw new Error(validation.errors.join(', '))
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
      p_supplier_name: supplierFormData.value.customerName || 'Unknown Supplier',
      p_supplier_contact: supplierFormData.value.deliveryInfo || '',
      p_delivery_info: supplierFormData.value.gameTag || null,
      p_notes: purchaseData.notes || null,
      p_priority_level: 3,
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
    
    // Upload files directly to order folder using order number for path
    const allProofFiles = []

    if (purchaseNegotiationFiles.value && purchaseNegotiationFiles.value.length > 0) {
            const negotiationUploadResults = await uploadFilesDirectly(
        purchaseNegotiationFiles.value,
        orderNumber,
        'negotiation'
      )
      allProofFiles.push(...negotiationUploadResults)
    }

    if (purchasePaymentFiles.value && purchasePaymentFiles.value.length > 0) {
            const paymentUploadResults = await uploadFilesDirectly(
        purchasePaymentFiles.value,
        orderNumber,
        'payment'
      )
      allProofFiles.push(...paymentUploadResults)
    }

    // Update order with proofs and change status to pending using UUID
    if (allProofFiles.length > 0) {
            const { error: updateError } = await supabase.rpc('update_currency_order_proofs', {
        p_order_id: orderUuid,  // Use UUID for database operation
        p_proofs: JSON.stringify(allProofFiles)
      })

      if (updateError) {
        throw new Error(`Không thể cập nhật bằng chứng: ${updateError.message}`)
      }
    }

    // Final success message
    message.success(`✅ Tạo đơn mua thành công! Order #${orderNumber}`)

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
  purchaseData.totalPriceVnd = null
  purchaseData.totalPriceUsd = null
  purchaseData.currencyId = null
  purchaseData.notes = ''

  // Reset supplier form
  supplierFormData.value.channelId = null
  supplierFormData.value.customerName = ''
  supplierFormData.value.gameTag = ''
  supplierFormData.value.deliveryInfo = ''

  // Reset file references
  purchaseNegotiationFiles.value = []
  purchasePaymentFiles.value = []

  // Reset file upload components
  if (purchaseNegotiationProofRef.value) {
    purchaseNegotiationProofRef.value.resetFiles()
  }
  if (purchasePaymentProofRef.value) {
    purchasePaymentProofRef.value.resetFiles()
  }

  // Reset current order ID
  currentOrderId.value = null
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
