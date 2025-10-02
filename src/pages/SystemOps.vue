<!-- path: src/pages/SystemOps.vue -->
<template>
  <div class="p-4">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold tracking-tight">Thao tác hệ thống (Audit Logs)</h1>
      <div class="flex items-center gap-2">
        <n-switch v-model:value="autoRefresh" size="small">
          <template #checked>Auto</template>
          <template #unchecked>Auto</template>
        </n-switch>
        <n-button size="small" :loading="loading" @click="loadLogs">Làm mới</n-button>
      </div>
    </div>

    <n-card v-if="!canView" :bordered="false" class="shadow-sm">
      <n-alert type="error" title="Không có quyền truy cập">
        Bạn không có quyền xem mục này.
      </n-alert>
    </n-card>

    <n-card v-else :bordered="false" class="shadow-sm">
      <div class="flex flex-wrap items-end gap-2 mb-3">
        <n-date-picker
          v-model:value="rangeModel"
          type="datetimerange"
          clearable
          size="small"
          class="w-[320px]"
          :shortcuts="rangeShortcuts"
        />
        <n-select
          v-model:value="ops"
          multiple
          clearable
          size="small"
          class="w-[220px]"
          :options="opOptions"
          placeholder="Op (INSERT/UPDATE/DELETE)"
        />
        <n-select
          v-model:value="entities"
          multiple
          clearable
          size="small"
          class="w-[260px]"
          :options="entityOptions"
          placeholder="Bảng / Entity"
        />
        <n-input
          v-model:value="actor"
          size="small"
          clearable
          class="w-[220px]"
          placeholder="Actor (UUID)"
        />
        <n-input
          v-model:value="kw"
          size="small"
          clearable
          class="w-[220px]"
          placeholder="Từ khoá (lọc diff client-side)"
        />
        <div class="flex items-center gap-2">
          <n-button size="small" tertiary @click="resetFilters">Xoá lọc</n-button>
          <n-button size="small" :loading="loading" @click="loadLogs">Áp dụng</n-button>
          <n-button size="small" tertiary :disabled="!rows.length" @click="exportCSV">CSV</n-button>
        </div>
        <div class="ml-auto text-xs text-neutral-500">Tổng: {{ totalLabel }}</div>
      </div>

      <div class="table-wrap overflow-x-auto">
        <n-data-table
          :columns="columns"
          :data="filteredRows"
          :loading="loading"
          :pagination="pagination"
          :row-key="(r) => r.id"
          size="small"
          class="datatable--tight"
        />
      </div>
    </n-card>

    <n-drawer v-model:show="detailOpen" width="880" placement="right">
      <n-drawer-content title="Chi tiết log">
        <template v-if="current">
          <div class="grid grid-cols-2 gap-2 mb-3">
            <div class="meta">ID</div>
            <div class="val">{{ current.id }}</div>
            <div class="meta">Thời điểm</div>
            <div class="val">{{ dt(current.at) }}</div>
            <div class="meta">Actor</div>
            <div class="val mono">{{ current.actor || '—' }}</div>
            <div class="meta">Entity</div>
            <div class="val">{{ current.entity }}</div>
            <div class="meta">Table</div>
            <div class="val">{{ current.table_name }}</div>
            <div class="meta">Op</div>
            <div class="val">
              <n-tag size="small" :type="opTag(current.op).type" :bordered="false">
                {{ opTag(current.op).label }}
              </n-tag>
            </div>
            <div class="meta">Action</div>
            <div class="val">{{ current.action || '—' }}</div>
          </div>

          <n-divider class="!my-3">PK</n-divider>
          <pre class="json">{{ pretty(current.pk) }}</pre>

          <n-divider class="!my-3">Diff</n-divider>
          <pre class="json">{{ pretty(current.diff) }}</pre>

          <n-divider class="!my-3">Row (old)</n-divider>
          <pre class="json">{{ pretty(current.row_old) }}</pre>

          <n-divider class="!my-3">Row (new)</n-divider>
          <pre class="json">{{ pretty(current.row_new) }}</pre>

          <n-divider class="!my-3">Context</n-divider>
          <pre class="json">{{ pretty(current.ctx) }}</pre>
        </template>
      </n-drawer-content>
    </n-drawer>
  </div>
</template>

