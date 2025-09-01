// path: src/lib/svc.ts
import { supabase } from '@/lib/supabase'

export type KindCode =
  | 'LEVELING' | 'BOSS' | 'PIT' | 'NIGHTMARE' | 'MYTHIC'
  | 'MATERIAL' | 'MASTERWORKING' | 'ALTARS' | 'RENOWN' | 'GENERIC'

export type SvcItemInput = {
  kind_code: KindCode
  params: Record<string, any>   // tuỳ theo kind (dưới có bảng mẫu)
  plan_qty: number              // số lượng kế hoạch
  status?: 'pending' | 'in_progress' | 'done' | string
}

// Gọi RPC để upsert danh sách items cho 1 line
export async function upsertLineItems(lineId: string, items: SvcItemInput[], replace = true) {
  const payload = items.map(it => ({
    kind_code: it.kind_code,
    params: it.params || {},
    plan_qty: Number.isFinite(it.plan_qty) ? Number(it.plan_qty) : 0,
    status: it.status ?? 'pending'
  }))
  const { error } = await supabase.rpc('svc_upsert_line_items_v1', {
    p_line_id: lineId,
    p_items: payload,
    p_replace: replace
  })
  if (error) throw error
}
