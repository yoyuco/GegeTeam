<!-- path: src/components/currency/CurrencyInventoryPanel.vue -->
<!-- Enhanced Currency Inventory Panel - Push Style -->
<template>
  <!-- Slide-out panel - no overlay, pure push style -->
  <div v-if="isOpen" class="inventory-panel">
    <div class="bg-white h-full flex flex-col">
      <!-- Header -->
      <div class="bg-gradient-to-r from-indigo-600 to-purple-600 text-white p-4 rounded-t-lg">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                />
              </svg>
            </div>
            <div>
              <h3 class="font-bold text-lg">Thông tin Kho</h3>
              <p class="text-indigo-100 text-sm">{{ inventoryData.length }} loại currency</p>
            </div>
          </div>
          <button
            class="w-8 h-8 bg-white/20 hover:bg-white/30 rounded-lg flex items-center justify-center transition-colors"
            @click="$emit('close')"
          >
            <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-hidden">
        <n-scrollbar style="max-height: calc(100vh - 120px)" class="p-4">
          <!-- Summary Stats -->
          <div class="grid grid-cols-2 gap-3 mb-6">
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-3">
              <div class="flex items-center gap-2">
                <div class="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center">
                  <svg
                    class="w-3 h-3 text-blue-600"
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
                  <p class="text-xs text-blue-600 font-medium">Tổng giá trị</p>
                  <p class="text-sm font-bold text-blue-900">{{ formatCurrency(totalValue) }} ₫</p>
                </div>
              </div>
            </div>
            <div class="bg-green-50 border border-green-200 rounded-lg p-3">
              <div class="flex items-center gap-2">
                <div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center">
                  <svg
                    class="w-3 h-3 text-green-600"
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
                </div>
                <div>
                  <p class="text-xs text-green-600 font-medium">Đang giữ</p>
                  <p class="text-sm font-bold text-green-900">
                    {{ totalReserved.toLocaleString() }}
                  </p>
                </div>
              </div>
            </div>
          </div>

          <!-- Currency Items -->
          <div v-if="inventoryData.length === 0" class="text-center py-8">
            <div
              class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4"
            >
              <svg
                class="w-8 h-8 text-gray-400"
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
            </div>
            <h3 class="text-gray-900 font-medium mb-1">Chưa có dữ liệu</h3>
            <p class="text-gray-500 text-sm">Chưa có currency trong kho</p>
          </div>

          <div v-else class="space-y-4">
            <div
              v-for="item in inventoryData"
              :key="item.currency"
              class="bg-white border border-gray-200 rounded-lg overflow-hidden hover:shadow-md transition-shadow"
            >
              <!-- Currency Header -->
              <div class="bg-gradient-to-r from-gray-50 to-gray-100 p-4 border-b border-gray-200">
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-3">
                    <div
                      class="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center"
                    >
                      <span class="text-white font-bold text-sm">{{
                        item.currency.charAt(0)
                      }}</span>
                    </div>
                    <div>
                      <h4 class="font-semibold text-gray-900">{{ item.currency }}</h4>
                      <p class="text-xs text-gray-500">Tổng: {{ item.total.toLocaleString() }}</p>
                    </div>
                  </div>
                  <div class="text-right">
                    <p class="text-sm font-medium text-gray-900">
                      {{ formatCurrency(item.total * item.avgVND) }} ₫
                    </p>
                    <p class="text-xs text-gray-500">${{ item.avgUSD }}</p>
                  </div>
                </div>
              </div>

              <!-- Currency Details -->
              <div class="p-4">
                <div class="grid grid-cols-2 gap-4 mb-4">
                  <div class="bg-gray-50 rounded-lg p-3">
                    <div class="flex items-center gap-2 mb-1">
                      <svg
                        class="w-4 h-4 text-blue-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
                        />
                      </svg>
                      <span class="text-xs font-medium text-gray-600">Sẵn có</span>
                    </div>
                    <p class="text-lg font-bold text-gray-900">
                      {{ (item.total - item.reserved).toLocaleString() }}
                    </p>
                  </div>
                  <div class="bg-orange-50 rounded-lg p-3">
                    <div class="flex items-center gap-2 mb-1">
                      <svg
                        class="w-4 h-4 text-orange-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                        />
                      </svg>
                      <span class="text-xs font-medium text-gray-600">Đang giữ</span>
                    </div>
                    <p class="text-lg font-bold text-orange-600">
                      {{ item.reserved.toLocaleString() }}
                    </p>
                  </div>
                </div>

                <!-- Account Details -->
                <div v-if="item.accounts && item.accounts.length > 0" class="border-t pt-3">
                  <div class="flex items-center gap-2 mb-3">
                    <svg
                      class="w-4 h-4 text-gray-600"
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
                    <span class="text-sm font-medium text-gray-700">Chi tiết theo Account</span>
                  </div>
                  <div class="space-y-2">
                    <div
                      v-for="acc in item.accounts"
                      :key="acc.name"
                      class="flex items-center justify-between bg-gray-50 rounded-lg p-2"
                    >
                      <div class="flex items-center gap-2">
                        <div
                          class="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center"
                        >
                          <svg
                            class="w-3 h-3 text-blue-600"
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
                        </div>
                        <span class="text-sm font-medium text-gray-700">{{ acc.name }}</span>
                      </div>
                      <span class="text-sm font-bold text-gray-900">{{
                        acc.amount.toLocaleString()
                      }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </n-scrollbar>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, watch, onUnmounted } from 'vue'
