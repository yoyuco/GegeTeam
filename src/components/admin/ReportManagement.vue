<!-- path: src/components/admin/ReportManagement.vue -->
<template>
  <div class="reports-management">
    <!-- Header Actions -->
    <div class="flex justify-between items-center mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-semibold">Quản lý Báo cáo Dịch vụ</h2>
        <n-tag type="info" size="small">{{ filteredReports.length }} báo cáo</n-tag>
        <n-tag type="warning" size="small">{{ pendingReports }} chờ xử lý</n-tag>
      </div>
      <div class="flex items-center gap-2">
        <n-button type="primary" @click="refreshReports">
          <template #icon>
            <n-icon><RefreshIcon /></n-icon>
          </template>
          Làm mới
        </n-button>
      </div>
    </div>

    <!-- Filter Panel -->
    <FilterPanel
      :show-status-filter="true"
      :show-date-filter="true"
      :show-employee-filter="true"
      :show-priority-filter="true"
      @filter-change="handleFilterChange"
    />

    <!-- Data Table -->
    <n-card>
      <n-data-table
        :columns="columns"
        :data="filteredReports"
        :loading="loading"
        :pagination="{ pageSize: 20 }"
        :bordered="false"
        :single-line="false"
        :row-key="(row: any) => row.report_id"
        striped
      />
    </n-card>

    <!-- Report Details Modal -->
    <n-modal
      v-model:show="reportModalOpen"
      :mask-closable="false"
      :style="{ width: '800px' }"
      preset="card"
      :title="`Xử lý Báo cáo #${selectedReport?.report_id?.substring(0, 8)}`"
      size="large"
    >
      <div class="report-modal">
        <n-spin :show="isSubmitting">
          <n-tabs type="line" animated>
            <n-tab-pane name="report" tab="Chi tiết Báo cáo">
              <n-descriptions label-placement="top" :column="1" bordered>
                <n-descriptions-item label="Người báo cáo">
                  {{ selectedReport?.reporter_name }}
                </n-descriptions-item>
                <n-descriptions-item label="Khách hàng">
                  {{ selectedReport?.customer_name }}
                </n-descriptions-item>
                <n-descriptions-item label="Thời điểm">
                  {{ selectedReport?.reported_at ? new Date(selectedReport.reported_at).toLocaleString() : '' }}
                </n-descriptions-item>
                <n-descriptions-item label="Nội dung báo cáo">
                  {{ selectedReport?.report_description }}
                </n-descriptions-item>
                <n-descriptions-item label="Hạng mục bị báo cáo">
                  <code>{{ selectedReport?.reported_item ? paramsLabel(selectedReport.reported_item) : '' }}</code>
                </n-descriptions-item>
                <n-descriptions-item label="Kênh">
                  {{ selectedReport?.channel_code }}
                </n-descriptions-item>
                <n-descriptions-item label="Deadline">
                  {{ selectedReport?.deadline ? new Date(selectedReport.deadline).toLocaleDateString() : 'N/A' }}
                </n-descriptions-item>
              </n-descriptions>

              <div v-if="selectedReport?.report_proof_urls?.length" class="mt-4">
                <h4 class="font-medium mb-2">Bằng chứng</h4>
                <n-image-group>
                  <n-space>
                    <n-image
                      v-for="url in selectedReport.report_proof_urls"
                      :key="url"
                      width="100"
                      :src="url"
                    />
                  </n-space>
                </n-image-group>
              </div>
            </n-tab-pane>

            <n-tab-pane name="edit-item" tab="Sửa Hạng mục Bị báo cáo">
              <n-form :model="itemEditForm" label-placement="top" class="space-y-2">
                <div class="grid grid-cols-2 gap-4">
                  <n-form-item label="Mục tiêu (Plan)">
                    <n-input-number
                      v-model:value="itemEditForm.plan_qty"
                      class="w-full"
                      :min="0"
                      disabled
                    />
                  </n-form-item>
                  <n-form-item label="Tiến độ đúng là (Actual Done Qty)"> <!-- cspell:disable-line -->
                    <n-input-number
                      v-model:value="itemEditForm.corrected_end_value"
                      class="w-full"
                    />
                  </n-form-item>
                </div>
                <div class="text-xs text-neutral-500 -mt-2 mb-2 px-1">
                  Nhập chỉ số thực tế tại thời điểm kết thúc phiên cuối cùng. Ví dụ: Farmer báo
                  level thực tế là 9.
                </div>

                <template v-if="selectedReport?.reported_item?.kind_code === 'LEVELING'">
                  <n-form-item label="Chế độ">
                    <n-select
                      v-model:value="itemEditForm.params.mode"
                      :options="levelingModeOptions"
                    />
                  </n-form-item>
                  <div class="grid grid-cols-2 gap-4">
                    <n-form-item label="Level Bắt đầu">
                      <n-input-number
                        v-model:value="itemEditForm.params.start"
                        class="w-full"
                        :min="1"
                      />
                    </n-form-item>
                    <n-form-item label="Level Kết thúc (Mục tiêu)">
                      <n-input-number
                        v-model:value="itemEditForm.params.end"
                        class="w-full"
                        :min="1"
                      />
                    </n-form-item>
                  </div>
                </template>

                <template v-if="selectedReport?.reported_item?.kind_code === 'BOSS'">
                  <n-form-item label="Tên Boss">
                    <n-select
                      v-model:value="itemEditForm.params.boss_code"
                      :options="bossDict"
                      filterable
                    />
                  </n-form-item>
                </template>

                <template v-if="selectedReport?.reported_item?.kind_code === 'THE_PIT'">
                  <n-form-item label="Tier">
                    <n-select
                      v-model:value="itemEditForm.params.tier_code"
                      :options="pitTierDict"
                      filterable
                    />
                  </n-form-item>
                </template>

                <template
                  v-if="
                    ['MATERIALS', 'MASTERWORKING', 'NIGHTMARE'].includes(
                      selectedReport?.reported_item?.kind_code || ''
                    )
                  "
                >
                  <n-form-item label="Loại">
                    <n-select
                      v-model:value="itemEditForm.params.attribute_code"
                      :options="materialDict"
                      filterable
                    />
                  </n-form-item>
                </template>

                <template v-if="selectedReport?.reported_item?.kind_code === 'MYTHIC'">
                  <n-form-item label="Mythic Item">
                    <n-select
                      v-model:value="itemEditForm.params.item_code"
                      :options="mythicItemDict"
                      filterable
                    />
                  </n-form-item>
                  <n-form-item label="Greater Affix (GA)">
                    <n-select
                      v-model:value="itemEditForm.params.ga_code"
                      :options="mythicGADict"
                      filterable
                      clearable
                    />
                  </n-form-item>
                </template>

                <n-form-item label="Lý do sửa đổi">
                  <n-input
                    v-model:value="itemEditForm.correction_reason"
                    type="textarea"
                    placeholder="Nhập lý do ngắn gọn..."
                  />
                </n-form-item>
                <n-alert title="Lưu ý" type="warning" class="mt-4">
                  Hành động này sẽ thiết lập lại tiến độ của hạng mục về giá trị "Tiến độ đúng là" <!-- cspell:disable-line -->
                  và vô hiệu hóa lịch sử làm việc cũ.
                </n-alert>
                <n-button type="primary" block class="mt-4" @click="handleSaveItemChanges">
                  Chuẩn hóa Tiến độ <!-- cspell:disable-line -->
                </n-button>
              </n-form>
            </n-tab-pane>

            <n-tab-pane name="resolve" tab="Giải quyết">
              <div class="space-y-4">
                <p>
                  Sau khi đã chỉnh sửa thông tin đơn hàng (nếu cần), hãy nhập ghi chú giải quyết
                  và đóng báo cáo này.
                </p>
                <n-input
                  v-model:value="resolverNotes"
                  type="textarea"
                  placeholder="Nhập ghi chú giải quyết cho Farmer..."
                  :autosize="{ minRows: 4 }"
                />
                <n-button type="success" block @click="handleResolveReport">
                  Đánh dấu đã giải quyết
                </n-button>
              </div>
            </n-tab-pane>
          </n-tabs>
        </n-spin>
      </div>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, h, reactive, computed, watch } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/auth'
