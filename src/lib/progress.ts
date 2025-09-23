// path: src/lib/progress.ts
import { supabase } from '@/lib/supabase'

/* ================== Types ================== */

export type SessionOutputRow = {
  item_id: string
  start_value: number | null
  current_value: number | null
  start_proof_url?: string | null
  end_proof_url?: string | null
}

export type ActivityRow = {
  item_id: string | null
  kind_code: 'ACTIVITY'
  delta: number
  params?: { label?: string | null }
  // Thêm các trường này để khớp với SessionOutputRow
  start_value: number
  current_value: number
  start_proof_url: string | null
  end_proof_url: string | null
}

export function newIdem(): string {
  return globalThis.crypto?.randomUUID?.() ?? '00000000-0000-0000-0000-000000000000'
}

/* ============== RPC Wrappers ============== */

export async function isPrivileged(): Promise<boolean> {
  const { data, error } = await supabase.rpc('is_privileged_v1')
  if (error) {
    console.warn('[isPrivileged] rpc error', error)
    return false
  }
  return !!data
}


export async function fetchLastProofs(itemIds: string[]) {
  if (!itemIds?.length) return []
  const { data, error } = await supabase.rpc('get_last_item_proof_v1', {
    p_item_ids: itemIds
  })
  if (error) throw error
  return (Array.isArray(data) ? data : []) as Array<{
    item_id: string
    last_start_proof_url: string | null
    last_end_proof_url: string | null
    last_end: number | null
    last_delta: number | null
    last_exp_percent: number | null
  }>
}

export async function startWorkSession(
  lineId: string,
  startState: any[],
  note?: string | null
): Promise<string> {
  if (!lineId) {
    throw new Error('Order Line ID is required.');
  }

  const { data, error } = await supabase.rpc('start_work_session_v1', {
    p_order_line_id: lineId,
    p_start_state: startState,
    p_initial_note: note
  });

  if (error) {
    console.error('Error starting work session:', error);
    throw new Error(`Không thể bắt đầu phiên làm việc: ${error.message}`);
  }
  return data;
}

export async function finishWorkSessionIdem(
  sessionId: string,
  outputs: SessionOutputRow[],
  activityRows: ActivityRow[],
  overrunReason: string | null,
  idemKey: string,
  overrunType: string | null,
  overrunProofUrls: string[] | null
) {
  return supabase.rpc('finish_work_session_idem_v1', {
    p_session_id: sessionId,
    p_outputs: outputs,
    p_activity_rows: activityRows,
    p_overrun_reason: overrunReason,
    p_idem_key: idemKey,
    p_overrun_type: overrunType,
    p_overrun_proof_urls: overrunProofUrls
  });
}

// 🚫 ĐÃ XOÁ HOÀN TOÀN:
// - export type WorkOutput
// - export async function finishWorkSession(...)
// - export const createWorkSession
