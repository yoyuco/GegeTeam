<!-- path: src/pages/ServiceBoosting.vue -->
<template>
  <div class="p-4">
    <!-- Header -->
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold tracking-tight">Service – Boosting</h1>
      <div class="flex items-center gap-2">
        <n-button size="small" :loading="loading" @click="loadOrders">Làm mới</n-button>
        <n-switch v-model:value="autoRefresh" size="small">
          <template #checked>Auto</template>
          <template #unchecked>Auto</template>
        </n-switch>
      </div>
    </div>

    <n-card :bordered="false" class="shadow-sm">
      <div class="table-wrap overflow-x-auto">
        <n-data-table
          :columns="columns"
          :data="rows"
          :loading="loading"
          :pagination="pagination"
          size="small"
          :row-key="(r) => r.id"
          class="datatable--tight"
        />
      </div>
    </n-card>

    <!-- Drawer -->
    <n-drawer v-model:show="detailOpen" width="1040" placement="right">
      <n-drawer-content title="Thao tác đơn hàng">
        <div class="flex items-center justify-between mb-2">
          <div class="text-sm text-neutral-500">Thông tin đơn hàng</div>
          <div class="flex items-center gap-2">
            <template v-if="!editing">
              <n-button size="tiny" tertiary @click="toggleEdit()">Sửa</n-button>
            </template>
            <template v-else>
              <n-button size="tiny" type="primary" @click="saveInfo" :loading="savingInfo">Lưu</n-button>
              <n-button size="tiny" tertiary @click="cancelEdit">Huỷ</n-button>
            </template>
          </div>
        </div>

        <n-divider class="!my-3">Thông tin chính</n-divider>

        <div class="space-y-1">
          <div class="row">
            <div class="meta">Loại hình</div>
            <div class="val">
              <n-radio-group
                v-model:value="detail.service_type"
                name="service_type"
                size="small"
                :disabled="!editing"
                class="service-type"
              >
                <n-radio-button value="selfplay">Selfplay</n-radio-button>
                <n-radio-button value="pilot">Pilot</n-radio-button>
              </n-radio-group>
            </div>
          </div>

          <div class="row">
            <div class="meta">Dịch vụ (gói)</div>
            <div class="val">
              <div class="flex items-center gap-2">
                <n-tag size="small" :type="pkgTypeTag(detail.package_type).type" :bordered="false">
                  {{ pkgTypeTag(detail.package_type).label }}
                </n-tag>
                <span class="text-xs text-neutral-500">|</span>
                <span class="text-sm">{{ detail.channel_code }}</span>
                <span class="text-xs text-neutral-400">•</span>
                <span class="text-sm">{{ detail.customer_name }}</span>
              </div>
              <div class="text-sm text-neutral-500 mt-1" v-if="detail.package_note">
                {{ detail.package_note }}
              </div>
            </div>
          </div>

          <div class="row">
            <div class="meta">Mô tả</div>
            <div class="val pre">
              <n-input
                v-if="editing"
                v-model:value="detail.service_desc"
                type="textarea"
                :autosize="{ minRows: 2, maxRows: 5 }"
                placeholder="Mô tả dịch vụ (tóm tắt)"
              />
              <template v-else>{{ detail.service_desc || '—' }}</template>
            </div>
          </div>

          <div class="row">
            <div class="meta">Deadline</div>
            <div class="val">
              <template v-if="editing">
                <n-date-picker
                  v-model:value="deadlineModel"
                  type="datetime"
                  clearable
                  placeholder="Chọn hạn chót"
                  class="w-full"
                />
              </template>
              <template v-else>
                <n-tooltip trigger="hover" v-if="detail.deadline">
                  <template #trigger>
                    <n-tag size="small" :type="relText(toTs(detail.deadline), now).color" :bordered="false">
                      {{ relText(toTs(detail.deadline), now).text }}
                    </n-tag>
                  </template>
                  {{ new Date(toTs(detail.deadline)!).toLocaleString() }}
                </n-tooltip>
                <span v-else>—</span>
              </template>
            </div>
          </div>

          <div class="row">
            <div class="meta">Trạng thái</div>
            <div class="val">
              <n-tag size="small" :type="statusView(detail.status).type" :bordered="false">
                {{ statusView(detail.status).label }}
              </n-tag>
            </div>
          </div>

          <div class="row">
            <div class="meta">Người thực hiện</div>
            <div class="val">
              <span class="text-sm">{{ detail.assignees_text || '—' }}</span>
            </div>
          </div>

          <div class="row" v-if="detail.service_type === 'selfplay'">
            <div class="meta">Btag</div>
            <div class="val">
              <n-input v-if="editing" v-model:value="detail.btag" placeholder="Player#1234" />
              <template v-else>{{ detail.btag || '—' }}</template>
            </div>
          </div>
          <template v-else>
            <div class="row">
              <div class="meta">Login ID</div>
              <div class="val">
                <n-input v-if="editing" v-model:value="detail.login_id" placeholder="Login ID" />
                <template v-else>{{ detail.login_id || '—' }}</template>
              </div>
            </div>
            <div class="row">
              <div class="meta">Login Pwd</div>
              <div class="val">
                <n-input v-if="editing" v-model:value="detail.login_pwd" type="password" show-password-on="mousedown" placeholder="••••••" />
                <template v-else>{{ detail.login_pwd ? '••••••' : '—' }}</template>
              </div>
            </div>
          </template>
        </div>

        <n-divider class="!my-3">Danh mục sub (svc_items)</n-divider>
        <div class="space-y-2">
          <div v-for="grp in svcGroups" :key="grp.key" class="svc-kind">
            <div class="svc-kind__head">{{ grp.label }}</div>
            <ul class="svc-kind__list">
              <li v-for="it in grp.items" :key="it.id" class="svc-kind__item">{{ paramsLabel(it) }}</li>
            </ul>
          </div>
          <div v-if="!svcGroups.length" class="text-sm text-neutral-500">Chưa có svc_items — sẽ parse tạm từ service_desc nếu có.</div>
        </div>

        <n-divider class="!my-3">Tiến trình & phiên làm việc</n-divider>

        <div class="mb-2">
          <div class="text-xs text-neutral-500 mb-1">Chọn nhóm để cập nhật tiến trình</div>
          <n-select
            v-model:value="ws2.kindSelected"
            :options="kindOptionsFromOrder"
            multiple
            placeholder="Chọn KIND cần thao tác"
            @update:value="syncRowsFromKinds"
          />
        </div>

        <div class="ws-table mb-3" v-if="ws2.rows.length">
          <div class="ws-head">
            <div>Nội dung</div>
            <div>Start</div>
            <div>Current</div>
            <div>Proof (tuỳ chọn)</div>
          </div>
          <div v-for="(r, i) in ws2.rows" :key="r.item_id" class="ws-row">
            <div class="truncate">{{ r.label }}</div>
            <div><n-input-number v-model:value="r.start_value" :show-button="false" /></div>
            <div><n-input-number v-model:value="r.current_value" :show-button="false" /></div>
            <div class="flex items-center gap-2">
              <n-upload :default-upload="false" :max="1" @change="(f) => (ws2.rows[i].startFile = f.file?.file || null)">
                <n-button size="tiny">Start</n-button>
              </n-upload>
              <n-upload :default-upload="false" :max="1" @change="(f) => (ws2.rows[i].endFile = f.file?.file || null)">
                <n-button size="tiny">End</n-button>
              </n-upload>
            </div>
          </div>
        </div>

        <div class="mb-2 grid gap-2">
          <div class="text-xs text-neutral-500">Hoạt động (tuỳ chọn)</div>
          <div class="flex items-center gap-2">
            <n-select v-model:value="ws2.activity" :options="activityOptions" style="width: 220px" />
            <n-button size="tiny" tertiary @click="addActRow">Thêm dòng</n-button>
          </div>
          <div class="grid gap-2">
            <div v-for="(ar, i) in ws2.activityRows" :key="'act-'+i" class="flex items-center gap-2">
              <n-input v-model:value="ar.label" placeholder="Mô tả" />
              <n-input-number v-model:value="ar.qty" :min="0" :show-button="false" placeholder="Qty" style="width: 120px" />
              <n-button size="tiny" tertiary @click="rmActRow(i)" :disabled="ws2.activityRows.length===1">Xoá</n-button>
            </div>
          </div>
        </div>

        <div class="mb-2">
          <n-input v-model:value="ws2.note" type="textarea" :autosize="{minRows:2, maxRows:4}" placeholder="Ghi chú thêm" />
        </div>

        <div class="flex justify-end gap-2">
          <n-button size="small" tertiary @click="detailOpen=false">Đóng</n-button>
          <n-button size="small" type="primary" :loading="submittingFinish" @click="finishSession">Cập nhật tiến trình</n-button>
        </div>
      </n-drawer-content>
    </n-drawer>

    <!-- Modal: Review -->
    <n-modal v-model:show="review.open" preset="dialog" title="Đánh giá đơn">
      <div class="space-y-3">
        <n-rate v-model:value="review.stars" allow-half />
        <n-input v-model:value="review.comment" type="textarea" :autosize="{minRows: 3, maxRows: 6}" placeholder="Nhận xét (tuỳ chọn)" />
        <div class="flex justify-end gap-2">
          <n-button tertiary size="small" @click="review.open = false">Huỷ</n-button>
          <n-button type="primary" size="small" :loading="review.saving" @click="submitReview">Gửi đánh giá</n-button>
        </div>
      </div>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { h, ref, reactive, computed, onMounted, onBeforeUnmount } from 'vue'