import {
  NCard,
  NButton,
  NDataTable,
  NModal,
  NSpin,
  NTabs,
  NTabPane,
  NDescriptions,
  NDescriptionsItem,
  NImage,
  NImageGroup,
  NSpace,
  NForm,
  NFormItem,
  NInput,
  NInputNumber,
  NSelect,
  NAlert,
  NTag,
  NIcon,
  createDiscreteApi,
  type DataTableColumns,
  type SelectOption,
} from 'naive-ui'
import { Refresh as RefreshIcon } from '@vicons/ionicons5'
import FilterPanel from './FilterPanel.vue'

// Types
type ReportRow = {
  report_id: string
  reported_at: string
  report_status: string
  report_description: string
  report_proof_urls: string[]
  reporter_name: string
  order_line_id: string
  customer_name: string
  channel_code: string
  deadline: string | null
  package_note: string | null
  btag: string | null
  login_id: string | null
  login_pwd: string | null
  service_type: string | null
  reported_item: {
    id: string
    kind_code: string
    plan_qty: number
    done_qty: number
    params: Record<string, unknown>
  } | null
}

interface ItemEditForm {
  plan_qty: number | null
  corrected_end_value: number | null
  correction_reason: string
  params: Record<string, any>
}

// Props
interface Props {
  searchQuery?: string
  refreshTrigger?: number
}

