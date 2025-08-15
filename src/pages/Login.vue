<!-- path: src/pages/Login.vue -->
<template>
  <div class="min-h-screen grid grid-cols-1 lg:grid-cols-2">
    <!-- Hero / Brand -->
    <aside
      class="relative hidden lg:flex items-center justify-center overflow-hidden
             bg-gradient-to-br from-indigo-600 via-violet-600 to-fuchsia-600"
    >
      <div class="absolute inset-0 opacity-20
                  bg-[radial-gradient(1000px_600px_at_10%_-10%,white,transparent_70%)]"></div>

      <div class="relative z-10 max-w-xl text-white px-12">
        <div class="flex items-center gap-3 mb-8">
          <img src="@/assets/logo.svg" class="h-9 w-9 drop-shadow" alt="Logo" />
          <h1 class="text-2xl font-semibold tracking-tight">My Admin</h1>
        </div>

        <h2 class="text-4xl font-bold leading-tight mb-4">
          Bảng quản trị nhanh, gọn và <span class="opacity-90">chuyên nghiệp</span>
        </h2>
        <p class="text-white/90 leading-relaxed">
          Quản lý bán hàng, đơn hàng, khách hàng, nhiệm vụ và KPI — tất cả trong một.
          Realtime, an toàn với Supabase.
        </p>

        <ul class="mt-8 space-y-3 text-white/90">
          <li class="flex items-center gap-3">
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4z"/></svg>
            Realtime Orders & Kanban Tasks
          </li>
          <li class="flex items-center gap-3">
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4z"/></svg>
            RLS đa tổ chức (multi-tenant)
          </li>
          <li class="flex items-center gap-3">
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4z"/></svg>
            Dashboard & KPI đẹp mắt
          </li>
        </ul>
      </div>
    </aside>

    <!-- Auth form -->
    <main class="flex items-center justify-center p-6 md:p-10 bg-neutral-50 dark:bg-neutral-950">
      <n-card
        class="w-full max-w-md shadow-lg border border-neutral-200/70 dark:border-neutral-800/70
               bg-white/80 dark:bg-neutral-900/80 backdrop-blur"
        :segmented="{
          content: true,
          footer: true
        }"
      >
        <template #header>
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-xl font-semibold">Đăng nhập</h3>
              <p class="text-neutral-500 dark:text-neutral-400 text-sm">Chào mừng quay lại 👋</p>
            </div>
            <img src="@/assets/logo.svg" class="h-8 w-8 opacity-80" alt="Logo" />
          </div>
        </template>

        <n-form
          ref="formRef"
          :model="form"
          :rules="rules"
          label-placement="top"
          @submit.prevent="onSubmit"
        >
          <n-form-item path="email" label="Email">
            <n-input
              v-model:value="form.email"
              placeholder="you@company.com"
              autofocus
              @keyup.enter="onSubmit"
            >
              <template #prefix>
                <svg class="w-4 h-4 text-neutral-400" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 13 2 6.76V18a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V6.76L12 13ZM12 11l10-6H2l10 6Z"/>
                </svg>
              </template>
            </n-input>
          </n-form-item>

          <n-form-item path="password" label="Mật khẩu">
            <n-input
              :type="showPassword ? 'text' : 'password'"
              v-model:value="form.password"
              placeholder="••••••••"
              @keyup.enter="onSubmit"
            >
              <template #suffix>
                <button
                  class="text-neutral-500 hover:text-neutral-700 dark:hover:text-neutral-300"
                  type="button"
                  @click="showPassword = !showPassword"
                  aria-label="Toggle password visibility"
                >
                  <svg v-if="!showPassword" class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 5c-7 0-10 7-10 7s3 7 10 7 10-7 10-7-3-7-10-7Zm0 12a5 5 0 1 1 0-10 5 5 0 0 1 0 10Z"/>
                  </svg>
                  <svg v-else class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                    <path d="m3 3 18 18-1.4 1.4-3.1-3.1A11.5 11.5 0 0 1 12 19C5 19 2 12 2 12a19.1 19.1 0 0 1 6-7.9L1.6 4.4 3 3Zm11.3 11.3L9.7 9.7a3 3 0 0 0 4.6 4.6ZM7.8 6.4A11.2 11.2 0 0 1 12 5c7 0 10 7 10 7a18.9 18.9 0 0 1-4.2 5.7l-2-2A14 14 0 0 0 20.1 12c0 0-2.6-5-8.1-5-1.5 0-2.8.4-4 .9Z"/>
                  </svg>
                </button>
              </template>
            </n-input>
          </n-form-item>

          <div class="flex items-center justify-between mb-1">
            <n-checkbox v-model:checked="remember">Ghi nhớ tôi</n-checkbox>
            <button
              type="button"
              class="text-sm text-indigo-600 hover:text-indigo-700 dark:text-indigo-400"
              @click="onForgot"
            >
              Quên mật khẩu?
            </button>
          </div>

          <n-alert v-if="errorMsg" type="error" class="mb-3" :show-icon="true">
            {{ errorMsg }}
          </n-alert>

          <n-button
            type="primary"
            class="w-full"
            size="large"
            :loading="loading"
            @click="onSubmit"
          >
            Đăng nhập
          </n-button>

          <n-divider>hoặc</n-divider>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <n-button tertiary strong class="w-full" :loading="loadingOAuth.google" @click="signInOAuth('google')">
              <span class="flex items-center gap-2">
                <img class="h-5 w-5" alt="Google" src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" />
                Google
              </span>
            </n-button>
            <n-button tertiary strong class="w-full" :loading="loadingOAuth.github" @click="signInOAuth('github')">
              <span class="flex items-center gap-2">
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor"><path d="M12 .5C5.7.5.9 5.3.9 11.6c0 4.9 3.2 9 7.6 10.5.6.1.8-.3.8-.6v-2c-3.1.7-3.8-1.3-3.8-1.3-.6-1.4-1.4-1.8-1.4-1.8-1.1-.7.1-.7.1-.7 1.1.1 1.7 1.1 1.7 1.1 1 .1.7 1.9 2.7 2.8.5.2 1.1.3 1.6.3s1.1-.1 1.6-.3c2-.9 1.7-2.7 2.7-2.8 0 0 .6-1 1.7-1.1 0 0 1.2 0 .1.7 0 0-.8.4-1.4 1.8 0 0-.7 2-3.8 1.3v2c0 .3.2.7.8.6 4.4-1.5 7.6-5.6 7.6-10.5C23.1 5.3 18.3.5 12 .5z"/></svg>
                GitHub
              </span>
            </n-button>
          </div>
        </n-form>

        <template #footer>
          <div class="text-xs text-neutral-500 dark:text-neutral-400 text-center">
            © {{ new Date().getFullYear() }} My Admin. All rights reserved.
          </div>
        </template>
      </n-card>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useMessage, type FormInst, type FormRules } from 'naive-ui'