import {
  NCard, NButton, NDataTable, NSwitch, NTag, NTooltip, NDrawer, NDrawerContent,
  NDivider, NRadioGroup, NRadioButton, NInput, NDatePicker, NUpload, NInputNumber,
  NModal, NRate, NSelect, createDiscreteApi, type DataTableColumns
} from 'naive-ui'
import { supabase } from '@/lib/supabase'

const { message } = createDiscreteApi(['message'])
const CUSTOMER_REL = 'customer:parties!orders_customer_id_fkey'

/* ===================== Types ===================== */
type Row = {
  id: string
  order_id: string
  created_at: string
  channel_code: string
  service_type: 'selfplay'|'pilot'
  customer_name: string
  package_type: 'BASIC'|'CUSTOM'|'BUILD'|null
  package_note: string|null
  service_desc: string|null
  deadline: string|null
  status: string|null
  assignees_text: string
}

type SvcItem = { id: string; kind_code: string; kind_name?: string; params: any; plan_qty?: number|null; done_qty?: number|null }

/* ===================== State ===================== */
const rows = ref<Row[]>([])
const loading = ref(false)
const autoRefresh = ref(true)
const pagination = reactive({ page: 1, pageSize: 20, pageSizes: [10, 20, 50, 100], showSizePicker: true })