const props = withDefaults(defineProps<Props>(), {
  searchQuery: '',
  refreshTrigger: 0
})

// Emits
const emit = defineEmits<{
  refreshed: [tabName: string]
  loadingChange: [loading: boolean]
}>()

// Composables
const { message } = createDiscreteApi(['message'])
const auth = useAuth()

// State
const loading = ref(false)
const reports = ref<ReportRow[]>([])
const reportModalOpen = ref(false)
const selectedReport = ref<ReportRow | null>(null)
const resolverNotes = ref('')
const isSubmitting = ref(false)
const currentFilters = ref<Record<string, any>>({})

// Forms
const itemEditForm = reactive<ItemEditForm>({
  plan_qty: null,
  corrected_end_value: null,
  correction_reason: '',
  params: {}
})

// Options and dictionaries
const attributeMap = ref<Map<string, { name: string; type: string }>>(new Map())
const bossDict = ref<SelectOption[]>([])
const pitTierDict = ref<SelectOption[]>([])
const materialDict = ref<SelectOption[]>([])
const mythicItemDict = ref<SelectOption[]>([])
const mythicGADict = ref<SelectOption[]>([])
const levelingModeOptions = ref([
  { label: 'Level', value: 'level' },
  { label: 'Paragon', value: 'paragon' },
])

// Computed
const filteredReports = computed(() => {
  let result = reports.value

  // Apply search query
  if (props.searchQuery) {
    const query = props.searchQuery.toLowerCase()
    result = result.filter(report =>
      report.reporter_name.toLowerCase().includes(query) ||
      report.customer_name.toLowerCase().includes(query) ||
      report.report_description.toLowerCase().includes(query) ||
      report.channel_code.toLowerCase().includes(query)
    )
  }

  // Apply status filter
  if (currentFilters.value.status) {
    if (Array.isArray(currentFilters.value.status) && currentFilters.value.status.length > 0) {
      result = result.filter(report =>
        currentFilters.value.status.some((status: string) =>
          report.report_status === status
        )
      )
    }
  }

  // Apply date filter
  if (currentFilters.value.dateFrom) {
    result = result.filter(report => {
      const reportDate = new Date(report.reported_at).getTime()
      return reportDate >= currentFilters.value.dateFrom
    })
  }

  if (currentFilters.value.dateTo) {
    result = result.filter(report => {
      const reportDate = new Date(report.reported_at).getTime()
      return reportDate <= currentFilters.value.dateTo
    })
  }

  // Apply employee filter
  if (currentFilters.value.employee) {
    result = result.filter(report =>
      report.reporter_name === currentFilters.value.employee
    )
  }

  return result
})

const pendingReports = computed(() => {
  return reports.value.filter(report => report.report_status === 'new').length
})

