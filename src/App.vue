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

            <!-- 🔥 MỤC MỚI -->
            <RouterLink to="/service-boosting" class="block">🚀 Service – Boosting</RouterLink>

            <RouterLink to="/customers" class="block">👥 Khách hàng</RouterLink>
            <RouterLink to="/employees" class="block">🧑‍💼 Nhân viên</RouterLink>
            <RouterLink to="/tasks" class="block">🗂️ Kanban</RouterLink>
            <RouterLink to="/kpi" class="block">📈 KPI</RouterLink>

            <button
              v-if="auth.user"
              class="block text-left text-red-600 hover:underline"
              @click="logout"
            >
              🚪 Đăng xuất
            </button>
            <RouterLink v-else to="/login" class="block">🔐 Đăng nhập</RouterLink>
          </nav>

          <!-- Thông tin người dùng -->
          <div v-if="auth.user" class="mt-6 space-y-1">
            <!-- Roles -->
            <div v-if="roleLabels.length" class="flex flex-wrap gap-1">
              <n-tag v-for="r in roleLabels" :key="r" size="small" round>{{ r }}</n-tag>
            </div>

            <!-- DisplayName -> full_name (metadata) -> email -->
            <div class="text-sm font-medium">
              {{ displayName || auth.user.user_metadata?.full_name || auth.user.email }}
            </div>

            <!-- Email -->
            <div class="text-xs text-neutral-500 break-all">
              {{ auth.user.email }}
            </div>
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
import { ref, watch } from 'vue'
import { NConfigProvider, NMessageProvider, NTag, createDiscreteApi } from 'naive-ui'
import { useAuth } from '@/stores/auth'
import { supabase } from '@/lib/supabase'

const router = useRouter()
const auth = useAuth()
const { message } = createDiscreteApi(['message'])

/** UI state */
const displayName = ref<string | null>(null)
const roleLabels = ref<string[]>([])

/**
 * Load thông tin phụ của user (display_name, roles)
 */
async function loadUserExtras(uid: string) {
  displayName.value = null
  roleLabels.value = []

  // B1: Display name từ profiles
  const { data: prof, error: profileErr } = await supabase
    .from('profiles')
    .select('display_name')
    .eq('id', uid)
    .maybeSingle()

  if (!profileErr) displayName.value = prof?.display_name ?? null

  // B2: role_id từ user_roles
  const { data: urs } = await supabase
    .from('user_roles')
    .select('role_id')
    .eq('user_id', uid)

  const roleIds = (urs ?? []).map(r => r.role_id).filter(Boolean)
  if (roleIds.length === 0) { roleLabels.value = []; return }

  // B3: tên role từ roles
  const { data: rs } = await supabase
    .from('roles')
    .select('id, name, code')
    .in('id', roleIds)

  const set = new Set<string>()
  for (const r of rs ?? []) {
    if (r?.name) set.add(r.name)
    else if (r?.code) set.add(r.code)
  }
  roleLabels.value = Array.from(set)
}

/** Đăng nhập/đăng xuất -> nạp lại thông tin phụ */
watch(
  () => auth.user?.id,
  (uid) => {
    if (uid) loadUserExtras(uid)
    else {
      displayName.value = null
      roleLabels.value = []
    }
  },
  { immediate: true }
)

const logout = async () => {
  try {
    await auth.signOut()
    message.success('Đã đăng xuất')
  } catch (e: any) {
    message.error(e?.message ?? 'Đăng xuất thất bại')
  } finally {
    router.replace('/login')
  }
}
</script>
