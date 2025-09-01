<!-- path: src/pages/Orders.vue -->
<template>
  <div class="p-4">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold">Đơn hàng</h1>
      <div class="flex items-center gap-2">
        <n-input
          v-model:value="q"
          placeholder="Tìm theo kênh / khách hàng..."
          clearable
          class="w-72"
          @update:value="debouncedReload"
        />
        <n-button secondary @click="reload">Làm mới</n-button>
      </div>
    </div>

    <n-card :bordered="false" class="shadow-sm">
      <n-data-table
        :loading="loading"
        :columns="columns"
        :data="rows"
        :pagination="false"
        size="small"
        :bordered="false"
      />
      <div class="mt-3 flex items-center justify-between">
        <div class="text-xs text-neutral-500">
          Tổng: {{ total.toLocaleString() }} đơn
        </div>
        <n-pagination
          :page="page"
          :page-size="pageSize"
          :item-count="total"
          @update:page="(p:number)=>{page=p; reload()}"
        />
      </div>
    </n-card>

    <!-- Drawer chi tiết -->
    <n-drawer v-model:show="showDrawer" :width="720">
      <n-drawer-content :title="`Đơn hàng #${selected?.id ?? ''}`">
        <template v-if="selected">
          <div class="grid grid-cols-2 gap-3 mb-4 text-sm">
            <div><span class="text-neutral-500">Ngày tạo:</span> {{ fmtDate(selected.created_at) }}</div>
            <div><span class="text-neutral-500">Trạng thái:</span> <n-tag size="small">{{ selected.status }}</n-tag></div>
            <div><span class="text-neutral-500">Kênh:</span> {{ selected.channel_code ?? '—' }}</div>
            <div><span class="text-neutral-500">Khách hàng:</span> {{ selected.customer_name ?? '—' }}</div>
            <div><span class="text-neutral-500">Tổng (base):</span> {{ fmtMoney(selected.price_sum_base) }}</div>
          </div>

          <n-card size="small" title="Dòng đơn (order_lines)" :bordered="false" class="shadow-sm">
            <n-data-table
              :loading="loadingLines"
              :columns="lineCols"
              :data="lines"
              size="small"
              :bordered="false"
            />
          </n-card>
        </template>
      </n-drawer-content>
    </n-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, h } from 'vue'
import {
  NCard, NButton, NInput, NDataTable, NPagination, NTag,
  NDrawer, NDrawerContent, useMessage, type DataTableColumns
} from 'naive-ui'
import { supabase } from '@/lib/supabase'

type Row = {
  id: string
  created_at: string
  status: string
  side: string
  price_sum_base: number
  channel_code?: string | null
  customer_name?: string | null
}

type Line = {
  id: string
  qty: number
  unit_price: number
  currency: string
  deadline_to: string | null
  service_desc?: string | null
}

const message = useMessage()

/* -------------------- state -------------------- */
const loading = ref(false)
const rows = ref<Row[]>([])
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const q = ref('')

/* Drawer */
const showDrawer = ref(false)
const selected = ref<Row | null>(null)
const loadingLines = ref(false)
const lines = ref<Line[]>([])

/* -------------------- columns -------------------- */
const columns = computed<DataTableColumns<Row>>(() => [
  { title: 'Ngày tạo', key: 'created_at', width: 160, render: (r)=>fmtDate(r.created_at) },
  { title: 'Kênh', key: 'channel_code', width: 120, ellipsis: { tooltip: true } },
  { title: 'Khách hàng', key: 'customer_name', width: 160, ellipsis: { tooltip: true } },
  {
    title: 'Trạng thái',
    key: 'status',
    width: 100,
    render: (r) => h(NTag, { size: 'small' }, { default: () => r.status })
  },
  { title: 'Tổng (base)', key: 'price_sum_base', width: 120, render: (r)=>fmtMoney(r.price_sum_base) },
  {
    title: 'Thao tác',
    key: 'actions',
    width: 110,
    render: (r) =>
      h('div', { class: 'flex gap-2' }, [
        h(NButton, { size: 'tiny', onClick: () => openDrawer(r) }, { default: () => 'Xem' })
      ])
  }
])

const lineCols = computed<DataTableColumns<Line>>(() => [
  { title: 'SKU/Line ID', key: 'id', width: 240, ellipsis: { tooltip: true } },
  { title: 'SL', key: 'qty', width: 60 },
  { title: 'Đơn giá', key: 'unit_price', width: 110, render: (l)=>fmtMoney(l.unit_price) },
  { title: 'Tiền tệ', key: 'currency', width: 80 },
  { title: 'Deadline', key: 'deadline_to', width: 160, render: (l)=> l.deadline_to ? fmtDate(l.deadline_to) : '—' },
  { title: 'Mô tả', key: 'service_desc', ellipsis: { tooltip: true } }
])

/* -------------------- helpers -------------------- */
function fmtDate(s: string) {
  try { return new Date(s).toLocaleString() } catch { return s }
}
function fmtMoney(n: number | null | undefined) {
  const v = Number(n ?? 0)
  return v.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
// helper id cho field
const fid = (s: string) => `sales-${s}`;
const lid = (s: string) => `${fid(s)}-label`;

/* -------------------- data loading -------------------- */
async function reload() {
  loading.value = true
  try {
    const from = (page.value - 1) * pageSize.value
    const to = from + pageSize.value - 1

    let query = supabase
      .from('order_list_v1')               // view đã tạo
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .range(from, to)

    const kw = q.value.trim()
    if (kw) {
      query = query.or(`channel_code.ilike.%${kw}%,customer_name.ilike.%${kw}%`)
    }

    const { data, error, count } = await query
    if (error) throw error

    rows.value = (data ?? []) as Row[]
    total.value = count ?? rows.value.length
  } catch (e: any) {
    console.error(e)
    message.error(e?.message || 'Không tải được đơn hàng')
  } finally {
    loading.value = false
  }
}

let t: any
function debouncedReload() {
  clearTimeout(t)
  t = setTimeout(reload, 300)
}

/* -------------------- lines for a selected order -------------------- */
async function openDrawer(r: Row) {
  selected.value = r
  showDrawer.value = true
  await loadLines(r.id)
}

async function loadLines(orderId: string) {
  loadingLines.value = true
  try {
    const { data, error } = await supabase
      .from('order_lines')
      .select('id, qty, unit_price, currency, deadline_to, meta_json')
      .eq('order_id', orderId)
      .order('id', { ascending: true })

    if (error) throw error

    lines.value = (data ?? []).map((l: any) => ({
      id: l.id,
      qty: Number(l.qty),
      unit_price: Number(l.unit_price),
      currency: l.currency,
      deadline_to: l.deadline_to,
      service_desc: l.meta_json?.service_desc ?? null
    }))
  } catch (e: any) {
    console.error(e)
    message.error(e?.message || 'Không tải được dòng đơn hàng')
  } finally {
    loadingLines.value = false
  }
}

/* init */
reload()
</script>