// Table columns
const columns: DataTableColumns<ReportRow> = [
  {
    title: 'Thời gian',
    key: 'reported_at',
    render: (row) => new Date(row.reported_at).toLocaleString(),
    width: 180
  },
  {
    title: 'Người báo cáo',
    key: 'reporter_name',
    width: 120
  },
  {
    title: 'Khách hàng',
    key: 'customer_name',
    width: 120
  },
  {
    title: 'Hạng mục',
    key: 'reported_item',
    render: (row) => h('code', row.reported_item ? paramsLabel(row.reported_item) : ''),
    ellipsis: {
      tooltip: true
    }
  },
  {
    title: 'Trạng thái',
    key: 'report_status',
    render: (row) => {
      const statusMap: Record<string, { type: string; text: string }> = {
        'new': { type: 'warning', text: 'Mới' },
        'processing': { type: 'info', text: 'Đang xử lý' },
        'resolved': { type: 'success', text: 'Đã giải quyết' },
        'closed': { type: 'default', text: 'Đã đóng' }
      }
      const status = statusMap[row.report_status] || { type: 'default', text: row.report_status }
      return h(NTag, { type: status.type as any, size: 'small' }, () => status.text)
    },
    width: 100
  },
  {
    title: 'Hành động',
    key: 'actions',
    render: (row) =>
      h(
        NButton,
        { size: 'small', type: 'primary', onClick: () => openReportModal(row) },
        { default: () => 'Xem & Xử lý' }
      ),
    width: 120
  },
]

// Methods
const loadReports = async () => {
  loading.value = true
  emit('loadingChange', true)

  try {
    const { data, error } = await supabase.rpc('get_service_reports_v1', { p_status: 'new' })
    if (error) throw error
    reports.value = data || []
  } catch (error) {
    console.error('Error loading reports:', error)
    message.error('Không thể tải danh sách báo cáo')
  } finally {
    loading.value = false
    emit('loadingChange', false)
  }
}

const loadAttributeMap = async () => {
  try {
    const { data: attributes, error } = await supabase
      .from('attributes')
      .select('id, code, name, type')
    if (error) throw error
    if (!attributes) return

    // Load relationships
    const { data: relationships, error: relError } = await supabase
      .from('attribute_relationships')
      .select('parent_attribute_id, child_attribute_id')
    if (relError) throw relError

    // Build maps
    const attrMapById = new Map(attributes.map((a) => [a.id, a]))
    const childrenMap = new Map<string, string[]>()
    for (const rel of relationships!) {
      if (!childrenMap.has(rel.parent_attribute_id)) {
        childrenMap.set(rel.parent_attribute_id, [])
      }
      childrenMap.get(rel.parent_attribute_id)!.push(rel.child_attribute_id)
    }

    const newAttrMap = new Map<string, { name: string; type: string }>()
    attributes.forEach((attr) => newAttrMap.set(attr.code, { name: attr.name, type: attr.type }))
    attributeMap.value = newAttrMap

    const toSelectOption = (attr: { name: string; code: string }) => ({
      label: attr.name,
      value: attr.code,
    })
    const sortFn = (a: SelectOption, b: SelectOption) =>
      String(a.label).localeCompare(String(b.label))

    // Build options for UI
    const groupedOptions: Record<string, SelectOption[]> = {}
    for (const attr of attributes) {
      if (!groupedOptions[attr.type]) groupedOptions[attr.type] = []
      groupedOptions[attr.type].push(toSelectOption(attr))
    }

    bossDict.value = (groupedOptions['BOSS_NAME'] || []).sort(sortFn)
    materialDict.value = (groupedOptions['MATS_NAME'] || []).sort(sortFn)
    mythicItemDict.value = (groupedOptions['MYTHIC_NAME'] || []).sort(sortFn)
    pitTierDict.value = (groupedOptions['TIER_DIFFICULTY'] || []).sort(
      (a, b) =>
        parseInt(String(a.label).match(/\d+/)?.[0] || '0') -
        parseInt(String(b.label).match(/\d+/)?.[0] || '0')
    )
    mythicGADict.value = (groupedOptions['MYTHIC_GA_TYPE'] || []).sort(sortFn)
  } catch (error) {
    console.error('Error loading attribute map:', error)
    message.error('Không tải được danh mục attributes')
  }
}

