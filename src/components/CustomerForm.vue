<!-- path: src/components/CustomerForm.vue -->
<!-- Customer Information Form Component -->
<template>
  <div class="bg-gradient-to-br from-gray-50 to-white rounded-xl p-6">
    <!-- Channel Selection -->
    <div class="mb-6">
      <div class="flex items-center gap-2 mb-3">
        <div class="w-8 h-8 bg-pink-100 rounded-lg flex items-center justify-center">
          <svg class="w-4 h-4 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"
            />
          </svg>
        </div>
        <label class="text-sm font-semibold text-gray-700">Kênh bán</label>
      </div>
      <n-select
        v-model:value="formData.channelId"
        :options="channelOptions"
        placeholder="Chọn kênh bán (G2G, PlayerAuctions...)"
        filterable
        :loading="loading"
        size="large"
        class="w-full"
      />
    </div>

    <!-- Customer Name -->
    <div class="mb-6">
      <div class="flex items-center gap-2 mb-3">
        <div class="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center">
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
              d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
            />
          </svg>
        </div>
        <label class="text-sm font-semibold text-gray-700">Tên khách hàng</label>
      </div>
      <n-input
        v-model:value="formData.customerName"
        placeholder="Tên/biệt danh của khách"
        size="large"
        class="w-full"
      />
    </div>

    <!-- Game-specific Field -->
    <div class="mb-6">
      <div class="flex items-center gap-2 mb-3">
        <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center">
          <svg
            class="w-4 h-4 text-purple-600"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M11 4a2 2 0 114 0v1a1 1 0 001 1h3a1 1 0 011 1v3a1 1 0 01-1 1h-1a2 2 0 100 4h1a1 1 0 011 1v3a1 1 0 01-1 1h-3a1 1 0 01-1-1v-1a2 2 0 10-4 0v1a1 1 0 01-1 1H7a1 1 0 01-1-1v-3a1 1 0 00-1-1H4a2 2 0 110-4h1a1 1 0 001-1V7a1 1 0 011-1h3a1 1 0 001-1V4z"
            />
          </svg>
        </div>
        <label class="text-sm font-semibold text-gray-700">{{ gameCustomerInfoLabel }}</label>
      </div>
      <n-input
        v-model:value="formData.gameTag"
        :placeholder="gameCustomerInfoPlaceholder"
        size="large"
        class="w-full"
      />
    </div>

    <!-- Delivery Information -->
    <div class="mb-6">
      <div class="flex items-center gap-2 mb-3">
        <div class="w-8 h-8 bg-yellow-100 rounded-lg flex items-center justify-center">
          <svg
            class="w-4 h-4 text-yellow-600"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
            />
          </svg>
        </div>
        <label class="text-sm font-semibold text-gray-700">Link/DM giao hàng</label>
      </div>
      <n-input
        v-model:value="formData.deliveryInfo"
        placeholder="Link Discord message, forum, game link..."
        size="large"
        class="w-full"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, watch } from 'vue'
import { NSelect, NInput } from 'naive-ui'
import type { Channel } from '@/types/composables'

// Props
interface Props {
  modelValue: {
    channelId: string | null
    customerName: string
    gameTag: string
    deliveryInfo: string
  }
  gameCode?: string | null
  channelType?: string
  channels?: Channel[]
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  gameCode: null,
  channelType: 'SALES',
  channels: () => [],
  loading: false,
})

// Emits
const emit = defineEmits<{
  'update:modelValue': [value: Props['modelValue']]
  'customer-changed': [customer: { name: string } | null]
  'game-tag-changed': [gameTag: string]
}>()

// Use props instead of useCurrency to ensure reactivity
const channels = computed(() => props.channels)
const loading = computed(() => props.loading)

// Computed properties
const formData = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value),
})

const channelOptions = computed(() => {
  return channels.value
    .filter((channel: Channel) => channel.channel_type === props.channelType)
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
    case 'D4':
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
    case 'D4':
      return 'Ví dụ: Player#1234'
    case 'WOW':
      return 'Ví dụ: CharacterName-RealmName'
    default:
      return 'Tên nhân vật hoặc ID game'
  }
})

// Watch for changes and emit events
watch(
  () => formData.value.customerName,
  (newName: string) => {
    emit('customer-changed', newName ? { name: newName } : null)
  }
)

watch(
  () => formData.value.gameTag,
  (newGameTag: string) => {
    emit('game-tag-changed', newGameTag || '')
  }
)
</script>
