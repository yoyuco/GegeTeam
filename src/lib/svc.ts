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
