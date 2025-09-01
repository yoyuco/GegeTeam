<!-- path: src/pages/Employees.vue -->
<template>
  <div>
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold">Nhân viên</h1>

      <div class="flex items-center gap-2">
        <n-input v-model:value="q" placeholder="Tìm theo tên/email/role..." clearable style="width: 280px" />
        <n-button tertiary @click="reload">Làm mới</n-button>
      </div>
    </div>

    <n-card>
      <n-data-table
        :columns="columns"
        :data="filteredRows"
        :bordered="false"
        :single-line="false"
        :row-key="(row) => row.id"
        :pagination="pagination"
      />
    </n-card>

    <!-- Modal chỉnh vai trò -->
    <n-modal v-model:show="showRoleModal">
      <n-card style="width: 520px" title="Chỉnh vai trò" :bordered="false" size="small">
        <div class="space-y-2">
          <div class="text-sm">
            <span class="opacity-70 mr-1">Nhân viên:</span>
            <span class="font-medium">{{ editingRow?.name }}</span>
          </div>

          <n-select
            v-model:value="selectedRoleIds"
            :options="roleOptions"
            multiple
            placeholder="Chọn vai trò"
          />
        </div>
        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="showRoleModal = false">Hủy</n-button>
            <n-button type="primary" :loading="saving" @click="saveRoles">Lưu</n-button>
          </div>
        </template>
      </n-card>
    </n-modal>

    <!-- Modal chỉnh trạng thái -->
    <n-modal v-model:show="showStatusModal">
      <n-card style="width: 460px" title="Sửa trạng thái" :bordered="false" size="small">
        <div class="space-y-2">
          <div class="text-sm">
            <span class="opacity-70 mr-1">Nhân viên:</span>
            <span class="font-medium">{{ editingRow?.name }}</span>
          </div>

          <n-select
            v-model:value="selectedStatus"
            :options="statusOptions"
            placeholder="Chọn trạng thái"
          />
        </div>
        <template #footer>
          <div class="flex justify-end gap-2">
            <n-button @click="showStatusModal = false">Hủy</n-button>
            <n-button type="primary" :loading="savingStatus" @click="saveStatus">Lưu</n-button>
          </div>
        </template>
      </n-card>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { computed, h, onMounted, ref } from 'vue'
import {
  NCard,
  NDataTable,
  type DataTableColumns,
  NTag,
  NButton,
  NModal,
  NSelect,
  NInput,
  createDiscreteApi
} from 'naive-ui'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/auth'

type Row = {
  id: string
  name: string
  email: string
  status: string | null
  roles: { id: number; label: string }[]
}

const { message } = createDiscreteApi(['message'])
const auth = useAuth()

const rows = ref<Row[]>([])
const q = ref('')
const pagination = { pageSize: 10 }

const roleOptions = ref<{ label: string; value: number }[]>([])
const statusOptions = ref([
  { label: 'Active', value: 'active' },
  { label: 'Inactive', value: 'inactive' },
  { label: 'Blocked', value: 'blocked' }
])

const showRoleModal = ref(false)
const showStatusModal = ref(false)
const editingRow = ref<Row | null>(null)

const selectedRoleIds = ref<number[]>([])
const selectedStatus = ref<string | null>(null)

const saving = ref(false)
const savingStatus = ref(false)

/** QUYỀN: chỉ admin/manager/mod mới thấy chữ "sửa" */
const canEdit = ref(false)
async function determineCanEdit() {
  const uid = auth.user?.id
  if (!uid) return
  // lấy role id của chính mình
  const { data: urs, error: urErr } = await supabase
    .from('user_roles')
    .select('role_id')
    .eq('user_id', uid)
  if (urErr) return
  const roleIds = (urs ?? []).map((r: any) => Number(r.role_id)).filter(Number.isFinite)
  if (!roleIds.length) return
  const { data: rs } = await supabase
    .from('roles')
    .select('id, code')
    .in('id', roleIds)
  const codes = (rs ?? []).map((r: any) => String(r.code || '').toLowerCase())
  canEdit.value = ['admin', 'manager', 'mod'].some(c => codes.includes(c))
}

/** Bảng */
const columns: DataTableColumns<Row> = [
  { title: 'Tên', key: 'name', sorter: 'default' },
  { title: 'Email', key: 'email' },
  {
    title: 'Vai trò',
    key: 'roles',
    render: (row) => {
      const nodes: any[] = []
      if (!row.roles?.length) {
        nodes.push(h('span', {}, '—'))
      } else {
        for (const r of row.roles) {
          nodes.push(h(NTag, { size: 'small', round: true, style: 'margin-right:6px' }, { default: () => r.label }))
        }
      }
      if (canEdit.value) {
        nodes.push(
          h(
            'button',
            {
              class: 'ml-1 text-xs text-primary-600 hover:underline cursor-pointer',
              onClick: () => openRoleModal(row)
            },
            'Sửa'
          )
        )
      }
      return h('div', { class: 'flex items-center flex-wrap' }, nodes)
    }
  },
  {
    title: 'Trạng thái',
    key: 'status',
    render: (row) => {
      const nodes: any[] = [h('span', {}, row.status || '—')]
      if (canEdit.value) {
        nodes.push(
          h(
            'button',
            {
              class: 'ml-2 text-xs text-primary-600 hover:underline cursor-pointer',
              onClick: () => openStatusModal(row)
            },
            'Sửa'
          )
        )
      }
      return h('div', { class: 'flex items-center' }, nodes)
    }
  }
  // ĐÃ LOẠI BỎ cột "Thao tác"
]

