<!-- path: src/pages/ResetPassword.vue -->
<template>
  <div class="min-h-screen flex items-center justify-center bg-neutral-50 p-4">
    <div class="w-full max-w-md">
      <h1 class="text-center text-2xl font-semibold tracking-tight mb-6">Đặt lại mật khẩu</h1>

      <n-card :bordered="false" class="shadow-sm">
        <div v-if="successMessage" class="text-center">
          <p class="text-green-600 mb-4">{{ successMessage }}</p>
          <n-button type="primary" block @click="toLogin"> Trở về trang Đăng nhập </n-button>
        </div>

        <n-form
          v-else
          :model="form"
          :rules="rules"
          ref="formRef"
          size="large"
          label-placement="top"
          @keyup.enter.prevent="handleReset"
        >
          <n-form-item label="Mật khẩu mới" path="password">
            <n-input
              type="password"
              show-password-on="mousedown"
              v-model:value="form.password"
              placeholder="Ít nhất 6 ký tự"
              :input-props="{ autocomplete: 'new-password' }"
            />
          </n-form-item>

          <n-form-item label="Xác nhận mật khẩu mới" path="confirmPassword">
            <n-input
              type="password"
              show-password-on="mousedown"
              v-model:value="form.confirmPassword"
              placeholder="Nhập lại mật khẩu mới"
              :input-props="{ autocomplete: 'new-password' }"
            />
          </n-form-item>

          <n-button type="primary" block :loading="loading" @click="handleReset">
            Lưu mật khẩu mới
          </n-button>
        </n-form>
      </n-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import type { FormInst, FormRules, FormItemRule } from 'naive-ui'
import { useMessage, NCard, NForm, NFormItem, NInput, NButton } from 'naive-ui'
import { supabase } from '@/lib/supabase'

const router = useRouter()
const message = useMessage()

const formRef = ref<FormInst | null>(null)
const loading = ref(false)
const successMessage = ref('')

const form = reactive({
  password: '',
  confirmPassword: '',
})

// Validation rules
const validatePasswordConfirm = (rule: FormItemRule, value: string): boolean => {
  return value === form.password
}

const rules: FormRules = {
  password: [
    { required: true, message: 'Vui lòng nhập mật khẩu mới', trigger: 'blur' },
    { min: 6, message: 'Mật khẩu phải có ít nhất 6 ký tự', trigger: 'blur' },
  ],
  confirmPassword: [
    { required: true, message: 'Vui lòng xác nhận mật khẩu', trigger: 'blur' },
    {
      validator: validatePasswordConfirm,
      message: 'Mật khẩu xác nhận không khớp',
      trigger: ['blur', 'password-input'],
    },
  ],
}

// Methods
async function handleReset() {
  await formRef.value?.validate()
  loading.value = true
  try {
    const { error } = await supabase.auth.updateUser({
      password: form.password,
    })
    if (error) throw error

    successMessage.value = 'Mật khẩu của bạn đã được cập nhật thành công!'
  } catch (err: any) {
    console.error(err)
    message.error(err?.message || 'Không thể đặt lại mật khẩu. Link có thể đã hết hạn.')
  } finally {
    loading.value = false
  }
}

function toLogin() {
  router.replace('/login')
}
</script>

<style scoped>
:deep(.n-card) {
  border-radius: 14px;
}
</style>