/* ===================== Helpers ===================== */
const clip = (s: any, n = 60) => {
  const str = (s ?? '').toString()
  return str.length > n ? (str.slice(0, n - 1) + '…') : str
}
function renderTrunc(text: any, len = 30) {
  const full = (text ?? '').toString()
  const short = clip(full, len)
  if (!full) return '—'
  if (short === full) return full
  return h(
    NTooltip,
    { trigger: 'hover' },
    { trigger: () => h('span', { class: 'cell-text' }, short), default: () => full }
  )
}
function pkgTypeTag(v: any) {
  const s = (v ?? '').toString().toUpperCase()
  if (s === 'CUSTOM') return { label: 'Custom', type: 'warning' as const }
  if (s === 'BUILD')  return { label: 'Build',  type: 'info'    as const }
  return { label: 'Basic',  type: 'success' as const }
}
function statusView(s: any) {
  const v = (s ?? '').toString().toUpperCase()
  if (v === 'CLOSED') return { label: 'Closed', type: 'default' as const }
  if (v === 'PENDING') return { label: 'Pending', type: 'warning' as const }
  if (v === 'CANCELLED') return { label: 'Cancelled', type: 'error' as const }
  return { label: 'Active', type: 'success' as const }
}
const now = ref(Date.now())
let clock: number | null = null
function startClock(){ stopClock(); clock = window.setInterval(()=> now.value = Date.now(), 1000) }
function stopClock(){ if (clock) { clearInterval(clock); clock = null } }
const toTs = (v: any) => !v ? null : (typeof v === 'number' ? v : Date.parse(v))
function relText(ts: number | null, nowMs: number) {
  if (!ts) return { text: '—', color: 'default' as const }
  const diff = ts - nowMs
  const abs = Math.abs(diff)
  const mins = Math.round(abs / 60000)
  if (diff < 0) {
    if (mins < 60) return { text: `Quá hạn ${mins}m`, color: 'error' as const }
    const h = Math.round(mins/60); return { text:`Quá hạn ${h}h`, color:'error' as const }
  } else {
    if (mins <= 30) return { text: `Còn ${mins}m`, color: 'warning' as const }
    const h = Math.round(mins/60); return { text:`Còn ${h}h`, color:'success' as const }
  }
}

