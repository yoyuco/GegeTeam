<template>
  <div class="min-h-screen grid place-items-center">
    <div class="text-center text-neutral-600 dark:text-neutral-300">
      <div class="mb-2 animate-pulse">Đang đăng nhập…</div>
      <div class="text-xs opacity-70">Vui lòng chờ giây lát.</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '@/lib/supabase'

const router = useRouter()
const route = useRoute()

onMounted(async () => {
  // Supabase sẽ tự đọc token trên URL
  setTimeout(async () => {
    const {
      data: { session },
    } = await supabase.auth.getSession()
    const redirect = (route.query.redirect as string) || '/'
    router.replace(session ? redirect : '/login')
  }, 600)
})
</script>
