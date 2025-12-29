<!-- path: src/components/CustomerForm.vue -->
<!-- Customer/Supplier Information Form Component with Tabs -->
<template>
  <div class="bg-white rounded-xl shadow-sm border border-gray-200">
      <!-- Tab Content -->
    <div class="p-6">
      <div v-if="formMode === 'customer' || (!formMode && activeTab === 'customer')" class="space-y-6">

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
            v-model:value="customerNameValue"
            :options="customerOptions.map(opt => ({ label: opt.label, value: opt.label }))"
            :loading="customerLoading"
            placeholder="Nhập hoặc chọn khách hàng"
            size="large"
            class="w-full"
            clearable
            @update:value="(value) => {
              customerSearchText = value || ''

              const selected = customerOptions.find(opt => opt.label === value)

              if (selected) {
                const current = props.customerModelValue as any || { channelId: null, customerName: '', gameTag: '', deliveryInfo: '' }
                const updated = {
                  ...current,
                  customerName: value,
                  deliveryInfo: selected.data.contact_info?.deliveryInfo || current?.deliveryInfo || '',
                  gameTag: selected.data.contact_info?.gameTag || current?.gameTag || ''
                }
                if (!current?.channelId) {
                  updated.channelId = null
                }
                emit('update:customerModelValue', updated)
              } else if (value && value.trim()) {
                loadCustomerData(value.trim())
              }
            }"
          />
        </div>

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
            v-model:value="customerGameTagValue"
            :placeholder="gameCustomerInfoPlaceholder"
            size="large"
            class="w-full"
          />
        </div>

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
            v-model:value="customerDeliveryInfoValue"
            placeholder="Email, Discord, hoặc thông tin liên hệ khác"
            size="large"
            class="w-full"
          />
        </div>
      </div>

      <div v-if="formMode === 'supplier' || (!formMode && activeTab === 'supplier')" class="space-y-6">

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
            v-model:value="supplierChannelIdValue"
            :options="supplierChannelOptions"
            placeholder="Chọn kênh mua (Facebook, Zalo...)"
            filterable
            :loading="loading"
            size="large"
            class="w-full"
          />
        </div>

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
            v-model:value="supplierNameValue"
            :options="supplierOptions.map(opt => ({ label: opt.label, value: opt.label }))"
            :loading="supplierLoading"
            placeholder="Nhập hoặc chọn nhà cung cấp"
            size="large"
            class="w-full"
            clearable
            @update:value="(value) => {
              supplierSearchText = value || ''

              const selected = supplierOptions.find(opt => opt.label === value)

              if (selected) {
                const current = props.supplierModelValue as any || { channelId: null, supplierName: '', supplierContact: '', deliveryLocation: '' }
                const updated = {
                  ...current,
                  supplierName: value,
                  supplierContact: selected.data.contact_info?.contact || current?.supplierContact || '',
                  deliveryLocation: selected.data.contact_info?.gameTag || current?.deliveryLocation || ''
                }
                if (!current?.channelId) {
                  updated.channelId = null
                }
                emit('update:supplierModelValue', updated)
              } else if (value && value.trim()) {
                loadSupplierData(value.trim())
              }
            }"
          />
        </div>

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
            v-model:value="supplierGameTagValue"
            :placeholder="gameCustomerInfoPlaceholder"
            size="large"
            class="w-full"
          />
        </div>

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
            v-model:value="supplierDeliveryInfoValue"
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
  loadPartyByNameType,
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
    supplierName: string
    supplierContact: string
    deliveryLocation: string
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
const emit = defineEmits([
  'update:modelValue',
  'update:customerModelValue',
  'update:supplierModelValue',
  'update:activeTab',
  'customer-changed',
  'game-tag-changed',
  'supplier-changed',
  'supplier-game-tag-changed'
])

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
        return props.customerModelValue || props.modelValue || {
      channelId: null,
      customerName: '',
      gameTag: '',
      deliveryInfo: ''
    }
  },
  set: (value: any) => {
    emit('update:customerModelValue', value)
  },
})

const supplierFormData = computed({
  get: () => {
    const defaultValue = {
      channelId: null,
      supplierName: '',
      supplierContact: '',
      deliveryLocation: ''
    }

    const data = props.supplierModelValue || props.modelValue || defaultValue

    // Handle both old field names and new field names for backward compatibility
    if ('supplierName' in data) {
      // New field names - use directly
      return {
        channelId: data.channelId,
        supplierName: data.supplierName || '',
        supplierContact: data.supplierContact || '',
        deliveryLocation: data.deliveryLocation || ''
      }
    } else {
      // Old field names (backward compatibility) - map to new field names
      return {
        channelId: data.channelId,
        supplierName: data.customerName || '',
        supplierContact: data.deliveryInfo || '',
        deliveryLocation: data.gameTag || ''
      }
    }
  },
  set: (value: any) => {
    // Use the new field names directly when updating
    const updatedValue = {
      channelId: value.channelId,
      supplierName: value.supplierName || '',
      supplierContact: value.supplierContact || '',
      deliveryLocation: value.deliveryLocation || ''
    }
    emit('update:supplierModelValue', updatedValue)
  },
})

