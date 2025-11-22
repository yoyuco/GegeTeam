<template>
  <div class="p-6 h-full flex flex-col">
    <!-- Header -->
    <div class="mb-6">
      <div class="flex items-center gap-3 mb-2">
        <div class="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl flex items-center justify-center">
          <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"
            />
          </svg>
        </div>
        <div>
          <h2 class="text-xl font-bold text-gray-900">Chuyển Currency</h2>
        </div>
      </div>
    </div>

    <!-- Main Content Area -->
    <div class="flex-1 space-y-6 overflow-y-auto">
      <!-- Step 1: Source & Target Accounts -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div class="bg-gradient-to-r from-indigo-50 to-purple-50 px-4 py-3 border-b border-gray-200">
          <div class="flex items-center gap-2">
            <div class="w-6 h-6 bg-indigo-100 rounded-full flex items-center justify-center">
              <span class="text-indigo-600 font-bold text-xs">1</span>
            </div>
            <h3 class="text-sm font-semibold text-gray-800">Chọn nguồn & đích</h3>
          </div>
        </div>

        <div class="p-6 space-y-4">
          <!-- Source Account -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              <div class="flex items-center gap-1">
                <svg class="w-4 h-4 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                  />
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M17 16l4 4m0 0l-4 4m4-4H9"
                  />
                </svg>
                Account nguồn
                <span class="text-red-500">*</span>
              </div>
            </label>
            <div class="relative">
              <select
                v-model="transferForm.sourceAccountId"
                @change="onSourceAccountChange"
                class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors appearance-none bg-white text-sm"
              >
                <option value="">Chọn account nguồn</option>
                <option
                  v-for="account in availableAccounts"
                  :key="account.id"
                  :value="account.id"
                >
                  {{ account.account_name }}
                </option>
              </select>
              <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                <svg class="w-3.5 h-3.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </div>
            </div>
          </div>

          <!-- Target Account -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              <div class="flex items-center gap-1">
                <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                  />
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M7 16l-4 4m0 0l4 4m-4-4h12"
                  />
                </svg>
                Account đích
                <span class="text-red-500">*</span>
              </div>
            </label>
            <div class="relative">
              <select
                v-model="transferForm.targetAccountId"
                :disabled="!transferForm.sourceAccountId"
                class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 disabled:bg-gray-50 disabled:text-gray-500 transition-colors appearance-none bg-white text-sm"
              >
                <option value="">Chọn account đích</option>
                <option
                  v-for="account in availableAccounts"
                  :key="account.id"
                  :value="account.id"
                  :disabled="account.id === transferForm.sourceAccountId"
                >
                  {{ account.account_name }}
                  <span v-if="account.id === transferForm.sourceAccountId" class="text-gray-400"> (không thể chọn)</span>
                </option>
              </select>
              <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                <svg class="w-3.5 h-3.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Step 2: Currency Selection -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden" :class="{ 'opacity-50': !transferForm.sourceAccountId }">
        <div class="bg-gradient-to-r from-blue-50 to-cyan-50 px-4 py-3 border-b border-gray-200">
          <div class="flex items-center gap-2">
            <div class="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center">
              <span class="text-blue-600 font-bold text-xs">2</span>
            </div>
            <h3 class="text-sm font-semibold text-gray-800">Chọn currency</h3>
          </div>
        </div>

        <div class="p-6">
          <div v-if="!transferForm.sourceAccountId" class="text-center py-8">
            <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19.428 15.428A2 2 0 0 1 18 15.428a2 2 0 0 1-.584 1.414m0 0a2 2 0 0 1-3.416 1.414M6 9l6 6m0 0l6 6m0-12V6"
                />
              </svg>
            </div>
            <p class="text-gray-500">Vui lòng chọn account nguồn trước</p>
          </div>

          <div v-else class="space-y-4">
            <!-- Currency Selection Grouped by Cost Currency -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                <div class="flex items-center gap-1">
                  <svg class="w-3.5 h-3.5 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                  Currency
                  <span class="text-red-500">*</span>
                </div>
              </label>
              <div class="relative">
                <select
                  v-model="transferForm.currencyId"
                  @change="onCurrencyChange"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors appearance-none bg-white text-sm"
                >
                  <option value="">Chọn currency</option>
                  <optgroup
                    v-for="(currencies, costCurrency) in groupedCurrencies"
                    :key="costCurrency"
                    :label="`Kho ${costCurrency}`"
                  >
                    <option
                      v-for="currency in currencies"
                      :key="`${currency.currency_attribute_id}_${currency.cost_currency}`"
                      :value="`${currency.currency_attribute_id}_${currency.cost_currency}`"
                    >
                      {{ currency.currency_name }} ({{ formatQuantity(currency.quantity) }})
                    </option>
                  </optgroup>
                </select>
                <div class="absolute inset-y-0 right-0 flex items-center px-3 pointer-events-none">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M19 9l-7 7-7-7"
                    />
                  </svg>
                </div>
              </div>

              <!-- Show pool details for selected currency -->
              <div v-if="selectedCurrency && selectedCurrency.pools && selectedCurrency.pools.length > 1" class="mt-2 p-2 bg-blue-50 rounded-lg border border-blue-200">
                <div class="text-xs text-blue-700 font-medium mb-1">Sẽ lấy từ {{ selectedCurrency.pools.length }} pool theo thứ tự:</div>
                <div class="space-y-1">
                  <div
                    v-for="(pool, index) in selectedCurrency.pools.slice(0, 3)"
                    :key="pool.id"
                    class="text-xs text-blue-600 flex justify-between"
                  >
                    <span>{{ pool.channel_name || `Pool ${index + 1}` }}: {{ formatQuantity(pool.quantity) }}</span>
                    <span>{{ formatDate(pool.last_updated_at) }}</span>
                  </div>
                  <div v-if="selectedCurrency.pools.length > 3" class="text-xs text-blue-500 italic">
                    ...và {{ selectedCurrency.pools.length - 3 }} pool khác
                  </div>
                </div>
              </div>
            </div>

            <!-- Quantity Input -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                <div class="flex items-center gap-1">
                  <svg class="w-3.5 h-3.5 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"
                    />
                  </svg>
                  Số lượng
                  <span class="text-red-500">*</span>
                </div>
              </label>
              <div class="relative">
                <input
                  v-model.number="transferForm.quantity"
                  type="number"
                  min="0"
                  :max="maxAvailableQuantity"
                  step="0.01"
                  placeholder="0.00"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors text-sm"
                />
                <div v-if="maxAvailableQuantity > 0" class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                  <span class="text-xs text-gray-500 bg-white px-2 py-1 rounded border border-gray-200">
                    Max: {{ formatQuantity(maxAvailableQuantity) }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Step 3: Transfer Summary -->
      <div v-if="showPreview" class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div class="bg-gradient-to-r from-amber-50 to-orange-50 px-4 py-3 border-b border-gray-200">
          <div class="flex items-center gap-2">
            <div class="w-6 h-6 bg-amber-100 rounded-full flex items-center justify-center">
              <span class="text-amber-600 font-bold text-xs">3</span>
            </div>
            <h3 class="text-sm font-semibold text-gray-800">Xác nhận chuyển đổi</h3>
          </div>
        </div>

        <div class="p-6 space-y-4">
          <!-- Transaction Summary -->
          <div class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl border border-blue-200 p-4">
            <div class="space-y-4">
              <h4 class="font-semibold text-gray-800 text-base mb-3">Chi tiết giao dịch</h4>

              <!-- Source Account -->
              <div class="bg-white rounded-lg p-3 border border-blue-300">
                <div class="flex justify-between items-center mb-2">
                  <div class="flex items-center gap-2">
                    <div class="w-6 h-6 bg-red-100 rounded-full flex items-center justify-center">
                      <svg class="w-3 h-3 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M7 16l-4-4m0 0l4-4m-4 4h14"
                        />
                      </svg>
                    </div>
                    <span class="font-medium text-gray-700 text-sm">Từ</span>
                  </div>
                  <span class="font-bold text-gray-900 text-sm text-right max-w-[120px] truncate">{{ getAccountName(transferForm.sourceAccountId) }}</span>
                </div>

                <div class="space-y-1">
                  <div class="flex justify-between">
                    <span class="text-xs text-gray-600">Currency:</span>
                    <span class="text-xs font-medium text-gray-900">{{ selectedCurrency?.currency_name || '-' }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-xs text-gray-600">Số lượng:</span>
                    <span class="text-xs font-bold text-red-600">-{{ formatQuantity(transferForm.quantity) }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-xs text-gray-600">Giá TB:</span>
                    <span class="text-xs font-medium text-gray-900">{{ formatCurrency(selectedCurrency?.avg_buy_price_vnd || 0, selectedCurrency?.cost_currency || 'VND') }} {{ getCurrencySymbol(selectedCurrency?.cost_currency || 'VND') }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-xs text-gray-600">Giá trị:</span>
                    <span class="text-xs font-bold text-orange-600">-{{ formatCurrency((transferForm.quantity * (selectedCurrency?.avg_buy_price_vnd || 0)), selectedCurrency?.cost_currency || 'VND') }} {{ getCurrencySymbol(selectedCurrency?.cost_currency || 'VND') }}</span>
                  </div>
                  <!-- Pool selection details -->
                  <div v-if="selectedCurrency && selectedCurrency.pools && selectedCurrency.pools.length > 1" class="mt-2 pt-2 border-t border-red-200">
                    <div class="text-xs text-gray-600 mb-1">Lấy từ {{ Math.min(3, selectedCurrency.pools.length) }} pool đầu:</div>
                    <div class="space-y-0.5">
                      <div
                        v-for="(pool, index) in selectedCurrency.pools.slice(0, 3)"
                        :key="pool.id"
                        class="text-xs text-red-600 flex justify-between"
                      >
                        <span>{{ pool.channel_name || `Pool ${index + 1}` }}:</span>
                        <span>{{ formatQuantity(getPoolQuantity(index)) }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Target Account -->
              <div class="bg-white rounded-lg p-3 border border-green-300">
                <div class="flex justify-between items-center mb-2">
                  <div class="flex items-center gap-2">
                    <div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center">
                      <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M17 8l4 4m0 0l-4 4m4-4H3"
                        />
                      </svg>
                    </div>
                    <span class="font-medium text-gray-700 text-sm">Đến</span>
                  </div>
                  <span class="font-bold text-gray-900 text-sm text-right max-w-[120px] truncate">{{ getAccountName(transferForm.targetAccountId) }}</span>
                </div>

                <div class="space-y-1">
                  <div class="flex justify-between">
                    <span class="text-xs text-gray-600">Hiện có:</span>
                    <span class="text-xs font-medium text-gray-900">{{ formatQuantity(targetCurrency?.quantity || 0) }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-xs text-gray-600">Sau chuyển:</span>
                    <span class="text-xs font-bold text-green-600">+{{ formatQuantity((targetCurrency?.quantity || 0) + transferForm.quantity) }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-xs text-gray-600">Giá TB mới:</span>
                    <span class="text-xs font-bold text-blue-600">{{ formatCurrency(calculatedNewAvgCost, selectedCurrency?.cost_currency || 'VND') }} {{ getCurrencySymbol(selectedCurrency?.cost_currency || 'VND') }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-xs text-gray-600">Tăng giá trị:</span>
                    <span class="text-xs font-bold text-green-600">+{{ formatCurrency((transferForm.quantity * (selectedCurrency?.avg_buy_price_vnd || 0)), selectedCurrency?.cost_currency || 'VND') }} {{ getCurrencySymbol(selectedCurrency?.cost_currency || 'VND') }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="flex flex-col gap-3 mt-6">
            <button
              @click="executeTransfer"
              :disabled="!canTransfer || loading"
              class="w-full bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-6 py-3 rounded-xl font-semibold shadow-lg hover:from-indigo-700 hover:to-purple-700 transition-all duration-200 disabled:from-gray-400 disabled:cursor-not-allowed"
            >
              <span v-if="loading" class="flex items-center justify-center">
                <svg class="animate-spin h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path
                    class="opacity-75"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="4"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M4 12v8a8 8 0 018 0H4z"
                  />
                </svg>
                Đang xử lý...
              </span>
              <span v-else class="flex items-center justify-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                  />
                </svg>
                Chuyển ngay
              </span>
            </button>
            <button
              @click="resetForm"
              class="w-full px-6 py-3 border border-gray-300 text-gray-700 rounded-xl font-medium hover:bg-gray-50 transition-all duration-200"
            >
              <span class="flex items-center justify-center gap-2">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                  />
                </svg>
                Đặt lại
              </span>
            </button>
          </div>
        </div>
      </div>

      <!-- Success/Error Messages -->
      <div v-if="message" class="mt-4">
        <div
          class="p-4 rounded-lg border-l-4"
          :class="messageType === 'success'
            ? 'bg-green-50 border-green-400 text-green-800'
            : 'bg-red-50 border-red-400 text-red-800'"
        >
          <div class="flex items-start gap-3">
            <div>
              <svg
                v-if="messageType === 'success'"
                class="w-5 h-5 text-green-600 mt-0.5"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 4 0-8-8-4 0-4 0 0 0 0 8z" clip-rule="evenodd"/>
                <path d="m10.344 15.97a.568.568 0 00.936-.06.568.568 0 00.631-.34.568.568 0 00.631-.34.568.568 0 00.845.254.568.568 0 00.845.254c.215.215.459.498.945.498.0 0 .332-.188.668-.188.338 0 0 .062.011.13.011.07.01.0zm-3.86-2.76a.75.75 0 00-.634-.634l-3.86 2.76z" clip-rule="evenodd"/>
                <path d="M10 8a.568.568 0 01.342-.115.568.568 0 01.063.011.075.011.075.01l.412.33c-.4.422.426.906.906.485 0 .503.376.485.5zM14.06 40a.568.568 0 01.342-.115.568.568 0 01.063.011.075.011.075.01l.412.33c.4.422.426.906.906.485 0 .503.376.485.5z" clip-rule="evenodd"/>
                <path
                  d="M15.757 6.096a.568.568 0 01-.057.007.09.014.09.007.014zM16.834 15.803a.568.568 0 00-.07.007.053.053.053-.045.055.057-.045zm-.011.007l-3.488.15c-.424-.4-.417-.852.045-.084.067-.084.063.12.012zm-2.504-2.176c-.095.095-.195.195-.195 0 0 .02.01.011.015.016l3.5-.37c.424.415.661.50.661.50 0 .062-.011.12-.011.013-.025z"
                  clip-rule="evenodd"
                />
              </svg>
              <div v-else class="w-5 h-5 text-red-600 mt-0.5">
                <svg fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 4 0-8-8-4 0 0 0 0 0zM8.707 7.293c1.251 1.252 1.252 3.275 0 4.527-3.277 4.527-4.527 0-.538-.014.537-.335.833.833 0 .531-.185.532.537.532 0 0 1.07.068zm1.06-1.06a.568.568 0 01-.718.071.718.071 0 .03.01.004.015.01.013.01.006l-3.012 2.692a.568.568 0 00-.01.635.635.635 0 0 1.082.15.108.15.013zm.613 2.244a.568.568 0 00-.701.088.701.088 0 0 .072.015.072.015.015zm-1.379 4.254a.568.568 0 00-.08.06.342.052.052.052 0 0 .04.001.012l-2.064-2.886a.568.568 0 00-.063-.011.445.445.445.445 0 0 .051.003.015.007.007l2.064 2.886z"/>
                </svg>
              </div>
            </div>
            <div class="flex-1">
              <p class="font-medium" :class="messageType === 'success' ? 'text-green-900' : 'text-red-900'">
                {{ message }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import { useCurrencyTransfer } from '@/composables/useCurrencyTransfer.js'

interface TransferForm {
  sourceAccountId: string | null
  targetAccountId: string | null
  currencyId: string | null // Format: "currencyAttributeId_costCurrency"
  quantity: number
}

interface Account {
  id: string
  account_name: string
  purpose: string
}

interface CurrencyPool {
  id: string
  quantity: number
  average_cost: number
  cost_currency: string
  last_updated_at: string
  channel_name?: string
}

interface Currency {
  currency_attribute_id: string
  currency_name: string
  quantity: number
  avg_buy_price_vnd: number
  cost_currency: string
  game_account_id?: string
  pools?: CurrencyPool[]
}

const props = defineProps<{
  gameCode: string
  serverCode: string
}>()

// Use currency transfer composable
const { transferCurrency, loading: transferLoading } = useCurrencyTransfer()

// Reactive state
const loading = ref(false)
const message = ref('')
const messageType = ref<'success' | 'error'>('success')
const availableAccounts = ref<Account[]>([])
const availableCurrencies = ref<Currency[]>([])
const groupedCurrencies = ref<Record<string, Currency[]>>({})
const allInventoryData = ref<Currency[]>([])

const transferForm = ref<TransferForm>({
  sourceAccountId: null,
  targetAccountId: null,
  currencyId: null,
  quantity: 0
})

// Computed properties
const maxAvailableQuantity = computed(() => {
  if (!transferForm.value.currencyId) return 0

  // Parse the combined key: "currencyAttributeId_costCurrency"
  const [currencyAttributeId, costCurrency] = transferForm.value.currencyId.split('_')

  // First try to find in availableCurrencies (individual entries with combined key)
  const currency = availableCurrencies.value.find(
    c => c.currency_attribute_id === currencyAttributeId && c.cost_currency === costCurrency
  )

  if (currency) return currency.quantity || 0

  // If not found in availableCurrencies, search in groupedCurrencies
  if (groupedCurrencies.value[costCurrency]) {
    const grouped = groupedCurrencies.value[costCurrency].find(
      c => c.currency_attribute_id === currencyAttributeId
    )
    if (grouped) return grouped.quantity || 0
  }

  return 0
})

const selectedCurrency = computed(() => {
  if (!transferForm.value.currencyId) return null

  // Parse the combined key: "currencyAttributeId_costCurrency"
  const [currencyAttributeId, costCurrency] = transferForm.value.currencyId.split('_')

  // First try to find in availableCurrencies (individual entries with combined key)
  const currency = availableCurrencies.value.find(
    c => c.currency_attribute_id === currencyAttributeId && c.cost_currency === costCurrency
  )

  if (currency) return currency

  // If not found in availableCurrencies, search in groupedCurrencies
  if (groupedCurrencies.value[costCurrency]) {
    const grouped = groupedCurrencies.value[costCurrency].find(
      c => c.currency_attribute_id === currencyAttributeId
    )
    if (grouped) return grouped
  }

  return null
})

const targetCurrency = computed(() => {
  if (!transferForm.value.targetAccountId || !transferForm.value.currencyId) return null

  const sourceCurrency = selectedCurrency.value
  if (!sourceCurrency) return null

  // Parse the combined key: "currencyAttributeId_costCurrency"
  const [currencyAttributeId] = transferForm.value.currencyId.split('_')

  return allInventoryData.value.find(
    c => c.currency_attribute_id === currencyAttributeId &&
    c.game_account_id === transferForm.value.targetAccountId
  ) || {
    currency_attribute_id: currencyAttributeId,
    currency_name: sourceCurrency.currency_name,
    quantity: 0,
    avg_buy_price_vnd: 0,
    cost_currency: sourceCurrency.cost_currency,
    game_account_id: transferForm.value.targetAccountId
  }
})

const calculatedNewAvgCost = computed(() => {
  const target = targetCurrency.value
  const source = selectedCurrency.value

  if (!target || !source || transferForm.value.quantity <= 0) {
    return source?.avg_buy_price_vnd || 0
  }

  const existingValue = (target.quantity || 0) * (target.avg_buy_price_vnd || 0)
  const transferValue = transferForm.value.quantity * source.avg_buy_price_vnd
  const totalQuantity = (target.quantity || 0) + transferForm.value.quantity

  if (totalQuantity === 0) return 0

  return (existingValue + transferValue) / totalQuantity
})

const canTransfer = computed(() => {
  return (
    transferForm.value.sourceAccountId &&
    transferForm.value.targetAccountId &&
    transferForm.value.currencyId &&
    transferForm.value.quantity > 0 &&
    transferForm.value.quantity <= maxAvailableQuantity.value &&
    transferForm.value.sourceAccountId !== transferForm.value.targetAccountId
  )
})

const showPreview = computed(() => {
  return canTransfer.value && transferForm.value.quantity > 0
})

// Methods
const formatQuantity = (amount: number) => {
  return new Intl.NumberFormat('vi-VN').format(amount)
}

const formatCurrency = (amount: number, currencyCode = 'VND') => {
  if (!amount && amount !== 0) return '0'

  if (currencyCode === 'VND') {
    return new Intl.NumberFormat('vi-VN', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(Math.round(amount))
  } else {
    return new Intl.NumberFormat('vi-VN', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 5
    }).format(amount)
  }
}

const formatDate = (dateString: string) => {
  try {
    const date = new Date(dateString)
    return new Intl.DateTimeFormat('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date)
  } catch {
    return dateString
  }
}

const getAccountName = (accountId: string | null) => {
  const account = availableAccounts.value.find(a => a.id === accountId)
  return account?.account_name || '-'
}

const getCurrencySymbol = (currencyCode: string) => {
  const symbols: { [key: string]: string } = {
    'VND': '₫',
    'USD': '$',
    'CNY': '¥',
    'EUR': '€',
    'JPY': '¥'
  }
  return symbols[currencyCode] || currencyCode
}

const getPoolQuantity = (poolIndex: number) => {
  if (!selectedCurrency.value || !selectedCurrency.value.pools || !transferForm.value.quantity) {
    return 0
  }

  let remainingQuantity = transferForm.value.quantity

  // Calculate how much to take from each pool based on FIFO
  for (let i = 0; i < poolIndex; i++) {
    const pool = selectedCurrency.value.pools[i]
    remainingQuantity -= Math.min(pool.quantity, remainingQuantity)
  }

  if (remainingQuantity <= 0) return 0

  const currentPool = selectedCurrency.value.pools[poolIndex]
  return Math.min(currentPool.quantity, remainingQuantity)
}

const loadAccounts = async () => {
  try {
    // First try to get accounts from game_accounts table
    const { data: gameAccountsData, error: gameAccountsError } = await supabase
      .from('game_accounts')
      .select('*')
      .eq('game_code', props.gameCode)
      .eq('server_attribute_code', props.serverCode)
      .eq('purpose', 'INVENTORY')
      .eq('is_active', true)
      .order('account_name')

    if (gameAccountsError) {
      console.warn('Error loading game_accounts:', gameAccountsError)
    }

    if (gameAccountsData && gameAccountsData.length > 0) {
      availableAccounts.value = gameAccountsData
      return
    }

    // Fallback: Get unique accounts from inventory_pools
    const { data: inventoryData, error: inventoryError } = await supabase
      .from('inventory_pools')
      .select(`
        game_account_id
      `)
      .eq('game_code', props.gameCode)
      .eq('server_attribute_code', props.serverCode)
      .not('game_account_id', 'is', null)

    if (inventoryError) throw inventoryError

    // Extract unique accounts from inventory data
    const uniqueAccounts = new Map()
    ;(inventoryData || []).forEach((item: any) => {
      if (item.game_account_id) {
        uniqueAccounts.set(item.game_account_id, {
          id: item.game_account_id,
          account_name: `Account ${item.game_account_id}`, // Fallback name
          purpose: 'INVENTORY'
        })
      }
    })

    // Try to get actual account names if possible
    const accountIds = Array.from(uniqueAccounts.keys())
    if (accountIds.length > 0) {
      const { data: accountDetails, error: detailsError } = await supabase
        .from('game_accounts')
        .select('id, account_name, purpose')
        .in('id', accountIds)

      if (!detailsError && accountDetails) {
        accountDetails.forEach(account => {
          const existing = uniqueAccounts.get(account.id)
          if (existing) {
            existing.account_name = account.account_name || existing.account_name
            existing.purpose = account.purpose || existing.purpose
          }
        })
      }
    }

    const accounts = Array.from(uniqueAccounts.values())
    availableAccounts.value = accounts

    if (availableAccounts.value.length === 0) {
      console.warn('No accounts found in game_accounts or inventory_pools')
      showMessage('Không tìm thấy account nào cho game/server này', 'error')
    }
  } catch (err) {
    console.error('Error loading accounts:', err)
    showMessage('Không thể tải danh sách accounts: ' + (err as Error).message, 'error')
  }
}

const loadAllInventory = async () => {
  try {

    const { data, error } = await supabase
      .from('inventory_pools')
      .select(`
        currency_attribute_id,
        quantity,
        average_cost,
        cost_currency,
        game_account_id,
        attributes!inventory_pools_currency_attribute_id_fkey (
          name,
          code
        )
      `)
      .eq('game_code', props.gameCode)
      .eq('server_attribute_code', props.serverCode)

    if (error) throw error

    // Transform data
    const transformedData = (data || []).map((item: any) => ({
      currency_attribute_id: item.currency_attribute_id,
      currency_name: (item.attributes as any)?.name || 'Unknown',
      quantity: parseFloat(item.quantity) || 0,
      avg_buy_price_vnd: parseFloat(item.average_cost) || 0,
      cost_currency: item.cost_currency,
      game_account_id: item.game_account_id
    }))

    allInventoryData.value = transformedData
  } catch (err) {
    console.error('Error loading inventory:', err)
  }
}

const onSourceAccountChange = () => {
  transferForm.value.currencyId = null
  transferForm.value.quantity = 0
  loadAvailableCurrencies()
}

const onCurrencyChange = () => {
  transferForm.value.quantity = 0
}

const loadAvailableCurrencies = async () => {
  if (!transferForm.value.sourceAccountId) {
    availableCurrencies.value = []
    groupedCurrencies.value = {}
    return
  }

  try {

    const { data, error } = await supabase
      .from('inventory_pools')
      .select(`
        id,
        currency_attribute_id,
        quantity,
        average_cost,
        cost_currency,
        game_account_id,
        last_updated_at,
        channels!channel_id!left (
          name
        ),
        attributes!inventory_pools_currency_attribute_id_fkey (
          name,
          code
        )
      `)
      .eq('game_code', props.gameCode)
      .eq('server_attribute_code', props.serverCode)
      .eq('game_account_id', transferForm.value.sourceAccountId)
      .gt('quantity', 0)
      .order('last_updated_at', { ascending: true }) // FIFO: oldest first

    if (error) throw error

    // Group by currency AND cost currency (key is combination of both)
    const currencyMap: Record<string, Currency> = {}
    const groupedMap: Record<string, Currency[]> = {}
    const totalQuantityByCurrency: Record<string, number> = {}

    ;(data || []).forEach((item: any) => {
      const currencyKey = item.currency_attribute_id
      const costCurrency = item.cost_currency
      const combinedKey = `${currencyKey}_${costCurrency}` // Key combining currency + cost currency

      const currentQuantity = parseFloat(item.quantity) || 0

      // Only include pools that have quantity > 0
      if (currentQuantity <= 0) {
        return
      }

      // Create pool entry with current quantity
      const pool: CurrencyPool = {
        id: item.id,
        quantity: currentQuantity, // Use current quantity directly
        average_cost: parseFloat(item.average_cost) || 0,
        cost_currency: item.cost_currency,
        last_updated_at: item.last_updated_at,
        channel_name: (item.channels as any)?.name || 'Unknown Channel'
      }

      // Track total quantity per currency (across all cost currencies)
      if (!totalQuantityByCurrency[currencyKey]) {
        totalQuantityByCurrency[currencyKey] = 0
      }
      totalQuantityByCurrency[currencyKey] += currentQuantity

      if (!currencyMap[combinedKey]) {
        currencyMap[combinedKey] = {
          currency_attribute_id: item.currency_attribute_id,
          currency_name: (item.attributes as any)?.name || 'Unknown',
          quantity: currentQuantity,
          avg_buy_price_vnd: parseFloat(item.average_cost) || 0,
          cost_currency: item.cost_currency, // Keep the specific cost currency
          game_account_id: item.game_account_id,
          pools: [pool] // Initialize pools array
        }
      } else {
        // Update existing entry
        currencyMap[combinedKey].quantity += currentQuantity
        currencyMap[combinedKey].pools!.push(pool)
        // Calculate weighted average cost
        const totalValue = (currencyMap[combinedKey].avg_buy_price_vnd * (currencyMap[combinedKey].quantity - currentQuantity)) +
                          (pool.average_cost * currentQuantity)
        currencyMap[combinedKey].avg_buy_price_vnd = currencyMap[combinedKey].quantity > 0 ? totalValue / currencyMap[combinedKey].quantity : 0
      }

      // Group by cost currency for display - but ensure each currency appears once per cost currency
      if (!groupedMap[costCurrency]) {
        groupedMap[costCurrency] = []
      }

      const existingGrouped = groupedMap[costCurrency].find(c => c.currency_attribute_id === currencyKey)
      if (!existingGrouped) {
        groupedMap[costCurrency].push({
          ...currencyMap[combinedKey]
        })
      } else {
        // If currency already exists in this cost currency group, update its quantity
        existingGrouped.quantity += currentQuantity
        // Recalculate weighted average cost for the grouped item
        const totalValue = (existingGrouped.avg_buy_price_vnd * (existingGrouped.quantity - currentQuantity)) +
                          (pool.average_cost * currentQuantity)
        existingGrouped.avg_buy_price_vnd = existingGrouped.quantity > 0 ? totalValue / existingGrouped.quantity : 0
      }
    })

    // Remove the quantity overriding logic - keep quantities as calculated per cost currency
    // This ensures each cost currency group shows only the quantity for that specific cost currency

    availableCurrencies.value = Object.values(currencyMap)
    groupedCurrencies.value = groupedMap

    if (availableCurrencies.value.length === 0) {
      showMessage('Account nguồn không có currency nào available để chuyển', 'error')
    }
  } catch (err) {
    console.error('Error loading available currencies:', err)
    showMessage('Không thể tải danh sách currencies: ' + (err as Error).message, 'error')
  }
}

const executeTransfer = async () => {
  if (!canTransfer.value) return

  loading.value = true
  message.value = ''

  try {
    // Parse the combined key: "currencyAttributeId_costCurrency"
    const [currencyAttributeId] = transferForm.value.currencyId!.split('_')

    const result = await transferCurrency({
      sourceAccountId: transferForm.value.sourceAccountId!,
      targetAccountId: transferForm.value.targetAccountId!,
      currencyId: currencyAttributeId, // Use only the currency attribute ID for the transfer
      quantity: transferForm.value.quantity,
      gameCode: props.gameCode,
      serverCode: props.serverCode,
      notes: `Transfer ${transferForm.value.quantity} ${selectedCurrency.value?.currency_name} from ${getAccountName(transferForm.value.sourceAccountId)} to ${getAccountName(transferForm.value.targetAccountId)}`
    })

    showMessage(`Chuyển thành công ${transferForm.value.quantity} ${selectedCurrency.value?.currency_name}!`, 'success')
    resetForm()

    // Emit event to refresh inventory data
    emit('transfer-completed', result)
  } catch (err) {
    console.error('Transfer error:', err)
    showMessage('Lỗi khi chuyển currency: ' + (err as Error).message, 'error')
  } finally {
    loading.value = false
  }
}

const resetForm = () => {
  transferForm.value = {
    sourceAccountId: null,
    targetAccountId: null,
    currencyId: null,
    quantity: 0
  }
  availableCurrencies.value = []
  message.value = ''
}

const showMessage = (msg: string, type: 'success' | 'error') => {
  message.value = msg
  messageType.value = type
}

// Define emits
const emit = defineEmits<{
  'transfer-completed': [result: any]
}>()

// Lifecycle
onMounted(async () => {
  await Promise.all([
    loadAccounts(),
    loadAllInventory()
  ])
})

// Watch for changes
watch(() => props.gameCode, () => {
  resetForm()
  loadAccounts()
  loadAllInventory()
})

watch(() => props.serverCode, () => {
  resetForm()
  loadAccounts()
  loadAllInventory()
})
</script>