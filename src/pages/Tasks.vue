<!-- path: src/pages/Tasks.vue -->
<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { supabase } from '@/lib/supabase'

type Task = {
  id: string
  title: string
  status: 'backlog' | 'todo' | 'in_progress' | 'review' | 'done'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  position: number
}

const tasks = ref<Task[]>([])

const fetchTasks = async () => {
  const { data, error } = await supabase
    .from('tasks')
    .select('*')
    .order('position')

  if (error) {
    console.error(error)
    return
  }
  tasks.value = (data ?? []) as Task[]
}

let channel: ReturnType<typeof supabase.channel> | null = null

onMounted(async () => {
  await fetchTasks()
  channel = supabase
    .channel('rt-tasks')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'tasks' },
      fetchTasks
    )
    .subscribe()
})

onBeforeUnmount(() => {
  if (channel) supabase.removeChannel(channel)
})
</script>

<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h1 class="text-xl font-semibold">Tasks</h1>
      <button class="border rounded px-3 py-1" @click="fetchTasks">Reload</button>
    </div>

    <!-- Bảng đơn giản; bạn có thể làm Kanban sau -->
    <div class="overflow-auto">
      <table class="min-w-[700px] w-full text-sm">
        <thead>
          <tr class="border-b bg-gray-50">
            <th class="text-left p-2">Title</th>
            <th class="text-left p-2">Status</th>
            <th class="text-left p-2">Priority</th>
            <th class="text-right p-2">Position</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="t in tasks" :key="t.id" class="border-b">
            <td class="p-2">{{ t.title }}</td>
            <td class="p-2">{{ t.status }}</td>
            <td class="p-2">{{ t.priority }}</td>
            <td class="p-2 text-right">{{ t.position }}</td>
          </tr>
          <tr v-if="!tasks.length">
            <td class="p-4 text-center text-gray-500" colspan="4">No tasks</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
