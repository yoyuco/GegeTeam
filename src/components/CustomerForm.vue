<!-- path: src/components/CustomerForm.vue -->
<!-- Customer/Supplier Information Form Component with Tabs -->
<template>
  <div class="bg-white rounded-xl shadow-sm border border-gray-200">
    <!-- Tab Headers -->
    <div class="flex border-b border-gray-200">
      <button
        :class="[
          'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
          activeTab === 'customer'
            ? 'tab-active text-blue-600 border-b-2 border-blue-600'
            : 'tab-inactive text-gray-500 hover:text-gray-700',
        ]"
        @click="activeTab = 'customer'"
      >
        <svg class="w-4 h-4 tab-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
          />
        </svg>
        Thông tin khách hàng
      </button>
      <button
        :class="[
          'px-6 py-4 text-sm font-medium transition-all duration-200 flex items-center gap-2',
          activeTab === 'supplier'
            ? 'tab-active text-green-600 border-b-2 border-green-600'
            : 'tab-inactive text-gray-500 hover:text-gray-700',
        ]"
        @click="activeTab = 'supplier'"
      >
        <svg class="w-4 h-4 tab-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
          />
        </svg>
        Thông tin nhà cung cấp
      </button>
    </div>

    <!-- Tab Content -->
    <div class="p-6">
      <!-- Customer Tab -->
      <div v-if="activeTab === 'customer'" class="space-y-6">
        <div class="flex items-center gap-2 mb-4">
          <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
              />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-gray-800">Thông tin khách hàng</h3>
        </div>

        <!-- Channel Selection -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-pink-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Kênh bán</label>
          </div>
          <n-select
            v-model:value="customerFormData.channelId"
            :options="customerChannelOptions"
            placeholder="Chọn kênh bán (G2G, PlayerAuctions...)"
            filterable
            :loading="loading"
            size="large"
            class="w-full"
          />
        </div>

        <!-- Customer Name -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-orange-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Tên khách hàng</label>
          </div>
          <n-input
            v-model:value="customerFormData.customerName"
            placeholder="Nhập tên khách hàng"
            size="large"
            class="w-full"
          />
        </div>

        <!-- Game Tag -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-purple-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">{{ gameCustomerInfoLabel }}</label>
          </div>
          <n-input
            v-model:value="customerFormData.gameTag"
            :placeholder="gameCustomerInfoPlaceholder"
            size="large"
            class="w-full"
          />
        </div>

        <!-- Delivery Info -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-green-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Thông tin giao hàng</label>
          </div>
          <n-input
            v-model:value="customerFormData.deliveryInfo"
            placeholder="Email, Discord, hoặc thông tin liên hệ khác"
            type="textarea"
            :rows="3"
            size="large"
            class="w-full"
          />
        </div>
      </div>

      <!-- Supplier Tab -->
      <div v-if="activeTab === 'supplier'" class="space-y-6">
        <div class="flex items-center gap-2 mb-4">
          <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
            <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
              />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-gray-800">Thông tin nhà cung cấp</h3>
        </div>

        <!-- Channel Selection -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-pink-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Kênh mua</label>
          </div>
          <n-select
            v-model:value="supplierFormData.channelId"
            :options="supplierChannelOptions"
            placeholder="Chọn kênh mua (Facebook, Zalo...)"
            filterable
            :loading="loading"
            size="large"
            class="w-full"
          />
        </div>

        <!-- Supplier Name -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-orange-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Tên nhà cung cấp</label>
          </div>
          <n-input
            v-model:value="supplierFormData.customerName"
            placeholder="Nhập tên nhà cung cấp"
            size="large"
            class="w-full"
          />
        </div>

        <!-- Game Tag -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-purple-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Tên nhân vật / ID</label>
          </div>
          <n-input
            v-model:value="supplierFormData.gameTag"
            :placeholder="gameCustomerInfoPlaceholder"
            size="large"
            class="w-full"
          />
        </div>

        <!-- Contact Info -->
        <div>
          <div class="flex items-center gap-2 mb-3">
            <div class="w-6 h-6 bg-green-100 rounded flex items-center justify-center">
              <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                />
              </svg>
            </div>
            <label class="text-sm font-medium text-gray-700">Thông tin liên hệ</label>
          </div>
          <n-input
            v-model:value="supplierFormData.deliveryInfo"
            placeholder="Email, SĐT, Zalo, hoặc thông tin liên hệ khác"
            type="textarea"
            :rows="3"
            size="large"
            class="w-full"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, watch, ref } from 'vue'
