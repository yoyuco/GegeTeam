<!-- src/pages/Orders.vue -->
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'

const rows = ref<any[]>([])
const loading = ref(false)

const load = async () => {
  loading.value = true
  const { data, error } = await supabase.from('orders_v')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(50)
  if (error) alert(error.message)
  rows.value = data ?? []
  loading.value = false
}

onMounted(load)
</script>

<template>
  <div class="p-6">
    <h1 class="text-xl font-semibold mb-4">Orders</h1>
    <button class="rounded px-3 py-1 border mb-3" @click="load">Reload</button>
    <div class="overflow-auto">
      <table class="min-w-[600px] w-full text-sm">
        <thead><tr class="border-b">
          <th class="text-left p-2">Code</th>
          <th class="text-left p-2">Customer</th>
          <th class="text-right p-2">Total</th>
          <th class="text-left p-2">Status</th>
        </tr></thead>
        <tbody>
          <tr v-for="r in rows" :key="r.id" class="border-b">
            <td class="p-2 font-mono">{{ r.code }}</td>
            <td class="p-2">{{ r.customer_name }}</td>
            <td class="p-2 text-right">{{ r.total_amount.toLocaleString() }}</td>
            <td class="p-2">{{ r.status }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
