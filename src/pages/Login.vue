<template>
  <div class="min-h-screen flex items-center justify-center bg-neutral-50 p-4">
    <div class="w-full max-w-md">
      <h1 class="text-center text-2xl font-semibold tracking-tight mb-6">
        Welcome Gege Team!
      </h1>

      <n-card :bordered="false" class="shadow-sm">
        <div class="flex mb-4 gap-3">
          <button
            class="flex-1 py-2 rounded-md text-sm font-medium"
            :class="tab === 'signin'
              ? 'bg-neutral-900 text-white'
              : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'"
            @click="tab = 'signin'"
          >
            Đăng nhập
          </button>
          <button
            class="flex-1 py-2 rounded-md text-sm font-medium"
            :class="tab === 'signup'
              ? 'bg-neutral-900 text-white'
              : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'"
            @click="tab = 'signup'"
          >
            Đăng ký
          </button>
        </div>

        <n-form
          v-if="tab === 'signin'"
          :model="signin"
          :rules="rulesSignin"
          ref="formSignin"
          size="large"
          label-placement="top"
          @keyup.enter.prevent="handleSignin"
        >
          <n-form-item label="Email" path="email">
            <n-input
              v-model:value="signin.email"
              type="text"
              placeholder="you@example.com"
              :input-props="{ autocomplete: 'email' }"
            />
          </n-form-item>

          <n-form-item label="Mật khẩu" path="password">
            <n-input
              :type="showPassword ? 'text' : 'password'"
              v-model:value="signin.password"
              placeholder="********"
              :input-props="{ autocomplete: 'current-password' }"
            >
              <template #suffix>
                <button
                  type="button"
                  class="text-xs text-neutral-500 hover:text-neutral-700"
                  @click="showPassword = !showPassword"
                >
                  {{ showPassword ? 'Ẩn' : 'Hiện' }}
                </button>
              </template>
            </n-input>
          </n-form-item>

          <div class="flex items-center justify-between mb-3">
            <label class="inline-flex items-center gap-2 text-xs text-neutral-600">
              <input type="checkbox" v-model="rememberEmail" />
              Ghi nhớ email
            </label>

            <button
              type="button"
              class="text-xs text-primary-600 hover:underline"
              @click="resetPassword"
            >
              Quên mật khẩu?
            </button>
          </div>

          <n-button
            type="primary"
            block
            :loading="loading"
            @click="handleSignin"
            class="mb-3"
          >
            Đăng nhập
          </n-button>

          <div class="text-center text-xs text-neutral-500 mb-3">hoặc</div>

          <div class="grid grid-cols-2 gap-3">
            <n-button secondary block @click="oauth('google')">
              <template #icon>
                <svg viewBox="0 0 24 24" width="16" height="16" aria-hidden="true"><path fill="#EA4335" d="M12 10.2v3.6h5.1c-.2 1.2-1.5 3.5-5.1 3.5-3.1 0-5.7-2.6-5.7-5.8s2.6-5.8 5.7-5.8c1.8 0 3 .7 3.7 1.4l2.5-2.4C16.6 3.2 14.5 2.3 12 2.3 6.9 2.3 2.7 6.5 2.7 11.5S6.9 20.7 12 20.7c7 0 9.8-4.9 9.1-9.5H12z" /></svg>
              </template>
              Google
            </n-button>

            <n-button secondary block @click="oauth('github')">
              <template #icon>
                <svg viewBox="0 0 24 24" width="16" height="16" aria-hidden="true"><path fill="currentColor" d="M12 .5a12 12 0 0 0-3.8 23.4c.6.1.8-.2.8-.5v-2c-3.3.7-4-1.5-4-1.5-.6-1.4-1.4-1.8-1.4-1.8-1.1-.8.1-.8.1-.8 1.2.1 1.8 1.2 1.8 1.2 1.1 1.8 2.9 1.3 3.6 1 .1-.8.4-1.3.7-1.6-2.6-.3-5.3-1.3-5.3-5.9 0-1.3.5-2.4 1.2-3.3-.1-.3-.5-1.6.1-3.3 0 0 1-.3 3.4 1.2a11.6 11.6 0 0 1 6.2 0c2.3-1.5 3.3-1.2 3.3-1.2.6 1.7.2 3 .1 3.3.8.9 1.2 2 1.2 3.3 0 4.6-2.7 5.6-5.3 5.9.4.4.8 1.1.8 2.2v3.3c0 .3.2.7.8.5A12 12 0 0 0 12 .5z" /></svg>
              </template>
              GitHub
            </n-button>
          </div>
        </n-form>

        <n-form
          v-else
          :model="signup"
          :rules="rulesSignup"
          ref="formSignup"
          size="large"
          label-placement="top"
          @keyup.enter.prevent="handleSignup"
        >
          <n-form-item label="Tên hiển thị" path="displayName">
            <n-input
              v-model:value="signup.displayName"
              type="text"
              placeholder="Ví dụ: Gege Team"
              :input-props="{ autocomplete: 'name' }"
            />
          </n-form-item>

          <n-form-item label="Email" path="email">
            <n-input
              v-model:value="signup.email"
              type="text"
              placeholder="you@example.com"
              :input-props="{ autocomplete: 'email' }"
            />
          </n-form-item>

          <n-form-item label="Mật khẩu" path="password">
            <n-input
              :type="showPassword ? 'text' : 'password'"
              v-model:value="signup.password"
              placeholder="Ít nhất 6 ký tự"
              :input-props="{ autocomplete: 'new-password' }"
            >
              <template #suffix>
                <button
                  type="button"
                  class="text-xs text-neutral-500 hover:text-neutral-700"
                  @click="showPassword = !showPassword"
                >
                  {{ showPassword ? 'Ẩn' : 'Hiện' }}
                </button>
              </template>
            </n-input>
          </n-form-item>

          <n-button
            type="primary"
            block
            :loading="loading"
            @click="handleSignup"
          >
            Tạo tài khoản
          </n-button>
        </n-form>
      </n-card>

      <div class="text-center mt-4">
        <n-button text @click="toHome" v-if="auth.user">
          ← Trở về Dashboard
        </n-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import type { FormInst, FormRules } from 'naive-ui'
