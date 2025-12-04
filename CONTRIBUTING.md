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

- Allowed: **Merge commit** and **Squash & merge**.
- Bật: **Require PR**, **Require status checks** (loose mode), **Require deployments to succeed (Preview)**.
- Bật: **Allow force pushes** (team-only).
- Tắt: **Require linear history** (để có merge-commit khi sync `main → develop`).
- Tắt: **Require branches to be up to date** để giảm kẹt khi review.
- Tắt: **Include administrators** (cho phép bypass).

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

> Mục tiêu: giữ develop sync với main với **clean history**.

#### Option A: Rebase-based Sync (Recommended nếu có force-push permissions)
```bash
git checkout develop
git fetch origin
git rebase origin/main
git push --force-with-lease
```

#### Option B: Clean PR Sync (GitHub-compliant)
1. Tạo sync branch:
   ```bash
   git checkout -b sync/main-to-develop-$(date +%Y%m%d-%H%M) origin/develop
   ```
2. Rebase thay vì merge:
   ```bash
   git fetch origin && git rebase origin/main
   ```
3. Push sync branch:
   ```bash
   git push -u origin sync/main-to-develop-*
   ```
4. Mở PR: **base = develop, compare = sync/main-to-develop-***
5. **SQUASH & MERGE** (tạo 1 commit clean duy nhất)

#### Option C: Legacy Merge (chỉ khi cần)
1. Mở PR **base = develop, compare = main**
2. Chọn **Merge pull request (Create a merge commit)** _(không Squash/Rebase)_.
3. Sau khi merge xong, `develop` đã "nuốt" hết `main`.

> **Note**: Option A tạo history clean nhất. Option B balanced giữa clean và GitHub compliance.

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
    migrations/            # chỉ giữ các migration files đang hoạt động
  ```
- **Luôn dùng `git mv`** khi di chuyển file để Git nhận rename (tránh "hồi sinh" file cũ sau merge).
- Tool chỉ nên quét `supabase/migrations/`.

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

- Sử dụng **Option A, B, hoặc C** trong section 3.2 để sync develop với main.

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

**Enhanced Workflow 2025:**
```
Feature → (PR squash) → develop → (PR squash) → main
                    ↑                ↑
                    |                |
               (rebase sync)   (production ready)
                    ↓                ↓
             develop ←←←←←←←←←←←←←←← main
```

**Legacy Workflow (chỉ khi cần):**
```
(main)  ——(PR squash)—>  main
  ^                       ^
  |                       |
  |        (PR merge-commit)    (khi develop out-of-date)
  └———— develop  <———————————— main
```

### 6.5 Enhanced Branch Protection Rules (2025)

#### Main Branch Rules:
```
✅ Require PR reviews (2 reviewers)
✅ Require status checks (strict mode)
✅ Require linear history
✅ Require up-to-date branches
❌ Allow force pushes
❌ Allow deletions
✅ Include administrators
```

#### Develop Branch Rules:
```
✅ Require PR reviews (1 reviewer)
✅ Require status checks (loose mode)
❌ Require linear history (allows merge commits)
✅ Allow force pushes (team-only)
❌ Allow deletions
❌ Include administrators (allows bypass)
```

### 6.6 Workflow Automation (Optional)

Team có thể setup GitHub Actions cho auto-sync:

```yaml
# .github/workflows/sync-develop.yml
name: Auto-Sync Develop from Main
on:
  workflow_dispatch:  # Manual trigger only
    inputs:
      sync_method:
        description: 'Sync method'
        required: true
        default: 'rebase'

jobs:
  sync:
    runs-on: ubuntu-latest
    if: github.event_name == 'workflow_dispatch'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.PAT }}

      - name: Sync develop with main
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          git checkout develop
          git fetch origin
          git rebase origin/main
          git push --force-with-lease origin develop
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

## nếu ≠ 0: sync main -> develop

# Option A: Rebase-based (Recommended)
git checkout develop
git fetch origin
git rebase origin/main
git push --force-with-lease

# Option B: Clean PR Sync (GitHub-compliant)
git switch -c sync/main-into-develop-$(Get-Date -Format "yyyyMMdd-HHmm") origin/develop
git fetch origin && git rebase origin/main
git push -u origin HEAD
# -> mở PR base=develop, compare=sync/... ; Squash & merge

# Option C: Legacy Merge (nếu cần)
git switch -c sync/main-into-develop-$(Get-Date -Format "yyyyMMdd-HHmm") origin/develop
git merge --no-ff origin/main
# giải conflict nếu có -> git add . ; git commit
git push -u origin HEAD
# -> mở PR base=develop, compare=sync/... ; Create a merge commit

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
