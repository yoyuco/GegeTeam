<template>
  <div class="poe-currency-page">
    <div class="main-content">
      <div class="flex items-center justify-between mb-4">
        <h1 class="text-xl font-semibold tracking-tight">Vận hành Giao dịch Currency POE</h1>
        <n-button tertiary @click="isInventoryOpen = !isInventoryOpen">
          {{ isInventoryOpen ? 'Đóng Kho' : 'Mở Kho' }}
        </n-button>
      </div>

      <n-card :bordered="false">
        <n-tabs type="line" animated>
          <n-tab-pane name="purchase" tab="Mua Hàng">
            <n-form
              :model="trader2Forms.purchase"
              label-placement="top"
              class="grid grid-cols-1 md:grid-cols-4 gap-x-6"
            >
              <n-form-item label="Nguồn mua">
                <n-auto-complete
                  v-model:value="trader2Forms.purchase.source"
                  :options="sourceOptions"
                  placeholder="Vd: Wholesaler A, Player B..."
                />
              </n-form-item>
              <n-form-item label="Tên đối tác">
                <n-input
                  v-model:value="trader2Forms.purchase.partnerName"
                  placeholder="Tên người bán"
                />
              </n-form-item>
              <n-form-item label="Loại Currency">
                <n-select
                  v-model:value="trader2Forms.purchase.currencyType"
                  filterable
                  tag
                  :options="currencyOptions"
                />
              </n-form-item>
              <n-form-item label="Số lượng">
                <n-input-number
                  v-model:value="trader2Forms.purchase.quantity"
                  class="w-full"
                  :min="0"
                />
              </n-form-item>
              <n-form-item label="Giá mua (VND)">
                <n-input-number
                  v-model:value="trader2Forms.purchase.buyPrice"
                  class="w-full"
                  :min="0"
                >
                  <template #suffix>₫</template>
                </n-input-number>
              </n-form-item>
              <n-form-item label="Nhập vào Kho (Account)">
                <n-select v-model:value="trader2Forms.purchase.account" :options="accountOptions" />
              </n-form-item>
              <n-form-item label="Ghi chú" class="md:col-span-2">
                <n-input
                  v-model:value="trader2Forms.purchase.notes"
                  type="textarea"
                  placeholder="Thông tin thêm..."
                />
              </n-form-item>
              <n-form-item label="Bằng chứng mua hàng" class="md:col-span-4">
                <n-upload multiple list-type="image-card" />
              </n-form-item>
            </n-form>
            <div class="flex justify-end mt-4">
              <n-button type="primary">Lưu giao dịch mua</n-button>
            </div>
          </n-tab-pane>

          <n-tab-pane name="exchange" tab="Trao Đổi Currency">
            <n-form :model="trader2Forms.exchange" label-placement="top">
              <div class="grid grid-cols-2 gap-6 items-center">
                <n-card title="Từ">
                  <n-form-item label="Loại Currency nguồn">
                    <n-select
                      v-model:value="trader2Forms.exchange.sourceType"
                      filterable
                      tag
                      :options="currencyOptions"
                    />
                  </n-form-item>
                  <n-form-item label="Số lượng">
                    <n-input-number
                      v-model:value="trader2Forms.exchange.sourceQty"
                      class="w-full"
                      :min="0"
                    />
                  </n-form-item>
                </n-card>
                <n-card title="Thành">
                  <n-form-item label="Loại Currency đích">
                    <n-select
                      v-model:value="trader2Forms.exchange.targetType"
                      filterable
                      tag
                      :options="currencyOptions"
                    />
                  </n-form-item>
                  <n-form-item label="Số lượng">
                    <n-input-number
                      v-model:value="trader2Forms.exchange.targetQty"
                      class="w-full"
                      :min="0"
                    />
                  </n-form-item>
                </n-card>
              </div>
              <n-form-item label="Bằng chứng trao đổi" class="mt-4">
                <n-upload multiple list-type="image-card" />
              </n-form-item>
            </n-form>
            <div class="flex justify-end mt-4">
              <n-button type="primary">Lưu giao dịch trao đổi</n-button>
            </div>
          </n-tab-pane>

          <n-tab-pane name="delivery" tab="Giao Hàng">
            <template #tab>
              Giao Hàng
              <n-badge :value="pendingDeliveries.length" :max="99" class="ml-2" />
            </template>
            <n-data-table
              :columns="deliveryColumns"
              :data="pendingDeliveries"
              :pagination="{ pageSize: 5 }"
            />
          </n-tab-pane>
        </n-tabs>
      </n-card>
    </div>

    <PoeInventoryPanel :is-open="isInventoryOpen" :inventory-data="inventory" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, h } from 'vue'
