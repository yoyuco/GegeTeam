// src/lib/orders.ts
import { supabase } from '@/lib/supabase'
import type { CoreForm, SubServiceRow } from '@/types/service'
import { type LabelMaps, buildServiceDesc, mapRowsToRpcItems } from '@/lib/service-desc'

export type CreateOrderResult = { order_id: string; line_id: string }

// ===== Helpers =====
function upper3(v?: string | null): string {
  const s = (v ?? '').trim().toUpperCase()
  return s ? s.slice(0, 3) : 'USD'
}
function toNumberOr(v: unknown, fallback: number): number {
  const n = Number(v)
  return Number.isFinite(n) ? n : fallback
}
function toIsoOrNull(v?: string | number | Date | null): string | null {
  if (v === null || v === undefined || v === '') return null
  try {
    const d = typeof v === 'number' ? new Date(v) : new Date(v as any)
    return isNaN(d.getTime()) ? null : d.toISOString()
  } catch {
    return null
  }
}

/**
 * Gọi RPC tạo order + 1 dòng order_line (RPC cũng tự insert sub-items).
 */
export async function createServiceOrder(
  core: CoreForm,
  rows: SubServiceRow[],
  labelMaps?: LabelMaps
): Promise<CreateOrderResult> {
  // Lấy uid
  const { data: authData, error: authErr } = await supabase.auth.getUser()
  if (authErr) throw authErr
  const uid = authData?.user?.id
  if (!uid) throw new Error('Không xác định được người dùng. Vui lòng đăng nhập lại.')

  // Chuẩn hoá dữ liệu
  const currency = upper3(core.currency)
  const price = toNumberOr(core.price, 0)
  const deadlineIso = toIsoOrNull(core.deadline)
  const pkg = String(core.package_type || 'BASIC').toUpperCase() as CoreForm['package_type']
  const service_desc = buildServiceDesc(rows, labelMaps)
  const p_sub_rows = mapRowsToRpcItems(rows, labelMaps ?? ({} as any)) // <-- CHUẨN cho RPC

  // Payload RPC
  const payload = {
    p_channel_code: (core.channel_code || '').trim() || null,
    p_service_type: core.service_type,
    p_customer_name: (core.customer_name || '').trim() || null,

    p_btag: core.service_type === 'selfplay' ? core.btag || null : null,
    p_login_id: core.service_type === 'pilot' ? core.login_id || null : null,
    p_login_pwd: core.service_type === 'pilot' ? core.login_pwd || null : null,

    p_deadline: deadlineIso,
    p_price: price,
    p_currency: currency,

    p_package_type: pkg,
    p_package_note: core.package_note || null,

    p_qty: 1,
    p_fx_to_base: 1,

    p_created_by: uid,
    p_service_desc: service_desc || null,
    p_sub_rows,
  }

  // DEBUG cuối trước khi gọi RPC
  console.debug('[TEST] p_sub_rows (FINAL) =', p_sub_rows)
  const { data, error } = await supabase.rpc('create_service_order_v1', payload)
  if (error) throw error

  // Chuẩn hoá output
  const row = Array.isArray(data) ? data[0] : data
  if (!row?.order_id || !row?.line_id) {
    throw new Error('RPC không trả về order_id/line_id hợp lệ.')
  }
  return { order_id: row.order_id as string, line_id: row.line_id as string }
}

/** (Tuỳ chọn) Wrapper, vẫn phải return kết quả để TS không báo lỗi 
export async function createOrderWithItems(
  core: CoreForm,
  rows: SubServiceRow[],
  labelMaps?: LabelMaps
): Promise<CreateOrderResult> {
  // RPC đã insert sub-items, không gọi upsert lần 2 nữa
  const res = await createServiceOrder(core, rows, labelMaps)
  return res
}
*/
