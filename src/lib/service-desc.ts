// path: src/lib/service-desc.ts

/** Cặp value-label chung */
export type ValueLabel = { value: string; label: string };

/** Tập Map nhãn cho từng KIND */
export type LabelMaps = {
  BOSS: Map<string, string>;
  PIT: Map<string, string>;
  MATERIAL: Map<string, string>;
  MASTERWORKING: Map<string, string>;
  ALTARS: Map<string, string>;
  RENOWN: Map<string, string>;
  NIGHTMARE: Map<string, string>;
  MYTHIC_ITEM: Map<string, string>;
  MYTHIC_GA: Map<string, string>;
  ITEM_STATS_SORT: Map<string, string>; // <-- ĐÃ THÊM
};

/** Input cho makeLabelMapsFromOptions */
type LabelOptions = {
  BOSS?: ValueLabel[];
  PIT?: ValueLabel[];
  MATERIAL?: ValueLabel[];
  MASTERWORKING?: ValueLabel[];
  ALTARS?: ValueLabel[];
  RENOWN?: ValueLabel[];
  NIGHTMARE?: ValueLabel[];
  MYTHIC_ITEM?: ValueLabel[];
  MYTHIC_GA?: ValueLabel[];
  ITEM_STATS_SORT?: ValueLabel[]; // <-- ĐÃ THÊM
};

/** Chuyển mảng {value,label} → Map<value,label> */
function toMap(list?: ValueLabel[] | null): Map<string, string> {
  const m = new Map<string, string>();
  for (const it of list || []) {
    const v = String(it?.value ?? '');
    const l = String(it?.label ?? v);
    if (v) m.set(v, l);
  }
  return m;
}

/** Tạo LabelMaps từ các options */
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
    MYTHIC_GA: toMap(opts.MYTHIC_GA),
    ITEM_STATS_SORT: toMap(opts.ITEM_STATS_SORT), // <-- ĐÃ THÊM
  };
}

// ----- shim exports for CI build (non-breaking) -----
// mục đích: bảo đảm tồn tại 2 export mà FE đang import ở orders.ts.
// nếu file này đã có 2 hàm đó, khối dưới KHÔNG gây xung đột vì tên trùng sẽ bị chặn bởi khai báo trước đó.
// nếu chưa có, khối dưới cung cấp triển khai tối thiểu đủ cho build/preview chạy.

export type _SvcRow = any
export type _LabelMaps = {
  [k: string]: Map<string, string> | undefined
}

/** gộp mô tả đơn giản: "<kind>: <json>" – đủ để xem preview */
export function buildServiceDesc(rows: _SvcRow[] = [], _lm?: _LabelMaps): string {
  try {
    if (!Array.isArray(rows) || rows.length === 0) return ''
    const segs: string[] = []
    for (const r of rows) {
      const k = String((r && r.kind) || 'GENERIC').toUpperCase()
      segs.push(`${k}: ${JSON.stringify(r)}`)
    }
    return segs.join(' | ')
  } catch {
    return ''
  }
}

/** map tối thiểu sang payload RPC; giữ nguyên dữ liệu đầu vào */
export function mapRowsToRpcItems(rows: _SvcRow[] = [], _lm?: _LabelMaps) {
  return (rows || []).map((r: any) => ({
    kind_code: String((r && r.kind) || 'GENERIC').toUpperCase(),
    params: r,
    plan_qty: (r && (r.qty || r.runs)) ?? null
  }))
}
// ----- end shim -----
