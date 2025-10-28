<template>
  <div class="space-y-4">
    <n-card title="Emergency Reassignment" :bordered="false">
      <template #header-extra>
        <n-button type="error" @click="showEmergencyModal = true">
          <template #icon>
            <n-icon :component="AlertIcon" />
          </template>
          Emergency Reassignment
        </n-button>
      </template>

      <n-alert type="warning" :show-icon="false">
        Use this feature when an account fails and needs immediate reassignment.
        This will automatically reassign affected employees to available backup accounts.
      </n-alert>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <n-select
          v-model:value="failedAccountId"
          :options="accountOptions"
          placeholder="Select failed account"
          clearable
        />
        <n-input
          v-model:value="failureReason"
          type="textarea"
          placeholder="Describe the failure reason"
          :rows="3"
        />
      </div>

      <n-button
        type="error"
        @click="handleEmergencyReassignment"
        :loading="isProcessing"
        :disabled="!failedAccountId || !failureReason"
      >
        Execute Emergency Reassignment
      </n-button>
    </n-card>

    <!-- Recent Emergency Reassignments -->
    <n-card title="Recent Emergency Reassignments" :bordered="false">
      <n-data-table
        :columns="emergencyColumns"
        :data="emergencyHistory"
        :loading="loadingHistory"
        :bordered="false"
        :pagination="{ pageSize: 10 }"
      />
    </n-card>

    <!-- Emergency Modal -->
    <n-modal v-model:show="showEmergencyModal">
      <n-card
        style="width: 600px"
        title="Emergency Reassignment"
        :bordered="false"
        size="huge"
      >
        <n-form :model="emergencyForm" :rules="emergencyRules" ref="emergencyFormRef">
          <n-form-item label="Failed Account" path="failedAccountId">
            <n-select
              v-model:value="emergencyForm.failedAccountId"
              :options="accountOptions"
              placeholder="Select the account that failed"
            />
          </n-form-item>

          <n-form-item label="Failure Reason" path="failureReason">
            <n-input
              v-model:value="emergencyForm.failureReason"
              type="textarea"
              placeholder="Describe what happened with the account"
              :rows="4"
            />
          </n-form-item>

          <n-form-item label="Impact Assessment">
            <n-space vertical>
              <n-text depth="3">
                This emergency reassignment will:
              </n-text>
              <ul class="list-disc list-inside text-sm text-gray-600 ml-4">
                <li>Immediately reassign affected employees</li>
                <li>Create fallback assignments</li>
                <li>Notify all stakeholders</li>
                <li>Log emergency actions for audit</li>
              </ul>
            </n-space>
          </n-form-item>
        </n-form>

        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="showEmergencyModal = false">Cancel</n-button>
            <n-button
              type="error"
              @click="executeEmergencyReassignment"
              :loading="isProcessing"
            >
              Execute Emergency Reassignment
            </n-button>
          </div>
        </template>
      </n-card>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, h } from 'vue'
import { supabase } from '@/lib/supabase'
import {
  NCard,
  NButton,
  NIcon,
  NDataTable,
  type DataTableColumns,
  NModal,
  NForm,
  NFormItem,
  NSelect,
  NInput,
  NSpace,
  NText,
  NAlert,
  createDiscreteApi,
} from 'naive-ui'
import { Alert as AlertIcon } from '@vicons/ionicons5'
import { AssignmentHelper } from '@/utils/assignmentHelper'

const { message } = createDiscreteApi(['message'])

interface EmergencyRecord {
  id: string
  failed_account_id: string
  failed_account_name: string
  failure_reason: string
  reassigned_count: number
  executed_at: string
  executed_by: string
}

// Reactive data
const failedAccountId = ref('')
const failureReason = ref('')
const isProcessing = ref(false)
const showEmergencyModal = ref(false)
const emergencyHistory = ref<EmergencyRecord[]>([])
const loadingHistory = ref(false)
const accountOptions = ref<{ label: string; value: string }[]>([])

// Emergency form
const emergencyForm = reactive({
  failedAccountId: '',
  failureReason: '',
})

// Form validation rules
const emergencyRules = {
  failedAccountId: [
    { required: true, message: 'Vui lòng chọn account bị lỗi', trigger: 'change' },
  ],
  failureReason: [
    { required: true, message: 'Vui lòng mô tả lý do lỗi', trigger: 'blur' },
    { min: 10, message: 'Mô tả phải có ít nhất 10 ký tự', trigger: 'blur' },
  ],
}