const openReportModal = (row: ReportRow) => {
  selectedReport.value = row
  resolverNotes.value = ''

  // Populate item edit form
  const item = row.reported_item
  if (item) {
    itemEditForm.plan_qty = item.plan_qty
    itemEditForm.corrected_end_value = item.done_qty
    itemEditForm.correction_reason = ''
    itemEditForm.params = JSON.parse(JSON.stringify(item.params || {}))

    if (item.kind_code === 'MYTHIC' && !itemEditForm.params.stats) {
      itemEditForm.params.stats = [null, null, null] as any
    }
  }

  reportModalOpen.value = true
}

const handleSaveItemChanges = async () => {
  if (!selectedReport.value?.reported_item?.id) return
  if (itemEditForm.corrected_end_value === null) {
    message.error('Vui lòng nhập "Tiến độ đúng là".') // cspell:disable-line
    return
  }
  if (!itemEditForm.correction_reason.trim()) {
    message.error('Vui lòng nhập lý do sửa đổi.')
    return
  }

  isSubmitting.value = true
  try {
    const { error } = await supabase.rpc('admin_rebase_item_progress_v1', {
      p_service_item_id: selectedReport.value.reported_item.id,
      p_authoritative_done_qty: itemEditForm.corrected_end_value,
      p_new_params: itemEditForm.params,
      p_reason: itemEditForm.correction_reason,
    })

    if (error) throw error
    message.success('Đã chuẩn hóa tiến độ hạng mục thành công!')
    await loadReports()
  } catch (error) {
    console.error('Error saving item changes:', error)
    message.error('Lỗi khi chuẩn hóa tiến độ.')
  } finally {
    isSubmitting.value = false
  }
}

const handleResolveReport = async () => {
  if (!selectedReport.value) return

  try {
    const { error } = await supabase.rpc('resolve_service_report_v1', {
      p_report_id: selectedReport.value.report_id,
      p_resolver_notes: resolverNotes.value,
    })
    if (error) throw error
    message.success('Đã giải quyết báo cáo!')
    reportModalOpen.value = false
    await loadReports()
  } catch (error) {
    console.error('Error resolving report:', error)
    message.error('Lỗi khi giải quyết báo cáo.')
  }
}

const handleFilterChange = (filters: any) => {
  currentFilters.value = filters
}

const refreshReports = () => {
  loadReports()
}

const paramsLabel = (item: { kind_code?: string; params?: Record<string, unknown> }): string => {
  const k = (item.kind_code || '').toUpperCase()
  const p = item.params || {}
  const getName = (code: string) => attributeMap.value.get(code)?.name || code
  let mainLabel = ''

  switch (k) {
    case 'LEVELING':
      mainLabel = `${p.mode === 'paragon' ? 'Paragon' : 'Level'} ${p.start}→${p.end}`
      break
    case 'BOSS':
      mainLabel = `${p.boss_label || getName(String(p.boss_code || ''))}`
      break
    case 'THE_PIT':
      mainLabel = `${p.tier_label || getName(String(p.tier_code || ''))}`
      break
    case 'MATERIALS':
      mainLabel = `${getName(String(p.attribute_code || ''))}`
      break
    case 'MYTHIC':
      mainLabel = `${p.item_label || getName(String(p.item_code || ''))}`
      break
    case 'GENERIC':
      mainLabel = String(p.desc || p.note || 'Generic')
      break
    default:
      mainLabel = JSON.stringify(p)
      break
  }
  return mainLabel
}

// Watch for refresh trigger
watch(() => props.refreshTrigger, () => {
  loadReports()
})

// Lifecycle
onMounted(() => {
  Promise.all([loadReports(), loadAttributeMap()])
})
</script>

<style scoped>
.reports-management {
  padding: 1rem;
}

.report-modal {
  min-height: 400px;
}

.form-section {
  margin-bottom: 2rem;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  font-weight: 600;
  color: #2080f0;
  border-bottom: 2px solid #f0f0f0;
  padding-bottom: 0.5rem;
}

:deep(.n-data-table) {
  .n-data-table-th {
    font-weight: 600;
  }
}
</style>