import { NSelect, NInput } from 'naive-ui'
import type { Channel } from '@/types/composables'

// Props
interface Props {
  customerModelValue: {
    channelId: string | null
    customerName: string
    gameTag: string
    deliveryInfo: string
  }
  supplierModelValue: {
    channelId: string | null
    customerName: string
    gameTag: string
    deliveryInfo: string
  }
  channels: () => Channel[]
  loading?: boolean
  gameCode?: string
  activeTab?: 'customer' | 'supplier'
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  gameCode: '',
  activeTab: 'customer'
})

// Emits
const emit = defineEmits<{
  'update:customerModelValue': [value: Props['customerModelValue']]
  'update:supplierModelValue': [value: Props['supplierModelValue']]
  'update:activeTab': [value: 'customer' | 'supplier']
  'customer-changed': [customer: { name: string } | null]
  'game-tag-changed': [gameTag: string]
  'supplier-changed': [supplier: { name: string } | null]
  'supplier-game-tag-changed': [gameTag: string]
}>()

// Reactive state
const activeTab = ref<'customer' | 'supplier'>(props.activeTab)

// Form data
const customerFormData = computed({
  get: () => props.customerModelValue,
  set: (value) => emit('update:customerModelValue', value),
})

const supplierFormData = computed({
  get: () => props.supplierModelValue,
  set: (value) => emit('update:supplierModelValue', value),
})

// Computed properties
const loading = computed(() => props.loading)

const customerChannelOptions = computed(() => {
  return props.channels()
    .filter((channel: Channel) => channel.channel_type === 'SALES')
    .map((channel: Channel) => ({
      label: channel.name,
      value: channel.id,
    }))
})

const supplierChannelOptions = computed(() => {
  return props.channels()
    .filter((channel: Channel) => channel.channel_type === 'PURCHASE')
    .map((channel: Channel) => ({
      label: channel.name,
      value: channel.id,
    }))
})

const gameCustomerInfoLabel = computed(() => {
  switch (props.gameCode) {
    case 'POE1':
    case 'POE2':
      return 'Tên nhân vật (Character Name)'
    case 'LOST_ARK':
      return 'Tên nhân vật (Character Name)'
    case 'DIABLO_4':
      return 'BattleTag/ID'
    case 'WOW':
      return 'Tên nhân vật (Character Name)'
    default:
      return 'Tên nhân vật / ID'
  }
})

const gameCustomerInfoPlaceholder = computed(() => {
  switch (props.gameCode) {
    case 'POE1':
    case 'POE2':
      return 'Ví dụ: CharacterName'
    case 'LOST_ARK':
      return 'Ví dụ: CharacterName'
    case 'DIABLO_4':
      return 'Ví dụ: Player#1234'
    case 'WOW':
      return 'Ví dụ: CharacterName-RealmName'
    default:
      return 'Tên nhân vật hoặc ID game'
  }
})

// Watch for tab changes
watch(activeTab, (newTab) => {
  emit('update:activeTab', newTab)
})

// Watch for customer form changes and emit events
watch(
  () => customerFormData.value.customerName,
  (newName: string) => {
    emit('customer-changed', newName ? { name: newName } : null)
  }
)

watch(
  () => customerFormData.value.gameTag,
  (newGameTag: string) => {
    emit('game-tag-changed', newGameTag || '')
  }
)

// Watch for supplier form changes and emit events
watch(
  () => supplierFormData.value.customerName,
  (newName: string) => {
    emit('supplier-changed', newName ? { name: newName } : null)
  }
)

watch(
  () => supplierFormData.value.gameTag,
  (newGameTag: string) => {
    emit('supplier-game-tag-changed', newGameTag || '')
  }
)

// Expose methods for parent component
defineExpose({
  customerFormData,
  supplierFormData,
  activeTab,
})
</script>

<style scoped>
.tab-active {
  background: linear-gradient(to bottom, transparent, rgba(59, 130, 246, 0.05));
}

.tab-inactive {
  position: relative;
}

.tab-inactive:hover {
  background: linear-gradient(to bottom, transparent, rgba(156, 163, 175, 0.05));
}

.tab-icon {
  transition: all 0.2s ease;
}

.tab-active .tab-icon {
  transform: scale(1.1);
}

/* Form field styling */
.space-y-6 > div {
  transition: all 0.2s ease;
}

.space-y-6 > div:hover {
  transform: translateX(2px);
}
</style>