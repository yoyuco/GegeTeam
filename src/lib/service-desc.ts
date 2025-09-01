// path: src/lib/service-desc.ts
// Cung cấp:
//  - makeLabelMapsFromOptions: nhận { value,label }[] → trả Map cho từng KIND
//  - buildServiceDesc: tạo chuỗi mô tả gộp "label-first" từ SubServiceRow[]

import type { SubServiceRow } from '@/types/service'

/** Cặp value-label chung */
export type ValueLabel = { value: string; label: string }

/** Tập Map nhãn cho từng KIND (có thể thiếu, sẽ mặc định Map rỗng) */
export type LabelMaps = {
  BOSS?: Map<string, string>
  PIT?: Map<string, string>
  MATERIAL?: Map<string, string>
  MASTERWORKING?: Map<string, string>
  ALTARS?: Map<string, string>
  RENOWN?: Map<string, string>
  NIGHTMARE?: Map<string, string>
  MYTHIC_ITEM?: Map<string, string>
  MYTHIC_GA?: Map<string, string>
}

/** Input cho makeLabelMapsFromOptions */
type LabelOptions = {
  BOSS?: ValueLabel[]
  PIT?: ValueLabel[]
  MATERIAL?: ValueLabel[]
  MASTERWORKING?: ValueLabel[]
  ALTARS?: ValueLabel[]
  RENOWN?: ValueLabel[]
  NIGHTMARE?: ValueLabel[]
  MYTHIC_ITEM?: ValueLabel[]
  MYTHIC_GA?: ValueLabel[]
}

/** Chuyển mảng {value,label} → Map<value,label> */
function toMap(list?: ValueLabel[] | null): Map<string, string> {
  const m = new Map<string, string>()
  for (const it of list || []) {
    const v = String(it?.value ?? '')
    const l = String(it?.label ?? v)
    if (v) m.set(v, l)
  }
  return m
}

/** Tạo LabelMaps từ các options (label-first); thiếu KIND nào thì Map rỗng */
export function makeLabelMapsFromOptions(opts: LabelOptions): LabelMaps {
  return {
    BOSS: toMap(opts.BOSS),
    PIT: toMap(opts.PIT),
    MATERIAL: toMap(opts.MATERIAL),
    MASTERWORKING: toMap(opts.MASTERWORKING),
    ALTARS: toMap(opts.ALTARS),
    RENOWN: toMap(opts.RENOWN),
    NIGHTMARE: toMap(opts.NIGHTMARE),
    MYTHIC_ITEM: toMap(opts.MYTHIC_ITEM),
    MYTHIC_GA: toMap(opts.MYTHIC_GA)
  }
}

/* ===================== buildServiceDesc ===================== */

const SEP_SEG = ' | '  // ngăn cách nhóm
const SEP_ITEM = '; '  // ngăn cách item trong 1 nhóm

function pick(m?: Map<string, string>, key?: unknown): string | null {
  if (!key && key !== 0) return null
  const k = String(key)
  if (!m) return k
  return m.get(k) ?? k
}

function j(items: string[]): string {
  return items.filter(s => !!s && s.trim().length > 0).join(SEP_ITEM)
}

/**
 * Tạo mô tả gộp (label-first) từ danh sách sub-services.
 * Ví dụ: "Boss: Duriel × 3; Uber Lilith × 1 | Pit: Tier 70 × 2 | Level: 50→70"
 */