/* ===================== Columns ===================== */
const columns: DataTableColumns<Row> = [
  { title: 'Nguồn bán', key: 'channel_code', width: 120, ellipsis: true, render: (row) => renderTrunc(row.channel_code, 16) },
  {
    title: 'Loại', key: 'service_type', width: 90,
    render: (row) => {
      const t = (row.service_type === 'pilot') ? 'Pilot' : 'Selfplay'
      const type: 'default' | 'primary' = row.service_type === 'pilot' ? 'default' : 'primary'
      return h(NTag, { size: 'small', type, bordered: false }, { default: () => t })
    }
  },
  { title: 'Tên khách hàng', key: 'customer_name', width: 180, ellipsis: true, render: (row) => renderTrunc(row.customer_name, 30) },
  {
    title: 'Gói dịch vụ', key: 'package_type', width: 100,
    render: (row) => {
      const t = pkgTypeTag(row.package_type)
      return h(NTag, { size: 'small', type: t.type, bordered: false }, { default: () => t.label })
    }
  },
  { title: 'Gói Note', key: 'package_note', width: 200, ellipsis: true, render: (row) => renderTrunc(row.package_note, 40) },
  {
    title: 'Dịch vụ (mô tả)',
    key: 'service_desc',
    minWidth: 480,
    ellipsis: true,
    render: (row) => {
      const full = (row.service_desc || '').toString()
      const short = clip(full, 120)
      const parts = full.split(/\s\|\s/g).filter(Boolean)
      return h(
        NTooltip,
        { trigger: 'hover', placement: 'top' },
        {
          trigger: () => h('span', { class: 'cell-text' }, short),
          default: () =>
            h('div', { class: 'tooltip-desc' }, [
              h(
                'ul',
                { class: 'tooltip-desc__list' },
                parts.map((p, i) => {
                  const m = p.match(/^([^:]+):\s*(.*)$/)
                  const head = m ? m[1] : null
                  const rest = m ? m[2] : p
                  return h('li', { class: 'tooltip-desc__item', key: i }, [
                    head ? h('strong', head + ': ') : null,
                    rest
                  ])
                })
              )
            ])
        }
      )
    }
  },
  {
    title: 'Deadline', key: 'deadline', width: 120,
    render: (row) => {
      const ts = toTs(row.deadline)
      if (!ts) return '—'
      const { text, color } = relText(ts, now.value)
      const abs = new Date(ts).toLocaleString()
      return h(
        NTooltip,
        { trigger: 'hover' },
        { trigger: () => h(NTag, { size: 'small', type: color, bordered: false }, { default: () => text }), default: () => abs }
      )
    }
  },
  {
    title: 'Trạng thái', key: 'status', width: 100,
    render: (row) => {
      const s = statusView(row.status ?? null)
      return h(NTag, { size: 'small', type: s.type, bordered: false }, { default: () => s.label })
    }
  },
  { title: 'Người đang thực hiện', key: 'assignees_text', width: 180, ellipsis: true, render: (row) => renderTrunc(row.assignees_text, 30) },
  {
    title: 'Thao tác', key: 'actions', width: 160, align: 'center',
    render: (row) => h('div', { class: 'row-actions' }, [
      h(NButton, { size: 'tiny', tertiary: true, onClick: () => openDetail(row) }, { default: () => 'Chi tiết' }),
      h(NButton, { size: 'tiny', tertiary: true, onClick: () => openReview(row) }, { default: () => 'Review' })
    ])
  }
]

/* ===================== Load list ===================== */
async function loadOrders() {
  loading.value = true
  try {
    const listSelect = [
      'id',
      'created_at',
      'deadline_to',
      'service_type',
      'meta_json',
      // thêm customer_id để dự phòng
      `orders!inner(id,status,package_type,package_note,customer_id,${CUSTOMER_REL}(name,btag,login_id,login_pwd),channels(code))`
    ].join(',')

    const { data, error } = await supabase
      .from('order_lines')
      .select(listSelect)
      .order('created_at', { ascending: false })
    if (error) throw error

    rows.value = (data ?? []).map((r: any) => {
      const ord = r.orders
      // do đã alias "customer:parties!..." nên dữ liệu nằm ở ord.customer (object)
      const pa = ord?.customer ?? null
      const ch = ord?.channels ?? null

      return {
        id: String(r.id),
        order_id: String(ord?.id ?? ''),
        created_at: String(r.created_at ?? ''),
        channel_code: ch?.code || '',
        service_type: String(r.service_type || 'selfplay').toLowerCase() === 'pilot' ? 'pilot' : 'selfplay',
        // 👇 đảm bảo field đúng tên bạn đang bind trong template
        customer_name: pa?.name || '',
        customer: pa?.name || '',              // nếu template dùng "customer", cũng có dữ liệu
        package_type: ord?.package_type ?? 'BASIC',
        package_note: ord?.package_note ?? '',
        deadline: r?.deadline_to ?? null,
        status: ord?.status ?? 'ACTIVE',
        service_desc: r?.meta_json?.service_desc || '',
        assignees_text: ''
      } as Row
    })

    // 3) Lấy người thực hiện — KHÔNG làm hỏng trang nếu RPC chưa có
    const lineIds = rows.value.map(r => r.id)
    if (lineIds.length) {
      try {
        const { data: assData, error: assErr } = await supabase.rpc('list_assignees_v1', {
          p_line_ids: lineIds
        })
        if (!assErr && Array.isArray(assData)) {
          const map = new Map<string, string[]>()
          for (const r of assData) {
            const k = String(r.order_line_id)
            if (!map.has(k)) map.set(k, [])
            if (r.full_name) map.get(k)!.push(String(r.full_name))
          }
          for (const row of rows.value) row.assignees_text = (map.get(row.id) || []).join(', ')
        } else {
          console.warn('[assignees] RPC vắng mặt hoặc trả lỗi — bỏ qua hiển thị assignees.')
        }
      } catch (e) {
        console.warn('[assignees] RPC không khả dụng — bỏ qua.', e)
      }
    }
  } catch (e: any) {
    console.error('[loadOrders]', e)
    message.error(e?.message || 'Không tải được danh sách')
  } finally {
    loading.value = false
  }
}