// Computed properties
const loading = computed(() => props.loading)

// Template-safe computed properties to avoid TypeScript union type issues
const customerNameValue = computed({
  get: () => {
    const data = customerFormData.value as any
    return data?.customerName || ''
  },
  set: (value: string) => {
    const current = customerFormData.value as any
    const updated = { ...current, customerName: value }
    emit('update:customerModelValue', updated)
  }
})

const customerGameTagValue = computed({
  get: () => {
    const data = customerFormData.value as any
    return data?.gameTag || ''
  },
  set: (value: string) => {
    const current = customerFormData.value as any
    const updated = { ...current, gameTag: value }
    emit('update:customerModelValue', updated)
  }
})

const customerDeliveryInfoValue = computed({
  get: () => {
    const data = customerFormData.value as any
    return data?.deliveryInfo || ''
  },
  set: (value: string) => {
    const current = customerFormData.value as any
    const updated = { ...current, deliveryInfo: value }
    emit('update:customerModelValue', updated)
  }
})

const supplierNameValue = computed({
  get: () => {
    const data = supplierFormData.value as any
    return data?.supplierName || ''
  },
  set: (value: string) => {
    const current = supplierFormData.value as any
    const updated = { ...current, supplierName: value }
    emit('update:supplierModelValue', updated)
  }
})

const supplierGameTagValue = computed({
  get: () => {
    const data = supplierFormData.value as any
    return data?.deliveryLocation || ''
  },
  set: (value: string) => {
    const current = supplierFormData.value as any
    const updated = { ...current, deliveryLocation: value }
    emit('update:supplierModelValue', updated)
  }
})

const supplierDeliveryInfoValue = computed({
  get: () => {
    const data = supplierFormData.value as any
    return data?.supplierContact || ''
  },
  set: (value: string) => {
    const current = supplierFormData.value as any
    const updated = { ...current, supplierContact: value }
    emit('update:supplierModelValue', updated)
  }
})

const supplierChannelIdValue = computed({
  get: () => {
    const data = supplierFormData.value as any
    return data?.channelId || null
  },
  set: (value: string | null) => {
    const current = supplierFormData.value as any
    const updated = { ...current, channelId: value }
    emit('update:supplierModelValue', updated)
  }
})

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
  () => customerNameValue.value,
  (newName: string) => {
    emit('customer-changed', newName ? { name: newName } : null)
  }
)

watch(
  () => customerGameTagValue.value,
  (newGameTag: string) => {
    emit('game-tag-changed', newGameTag || '')
  }
)

// Watch for supplier form changes and emit events
watch(
  () => supplierNameValue.value,
  (newName: string) => {
    emit('supplier-changed', newName ? { name: newName } : null)
  }
)

watch(
  () => supplierGameTagValue.value,
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
      supplierFormData.value?.supplierContact,
      undefined,
      props.gameCode,
      supplierFormData.value?.deliveryLocation, // Add gameTag (deliveryLocation = character name)
      supplierFormData.value?.supplierContact // Add deliveryInfo (supplierContact = delivery info)
    )
    return newSupplier
  } catch (error) {
    return null
  }
}

// Function to load supplier data from database for form pre-filling
const loadSupplierData = async (supplierName: string) => {
  try {
    const currentChannelId = supplierFormData.value?.channelId
    // Load supplier data filtered by current channel
    const supplierData = await loadPartyByNameType(supplierName, 'supplier', currentChannelId)
    if (supplierData) {
      // Auto-fill form with supplier data - using correct field mapping
      const current = props.supplierModelValue as any || {}
      const updated = {
        ...current,
        supplierName: supplierData.name,
        supplierContact: supplierData.contact_info?.contact || current?.supplierContact || '',
        deliveryLocation: supplierData.contact_info?.gameTag || current?.deliveryLocation || '',
        channelId: current?.channelId  // Keep current channel, don't override
      }
      emit('update:supplierModelValue', updated)
    }
  } catch (error) {
    // Silently fail - user can create a new supplier
  }
}

// Function to load customer data from database for form pre-filling
const loadCustomerData = async (customerName: string) => {
  try {
    const currentChannelId = customerFormData.value?.channelId
    // Load customer data filtered by current channel
    const customerData = await loadPartyByNameType(customerName, 'customer', currentChannelId)
    if (customerData) {
      // Auto-fill form with customer data - using correct field mapping
      const current = props.customerModelValue as any || {}
      const updated = {
        ...current,
        customerName: customerData.name,
        deliveryInfo: customerData.contact_info?.deliveryInfo || current?.deliveryInfo || '',
        gameTag: customerData.contact_info?.gameTag || current?.gameTag || '',
        channelId: current?.channelId  // Keep current channel, don't override
      }
      emit('update:customerModelValue', updated)
    }
  } catch (error) {
    // Silently fail - user can create a new customer
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

// Watch for direct props channel changes in supplier mode
watch(
  () => (props.supplierModelValue as any)?.channelId,
  async (newChannelId: string | null) => {
    if (newChannelId && props.formMode === 'supplier') {
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