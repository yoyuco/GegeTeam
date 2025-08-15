<!-- path: src/App.vue -->
<template>
  <n-config-provider>
    <n-message-provider>
      <div class="min-h-screen flex bg-neutral-50 text-neutral-900">
        <aside class="w-64 hidden md:block border-r border-neutral-200 p-4">
          <div class="font-semibold mb-4">Gege Team</div>

          <nav class="space-y-2">
            <RouterLink to="/" class="block">🏠 Dashboard</RouterLink>
            <RouterLink to="/sales" class="block">💰 Bán hàng</RouterLink>
            <RouterLink to="/orders" class="block">📦 Đơn hàng</RouterLink>
            <RouterLink to="/customers" class="block">👥 Khách hàng</RouterLink>
            <RouterLink to="/employees" class="block">🧑‍💼 Nhân viên</RouterLink>
            <RouterLink to="/tasks" class="block">🗂️ Kanban</RouterLink>
            <RouterLink to="/kpi" class="block">📈 KPI</RouterLink>

            <!-- Nếu có user => nút Đăng xuất ; ngược lại => link Đăng nhập -->
            <button
              v-if="auth.user"
              class="block text-left text-red-600 hover:underline"
              @click="logout"
            >
              🚪 Đăng xuất
            </button>
            <RouterLink v-else to="/login" class="block">🔐 Đăng nhập</RouterLink>
          </nav>

          <!-- hiển thị email user -->
          <div v-if="auth.user" class="mt-6 text-xs text-neutral-500 break-all">
            {{ auth.user.email }}
          </div>
        </aside>

        <main class="flex-1 p-4">
          <RouterView />
        </main>
      </div>
    </n-message-provider>
  </n-config-provider>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import { NConfigProvider, NMessageProvider, createDiscreteApi } from 'naive-ui'
import { useAuth } from '@/stores/auth'

const router = useRouter()
const auth = useAuth()

// ✅ Dùng discrete api để có `message` mà không cần provider bọc *bên trên* component hiện tại
const { message } = createDiscreteApi(['message'])

const logout = async () => {
  try {
    // Đảm bảo trong store có hàm signOut()
    await auth.signOut()
    message.success('Đã đăng xuất')
  } catch (e: any) {
    message.error(e?.message ?? 'Đăng xuất thất bại')
  } finally {
    router.replace('/login')
  }
}
</script>