/* ===================== Drawer detail ===================== */
const detailOpen = ref(false)
const detail = reactive<any>({
  id: '', order_id: '',
  service_type: 'selfplay',
  customer_name: '',
  channel_code: '',
  package_type: 'BASIC',
  package_note: '',
  service_desc: '',
  deadline: null as null | string,
  status: 'ACTIVE',
  btag: '', login_id: '', login_pwd: '',
  assignees_text: ''
})
const editing = ref(false)
const savingInfo = ref(false)
const deadlineModel = ref<number | null>(null)

function toggleEdit() { editing.value = true; syncEditModel() }
function cancelEdit() { editing.value = false; syncEditModel(true) }
function syncEditModel(reset=false) {
  // hiện tại chỉ đồng bộ deadline
  deadlineModel.value = detail.deadline ? Date.parse(detail.deadline) : null
}

async function openDetail(row: Row) {
  detail.assignees_text = row.assignees_text || ''   // điền sẵn từ list
  await refreshDetail(row.id)
  detailOpen.value = true
  editing.value = false
}

type QChannel = { code: string }
type QParty = { name: string; btag: string | null; login_id: string | null; login_pwd: string | null }
type QOrder = {
  id: string
  status: string | null
  package_type: 'BASIC' | 'CUSTOM' | 'BUILD' | null
  package_note: string | null
  channels: QChannel[] | QChannel | null
  parties: QParty[] | QParty | null
}
type QLine = {
  id: string
  deadline_to: string | null
  meta_json: any
  orders: QOrder
}

function first<T>(v: T | T[] | null | undefined): T | null {
  if (Array.isArray(v)) return (v[0] ?? null) as T | null
  return (v ?? null) as T | null
}

async function refreshDetail(lineId: string) {
  try {
    const detailSelect = [
      'id',
      'deadline_to',
      'service_type',
      'meta_json',
      `orders!inner(id,status,package_type,package_note,customer_id,${CUSTOMER_REL}(name,btag,login_id,login_pwd),channels(code))`
    ].join(',')

    const { data, error } = await supabase
      .from('order_lines')
      .select(detailSelect)
      .eq('id', lineId)
      .maybeSingle()

    if (error) throw error
    if (!data) return

    const d   = data as any
    const ord = d.orders
    const ch  = ord?.channels ?? null
    const pa  = ord?.customer ?? null  // 👈 do alias ở trên

    detail.id            = String(d.id)
    detail.order_id      = String(ord?.id || '')
    detail.service_type  = String(d.service_type || 'selfplay').toLowerCase() === 'pilot' ? 'pilot' : 'selfplay'
    detail.customer_name = pa?.name || ''
    detail.customer      = pa?.name || ''
    detail.channel_code  = ch?.code || ''
    detail.package_type  = (ord?.package_type ?? 'BASIC') as any
    detail.package_note  = ord?.package_note ?? ''
    detail.service_desc  = d?.meta_json?.service_desc || ''
    detail.deadline      = d.deadline_to ?? null
    detail.status        = ord?.status ?? 'ACTIVE'
    detail.btag          = pa?.btag || ''
    detail.login_id      = pa?.login_id || ''
    detail.login_pwd     = pa?.login_pwd || ''

    // assignees — an toàn khi RPC chưa có
    try {
      const { data: assData } = await supabase.rpc('list_assignees_v1', { p_line_ids: [lineId] })
      const names = (assData || [])
        .filter((r:any) => String(r.order_line_id) === String(lineId))
        .map((r:any) => r.full_name)
        .filter(Boolean)
      detail.assignees_text = names.join(', ')
    } catch {
      detail.assignees_text = detail.assignees_text || ''
    }

    await loadSvcItems(d.id)
    syncEditModel(true)
  } catch (e:any) {
    console.error('[refreshDetail]', e)
    message.error(e?.message || 'Không tải được chi tiết')
  }
}