import { supabase } from '@/lib/supabase' // giữ đúng đường dẫn bạn đang dùng

const router = useRouter()
const message = useMessage()

const formRef = ref<FormInst | null>(null)
const form = ref({
  email: '',
  password: ''
})
const remember = ref(true)
const showPassword = ref(false)
const loading = ref(false)
const errorMsg = ref<string>('')

const loadingOAuth = ref<{google: boolean; github: boolean}>({ google: false, github: false })

const rules: FormRules = {
  email: [
    { required: true, message: 'Vui lòng nhập email', trigger: ['input', 'blur'] },
    { validator: (_, value: string) => /^\S+@\S+\.\S+$/.test(value), message: 'Email không hợp lệ', trigger: ['blur', 'input'] }
  ],
  password: [
    { required: true, message: 'Vui lòng nhập mật khẩu', trigger: ['input', 'blur'] },
    { min: 6, message: 'Tối thiểu 6 ký tự', trigger: ['input', 'blur'] }
  ]
}

onMounted(() => {
  const saved = localStorage.getItem('remember_email')
  if (saved) form.value.email = saved
})

async function onSubmit() {
  errorMsg.value = ''
  await formRef.value?.validate(async (errors) => {
    if (errors) return
    loading.value = true
    try {
      if (remember.value) {
        localStorage.setItem('remember_email', form.value.email)
      } else {
        localStorage.removeItem('remember_email')
      }

      const { data, error } = await supabase.auth.signInWithPassword({
        email: form.value.email.trim(),
        password: form.value.password
      })
      if (error) throw error

      message.success('Đăng nhập thành công')
      // điều hướng sau login
      router.push('/')
    } catch (e: any) {
      errorMsg.value = e?.message ?? 'Không thể đăng nhập, vui lòng thử lại'
    } finally {
      loading.value = false
    }
  })
}

async function signInOAuth(provider: 'google' | 'github') {
  errorMsg.value = ''
  loadingOAuth.value[provider] = true
  try {
    const { error } = await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: window.location.origin // sau login quay về app
      }
    })
    if (error) throw error
  } catch (e: any) {
    errorMsg.value = e?.message ?? 'Không thể đăng nhập OAuth'
    loadingOAuth.value[provider] = false
  }
}

function onForgot() {
  message.info('Chức năng đặt lại mật khẩu: nhập email ở form đăng nhập rồi bấm "Quên mật khẩu" (bạn có thể làm form riêng và dùng supabase.auth.resetPasswordForEmail).')
}
</script>

<style scoped>
/* tinh chỉnh nhẹ Naive UI + Tailwind */
:deep(.n-card__content) { @apply pt-4; }
:deep(.n-divider__line) { @apply opacity-60; }
</style>
