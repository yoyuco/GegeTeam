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