// Table columns
const emergencyColumns: DataTableColumns<EmergencyRecord> = [
  {
    title: 'Failed Account',
    key: 'failed_account_name',
    width: 200,
  },
  {
    title: 'Failure Reason',
    key: 'failure_reason',
    width: 250,
    ellipsis: true,
  },
  {
    title: 'Reassigned Count',
    key: 'reassigned_count',
    width: 120,
    render: (row) => `${row.reassigned_count} assignments`,
  },
  {
    title: 'Executed At',
    key: 'executed_at',
    width: 150,
    render: (row) => new Date(row.executed_at).toLocaleString('vi-VN'),
  },
  {
    title: 'Executed By',
    key: 'executed_by',
    width: 150,
  },
]

// Load game accounts
async function loadGameAccounts() {
  try {
    const { data, error } = await supabase
      .from('game_accounts')
      .select('id, account_name, game_code')
      .eq('is_active', true)
      .order('account_name')

    if (error) throw error

    accountOptions.value = (data || []).map(account => ({
      label: `${account.account_name} (${account.game_code})`,
      value: account.id,
    }))
  } catch (error: any) {
    message.error(error.message || 'Không thể tải danh sách account')
  }
}

// Load emergency history
async function loadEmergencyHistory() {
  loadingHistory.value = true
  try {
    // Since we don't have a dedicated emergency table yet,
    // we'll simulate with fallback assignments
    const { data, error } = await supabase
      .from('employee_shift_assignments')
      .select('*')
      .eq('is_fallback', true)
      .not('fallback_reason', 'is null')
      .order('fallback_time', { ascending: false })
      .limit(50)

    if (error) throw error

    // Transform fallback records to emergency records
    emergencyHistory.value = (data || []).map((record, index) => ({
      id: record.id,
      failed_account_id: 'unknown', // Would be stored in real implementation
      failed_account_name: `Emergency #${index + 1}`,
      failure_reason: record.fallback_reason || 'Unknown reason',
      reassigned_count: 1, // Would be calculated in real implementation
      executed_at: record.fallback_time || record.created_at,
      executed_by: 'System', // Would track actual user
    }))
  } catch (error: any) {
    message.error(error.message || 'Không thể tải lịch sử emergency')
  } finally {
    loadingHistory.value = false
  }
}

// Handle emergency reassignment from main UI
async function handleEmergencyReassignment() {
  if (!failedAccountId.value || !failureReason.value) {
    message.warning('Vui lòng chọn account và mô tả lý do lỗi')
    return
  }

  isProcessing.value = true
  try {
    const result = await AssignmentHelper.handleEmergencyReassignment(
      failedAccountId.value,
      failureReason.value
    )

    if (result.success) {
      message.success(
        `Emergency reassignment completed! ${result.reassignedCount} assignments were reassigned.`
      )

      // Clear form
      failedAccountId.value = ''
      failureReason.value = ''

      // Reload history
      await loadEmergencyHistory()
    } else {
      message.error('Emergency reassignment failed')
    }
  } catch (error: any) {
    message.error(error.message || 'Không thể thực hiện emergency reassignment')
  } finally {
    isProcessing.value = false
  }
}

// Execute emergency reassignment from modal
async function executeEmergencyReassignment() {
  try {
    await emergencyFormRef.value?.validate()
  } catch {
    return
  }

  showEmergencyModal.value = false
  isProcessing.value = true

  try {
    const result = await AssignmentHelper.handleEmergencyReassignment(
      emergencyForm.failedAccountId,
      emergencyForm.failureReason
    )

    if (result.success) {
      message.success(
        `Emergency reassignment completed! ${result.reassignedCount} assignments were reassigned.`
      )

      // Reset form
      emergencyForm.failedAccountId = ''
      emergencyForm.failureReason = ''

      // Reload history
      await loadEmergencyHistory()
    } else {
      message.error('Emergency reassignment failed')
    }
  } catch (error: any) {
    message.error(error.message || 'Không thể thực hiện emergency reassignment')
  } finally {
    isProcessing.value = false
  }
}

// Form ref
const emergencyFormRef = ref()

// Load data on mount
onMounted(() => {
  loadGameAccounts()
  loadEmergencyHistory()
})
</script>