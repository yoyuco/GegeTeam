<!-- path: src/components/charts/SalesLineChart.vue -->
<script setup lang="ts">
import { computed } from 'vue'
import { Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  LineElement,
  PointElement,
  LinearScale,
  TimeSeriesScale,
  CategoryScale,
  Tooltip,
  Legend
} from 'chart.js'

ChartJS.register(LineElement, PointElement, LinearScale, TimeSeriesScale, CategoryScale, Tooltip, Legend)

const props = defineProps<{ points: { x: string; y: number }[] }>()

const data = computed(() => ({
  labels: props.points.map(p => p.x),
  datasets: [
    {
      label: 'Doanh thu',
      data: props.points.map(p => p.y),
      fill: false,
      tension: 0.25
    }
  ]
}))

const options = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: true } },
  scales: {
    y: { beginAtZero: true }
  }
}
</script>

<template>
  <div class="h-64">
    <Line :data="data" :options="options" />
  </div>
</template>
