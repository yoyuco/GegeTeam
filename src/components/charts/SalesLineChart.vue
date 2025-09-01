<!-- path: src/components/charts/SalesLineChart.vue -->
<template>
  <div class="w-full h-64">
    <svg :viewBox="`0 0 ${W} ${H}`" class="w-full h-full">
      <!-- grid ngang -->
      <g v-for="(g, i) in 11" :key="i">
        <line
          :x1="P" :x2="W-P"
          :y1="P + i * stepY" :y2="P + i * stepY"
          stroke="#e5e7eb" stroke-width="1"
        />
      </g>

      <!-- trục -->
      <line :x1="P" :y1="P" :x2="P" :y2="H-P" stroke="#a3a3a3" stroke-width="1.5"/>
      <line :x1="P" :y1="H-P" :x2="W-P" :y2="H-P" stroke="#a3a3a3" stroke-width="1.5"/>

      <!-- đường doanh thu -->
      <polyline
        :points="points"
        fill="none"
        stroke="#6b7280"
        stroke-width="2"
      />

      <!-- label giữa -->
      <text
        x="50%" y="18" text-anchor="middle"
        font-size="10" fill="#9ca3af"
      >Doanh thu</text>
    </svg>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  /** 12 phần tử, doanh thu từng tháng */
  series: number[]
}>()

const W = 720
const H = 240
const P = 28 // padding

const maxY = computed(() => {
  const m = Math.max(1, ...(props.series ?? [0]))
  // bo tròn lên cho đẹp
  const pow = Math.pow(10, String(Math.floor(m)).length - 1)
  return Math.ceil(m / pow) * pow
})

const stepX = computed(() => (W - 2 * P) / 11)
const stepY = computed(() => (H - 2 * P) / 10)

const points = computed(() => {
  const s = (props.series ?? []).slice(0, 12)
  const arr = s.length === 12 ? s : Array.from({ length: 12 }, (_, i) => s[i] ?? 0)
  return arr
    .map((v, i) => {
      const x = P + i * stepX.value
      const y = H - P - (v / (maxY.value || 1)) * (H - 2 * P)
      return `${x},${y}`
    })
    .join(' ')
})
</script>
