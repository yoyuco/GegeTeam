# README_team.md — Quy trình làm việc (GitHub + Vercel + Supabase)

> Mục tiêu: chuẩn hóa luồng **dev → preview → release**, an toàn cho dữ liệu và dễ rollback.  
> Tech: **pnpm + Vite**, **GitHub**, **Vercel**, **Supabase**.

---

## 0) Sơ đồ môi trường

| Nhánh / Máy            | Vercel         | Supabase       |
| ---------------------- | -------------- | -------------- |
| `main`                 | **Production** | **Production** |
| `develop`, `feature/*` | **Preview**    | **Staging**    |
| **local**              | —              | **Staging**    |

> Quy ước: client chỉ dùng **`VITE_SUPABASE_URL`** + **`VITE_SUPABASE_ANON_KEY`**. **Không** đưa `SERVICE_ROLE_KEY` ra client.

---

## 1) Chuẩn bị máy dev (1 lần)

- Node LTS, pnpm v10+
- CLI (tùy chọn): `npm i -g supabase vercel`
- Cấu hình pnpm (loại bỏ cảnh báo build scripts, đảm bảo CI giống local):
  ```bash
  pnpm approve-builds   # chọn: esbuild, @tailwindcss/oxide, supabase
  git add pnpm-workspace.yaml
  git commit -m "pnpm: allow esbuild/oxide/supabase"
  ```

---

## 2) Quy ước

- Nhánh: `feat/<ten-task>`, `fix/<mo-ta>`, `chore/<mo-ta>`
- Commit: ngắn, rõ (ví dụ: `feat(auth): add magic link`)

---

## 3) Checklist hằng ngày

### 3.1 Dev local & tạo nhánh tính năng

- [ ] Cập nhật nền:
  ```bash
  git switch main && git pull
  ```
- [ ] Tạo nhánh:
  ```bash
  git switch -c feat/<ten-task>
  ```
- [ ] Chạy dự án (kết nối **Staging**):
  ```bash
  pnpm i
  pnpm dev
  ```
- [ ] Commit:
  ```bash
  git add -A
  git commit -m "feat(x): <mo-ta-ngan>"
  ```

### 3.2 Đẩy nhánh & mở PR vào **develop**

- [ ] Đẩy lần đầu:
  ```bash
  git push -u origin feat/<ten-task>
  ```
- [ ] GitHub → **New Pull Request** → **base = `develop`**, **compare = `feat/<ten-task>`**
- [ ] Đợi **Vercel (Preview)** xanh → bấm **Preview** để QA nhanh

### 3.3 Gộp vào **develop**

- [ ] **Squash and merge** PR vào `develop`
- [ ] Cập nhật local:
  ```bash
  git switch develop && git pull
  ```

### 3.4 Phát hành **develop → main** (Production)

- [ ] Mở PR: **base = `main`**, **compare = `develop`**
- [ ] Kiểm tra **checks** (Vercel) xanh; mở **Preview** test
- [ ] Merge:
  - Có reviewer → cần **1 approval** trên `main`
  - Solo → tạm đặt **Required approvals = 0** (Settings → Rules → `main`), merge xong đặt lại **= 1**
- [ ] Theo dõi Vercel **Production (Current)** → **Build Logs** “Ready”
- [ ] **Visit** site (prod) → DevTools **Network** lọc `supabase.co` → host phải là **prod**

### 3.5 Dọn dẹp nhánh

```bash
git switch develop && git pull
git branch -d feat/<ten-task>
git push origin --delete feat/<ten-task>
git switch main && git pull
```

---

## 4) Supabase — Migrations & Dữ liệu (an toàn)

> Quy tắc: **Staging trước, Production sau**. Sao lưu Prod trước khi đẩy.

### 4.1 Tạo & test migration

```bash
supabase migration new <ten-migration>
# chỉnh SQL theo yêu cầu
# test local nếu cần:
# supabase db reset
```

### 4.2 Đẩy **Staging**

```bash
supabase link --project-ref <STAGING_REF>
supabase db push
# (nếu có seed an toàn)
pnpm db:seed:staging
```

### 4.3 Đẩy **Production** (sau khi merge vào `main`)

1. Supabase (Prod) → **Database → Backups** → tạo backup
2. CLI:
   ```bash
   supabase link --project-ref <PROD_REF>
   supabase db push
   # (nếu có seed prod, chỉ chạy khi chắc chắn)
   # pnpm db:seed:prod
   ```

> Tránh commit thư mục tạm: add vào `.gitignore`

```
supabase/.temp/
```

---

## 5) Biến môi trường (Vercel)

### 5.1 Quy ước

- **Production**: dùng key/project **Prod**
- **Preview**: dùng key/project **Staging**
- Client: `VITE_...`; Server-only: không có `VITE_...`

### 5.2 Thay đổi env đúng cách

1. Vercel → **Project → Settings → Environment Variables**
2. Thêm/sửa biến ở **Production** và/hoặc **Preview**
3. Áp dụng:
   - Production → **Redeploy** deployment hiện tại
   - Preview → tạo PR nhỏ để sinh build preview mới

> Kiểm tra: mở site → DevTools **Network** → request `*.supabase.co` đúng host **prod/staging** tương ứng.

---

## 6) Branch Protection (đã bật sẵn)

### `main` (nghiêm ngặt)

- Require PR (1 approval), Dismiss stale, Resolve conversations
- Require status checks (Vercel) & Require deployments to succeed (Preview)
- Restrict deletions, Block force pushes, Require linear history
- Merge kiểu **Squash**

### `develop` (nhanh – Preset A)

- Restrict deletions, Block force pushes
- _Không_ bắt buộc status checks / approval (khuyến khích dùng PR)

---

## 7) Rollback nhanh

- **Vercel**: **Deployments** → mở deployment trước đó → **Promote to Production**
- **Supabase**: **Database → Backups → Restore** (Prod)

---

## 8) Troubleshooting nhanh

- **Không switch branch vì có thay đổi dở:**
  ```bash
  git add -A && git commit -m "wip: snapshot"   # hoặc: git stash push -u -m "temp"
  git switch <branch>
  ```
- **Local và remote “diverged”:** (giữ remote, có backup)
  ```bash
  git branch backup/<ten-nhanh>
  git fetch --prune
  git reset --hard origin/<ten-nhanh>
  ```
- **Conflict khi rebase/merge:** (giữ phiên bản nhánh đang làm)
  ```bash
  git checkout --theirs <file>   # khi đang rebase
  git add <file>
  git rebase --continue
  ```
- **pnpm v10 cảnh báo “Ignored build scripts”:**
  ```bash
  pnpm approve-builds
  git add pnpm-workspace.yaml
  git commit -m "pnpm: allow build scripts"
  ```
- **JWT lộ trên client là `anon key`?** → OK nếu RLS/policy chặt. **Không** để lộ `service_role` (decode payload để kiểm).

---

## 9) Quick commands (cheat sheet)

```bash
# tạo nhánh tính năng
git switch main && git pull
git switch -c feat/<ten>

# đẩy & mở PR vào develop
git push -u origin feat/<ten>

# merge develop -> main (PR trên GitHub)
# sau merge: theo dõi Vercel Production

# dọn nhánh
git switch develop && git pull
git branch -d feat/<ten>
git push origin --delete feat/<ten>
```

---

**Hết.** Nếu cần, thêm phần “Checklist phát hành” theo sản phẩm để QA cuối.