async function saveInfo() {
  if (!detail.id) return
  try {
    savingInfo.value = true
    const payload: any = {
      p_line_id: detail.id,
      p_service_desc: detail.service_desc || null,
      p_deadline: deadlineModel.value ? new Date(deadlineModel.value).toISOString() : null,
      p_btag: detail.service_type === 'selfplay' ? (detail.btag || null) : null,
      p_login_id: detail.service_type === 'pilot' ? (detail.login_id || null) : null,
      p_login_pwd: detail.service_type === 'pilot' ? (detail.login_pwd || null) : null,
    }
    const { error } = await supabase.rpc('update_service_order_v1', payload)
    if (error) throw error
    message.success('Đã lưu')
    editing.value = false
    await loadOrders()
    await refreshDetail(detail.id)
  } catch (e:any) {
    console.error('[saveInfo]', e)
    message.error(e?.message || 'Không lưu được thay đổi')
  } finally {
    savingInfo.value = false
  }
}

/* ===================== svc_items ===================== */
const svcItems = ref<SvcItem[]>([])
const svcGroups = computed(() => groupAndSort(svcItems.value))
function paramsLabel(it: SvcItem): string {
  const k = (it.kind_code || '').toUpperCase()
  const p = it.params || {}
  const plan = Number(it.plan_qty ?? p.plan_qty ?? p.qty ?? 0)
  const done = Number(it.done_qty ?? 0)

  const suffix = plan ? ` (${done}/${plan})` : (done ? ` (${done})` : '')

  if (k === 'LEVELING') return `${p.mode === 'paragon' ? 'Paragon' : 'Level'} ${p.start}→${p.end}${suffix}`
  if (k === 'BOSS')     return `${p.boss_label || p.boss_code}${suffix}`
  if (k === 'PIT')      return `${p.tier_label || ('Tier ' + p.tier)}${suffix}`
  if (k === 'NIGHTMARE')return `${p.tier_label || ('Tier ' + p.tier)}${suffix}`
  if (k === 'MATERIAL') return `${p.material_label || p.code}${suffix}`
  if (k === 'MYTHIC')   return `${p.item_label || p.item_code}${p.ga_label ? ' ('+p.ga_label+(p.ga_note?': '+p.ga_note:'')+')' : ''}${suffix}`
  if (k === 'MASTERWORKING') return `${p.variant_label || p.variant}${suffix}`
  if (k === 'ALTARS')   return `${p.region_label || p.region}${suffix}`
  if (k === 'RENOWN')   return `${p.region_label || p.region}${suffix}`
  if (k === 'GENERIC')  return (p.desc || 'Generic') + suffix
  return JSON.stringify(p) + suffix
}

const KIND_ORDER: Record<string, number> = {
  LEVELING: 10, BOSS: 20, PIT: 30, NIGHTMARE: 40, MYTHIC: 50,
  MATERIAL: 60, MASTERWORKING: 70, ALTARS: 80, RENOWN: 90, GENERIC: 999
}

function groupAndSort(items: SvcItem[]) {
  const groups = new Map<string, { key: string; label: string; code: string; items: SvcItem[] }>()
  for (const it of items) {
    const code = (it.kind_code || 'GENERIC').toString().toUpperCase()
    const label = (it.kind_name || code).toString().replace(/_/g, ' ')
    if (!groups.has(code)) groups.set(code, { key: code, label, code, items: [] })
    groups.get(code)!.items.push(it)
  }
  return Array.from(groups.values()).sort((a, b) => {
    const ra = KIND_ORDER[a.code] ?? 999
    const rb = KIND_ORDER[b.code] ?? 999
    return ra - rb
  })
}

async function loadSvcItems(lineId: string) {
  try {
    const { data, error } = await supabase
      .from('order_service_items')
      .select('id, kind_code, params, plan_qty, done_qty, service_kinds(label)')
      .eq('line_id', lineId)
      .order('created_at', { ascending: true })
    if (error) throw error

    svcItems.value = (data || []).map((r: any) => ({
      id: r.id,
      kind_code: r.kind_code,
      params: r.params,
      plan_qty: r.plan_qty,
      done_qty: r.done_qty,
      kind_name: r.service_kinds?.label
    }))
  } catch (e) {
    console.error('[loadSvcItems]', e)
    svcItems.value = []
  }
}

