<!-- path: src/pages/Dashboard.vue -->
<template>
  <div>
    <h1 class="text-xl font-semibold mb-4">Dashboard</h1>

    <!-- KPI cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
      <n-card>
        <div class="text-xs text-neutral-500">Doanh thu tháng</div>
        <div class="text-2xl font-semibold">{{ kpi.month_revenue.toLocaleString() }} đ</div>
      </n-card>
      <n-card>
        <div class="text-xs text-neutral-500">Số đơn hàng</div>
        <div class="text-2xl font-semibold">{{ kpi.orders_count }}</div>
      </n-card>
      <n-card>
        <div class="text-xs text-neutral-500">Khách hàng mới</div>
        <div class="text-2xl font-semibold">{{ kpi.new_customers }}</div>
      </n-card>
    </div>

    <!-- Biểu đồ doanh thu tháng -->
    <n-card>
      <div class="text-center text-xs text-neutral-500 mb-2">Doanh thu</div>
      <SalesLineChart :series="revenueSeries" />
    </n-card>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { NCard } from 'naive-ui'
import SalesLineChart from '@/components/charts/SalesLineChart.vue'
import { supabase } from '@/lib/supabase'

type KPI = { month_revenue: number; orders_count: number; new_customers: number }

const now = new Date()
const y = now.getFullYear()
const m = now.getMonth() + 1

const kpi = ref<KPI>({ month_revenue: 0, orders_count: 0, new_customers: 0 })

/** Mảng 12 tháng, mặc định 0 để chắc chắn không 404 Storage */
const revenueSeries = ref<number[]>(Array.from({ length: 12 }, () => 0))

async function loadKPIs() {
  // Ưu tiên RPC (nếu có). Nếu chưa có sẽ throw → giữ kpi mặc định = 0
  const { data, error } = await supabase.rpc('dashboard_kpis', { _year: y, _month: m })
  if (!error && data) {
    // data có thể là 1 record hoặc 1 row set; chuẩn hoá về KPI
    const row = Array.isArray(data) ? data[0] : data
    kpi.value = {
      month_revenue: Number(row?.month_revenue ?? 0),
      orders_count: Number(row?.orders_count ?? 0),
      new_customers: Number(row?.new_customers ?? 0),
    }
  } else {
    console.warn('[dashboard_kpis] RPC missing or error:', error?.message)
  }
}

/**
 * Lấy dữ liệu biểu đồ từ DB (KHÔNG DÙNG STORAGE).
 * - Nếu có view `monthly_revenue_v(d int, revenue_base numeric)`, sẽ map vào mảng 12 phần tử.
 * - Nếu chưa có, giữ nguyên mảng 0.
 */
async function loadRevenueSeries() {
  const { data, error } = await supabase
    .from('monthly_revenue_v')
    .select('d, revenue_base')
    .eq('y', y) // nếu view có cột năm; nếu không có có thể bỏ dòng này
    .order('d', { ascending: true })

  if (!error && Array.isArray(data) && data.length) {
    const arr = Array.from({ length: 12 }, (_, i) => {
      const month = i + 1
      const row = data.find((r: any) => Number(r.d) === month)
      return Number(row?.revenue_base ?? 0)
    })
    revenueSeries.value = arr
  } else {
    console.warn('[monthly_revenue_v] not found or empty → keep zeros.', error?.message)
  }
}

onMounted(async () => {
  //await Promise.all([loadKPIs(), loadRevenueSeries()])
})
</script>