<script setup lang="ts">
import { h, ref, reactive, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import {
  NCard,
  NButton,
  NDataTable,
  NSwitch,
  NTag,
  NTooltip,
  NDrawer,
  NDrawerContent,
  DatePickerProps,
  NDivider,
  NInput,
  NDatePicker,
  NSelect,
  createDiscreteApi,
  type DataTableColumns,
  NAlert,
} from 'naive-ui'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/auth'

const { message } = createDiscreteApi(['message'])
const auth = useAuth()

/* ======== Permission ======== */
const canView = ref(false)

onMounted(() => {
  let unwatch: () => void // Khai báo biến trước

  unwatch = watch(
    () => auth.loading,
    (isLoading) => {
      if (!isLoading) {
        canView.value = auth.hasPermission('system:view_audit_logs')
        if (canView.value) {
          loadLogs()
          startPoll()
        }
        // Bây giờ có thể gọi unwatch một cách an toàn
        if (unwatch) {
          unwatch()
        }
      }
    },
    { immediate: true }
  )
})

onBeforeUnmount(() => stopPoll())

/* ======== Filters / state ======== */
type LogRow = {
  id: number
  at: string
  actor: string | null
  action: string | null
  entity: string | null
  table_name: string | null
  op: 'INSERT' | 'UPDATE' | 'DELETE' | string
  pk: Record<string, unknown> | null
  diff: Record<string, unknown> | null
  row_old: Record<string, unknown> | null
  row_new: Record<string, unknown> | null
  ctx: Record<string, unknown> | null
}

const rows = ref<LogRow[]>([])
const loading = ref(false)
const autoRefresh = ref(true)
let poll: number | null = null
function startPoll() {
  stopPoll()
  poll = window.setInterval(() => {
    if (autoRefresh.value && canView.value) loadLogs()
  }, 30000)
}
function stopPoll() {
  if (poll) {
    clearInterval(poll)
    poll = null
  }
}

const rangeModel = ref<[number, number] | null>(null)
const ops = ref<string[] | null>(null)
const entities = ref<string[] | null>(null)
const actor = ref<string>('')
const kw = ref<string>('')
type Shortcuts = NonNullable<DatePickerProps['shortcuts']>

// Helpers ngày
const DAY = 24 * 60 * 60 * 1000
const sod = (t: number) => new Date(new Date(t).setHours(0, 0, 0, 0)).getTime()
const eod = (t: number) => new Date(new Date(t).setHours(23, 59, 59, 999)).getTime()
const now = Date.now()

// ✅ Đúng kiểu Shortcuts (object key -> range | fn)
const rangeShortcuts: Shortcuts = {
  'Hôm nay': () => [sod(now), eod(now)],
  'Hôm qua': () => [sod(now - DAY), eod(now - DAY)],
  '7 ngày qua': () => [sod(now - 6 * DAY), eod(now)],
  '30 ngày qua': () => [sod(now - 29 * DAY), eod(now)],
}
const opOptions = [
  { label: 'INSERT', value: 'INSERT' },
  { label: 'UPDATE', value: 'UPDATE' },
  { label: 'DELETE', value: 'DELETE' },
]
const entityOptions = [
  { label: 'public.orders', value: 'public.orders' },
  { label: 'public.order_lines', value: 'public.order_lines' },
  { label: 'public.order_service_items', value: 'public.order_service_items' },
  { label: 'public.work_sessions', value: 'public.work_sessions' },
  { label: 'public.work_session_outputs', value: 'public.work_session_outputs' },
]
function resetFilters() {
  rangeModel.value = null
  ops.value = null
  entities.value = null
  actor.value = ''
  kw.value = ''
}

/* pagination */
const pagination = reactive({
  page: 1,
  pageSize: 50,
  pageSizes: [20, 50, 100, 200],
  showSizePicker: true,
  onChange: (p: number) => (pagination.page = p),
  onUpdatePageSize: (ps: number) => {
    pagination.pageSize = ps
    pagination.page = 1
  },
})
const total = ref<number | null>(null)
const totalLabel = computed(() => (total.value == null ? '—' : total.value.toLocaleString('en-US')))

/* ======== Load ======== */
async function loadLogs() {
  if (!canView.value) return
  loading.value = true
  try {
    const q = supabase
      .from('audit_logs')
      .select(
        'id, at, actor, action, entity, entity_id, table_name, op, pk, diff, row_old, row_new, ctx',
        { count: 'exact' }
      )
      .order('id', { ascending: false })
      .limit(pagination.pageSize)
      .range((pagination.page - 1) * pagination.pageSize, pagination.page * pagination.pageSize - 1)

    if (rangeModel.value) {
      const [from, to] = rangeModel.value
      q.gte('at', new Date(from).toISOString()).lte('at', new Date(to).toISOString())
    }
    if (ops.value?.length) q.in('op', ops.value)
    if (entities.value?.length) q.in('entity', entities.value)
    if (actor.value.trim()) q.eq('actor', actor.value.trim())

    const { data, error, count } = await q
    if (error) throw error

    rows.value = (data || []) as LogRow[]
    total.value = count ?? null
  } catch (e: unknown) {
    const error = e as Error
    console.error('[loadLogs]', error)
    message.error(error?.message || 'Không tải được audit logs')
  } finally {
    loading.value = false
  }
}

/* client-side keyword filter (diff) */
const filteredRows = computed(() => {
  const k = kw.value.trim().toLowerCase()
  if (!k) return rows.value
  return rows.value.filter((r) => {
    try {
      const s = JSON.stringify(r.diff ?? r.row_new ?? r.row_old ?? {}).toLowerCase()
      return s.includes(k)
    } catch {
      return false
    }
  })
})

/* ======== Table columns ======== */
function dt(iso: string) {
  try {
    return new Date(iso).toLocaleString()
  } catch {
    return iso
  }
}
function opTag(op: string | null | undefined) {
  const v = String(op || '').toUpperCase()
  if (v === 'INSERT') return { label: 'INSERT', type: 'success' as const }
  if (v === 'UPDATE') return { label: 'UPDATE', type: 'warning' as const }
  if (v === 'DELETE') return { label: 'DELETE', type: 'error' as const }
  return { label: v || '—', type: 'default' as const }
}
const columns: DataTableColumns<LogRow> = [
  { title: 'ID', key: 'id', width: 90 },
  { title: 'Thời điểm', key: 'at', width: 160, render: (row) => dt(row.at) },
  {
    title: 'Op',
    key: 'op',
    width: 90,
    render: (row) =>
      h(
        NTag,
        { size: 'small', type: opTag(row.op).type, bordered: false },
        { default: () => opTag(row.op).label }
      ),
  },
  { title: 'Entity', key: 'entity', width: 180 },
  { title: 'Table', key: 'table_name', width: 160 },
  { title: 'Actor', key: 'actor', width: 240, render: (row) => row.actor || '—' },
  {
    title: 'Diff',
    key: 'diff',
    minWidth: 420,
    render: (row) => {
      const s = safeClip(JSON.stringify(row.diff ?? {}), 220)
      return h(
        NTooltip,
        { trigger: 'hover', placement: 'top' },
        {
          trigger: () => h('span', { class: 'cell-text mono' }, s),
          default: () => h('pre', { class: 'json' }, pretty(row.diff)),
        }
      )
    },
  },
  {
    title: 'Chi tiết',
    key: 'actions',
    width: 110,
    align: 'center',
    render: (row) =>
      h(
        NButton,
        { size: 'tiny', tertiary: true, onClick: () => openDetail(row) },
        { default: () => 'Xem' }
      ),
  },
]
function safeClip(s: string, n = 220) {
  if (!s) return '—'
  return s.length > n ? s.slice(0, n - 1) + '…' : s
}
function pretty(v: unknown) {
  try {
    return JSON.stringify(v ?? null, null, 2)
  } catch {
    return String(v)
  }
}

/* ======== Drawer detail ======== */
const detailOpen = ref(false)
const current = ref<LogRow | null>(null)
function openDetail(row: LogRow) {
  current.value = row
  detailOpen.value = true
}

/* ======== Export CSV ======== */
function csvEsc(v: unknown) {
  const s = v == null ? '' : typeof v === 'string' ? v : JSON.stringify(v)
  // Dùng regex global thay cho replaceAll (chạy tốt từ ES5 trở lên)
  return `"${s.replace(/"/g, '""')}"`
}

function exportCSV() {
  const headers = [
    'id',
    'at',
    'actor',
    'entity',
    'table_name',
    'op',
    'action',
    'pk',
    'diff',
    'row_old',
    'row_new',
    'ctx',
  ]
  const lines = [headers.join(',')]

  for (const r of filteredRows.value) {
    lines.push(
      [
        r.id,
        r.at,
        r.actor ?? '',
        r.entity ?? '',
        r.table_name ?? '',
        r.op ?? '',
        r.action ?? '',
        csvEsc(r.pk),
        csvEsc(r.diff),
        csvEsc(r.row_old),
        csvEsc(r.row_new),
        csvEsc(r.ctx),
      ].join(',')
    )
  }

  const blob = new Blob([lines.join('\n')], { type: 'text/csv;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `audit_logs_${new Date().toISOString().slice(0, 10)}.csv`
  a.click()
  URL.revokeObjectURL(url)
}
</script>

<style scoped>
:deep(.n-card) {
  border-radius: 14px;
}
.datatable--tight :deep(.n-data-table-th),
.datatable--tight :deep(.n-data-table-td) {
  padding: 8px 10px;
}
.cell-text {
  display: inline-block;
  max-width: 100%;
  vertical-align: bottom;
}
.mono {
  font-family:
    ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New',
    monospace;
}
.meta {
  font-size: 12px;
  color: #6b7280;
}
.val {
  font-size: 14px;
  word-break: break-all;
}
.json {
  background: #0f172a;
  color: #e2e8f0;
  padding: 8px 10px;
  border-radius: 8px;
  max-height: 300px;
  overflow: auto;
  white-space: pre-wrap;
}
.w-\[320px\] {
  width: 320px;
}
.w-\[260px\] {
  width: 260px;
}
.w-\[220px\] {
  width: 220px;
}
</style>