import { useMessage, NCard, NForm, NFormItem, NInput, NButton } from 'naive-ui'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/auth'

type Provider = 'google' | 'github'
type SigninModel = { email: string; password: string }
type SignupModel = { displayName: string; email: string; password: string }

const router = useRouter()
const route = useRoute()
const auth = useAuth()
const message = useMessage()

// tabs & ui
const tab = ref<'signin' | 'signup'>('signin')
const showPassword = ref(false)
const loading = ref(false)

// remember email
const LS_KEY_REMEMBER = 'remember_email'
const LS_KEY_EMAIL = 'remember_email_value'
const rememberEmail = ref(false)

// models
const signin = ref<SigninModel>({ email: '', password: '' })
const signup = ref<SignupModel>({ displayName: '', email: '', password: '' })

// form refs
const formSignin = ref<FormInst | null>(null)
const formSignup = ref<FormInst | null>(null)

// validation rules
const rulesSignin: FormRules = {
  email: [{ required: true, message: 'Vui lòng nhập email', trigger: 'blur' }],
  password: [{ required: true, message: 'Vui lòng nhập mật khẩu', trigger: 'blur' }]
}
const rulesSignup: FormRules = {
  displayName: [{ required: true, message: 'Vui lòng nhập tên hiển thị', trigger: 'blur' }],
  email: [{ required: true, message: 'Vui lòng nhập email', trigger: 'blur' }],
  password: [{ required: true, message: 'Ít nhất 6 ký tự', trigger: 'blur' }]
}

onMounted(() => {
  try {
    rememberEmail.value = localStorage.getItem(LS_KEY_REMEMBER) === '1'
    if (rememberEmail.value) {
      signin.value.email = localStorage.getItem(LS_KEY_EMAIL) || ''
    }
  } catch {}
})

function toHome() {
  router.push('/')
}

async function handleSignin() {
  await formSignin.value?.validate?.();
  loading.value = true;
  try {
    // Gọi action từ store, không cần xử lý user/session ở đây
    await auth.signIn(signin.value.email.trim(), signin.value.password);

    // Xử lý ghi nhớ email
    try {
      if (rememberEmail.value) {
        localStorage.setItem(LS_KEY_REMEMBER, '1');
        localStorage.setItem(LS_KEY_EMAIL, signin.value.email.trim());
      } else {
        localStorage.removeItem(LS_KEY_REMEMBER);
        localStorage.removeItem(LS_KEY_EMAIL);
      }
    } catch {}

    message.success('Đăng nhập thành công!');
    const to = (route.query.redirect as string) || '/';
    router.replace(to);
  } catch (err: any) {
    console.error(err);
    message.error(err?.message || 'Không thể đăng nhập');
  } finally {
    loading.value = false;
  }
}

async function handleSignup() {
  await formSignup.value?.validate?.()
  loading.value = true
  try {
    const displayName = signup.value.displayName?.trim() || signup.value.email.trim().split('@')[0] || 'User'
    const { data, error } = await supabase.auth.signUp({
      email: signup.value.email.trim(),
      password: signup.value.password,
      options: {
        data: { display_name: displayName },
        emailRedirectTo: new URL('/auth/callback', window.location.origin).toString()
      }
    })
    if (error) throw error
    message.success('Tạo tài khoản thành công! Vui lòng kiểm tra email để xác minh.')
    tab.value = 'signin'
    signin.value.email = signup.value.email
  } catch (err: any) {
    console.error(err)
    message.error(err?.message || 'Không thể đăng ký')
  } finally {
    loading.value = false
  }
}

async function oauth(provider: Provider) {
  loading.value = true
  try {
    const redirectTo = new URL('/auth/callback', window.location.origin).toString()
    const { error } = await supabase.auth.signInWithOAuth({
      provider,
      options: { redirectTo }
    })
    if (error) throw error
  } catch (err: any) {
    console.error(err)
    message.error(err?.message || 'Không thể đăng nhập với OAuth')
  } finally {
    loading.value = false
  }
}

async function resetPassword() {
  if (!signin.value.email) {
    message.warning('Nhập email trước khi đặt lại mật khẩu');
    return;
  }
  loading.value = true; // Thêm loading để người dùng biết đang xử lý
  try {
    // THAY ĐỔI: Cập nhật redirectTo sang trang /reset-password
    const redirectTo = new URL('/reset-password', window.location.origin).toString();
    const { error } = await supabase.auth.resetPasswordForEmail(
      signin.value.email.trim(),
      { redirectTo }
    );
    if (error) throw error;
    message.success('Đã gửi email đặt lại mật khẩu! Vui lòng kiểm tra hộp thư của bạn.');
  } catch (err: any) {
    console.error(err);
    message.error(err?.message || 'Không thể gửi email đặt lại mật khẩu');
  } finally {
    loading.value = false; // Dừng loading
  }
}
</script>

<style scoped>
:deep(.n-card) {
  border-radius: 14px;
}
</style>