const filteredRows = computed(() => {
  const s = q.value.trim().toLowerCase()
  if (!s) return rows.value
  return rows.value.filter(r =>
    r.name.toLowerCase().includes(s) ||
    r.email.toLowerCase().includes(s) ||
    r.roles.some(role => role.label.toLowerCase().includes(s)) ||
    (r.status || '').toLowerCase().includes(s)
  )
})

function openRoleModal(row: Row) {
  editingRow.value = row
  selectedRoleIds.value = row.roles.map(r => r.id)
  showRoleModal.value = true
}

function openStatusModal(row: Row) {
  editingRow.value = row
  selectedStatus.value = row.status ?? 'active'
  showStatusModal.value = true
}

async function saveRoles() {
  if (!editingRow.value) return
  saving.value = true
  try {
    const uid = editingRow.value.id
    const current = new Set(editingRow.value.roles.map(r => r.id))
    const next = new Set(selectedRoleIds.value)

    const toAdd = [...next].filter(x => !current.has(x))
    const toRemove = [...current].filter(x => !next.has(x))

    if (toAdd.length) {
      const payload = toAdd.map(role_id => ({ user_id: uid, role_id }))
      const { error } = await supabase.from('user_roles').insert(payload)
      if (error) throw error
    }
    if (toRemove.length) {
      const { error } = await supabase.from('user_roles')
        .delete()
        .eq('user_id', uid)
        .in('role_id', toRemove)
      if (error) throw error
    }

    await reload()
    showRoleModal.value = false
    message.success('Cập nhật vai trò thành công')
  } catch (e: any) {
    message.error(e?.message ?? 'Lỗi lưu vai trò')
    console.error(e)
  } finally {
    saving.value = false
  }
}

async function saveStatus() {
  if (!editingRow.value) return
  if (!selectedStatus.value) { message.warning('Chọn trạng thái'); return }
  savingStatus.value = true
  try {
    const { error } = await supabase
      .from('profiles')
      .update({ status: selectedStatus.value })
      .eq('id', editingRow.value.id)
    if (error) throw error

    await reload()
    showStatusModal.value = false
    message.success('Cập nhật trạng thái thành công')
  } catch (e: any) {
    message.error(e?.message ?? 'Lỗi lưu trạng thái')
    console.error(e)
  } finally {
    savingStatus.value = false
  }
}

/** Nạp dữ liệu: roles, profiles, user_roles và gộp */
async function reload() {
  // 1) Roles
  const { data: roleRows, error: rErr } = await supabase
    .from('roles')
    .select('id, name, code')
    .order('id', { ascending: true })
  if (rErr) { message.error('Không đọc được roles'); console.warn('[roles]', rErr); return }

  const roleLabel = (r: any) => r?.name || r?.code || ''
  const roleMap = new Map<number, string>()
  for (const r of roleRows ?? []) roleMap.set(Number((r as any).id), roleLabel(r))
  roleOptions.value = (roleRows ?? []).map((r: any) => ({ label: roleLabel(r), value: Number(r.id) }))

  // 2) Profiles
  const { data: profiles, error: pErr } = await supabase
    .from('profiles')
    .select('id, display_name, status')
    .order('display_name', { ascending: true })
  if (pErr) { message.error('Không đọc được profiles'); console.warn('[profiles]', pErr); return }

  // 3) user_emails_by_ids RPC (nếu bạn đã tạo)
  const ids: string[] = (profiles ?? []).map((p: any) => String(p.id))
  let emailMap = new Map<string, string>()
  if (ids.length) {
    const { data: emailRows } = await supabase.rpc('user_emails_by_ids', { uids: ids })
    emailMap = new Map<string, string>(emailRows?.map((r: any) => [String(r.id), String(r.email)]) ?? [])
  }

  // 4) user_roles
  const { data: urs, error: urErr } = await supabase.from('user_roles').select('user_id, role_id')
  if (urErr) { message.error('Không đọc được user_roles'); console.warn('[user_roles]', urErr); return }

  // 5) gom roles theo user
  const mapRoles = new Map<string, { id: number; label: string }[]>()
  for (const r of urs ?? []) {
    const uid = String((r as any).user_id)
    const rid = Number((r as any).role_id)
    const label = roleMap.get(rid)
    if (!uid || !rid || !label) continue
    if (!mapRoles.has(uid)) mapRoles.set(uid, [])
    const arr = mapRoles.get(uid)!
    if (!arr.find(x => x.id === rid)) arr.push({ id: rid, label })
  }

  // 6) map rows
  rows.value = (profiles ?? []).map((p: any) => {
    const id = String(p.id)
    const email = emailMap.get(id) ?? ''
    const name = (p.display_name || email || id)?.toString()
    return {
      id,
      name,
      email,
      status: p.status ?? null,
      roles: mapRoles.get(id) ?? []
    } as Row
  })
}

onMounted(async () => {
  await determineCanEdit()
  await reload()
})
</script>

<style scoped>
/* chữ "sửa" nhỏ gọn nằm cùng dòng */
</style>
