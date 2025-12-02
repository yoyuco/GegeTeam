# Hướng dẫn Import Currency Attributes - Composite League Approach

## Tổng quan

Sử dụng **Approach 2: Composite League Codes** để quản lý currency với cấu trúc 3-level hierarchy:

```
GAME -> LEAGUE (composite codes) -> CURRENCY (shared)
```

## Files cần import

### 1. `currency_attributes_composite.csv`

**Cấu trúc dữ liệu:**

- **Games:** POE1, POE2, DIABLO_4
- **Leagues (composite codes):**
  - POE1: STANDARD_SOFTCORE, STANDARD_HARDCORE, SETTLERS_SOFTCORE, SETTLERS_HARDCORE
  - POE2: STANDARD_SOFTCORE_POE2, STANDARD_HARDCORE_POE2
  - D4: SEASON_5_STANDARD_D4, ETERNAL_STANDARD_D4
- **Currencies (shared across leagues):**
  - POE1: CHAOS_ORB, DIVINE_ORB, EXALTED_ORB, etc.
  - POE2: DIVINE_ORB_POE2, EXALTED_ORB_POE2
  - D4: GOLD, OBOL, RED_DUST, etc.

### 2. `attribute_relationships_composite_template.csv`

**Template relationships:**

- Game -> League relationships
- Game -> Currency relationships
- **Không cần** League -> Currency relationships vì currency được shared

## Quy trình import vào Staging

### Bước 1: Import Attributes

1. Vào Supabase Dashboard → Table Editor → Bảng `attributes`
2. Click "Insert" → "Import from CSV"
3. Chọn file `currency_attributes_composite.csv`
4. Map columns: `code`, `name`, `type`
5. Click "Import"

### Bước 2: Lấy ID mapping

Chạy query sau trong SQL Editor:

```sql
SELECT code, id, type, name
FROM public.attributes
WHERE type IN ('GAME', 'POE1_LEAGUE', 'POE2_LEAGUE', 'D4_LEAGUE', 'POE1_CURRENCY', 'POE2_CURRENCY', 'D4_CURRENCY')
ORDER BY type, code;
```

Lưu kết quả vào file `attribute_id_mapping.csv`

### Bước 3: Tạo Relationships file

Dùng Python script để tạo file `attribute_relationships.csv` từ mapping:

```python
import csv

# Đọc mapping
mapping = {}
with open('attribute_id_mapping.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        mapping[row['code']] = row['id']

# Tạo relationships
relationships = []
with open('attribute_relationships_composite_template.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        parent_id = mapping.get(row['parent_code'])
        child_id = mapping.get(row['child_code'])
        if parent_id and child_id:
            relationships.append({
                'parent_attribute_id': parent_id,
                'child_attribute_id': child_id
            })

# Ghi file
with open('attribute_relationships.csv', 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['parent_attribute_id', 'child_attribute_id'])
    writer.writeheader()
    writer.writerows(relationships)
```

### Bước 4: Import Relationships

1. Vào Table Editor → Bảng `attribute_relationships`
2. Import file `attribute_relationships.csv` vừa tạo

## Season Transition Usage

### Ví dụ: Kết chuyển từ Settlers về Standard

```sql
-- Kết chuyển 100 Chaos Orb từ Settlers Softcore về Standard Softcore
SELECT transition_league_currency(
    'game_account_uuid_here',
    (SELECT id FROM attributes WHERE code = 'SETTLERS_SOFTCORE'),
    (SELECT id FROM attributes WHERE code = 'STANDARD_SOFTCORE'),
    (SELECT id FROM attributes WHERE code = 'CHAOS_ORB'),
    100,
    'End of Settlers league transition'
);
```

### Bulk transition khi hết season

```sql
-- Kết chuyển toàn bộ currency từ Settlers về Standard
SELECT * FROM bulk_transition_league_currency(
    (SELECT id FROM attributes WHERE code = 'SETTLERS_SOFTCORE'),
    (SELECT id FROM attributes WHERE code = 'STANDARD_SOFTCORE')
);
```

## Benefits của Composite Approach

✅ **Mở rộng dễ dàng:** Thêm game/league mới không cần ALTER TABLE
✅ **Season transition đơn giản:** Chuyển trực tiếp giữa league codes
✅ **Performance tốt:** Query trực tiếp không cần nhiều JOIN
✅ **Flexible:** Hỗ trợ game có/không có league/season
✅ **Data integrity:** Constraints đảm bảo currency thuộc đúng game

## Validation & Testing

### Kiểm tra relationships sau import

```sql
-- Kiểm tra game -> league relationships
SELECT
    parent.name as game_name,
    child.name as league_name,
    child.type as league_type
FROM attribute_relationships rel
JOIN attributes parent ON rel.parent_attribute_id = parent.id
JOIN attributes child ON rel.child_attribute_id = child.id
WHERE parent.type = 'GAME' AND child.type LIKE '%LEAGUE'
ORDER BY parent.name, child.name;

-- Kiểm tra game -> currency relationships
SELECT
    parent.name as game_name,
    child.name as currency_name,
    child.type as currency_type
FROM attribute_relationships rel
JOIN attributes parent ON rel.parent_attribute_id = parent.id
JOIN attributes child ON rel.child_attribute_id = child.id
WHERE parent.type = 'GAME' AND child.type LIKE '%CURRENCY'
ORDER BY parent.name, child.name;
```

### Test season transition logic

```sql
-- Test validation function
SELECT validate_currency_scope(
    (SELECT id FROM attributes WHERE code = 'CHAOS_ORB'),
    (SELECT id FROM attributes WHERE code = 'STANDARD_SOFTCORE')
); -- Should return TRUE

-- Test với sai game
SELECT validate_currency_scope(
    (SELECT id FROM attributes WHERE code = 'CHAOS_ORB'),
    (SELECT id FROM attributes WHERE code = 'SEASON_5_STANDARD_D4')
); -- Should return FALSE
```

## Next Steps

Sau khi import xong attributes:

1. Implement currency tables (`game_accounts`, `currency_inventory`, `currency_transactions`)
2. Tạo RPC functions cho currency management
3. Update frontend để hỗ trợ composite league selection
4. Test season transition workflows
