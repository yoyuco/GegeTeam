# Contributing Guide

Tài liệu này mô tả **cách làm việc chuẩn** cho repo, nhằm tránh kẹt PR/CI (đặc biệt với Vercel Preview) và xử lý migratons của Supabase.

---

## 1) Nhánh & vai trò

- **main**: production. lịch sử **tuyến tính**. **Squash & merge only**.
- **develop**: nhánh tích hợp. **Cho phép merge commit** (để đồng bộ `main → develop`).
- Nhánh làm việc: `feature/*`, `fix/*`, `chore/*`, `docs/*`, …

> **Không push trực tiếp** vào `main`/`develop`. Mọi thay đổi đều qua Pull Request (PR).

---

## 2) Quy tắc merge theo nhánh

### main

- Allowed: **Squash & merge** (duy nhất).
- Bật: **Require linear history**, **Require PR**, **Require status checks**, **Require up-to-date**, **Block force pushes**, **Require deployments to succeed (Preview)**.
- Required checks: **Vercel** (đủ), _không bắt buộc_ “Vercel Preview Comments”.

### develop

- Allowed: **Merge commit**, có thể bật thêm Squash (tùy nhóm).
- Bật: **Require PR**, **Require status checks**, **Require deployments to succeed (Preview)**, **Block force pushes**.
- Tắt: **Require linear history** (để có merge-commit khi sync `main → develop`).
- _Có thể tắt_ “Require branches to be up to date” để giảm kẹt khi review.

---

## 3) Quy trình làm việc hằng ngày

### 3.1 Tạo tính năng/sửa lỗi

1. Tạo nhánh: `feature/xxx` (hoặc `fix/xxx`, `chore/xxx`).
2. Commit theo **Conventional Commits**:  
   `feat: …`, `fix: …`, `chore: …`, `docs: …`
3. Mở PR **base = develop, compare = feature/xxx**
   - Chờ checks xanh (Vercel Preview).
   - Merge: **Squash** hoặc **Create a merge commit** (tùy nhóm; khuyến nghị _Squash_ để gọn lịch sử).

### 3.2 Đồng bộ khi `develop` bị out-of-date so với `main` ⟵ **rất quan trọng**

> Mục tiêu: tạo **merge commit thật** `main → develop` trên **remote**.

1. Mở PR **base = develop, compare = main**
2. Chọn **Merge pull request (Create a merge commit)** _(không Squash/Rebase)_.
3. Sau khi merge xong, `develop` đã “nuốt” hết `main`.

### 3.3 Release lên production

1. Mở PR **base = main, compare = develop**.
2. Đợi checks & Preview xanh.
3. **Squash & merge**.
4. (tuỳ chọn) Tag phiên bản: `vX.Y.Z`.

---

## 4) Supabase Migrations (chuẩn hoá)

- Thư mục chuẩn:
  ```
  supabase/
    migrations/            # chỉ giữ baseline/consolidate mới nhất (file .sql gần nhất)
    migrations_archive/    # toàn bộ migrations cũ
  ```
- **Luôn dùng `git mv`** khi di chuyển file để Git nhận rename (tránh “hồi sinh” file cũ sau merge).
- Không đặt `__init__.py` trong `migrations_archive/`.
- Tool chỉ nên quét `supabase/migrations/`.

### 4.1 Di chuyển nhanh (PowerShell)

```powershell
# sửa tên file baseline cần giữ lại (ví dụ: 20251004011427_remote_schema.sql)
$keep = @("supabase/migrations/20251004011427_remote_schema.sql")

$files = git ls-files supabase/migrations
foreach ($f in $files) {
  if ($keep -contains $f) { continue }
  $leaf = Split-Path $f -Leaf
  $dest = "supabase/migrations_archive/$leaf"
  if (Test-Path $dest) { git rm --quiet $f } else { git mv $f $dest }
}
git commit -m "chore: move legacy supabase migrations to migrations_archive; keep latest baseline"
```

_(bash tương đương có thể bổ sung khi cần)._

---

## 5) CI/Preview (Vercel)

- Required check: **Vercel**.
- Nếu Preview không chạy:
  - mở tab **Checks** → **Re-run** (nếu có), hoặc
  - đẩy commit rỗng để trigger:
    ```bash
    git commit --allow-empty -m "ci: trigger preview"
    git push
    ```
- Tránh dùng “Vercel Preview Comments” như required check (dễ flake).

---

## 6) Troubleshooting nhanh

### 6.1 “Update branch” bị chặn / “Changes must be made through a pull request”

Repo/ruleset đang cấm push trực tiếp. Hãy **làm PR ngược**:

- PR **base = develop, compare = main** → **Create a merge commit**.
- Xong quay lại PR chính.

### 6.2 “Merging is blocked: Missing successful active Preview deployment”

Preview chưa chạy/đỏ:

- Mở tab **Checks → Vercel** xem log.
- Sửa lỗi build hoặc trigger lại CI (commit rỗng như trên).

### 6.3 Kiểm tra develop đã “nuốt” hết main chưa?

```bash
git fetch origin
git rev-list --left-right --count origin/main...origin/develop
# Kỳ vọng: 0   N   (bên trái = 0)
```

### 6.4 Sơ đồ sync chuẩn

```
(main)  ——(PR squash)—>  main
  ^                       ^
  |                       |
  |        (PR merge-commit)    (khi develop out-of-date)
  └———— develop  <———————————— main
```

---

## 7) Thiết lập khuyến nghị

- `.gitattributes`
  ```
  * text=auto eol=lf
  *.sql diff
  ```
- Commit nhỏ, mô tả rõ; PR có tiêu đề ngắn gọn:  
  `feat: …`, `fix: …`, `chore: consolidate migrations`, …
- Không commit secrets; dùng môi trường/Secrets của Vercel/GitHub.

---

## 8) Liên hệ

- Chủ repo/Reviewers: @…
- CI/Deploy: Vercel (project: `gege-team`).

### Lệnh làm việc nhanh

## pre-flight

git fetch origin
git switch develop
git pull
git rev-list --left-right --count origin/main...origin/develop # cần 0 N

## nếu ≠ 0: sync main -> develop bằng merge-commit

git switch -c sync/main-into-develop-$(Get-Date -Format "yyyyMMdd-HHmm") origin/develop
git merge --no-ff origin/main

# giải conflict nếu có -> git add . ; git commit

git push -u origin HEAD

# -> mở PR base=develop, compare=sync/... ; Merge pull request (Create a merge commit)

## nhánh mới

git switch develop
$ts = Get-Date -Format "yyyyMMdd-HHmm"
git switch -c feature/<slug>-$ts

## làm việc

git add -A
git commit -m "feat: <mô tả>"
git push -u origin $(git branch --show-current)

## mở PR base=develop ; nếu preview không chạy:

git commit --allow-empty -m "ci: trigger preview"
git push

## tạm cất (stash) thay đổi rồi làm feature

git stash push -m "wip: contributing" -- CONTRIBUTING.md

# bắt đầu nhánh mới

$ts = Get-Date -Format "yyyyMMdd-HHmm"
git switch -c feature/<slug>-$ts
