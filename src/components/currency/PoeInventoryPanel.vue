<template>
  <div v-if="isOpen" class="inventory-panel">
    <n-card title="Thông tin Kho Currency" :bordered="false" size="small">
      <n-scrollbar style="max-height: calc(100vh - 100px)">
        <n-collapse accordion>
          <n-collapse-item
            v-for="item in inventoryData"
            :key="item.currency"
            :title="`${item.currency} (Tổng: ${item.total})`"
          >
            <n-descriptions label-placement="left" :column="1" size="small" bordered>
              <n-descriptions-item label="Tổng số lượng">{{ item.total }}</n-descriptions-item>
              <n-descriptions-item label="Số lượng giữ (cho đơn)">{{
                item.reserved
              }}</n-descriptions-item>
              <n-descriptions-item label="Giá TB USD">${{ item.avgUSD }}</n-descriptions-item>
              <n-descriptions-item label="Giá TB VND"
                >{{ item.avgVND.toLocaleString('vi-VN') }} ₫</n-descriptions-item
              >
            </n-descriptions>
            <n-divider title-placement="left" class="!my-2 !text-xs"
              >Chi tiết theo Account</n-divider
            >
            <n-descriptions label-placement="left" :column="1" size="small" bordered>
              <n-descriptions-item v-for="acc in item.accounts" :key="acc.name" :label="acc.name">
                {{ acc.amount }}
              </n-descriptions-item>
            </n-descriptions>
          </n-collapse-item>
        </n-collapse>
      </n-scrollbar>
    </n-card>
  </div>
</template>

<script setup lang="ts">
import {
  NCard,
  NCollapse,
  NCollapseItem,
  NDescriptions,
  NDescriptionsItem,
  NDivider,
  NScrollbar,
} from 'naive-ui'

// Props để nhận dữ liệu và trạng thái từ component cha
defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  inventoryData: {
    type: Array as () => Array<{
      currency: string
      total: number
      reserved: number
      avgUSD: number
      avgVND: number
      accounts: Array<{ name: string; amount: number }>
    }>,
    default: () => [],
  },
})
</script>

<style scoped>
.inventory-panel {
  position: fixed;
  right: 0;
  top: 60px; /* Điều chỉnh tùy theo chiều cao header của bạn */
  bottom: 0;
  width: 380px;
  background: #fdfdfd;
  border-left: 1px solid #e8e8e8;
  z-index: 100;
  transform: translateX(0);
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  padding: 1rem;
  box-shadow: -2px 0 8px rgba(0, 0, 0, 0.05);
}
</style>