import { NScrollbar } from 'naive-ui'
import type { PropType } from 'vue'

// Định nghĩa một interface cho cấu trúc dữ liệu inventory để code chặt chẽ hơn
interface InventoryItem {
  currency: string
  total: number
  reserved: number
  avgUSD: number
  avgVND: number
  accounts: Array<{ name: string; amount: number }>
}

// Props để nhận dữ liệu và trạng thái từ component cha
const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  inventoryData: {
    type: Array as PropType<InventoryItem[]>,
    default: () => [],
  },
})

// Emits
defineEmits<{
  close: []
}>()

// Computed properties
const totalValue = computed(() => {
  return props.inventoryData.reduce((total, item) => {
    return total + item.total * item.avgVND
  }, 0)
})

const totalReserved = computed(() => {
  return props.inventoryData.reduce((total, item) => {
    return total + item.reserved
  }, 0)
})

// Utility function for currency formatting
const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('vi-VN').format(Math.round(amount))
}

// Toggle body margin to push content when panel opens/closes
watch(
  () => props.isOpen,
  (isOpen: boolean) => {
    if (isOpen) {
      document.body.style.marginRight = '380px'
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.marginRight = '0'
      document.body.style.overflow = ''
    }
  }
)

onUnmounted(() => {
  // Clean up styles when component is unmounted
  document.body.style.marginRight = '0'
  document.body.style.overflow = ''
})
</script>

<style scoped>
.inventory-panel {
  position: fixed;
  right: 0;
  top: 0;
  bottom: 0;
  width: 380px;
  background: #ffffff;
  border-left: 1px solid #e5e7eb;
  z-index: 10;
  transform: translateX(0);
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: -2px 0 10px rgba(0, 0, 0, 0.05);
}

/* Panel animation */
.inventory-panel {
  animation: slideIn 0.3s ease-out;
  height: 100vh;
  overflow: hidden;
}

/* Body transition for smooth push effect */
:global(body) {
  transition: margin-right 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

/* Custom scrollbar styling */
:deep(.n-scrollbar-rail) {
  background-color: #f3f4f6;
  border-radius: 4px;
}

:deep(.n-scrollbar-bar) {
  background-color: #9ca3af;
  border-radius: 4px;
}

:deep(.n-scrollbar-bar:hover) {
  background-color: #6b7280;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .inventory-panel {
    width: 100vw;
  }
}

@media (max-width: 640px) {
  .inventory-panel {
    width: 100vw;
  }
}

/* Hover effects for interactive elements */
.inventory-panel .hover\:shadow-md:hover {
  box-shadow:
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Transition for all interactive elements */
.inventory-panel * {
  transition: all 0.2s ease-in-out;
}

/* Improve readability */
.inventory-panel {
  font-family:
    'Inter',
    -apple-system,
    BlinkMacSystemFont,
    'Segoe UI',
    Roboto,
    sans-serif;
}

/* Add subtle borders and shadows */
.inventory-panel .border-gray-200 {
  border-color: #e5e7eb;
}

.inventory-panel .shadow-md {
  box-shadow:
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06);
}
</style>