export function buildServiceDesc(rows: SubServiceRow[] = [], lm?: LabelMaps): string {
  if (!Array.isArray(rows) || rows.length === 0) return ''

  const segs: string[] = []

  // Nhóm theo kind
  const g = {
    GENERIC: [] as string[],
    LEVELING: [] as string[],
    BOSS: [] as string[],
    PIT: [] as string[],
    NIGHTMARE: [] as string[],
    MATERIAL: [] as string[],
    MYTHIC: [] as string[],
    MASTERWORKING: [] as string[],
    ALTARS: [] as string[],
    RENOWN: [] as string[]
  }

  for (const raw of rows) {
    const kind = String((raw as any).kind || '').toUpperCase()
    const r: any = raw

    switch (kind) {
      case 'GENERIC': {
        const note = (r.note || r.desc || '').toString().trim()
        if (note) g.GENERIC.push(note)
        break
      }
      case 'LEVELING': {
        const mode = (r.mode === 'paragon') ? 'Paragon' : 'Level'
        const from = Number(r.from ?? r.start ?? 0)
        const to   = Number(r.to   ?? r.end   ?? 0)
        if (to || from) g.LEVELING.push(`${mode} ${from}→${to}`)
        break
      }
      case 'BOSS': {
        const code = r.boss_code || r.code
        const qty  = Number(r.qty || 1)
        if (code) g.BOSS.push(`${pick(lm?.BOSS, code)} × ${qty}`)
        break
      }
      case 'PIT': {
        const tier = Number(r.tier || 0)
        const runs = Number(r.runs || r.qty || 1)
        const label = lm?.PIT?.get(String(tier)) || (tier ? `Tier ${tier}` : 'Tier ?')
        g.PIT.push(`${label} × ${runs}`)
        break
      }
      case 'NIGHTMARE': {
        const tier = Number(r.tier || 0)
        const runs = Number(r.runs || r.qty || 1)
        const label = lm?.NIGHTMARE?.get(String(tier)) || (tier ? `Tier ${tier}` : 'Tier ?')
        g.NIGHTMARE.push(`${label} × ${runs}`)
        break
      }
      case 'MATERIAL': {
        const code = r.code
        const qty  = Number(r.qty || 0)
        if (code) g.MATERIAL.push(`${pick(lm?.MATERIAL, code)} × ${qty}`)
        break
      }
      case 'MYTHIC': {
        const item = r.item_code || r.item
        const itemLabel = pick(lm?.MYTHIC_ITEM, item)
        const ga  = r.ga_code || r.ga
        const gaLabel = ga ? pick(lm?.MYTHIC_GA, ga) : null
        const note = (r.ga_note || '').toString().trim()
        const qty  = Number(r.qty || 1)
        const sup  = gaLabel ? (note ? ` (${gaLabel}: ${note})` : ` (${gaLabel})`) : (note ? ` (${note})` : '')
        if (item) g.MYTHIC.push(`${itemLabel}${sup} × ${qty}`)
        break
      }
      case 'MASTERWORKING': {
        const variant = r.variant || r.code
        const qty     = Number(r.qty || 1)
        if (variant) g.MASTERWORKING.push(`${pick(lm?.MASTERWORKING, variant)} × ${qty}`)
        break
      }
      case 'ALTARS': {
        const region = r.region
        const qty    = Number(r.qty || 1)
        if (region) g.ALTARS.push(`${pick(lm?.ALTARS, region)} × ${qty}`)
        break
      }
      case 'RENOWN': {
        const region = r.region
        const qty    = Number(r.qty || 1)
        if (region) g.RENOWN.push(`${pick(lm?.RENOWN, region)} × ${qty}`)
        break
      }
      default: {
        // fallback → stringify ngắn gọn
        const s = JSON.stringify(r)
        if (s) g.GENERIC.push(s)
      }
    }
  }

  if (g.GENERIC.length)        segs.push(`Generic: ${j(g.GENERIC)}`)
  if (g.LEVELING.length)       segs.push(`Level: ${j(g.LEVELING)}`)
  if (g.BOSS.length)           segs.push(`Boss: ${j(g.BOSS)}`)
  if (g.PIT.length)            segs.push(`Pit: ${j(g.PIT)}`)
  if (g.NIGHTMARE.length)      segs.push(`Nightmare: ${j(g.NIGHTMARE)}`)
  if (g.MATERIAL.length)       segs.push(`Materials: ${j(g.MATERIAL)}`)
  if (g.MYTHIC.length)         segs.push(`Mythic: ${j(g.MYTHIC)}`)
  if (g.MASTERWORKING.length)  segs.push(`Masterworking: ${j(g.MASTERWORKING)}`)
  if (g.ALTARS.length)         segs.push(`Altars: ${j(g.ALTARS)}`)
  if (g.RENOWN.length)         segs.push(`Renown: ${j(g.RENOWN)}`)

  return segs.join(SEP_SEG)
}