/* ===================== Work session ===================== */
type WsRow = {
  item_id: string
  kind_code: string
  label: string
  start_value: number
  current_value: number
  startFile: File | null
  endFile: File | null
  startProofUrl: string | null
  endProofUrl: string | null
}
const ws2 = ref<{
  activity: string
  activityRows: { label: string; qty: number }[]
  note: string
  startedAt: string | null
  kindSelected: string[]
  rows: WsRow[]
}>({
  activity: 'BOSS',
  activityRows: [{ label: '', qty: 0 }],
  note: '',
  startedAt: null,
  kindSelected: [],
  rows: []
})
const submittingFinish = ref(false)

const activityOptions = [
  { label: 'Boss', value: 'BOSS' },
  { label: 'The Pit', value: 'PIT' },
  { label: 'Hordes', value: 'HORDES' },
  { label: 'Kurast Undercity', value: 'KURAST_UNDERCITY' },
  { label: 'Helltide', value: 'HELLTIDE' },
  { label: 'Darkcitadel', value: 'DARKCITADEL' },
  { label: 'Khác', value: 'OTHER' }
]
function prettyKind(k: string) {
  const m: Record<string,string> = {
    LEVELING:'Leveling', BOSS:'Boss', PIT:'The Pit', NIGHTMARE:'Nightmare',
    MATERIAL:'Materials', MYTHIC:'Mythic', MASTERWORKING:'Masterworking',
    ALTARS:'Altars', RENOWN:'Renown'
  }
  return m[k] || k
}
const kindOptionsFromOrder = computed(() => {
  const kinds = Array.from(new Set((svcItems.value||[]).map((it:any)=>String(it.kind_code||'').toUpperCase())))
  return kinds.map(k => ({ label: `${prettyKind(k)}`, value: k }))
})
function baselineFromItem(it:any): number {
  const kind = String(it.kind_code || '').toUpperCase()
  const p = it.params || {}
  const done = Number(it.done_qty ?? 0)
  if (kind === 'LEVELING') {
    const st  = Number(p.start ?? 0)
    const end = Number(p.end ?? st)
    return Math.min(st + done, end)
  }
  return done
}
function syncRowsFromKinds() {
  const picked = new Set(ws2.value.kindSelected.map(k=>String(k).toUpperCase()))
  const list: WsRow[] = (svcItems.value||[])
    .filter((it:any)=> picked.has(String(it.kind_code||'').toUpperCase()))
    .map((it:any)=> {
      const base = baselineFromItem(it)
      return {
        item_id: String(it.id),
        kind_code: String(it.kind_code || '').toUpperCase(),
        label: paramsLabel(it),
        start_value: base,
        current_value: base,
        startFile: null, endFile: null,
        startProofUrl: null, endProofUrl: null
      }
    })
  ws2.value.rows = list
}
function addActRow(){ ws2.value.activityRows.push({ label:'', qty:0 }) }
function rmActRow(i:number){ ws2.value.activityRows.splice(i,1) }

const PROOF_BUCKET = 'work-proofs'
async function uploadProof(file: File, lineId: string, sessionId: string, itemId: string, phase: 'start'|'end') {
  const ext = file.name.split('.').pop() || 'bin'
  const path = `${lineId}/${sessionId}/${itemId}/${phase}.${ext}`
  const { error, data } = await supabase.storage.from(PROOF_BUCKET).upload(path, file, { upsert: true })
  if (error) throw error
  const { data: pub } = supabase.storage.from(PROOF_BUCKET).getPublicUrl(data.path)
  return pub?.publicUrl || null
}
async function finishSession() {
  if (!detail.id) return
  try {
    submittingFinish.value = true
    const { data: sess, error: sErr } = await supabase.rpc('start_work_session_v1', {
      p_line_id: detail.id,
      p_note: ws2.value.note || null,
      p_activity: ws2.value.activity || null
    })
    if (sErr) throw sErr
    const sessionId = Array.isArray(sess) ? (sess[0]?.id) : (sess?.id)
    if (!sessionId) throw new Error('Không khởi tạo được session')

    for (const r of ws2.value.rows) {
      if (r.startFile) r.startProofUrl = await uploadProof(r.startFile, detail.id, sessionId, r.item_id, 'start')
      if (r.endFile)   r.endProofUrl   = await uploadProof(r.endFile,   detail.id, sessionId, r.item_id, 'end')
    }

    const itemsPayload = ws2.value.rows.map(r => ({
      item_id: r.item_id,
      start_value: r.start_value,
      end_value: r.current_value,
      start_proof_url: r.startProofUrl,
      end_proof_url: r.endProofUrl
    }))
    const actRows = (ws2.value.activityRows || []).filter(a => (a.label || '').trim() || Number(a.qty || 0) > 0)

    const { error: fErr } = await supabase.rpc('finish_work_session_v1', {
      p_session_id: sessionId,
      p_items: itemsPayload,
      p_activity_rows: actRows
    })
    if (fErr) throw fErr

    message.success('Đã cập nhật tiến trình')
    await loadOrders()
    await refreshDetail(detail.id)
    ws2.value = { activity:'BOSS', activityRows:[{label:'', qty:0}], note:'', startedAt:null, kindSelected:[], rows:[] }
  } catch (e:any) {
    console.error('[finishSession]', e)
    message.error(e?.message || 'Không cập nhật được tiến trình')
  } finally {
    submittingFinish.value = false
  }
}

