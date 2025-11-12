<!-- path: src/components/CustomerForm.vue -->
<!-- Customer/Supplier Information Form Component with Tabs -->
<template>
  <div class="bg-white rounded-xl shadow-sm border border-gray-200">
      <!-- Tab Content -->
    <div class="p-6">
      <!-- Customer Tab -->
      <div v-if="formMode === 'customer' || (!formMode && activeTab === 'customer')" class="space-y-6">

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
            <span class="text-red-500">*</span>
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
            <span class="text-red-500">*</span>
          </div>
          <n-auto-complete
            v-model:value="customerFormData.customerName"
            :options="customerOptions.map(opt => ({ label: opt.label, value: opt.label }))"
            :loading="customerLoading"
            placeholder="Nhập hoặc chọn khách hàng"
            size="large"
            class="w-full"
            clearable
            @update:value="(value) => {
              customerSearchText = value || ''
              // Also update the customer data when selecting from dropdown
              const selected = customerOptions.find(opt => opt.label === value)
              if (selected) {
                // Pre-fill contact info if available
                if (selected.data.contact_info?.contact) {
                  customerFormData.deliveryInfo = selected.data.contact_info.contact
                }
                // Pre-fill game tag from parties contact_info (not customer_accounts)
                const gameTag = getCustomerGameTag(selected.data, props.gameCode)
                if (gameTag) {
                  customerFormData.gameTag = gameTag
                }
              }
            }"
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
            <span class="text-red-500">*</span>
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
            size="large"
            class="w-full"
          />
        </div>
      </div>

      <!-- Supplier Tab -->
      <div v-if="formMode === 'supplier' || (!formMode && activeTab === 'supplier')" class="space-y-6">

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
              <span class="text-red-500">*</span>
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
            <span class="text-red-500">*</span>
          </div>
          <n-auto-complete
            v-model:value="supplierFormData.customerName"
            :options="supplierOptions.map(opt => ({ label: opt.label, value: opt.label }))"
            :loading="supplierLoading"
            placeholder="Nhập hoặc chọn nhà cung cấp"
            size="large"
            class="w-full"
            clearable
            @update:value="(value) => {
              supplierSearchText = value || ''
              // Also update the supplier data when selecting from dropdown
              const selected = supplierOptions.find(opt => opt.label === value)
              if (selected) {
                // Pre-fill contact info if available
                if (selected.data.contact_info?.contact) {
                  supplierFormData.deliveryInfo = selected.data.contact_info.contact
                }
              }
            }"
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
            <span class="text-red-500">*</span>
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
import { NSelect, NInput, NAutoComplete } from 'naive-ui'
import type { Channel } from '@/types/composables'
import {
  loadSuppliersOrCustomersByChannel,
  searchSuppliersOrCustomers,
  createSupplierOrCustomer,
  getCustomerGameTag,
  type SupplierCustomerOption
} from '@/composables/useSupplierCustomer'

// Props
interface Props {
  modelValue?: {
    channelId: string | null
    customerName: string
    gameTag: string
    deliveryInfo: string
  }
  customerModelValue?: {
    channelId: string | null
    customerName: string
    gameTag: string
    deliveryInfo: string
  }
  supplierModelValue?: {
    channelId: string | null
    customerName: string
    gameTag: string
    deliveryInfo: string
  }
  channels?: Channel[]
  loading?: boolean
  gameCode?: string
  activeTab?: 'customer' | 'supplier'
  formMode?: 'customer' | 'supplier'
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  gameCode: '',
  activeTab: 'customer',
  formMode: 'customer'
})