// ===== Map SubServiceRow[] -> RPC items (p_sub_rows) =====
export type RpcItem = {
  kind_code: string
  params: any
  plan_qty?: number | null
}

export function mapRowsToRpcItems(rows: SubServiceRow[] = [], lm: LabelMaps = {} as any): RpcItem[] {
  const pickLabel = (k: keyof LabelMaps, v: any) => {
    const m = lm?.[k] as Map<string, string> | undefined
    return m?.get(String(v)) ?? String(v ?? '')
  }

  const out: RpcItem[] = []
  for (const r of rows) {
    switch (r.kind) {
      case 'GENERIC': {
        const note = (r as any).note || ''
        out.push({ kind_code: 'GENERIC', params: { desc: note }, plan_qty: null })
        break
      }
      case 'LEVELING': {
        const rr = r as any
        const from = Number(rr.from), to = Number(rr.to)
        out.push({
          kind_code: 'LEVELING',
          params: { mode: rr.mode, start: from, end: to },
          plan_qty: Math.max(0, to - from)
        })
        break
      }
      case 'BOSS': {
        const rr = r as any
        out.push({
          kind_code: 'BOSS',
          params: { boss_code: rr.boss_code, boss_label: pickLabel('BOSS', rr.boss_code) },
          plan_qty: Number(rr.qty || 1)
        })
        break
      }
      case 'PIT': {
        const rr = r as any
        const tier = Number(rr.tier || 0)
        out.push({
          kind_code: 'PIT',
          params: { tier, tier_label: pickLabel('PIT', tier) },
          plan_qty: Number(rr.runs || 1)
        })
        break
      }
      case 'NIGHTMARE': {
        const rr = r as any
        const tier = Number(rr.tier || 0)
        out.push({
          kind_code: 'NIGHTMARE',
          params: { tier, tier_label: pickLabel('NIGHTMARE', tier) },
          plan_qty: Number(rr.runs || rr.qty || 1)
        })
        break
      }
      case 'MATERIAL': {
        const rr = r as any
        out.push({
          kind_code: 'MATERIAL',
          params: { code: rr.code, material_label: pickLabel('MATERIAL', rr.code) },
          plan_qty: Number(rr.qty || 0)
        })
        break
      }
      case 'MYTHIC': {
        const rr = r as any
        out.push({
          kind_code: 'MYTHIC',
          params: {
            item_code: rr.item_code || rr.item,
            item_label: pickLabel('MYTHIC_ITEM', rr.item_code || rr.item),
            ga_code: rr.ga_code || rr.ga || '',
            ga_label: rr.ga ? pickLabel('MYTHIC_GA', rr.ga) : '',
            ga_note: rr.ga_note || ''
          },
          plan_qty: Number(rr.qty || 1)
        })
        break
      }
      case 'MASTERWORKING': {
        const rr = r as any
        out.push({
          kind_code: 'MASTERWORKING',
          params: { variant: rr.variant || rr.code, variant_label: pickLabel('MASTERWORKING', rr.variant || rr.code) },
          plan_qty: Number(rr.qty || 1)
        })
        break
      }
      case 'ALTARS': {
        const rr = r as any
        out.push({
          kind_code: 'ALTARS',
          params: { region: rr.region, region_label: pickLabel('ALTARS', rr.region) },
          plan_qty: Number(rr.qty || 1)
        })
        break
      }
      case 'RENOWN': {
        const rr = r as any
        out.push({
          kind_code: 'RENOWN',
          params: { region: rr.region, region_label: pickLabel('RENOWN', rr.region) },
          plan_qty: Number(rr.qty || 1)
        })
        break
      }
      default:
        out.push({ kind_code: String((r as any).kind || 'GENERIC').toUpperCase(), params: r, plan_qty: null })
    }
  }
  return out
}