/* ===================== Review flow ===================== */
const review = ref<{ open: boolean; lineId: string | null; stars: number; comment: string; saving: boolean }>({
  open: false, lineId: null, stars: 5, comment: '', saving: false
})
function openReview(row: Row) {
  review.value.open = true
  review.value.lineId = row.id
  review.value.stars = 5
  review.value.comment = ''
}
async function submitReview() {
  if (!review.value.lineId) return
  try {
    review.value.saving = true
    const { data, error } = await supabase.from('order_lines').select('meta_json').eq('id', review.value.lineId).maybeSingle()
    if (error) throw error
    const mj = (data?.meta_json ?? {}) as any
    const newMj = {
      ...mj,
      review: { stars: review.value.stars, comment: review.value.comment?.trim() || null, at: new Date().toISOString() }
    }
    const { error: upErr } = await supabase.from('order_lines').update({ meta_json: newMj }).eq('id', review.value.lineId)
    if (upErr) throw upErr
    message.success('Đã ghi nhận đánh giá')
    review.value.open = false
    review.value.lineId = null
    await loadOrders()
  } catch (e:any) {
    console.error('[submitReview]', e)
    message.error(e?.message || 'Không thể gửi đánh giá')
  } finally {
    review.value.saving = false
  }
}

/* ===================== Polling & lifecycle ===================== */
let poll: number | null = null
function startPoll () { stopPoll(); poll = window.setInterval(() => { if (autoRefresh.value) loadOrders() }, 30000) }
function stopPoll () { if (poll) { clearInterval(poll); poll = null } }

onMounted(() => { loadOrders(); startClock(); startPoll() })
onBeforeUnmount(() => { stopClock(); stopPoll() })
</script>

<style scoped>
:deep(.n-card) { border-radius: 14px; }

/* Gọn bảng */
.datatable--tight :deep(.n-data-table-th),
.datatable--tight :deep(.n-data-table-td) { padding: 8px 10px; }

.cell-text { display:inline-block; max-width:100%; vertical-align:bottom; }
.row-actions { display:flex; align-items:center; gap:8px; }

/* Drawer layout */
.row  { display:flex; align-items:flex-start; gap:.5rem; padding:.25rem 0; }
.meta { font-size:12px; color:#6b7280; flex-shrink:0; width:120px; }
.val  { font-size:14px; word-break:break-all; }
.pre  { white-space:pre-line; }

/* Radio trong drawer */
.service-type { display: inline-flex !important; gap: 8px; align-items: center; }
.service-type :deep(.n-radio-button) {
  min-width: 92px; height: 32px; padding: 0 10px; border-radius: 10px;
  border: 1px solid #e5e7eb !important; background: #fff; transition: all .2s ease;
  display: inline-flex; justify-content: center; align-items: center; box-shadow: none;
}
.service-type :deep(.n-radio-button--checked) {
  background: #111827; color: #fff; border-color: #111827 !important;
}

/* Tooltip */
.tooltip-desc { max-width: 960px; white-space: normal; }
.tooltip-desc__list { margin: 0; padding-left: 18px; }
.tooltip-desc__item { margin: 2px 0; line-height: 1.35; }

/* svc_items group */
.svc-kind { border: 1px dashed #e5e7eb; border-radius: 10px; padding: 8px 10px; }
.svc-kind + .svc-kind { margin-top: 6px; }
.svc-kind__head { font-weight: 600; font-size: 13px; margin-bottom: 4px; }
.svc-kind__list { margin: 0; padding-left: 18px; list-style: disc; }
.svc-kind__item { line-height: 1.4; margin: 2px 0; }

/* Work session table */
.ws-table { border: 1px solid #e5e7eb; border-radius: 10px; padding: 8px; }
.ws-head, .ws-row {
  display: grid;
  grid-template-columns: minmax(340px, 1fr) 120px 120px 1fr;
  gap: 10px;
  align-items: center;
}
.ws-head { font-size: 12px; color: #6b7280; padding: 4px 2px; }
.ws-row  { padding: 6px 2px; border-top: 1px dashed #eee; }
.ws-row:first-of-type { border-top: 0; }
</style>