// Emits
const emit = defineEmits<{
  'update:modelValue': [value: Props['modelValue']]
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

// Supplier loading state
const supplierOptions = ref<SupplierCustomerOption[]>([])
const supplierLoading = ref(false)
const supplierSearchText = ref('')

// Customer loading state
const customerOptions = ref<SupplierCustomerOption[]>([])
const customerLoading = ref(false)
const customerSearchText = ref('')

// Form data
const customerFormData = computed({
  get: () => {
    // Use different props based on form mode
    if (props.formMode === 'supplier') {
      return props.supplierModelValue || props.modelValue || {
        channelId: null,
        customerName: '',
        gameTag: '',
        deliveryInfo: ''
      }
    }
    return props.customerModelValue || props.modelValue || {
      channelId: null,
      customerName: '',
      gameTag: '',
      deliveryInfo: ''
    }
  },
  set: (value) => {
    if (props.formMode === 'supplier') {
      emit('update:supplierModelValue', value)
    } else {
      emit('update:customerModelValue', value)
    }
  },
})

const supplierFormData = computed({
  get: () => props.supplierModelValue || props.modelValue || {
    channelId: null,
    customerName: '',
    gameTag: '',
    deliveryInfo: ''
  },
  set: (value) => emit('update:supplierModelValue', value),
})

// Computed properties
const loading = computed(() => props.loading)

const customerChannelOptions = computed(() => {
  return (props.channels || [])
    .filter((channel: Channel) =>
      (channel.direction === 'SELL' || channel.direction === 'BOTH') &&
      channel.code !== 'DEFAULT'
    )
    .map((channel: Channel) => ({
      label: channel.name,
      value: channel.id,
    }))
})

const supplierChannelOptions = computed(() => {
  return (props.channels || [])
    .filter((channel: Channel) =>
      (channel.direction === 'BUY' || channel.direction === 'BOTH') &&
      channel.code !== 'DEFAULT'
    )
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
  () => customerFormData.value?.customerName,
  (newName: string) => {
    emit('customer-changed', newName ? { name: newName } : null)
  }
)

watch(
  () => customerFormData.value?.gameTag,
  (newGameTag: string) => {
    emit('game-tag-changed', newGameTag || '')
  }
)

// Watch for supplier form changes and emit events
watch(
  () => supplierFormData.value?.customerName,
  (newName: string) => {
    emit('supplier-changed', newName ? { name: newName } : null)
  }
)

watch(
  () => supplierFormData.value?.gameTag,
  (newGameTag: string) => {
    emit('supplier-game-tag-changed', newGameTag || '')
  }
)

// Supplier loading functions
const loadSuppliers = async (channelId: string) => {
  if (!channelId) {
    supplierOptions.value = []
    return
  }

  supplierLoading.value = true
  try {
    const suppliers = await loadSuppliersOrCustomersByChannel(channelId, 'supplier')
    supplierOptions.value = suppliers
  } catch (error) {
    console.error('Error loading suppliers:', error)
    supplierOptions.value = []
  } finally {
    supplierLoading.value = false
  }
}

const searchSuppliers = async (search: string) => {
  const channelId = supplierFormData.value?.channelId
  if (!channelId || !search) {
    supplierOptions.value = []
    return
  }

  supplierLoading.value = true
  try {
    const suppliers = await searchSuppliersOrCustomers(search, channelId, 'supplier', props.gameCode)
    supplierOptions.value = suppliers
  } catch (error) {
    console.error('Error searching suppliers:', error)
    supplierOptions.value = []
  } finally {
    supplierLoading.value = false
  }
}

const createNewSupplier = async (name: string) => {
  const channelId = supplierFormData.value?.channelId
  if (!channelId || !name) return null

  try {
    const newSupplier = await createSupplierOrCustomer(
      name,
      'supplier',
      channelId,
      supplierFormData.value?.deliveryInfo,
      undefined,
      props.gameCode
    )
    return newSupplier
  } catch (error) {
    console.error('Error creating supplier:', error)
    return null
  }
}

// Customer loading functions
const loadCustomers = async (channelId: string) => {
  if (!channelId) {
    customerOptions.value = []
    return
  }

  customerLoading.value = true
  try {
        const customers = await loadSuppliersOrCustomersByChannel(channelId, 'customer', props.gameCode)
        customerOptions.value = customers
  } catch (error) {
    console.error('Error loading customers:', error)
    customerOptions.value = []
  } finally {
    customerLoading.value = false
  }
}

const searchCustomers = async (search: string) => {
  const channelId = customerFormData.value?.channelId
  if (!channelId || !search) {
    customerOptions.value = []
    return
  }

  customerLoading.value = true
  try {
    const customers = await searchSuppliersOrCustomers(search, channelId, 'customer', props.gameCode)
    customerOptions.value = customers
  } catch (error) {
    console.error('Error searching customers:', error)
    customerOptions.value = []
  } finally {
    customerLoading.value = false
  }
}

// Watch for channel changes in supplier mode
watch(
  () => supplierFormData.value?.channelId,
  async (newChannelId: string | null) => {
    if (newChannelId && (props.formMode === 'supplier' || activeTab.value === 'supplier')) {
      await loadSuppliers(newChannelId)
    }
  },
  { immediate: true }
)

// Watch for supplier search
watch(
  supplierSearchText,
  (newSearch: string) => {
    if (newSearch.length >= 2) {
      searchSuppliers(newSearch)
    } else if (newSearch.length === 0) {
      // Reload all suppliers when search is cleared
      const channelId = supplierFormData.value?.channelId
      if (channelId) {
        loadSuppliers(channelId)
      }
    }
  }
)

// Watch for channel changes in customer mode
watch(
  () => customerFormData.value?.channelId,
  async (newChannelId: string | null) => {
    if (newChannelId && (props.formMode === 'customer' || activeTab.value === 'customer')) {
      // Only load customers if we have a gameCode, or wait for gameCode to become available
      if (props.gameCode) {
        await loadCustomers(newChannelId)
      }
    }
  }
)

// Watch for customer search
watch(
  customerSearchText,
  (newSearch: string) => {
    if (newSearch.length >= 2) {
      searchCustomers(newSearch)
    } else if (newSearch.length === 0) {
      // Reload all customers when search is cleared - only if gameCode is available
      const channelId = customerFormData.value?.channelId
      if (channelId && props.gameCode) {
                loadCustomers(channelId)
      }
    }
  }
)

// Watch for game code changes to reload customers with correct game-specific data
watch(
  () => props.gameCode,
  async (newGameCode: string) => {
    if (newGameCode && customerFormData.value?.channelId && (props.formMode === 'customer' || activeTab.value === 'customer')) {
      await loadCustomers(customerFormData.value.channelId)
    }
  }
)

// Expose methods for parent component
defineExpose({
  customerFormData,
  supplierFormData,
  activeTab,
  loadSuppliers,
  loadCustomers,
  createNewSupplier,
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