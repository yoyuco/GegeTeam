<template>
  <div class="poe-currency-page">
    <div class="main-content">
      <div class="flex items-center justify-between mb-4">
        <h1 class="text-xl font-semibold tracking-tight">Tạo đơn bán Currency POE</h1>
        <n-button tertiary @click="isInventoryOpen = !isInventoryOpen">
          {{ isInventoryOpen ? 'Đóng Kho' : 'Mở Kho' }}
        </n-button>
      </div>

      <n-card :bordered="false">
        <n-form
          :model="trader1Form"
          label-placement="top"
          class="grid grid-cols-1 md:grid-cols-3 gap-x-6"
        >
          <n-form-item label="Nguồn bán" class="md:col-span-1">
            <n-auto-complete
              v-model:value="trader1Form.source"
              :options="sourceOptions"
              placeholder="Vd: Funpay, G2G..."
            />
          </n-form-item>
          <n-form-item label="Tên khách hàng" class="md:col-span-1">
            <n-input
              v-model:value="trader1Form.customerName"
              placeholder="Tên/biệt danh của khách"
            />
          </n-form-item>
          <n-form-item label="Tên trong game" class="md:col-span-1">
            <n-input v-model:value="trader1Form.gameTag" placeholder="Tên nhân vật POE" />
          </n-form-item>
          <n-form-item label="Link/DM giao hàng" class="md:col-span-3">
            <n-input
              v-model:value="trader1Form.deliveryInfo"
              placeholder="Link Discord message, forum..."
            />
          </n-form-item>
          <n-form-item label="Loại Currency" class="md:col-span-1">
            <n-select
              v-model:value="trader1Form.currencyType"
              filterable
              tag
              :options="currencyOptions"
              placeholder="Divine Orb, Chaos Orb..."
            />
          </n-form-item>
          <n-form-item label="Số lượng" class="md:col-span-1">
            <n-input-number v-model:value="trader1Form.quantity" :min="0" class="w-full" />
          </n-form-item>
          <n-form-item label="Giá bán (USD)" class="md:col-span-1">
            <n-input-number v-model:value="trader1Form.sellPrice" :min="0" class="w-full">
              <template #prefix>$</template>
            </n-input-number>
          </n-form-item>
          <n-form-item label="Loại quy đổi" class="md:col-span-1">
            <n-radio-group v-model:value="trader1Form.exchangeType" name="exchange-type">
              <n-space>
                <n-radio value="none">Không</n-radio>
                <n-radio value="items">Items</n-radio>
                <n-radio value="service">Service</n-radio>
              </n-space>
            </n-radio-group>
          </n-form-item>
          <n-form-item label="Mô tả quy đổi" class="md:col-span-2">
            <n-input
              v-model:value="trader1Form.exchangeDescription"
              type="textarea"
              placeholder="Mô tả chi tiết về items hoặc service quy đổi"
              :disabled="trader1Form.exchangeType === 'none'"
            />
          </n-form-item>
        </n-form>
        <template #footer>
          <div class="flex justify-end">
            <n-button type="primary">Tạo đơn hàng</n-button>
          </div>
        </template>
      </n-card>
    </div>

    <PoeInventoryPanel :is-open="isInventoryOpen" :inventory-data="inventory" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import {
  NCard,
  NForm,
  NFormItem,
  NInput,
  NInputNumber,
  NSelect,
  NAutoComplete,
  NRadioGroup,
  NRadio,
  NSpace,
  NButton,
} from 'naive-ui'
import PoeInventoryPanel from '@/components/currency/PoeInventoryPanel.vue'

const isInventoryOpen = ref(true)

const sourceOptions = ref(['Funpay', 'G2G'].map((v) => ({ label: v, value: v })))
const currencyOptions = ref(
  ['Divine Orb', 'Chaos Orb', 'Mirror of Kalandra', 'Exalted Orb'].map((v) => ({
    label: v,
    value: v,
  }))
)

const trader1Form = reactive({
  source: '',
  customerName: '',
  gameTag: '',
  deliveryInfo: '',
  currencyType: null,
  quantity: 0,
  sellPrice: 0,
  exchangeType: 'none',
  exchangeDescription: '',
})

// Dữ liệu giả cho kho
const inventory = ref([
  {
    currency: 'Divine Orb',
    total: 520,
    reserved: 100,
    avgUSD: 0.85,
    avgVND: 20000,
    accounts: [
      { name: 'Acc POE 1', amount: 300 },
      { name: 'Acc POE 2', amount: 220 },
    ],
  },
  {
    currency: 'Chaos Orb',
    total: 15000,
    reserved: 5000,
    avgUSD: 0.01,
    avgVND: 230,
    accounts: [
      { name: 'Acc POE 1', amount: 10000 },
      { name: 'Acc POE 3', amount: 5000 },
    ],
  },
])
</script>

<style scoped>
.poe-currency-page {
  position: relative;
}
.main-content {
  padding-right: 16px; /* Thêm padding để không bị panel đè lên */
}
</style>
