<!-- path: src/pages/Dashboard.vue -->
<template>
  <section class="space-y-6">
    <h1 class="text-2xl font-bold">Dashboard</h1>

    <div class="grid md:grid-cols-3 gap-4">
      <div class="p-4 rounded-xl border">
        <h3 class="text-sm text-neutral-500">Doanh thu tháng</h3>
        <p class="text-3xl font-semibold">{{ currency(monthRevenue) }}</p>
      </div>

      <div class="p-4 rounded-xl border">
        <h3 class="text-sm text-neutral-500">Số đơn hàng</h3>
        <p class="text-3xl font-semibold">{{ ordersCount }}</p>
      </div>

      <div class="p-4 rounded-xl border">
        <h3 class="text-sm text-neutral-500">Khách hàng mới</h3>
        <p class="text-3xl font-semibold">{{ newCustomers }}</p>
      </div>
    </div>

    <div class="p-4 rounded-xl border">
      <SalesLineChart :points="chartPoints" />
    </div>
  </section>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import SalesLineChart from '@/components/charts/SalesLineChart.vue'

type RevRow = { month: string; revenue: number }

const monthRevenue = ref(0)
const ordersCount = ref(0)
const newCustomers = ref(0)
const chartPoints = ref<{ x: string; y: number }[]>([])

function currency(n: number) {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(n || 0)
}

onMounted(async () => {
  // 1) Line chart: view monthly_revenue_v
  const { data: rev, error: e1 } = await supabase
    .from('monthly_revenue_v')
    .select('*')
    .order('month', { ascending: true })
    .limit(12)

  if (!e1 && rev?.length) {
    const rows = rev as RevRow[]
    chartPoints.value = rows.map(r => ({ x: r.month, y: Number(r.revenue) }))
    monthRevenue.value = Number(rows[rows.length - 1]?.revenue ?? 0)
  }

  // 2) KPIs tổng hợp: function dashboard_kpis()
  const { data: stats, error: e2 } = await supabase.rpc('dashboard_kpis')
  if (!e2 && stats) {
    ordersCount.value = Number(stats.orders_count ?? 0)
    newCustomers.value = Number(stats.new_customers ?? 0)
  }
})
</script>
