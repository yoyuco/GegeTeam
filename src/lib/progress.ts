// path: src/lib/progress.ts
import { supabase } from '@/lib/supabase';

export type WorkOutput = {
  item_id?: string | null;
  kind_code: string;
  params?: any;
  delta: number;
};

export async function createWorkSession(lineId: string, activity: string, note?: string, startProofUrl?: string) {
  const { data, error } = await supabase.rpc('create_work_session_v1', {
    p_line_id: lineId,
    p_activity: activity,
    p_note: note ?? null,
    p_start_proof_url: startProofUrl ?? null
  });
  if (error) throw error;
  return data as string; // session_id
}

export async function finishWorkSession(sessionId: string, outputs: WorkOutput[], endProofUrl?: string) {
  const { error } = await supabase.rpc('finish_work_session_v1', {
    p_session_id: sessionId,
    p_end_proof_url: endProofUrl ?? null,
    p_outputs: outputs
  });
  if (error) throw error;
}