import {
  NCard,
  NForm,
  NFormItem,
  NInput,
  NInputNumber,
  NSelect,
  NAutoComplete,
  NButton,
  NTabs,
  NTabPane,
  NUpload,
  NDataTable,
  NBadge,
  NCheckbox,
  type DataTableColumns,
} from 'naive-ui'
import PoeInventoryPanel from '@/components/currency/PoeInventoryPanel.vue'

const isInventoryOpen = ref(true)

const sourceOptions = ref(['Wholesaler A', 'Player B'].map((v) => ({ label: v, value: v })))
const currencyOptions = ref(
  ['Divine Orb', 'Chaos Orb', 'Mirror of Kalandra', 'Exalted Orb'].map((v) => ({
    label: v,
    value: v,
  }))
)
const accountOptions = ref(
  ['Acc POE 1', 'Acc POE 2', 'Acc POE 3'].map((v) => ({ label: v, value: v }))
)

const trader2Forms = reactive({
  purchase: {
    source: '',
    partnerName: '',
    currencyType: null,
    quantity: 0,
    buyPrice: 0,
    account: null,
    notes: '',
  },
  exchange: { sourceType: null, sourceQty: 0, targetType: null, targetQty: 0 },
})

type Delivery = {
  id: number
  customerName: string
  gameTag: string
  deliveryInfo: string
  currencyType: string
  quantity: number
  exchangeInfo: string
}
const pendingDeliveries = ref<Delivery[]>([
  {
    id: 1,
    customerName: 'John Doe',
    gameTag: 'JohnSmites',
    deliveryInfo: 'Discord: john#1234',
    currencyType: 'Divine Orb',
    quantity: 100,
    exchangeInfo: 'Không có',
  },
  {
    id: 2,
    customerName: 'Jane Smith',
    gameTag: 'JaneRanger',
    deliveryInfo: 'Forum PM',
    currencyType: 'Chaos Orb',
    quantity: 5000,
    exchangeInfo: 'Service: Uber Lab run',
  },
])

const deliveryColumns = ref<DataTableColumns<Delivery>>([
  { title: 'Khách hàng', key: 'customerName' },
  { title: 'Tên trong game', key: 'gameTag' },
  {
    title: 'Loại/Số lượng',
    key: 'currency',
    render: (row) => `${row.quantity} ${row.currencyType}`,
  },
  { title: 'Link/DM Giao hàng', key: 'deliveryInfo' },
  { title: 'Quy đổi', key: 'exchangeInfo' },
  {
    title: 'Kho (Account)',
    key: 'account',
    render: () =>
      h(NSelect, { options: accountOptions.value, placeholder: 'Chọn kho', size: 'small' }),
  },
  {
    title: 'Bằng chứng',
    key: 'proof',
    render: () => h(NUpload, { listType: 'image-card', max: 1 }),
  },
  {
    title: 'Hành động',
    key: 'actions',
    render: () =>
      h('div', { class: 'flex gap-2' }, [
        h(NCheckbox, null, { default: () => 'Đã giao' }),
        h(NButton, { size: 'tiny', type: 'primary' }, { default: () => 'Lưu' }),
      ]),
  },
])

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
  padding-right: 16px;
}
</style>
