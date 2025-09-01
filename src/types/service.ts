// path: src/types/service.ts
// Các kiểu dùng chung cho tính năng Service (Boosting)

// ===== Kiểu cơ bản =====
export type ServiceType = 'selfplay' | 'pilot'
export type PackageType = 'BASIC' | 'CUSTOM' | 'BUILD'

/**
 * Dữ liệu form lõi khi tạo đơn (FE -> RPC).
 * - deadline là ISO string (timestamptz ở DB).
 */
export interface CoreForm {
  channel_code: string
  service_type: ServiceType
  customer_name: string

  // Chỉ 1 trong 2 cặp dưới được dùng tuỳ service_type
  btag?: string               // selfplay
  login_id?: string           // pilot
  login_pwd?: string          // pilot

  deadline?: string           // ISO string (VD: new Date().toISOString())
  price: number
  currency: string            // 'USD' | 'VND' | ...
  package_type: PackageType
  package_note?: string
}

// ===== Các dòng sub-service (discriminated union) =====
export type GenericRow = {
  kind: 'GENERIC'
  note: string
}

export type LevelingRow = {
  kind: 'LEVELING'
  mode: 'level' | 'paragon'
  from: number
  to: number
}

export type BossRow = {
  kind: 'BOSS'
  boss_code: string
  qty: number
}

export type PitRow = {
  kind: 'PIT'
  tier: number        // số tier
  runs: number        // số lần chạy
}

export type NightmareRow = {
  kind: 'NIGHTMARE'
  tier: number
  runs: number
}

export type MaterialRow = {
  kind: 'MATERIAL'
  code: string
  qty: number
}

export type MythicRow = {
  kind: 'MYTHIC'
  item_code: string
  ga_code?: string
  ga_note?: string
  qty: number
}

export type MasterworkingRow = {
  kind: 'MASTERWORKING'
  variant: string
  qty: number
}

export type AltarsRow = {
  kind: 'ALTARS'
  region: string
  qty: number
}

export type RenownRow = {
  kind: 'RENOWN'
  region: string
  qty: number
}

// Union dùng trong toàn bộ FE
export type SubServiceRow =
  | GenericRow
  | LevelingRow
  | BossRow
  | PitRow
  | NightmareRow
  | MaterialRow
  | MythicRow
  | MasterworkingRow
  | AltarsRow
  | RenownRow

// (Tuỳ chọn) Kiểu item khi upsert qua RPC svc_upsert_line_items_v1
export type RpcItem = {
  kind_code: string         // VD: 'BOSS', 'PIT', ...
  params: any               // payload tuỳ KIND
  plan_qty?: number | null  // nếu có (VD: số lượng dự kiến)
}
