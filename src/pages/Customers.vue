<template>
  <section class="space-y-4">
    <h1 class="text-2xl font-bold">Khách hàng</h1>
    <form class="flex gap-2" @submit.prevent="add">
      <input v-model="form.name" placeholder="Tên" class="border p-2 rounded" />
      <input v-model="form.email" placeholder="Email" class="border p-2 rounded" />
      <button class="px-3 py-2 rounded bg-black text-white">Thêm</button>
    </form>
    <table class="w-full border">
      <thead>
        <tr class="bg-neutral-100">
          <th class="p-2 text-left">Tên</th>
          <th class="p-2 text-left">Email</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="c in customers" :key="c.id" class="border-t">
          <td class="p-2">{{ c.name }}</td>
          <td class="p-2">{{ c.email }}</td>
        </tr>
      </tbody>
    </table>
  </section>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
interface Customer {
  id: string
  name: string
  email: string
  created_at?: string
}

const customers = ref<Customer[]>([])
const form = ref({ name: '', email: '' })
async function load() {
  const { data } = await supabase
    .from('customers')
    .select('*')
    .order('created_at', { ascending: false })
  customers.value = data || []
}
async function add() {
  await supabase.from('customers').insert(form.value)
  form.value = { name: '', email: '' }
  await load()
}
onMounted(load)
</script>
