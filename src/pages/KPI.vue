<!-- src/pages/KPI.vue -->
<script setup lang="ts">
import { ref } from 'vue'
const result = ref('')

const recalc = async () => {
  const res = await fetch('/functions/v1/kpi-recalc', { method: 'POST' })
  result.value = await res.text()
}
</script>

<template>
  <div class="p-6 space-y-4">
    <h1 class="text-xl font-semibold">KPI</h1>
    <button class="rounded px-3 py-1 border" @click="recalc">Recalc KPI</button>
    <pre class="bg-black text-white p-3 rounded-xl whitespace-pre-wrap">{{ result }}</pre>
  </div>
</template>
