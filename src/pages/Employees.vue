<template>
  <section class="space-y-4">
    <h1 class="text-2xl font-bold">Nhân viên</h1>
    <table class="w-full border">
      <thead><tr class="bg-neutral-100"><th class="p-2 text-left">Tên</th><th class="p-2 text-left">Vai trò</th></tr></thead>
      <tbody><tr v-for="e in employees" :key="e.id" class="border-t"><td class="p-2">{{e.full_name}}</td><td class="p-2">{{e.role}}</td></tr></tbody>
    </table>
  </section>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
const employees = ref<any[]>([])
onMounted(async()=>{ const { data } = await supabase.from('employees_v').select('*'); employees.value = data||[] })
</script>
