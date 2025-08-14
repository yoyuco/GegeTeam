<!-- src/pages/Login.vue -->
<script setup lang="ts">
import { ref } from 'vue'
import { useAuth } from '@/stores/auth'
import { useRouter } from 'vue-router'

const email = ref('')
const password = ref('')
const loading = ref(false)
const auth = useAuth()
const router = useRouter()

const submit = async () => {
  loading.value = true
  try {
    await auth.signIn(email.value, password.value)
    router.push('/')
  } catch (e:any) {
    alert(e.message)
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen grid place-items-center p-6">
    <div class="w-full max-w-sm bg-white/50 rounded-2xl p-6 shadow">
      <h1 class="text-xl font-semibold mb-4">Đăng nhập</h1>
      <div class="space-y-3">
        <input class="w-full border rounded px-3 py-2" placeholder="Email" v-model="email" />
        <input class="w-full border rounded px-3 py-2" placeholder="Password" type="password" v-model="password" />
        <button class="w-full rounded-xl px-4 py-2 bg-black text-white" :disabled="loading" @click="submit">
          {{ loading ? 'Đang đăng nhập...' : 'Đăng nhập' }}
        </button>
      </div>
    </div>
  </div>
</template>
