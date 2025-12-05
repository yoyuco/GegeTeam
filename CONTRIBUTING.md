# Contributing Guide

Tài liệu này mô tả **quy trình làm việc chuẩn (Standard Workflow)** của dự án, nhằm đảm bảo lịch sử code sạch đẹp, hạn chế conflict và an toàn khi deploy lên Production.

---

## 1. Chiến lược nhánh (Branch Strategy)

Chúng ta sử dụng mô hình 3 lớp nhánh. Vui lòng tuân thủ nghiêm ngặt quy tắc merge dưới đây:

| Nhánh | Vai trò | Môi trường (Vercel) | Quy tắc Merge vào nhánh này |
| :--- | :--- | :--- | :--- |
| **`main`** | **Production**. Chứa code chính thức, ổn định. | Production | **Create a Merge Commit**<br>*(Tuyệt đối không Squash)* |
| **`develop`** | **Staging**. Nhánh tích hợp để kiểm thử. | Preview/Dev | **Squash & Merge**<br>*(Gộp thành 1 commit sạch)* |
| **`feature/*`**| **Development**. Nhánh làm việc cá nhân. | Preview | N/A |

> **Nguyên tắc cốt lõi:**
> 1. `develop`: Lịch sử **tuyến tính (Linear history)**, mỗi commit là một tính năng hoàn chỉnh.
> 2. `main`: Lịch sử **theo vết (Traceable history)**, lưu giữ các dấu mốc release.

---

## 2. Quy trình làm việc (Workflow)

### Bước 1: Khởi tạo nhánh làm việc

Luôn bắt đầu từ `develop` mới nhất.

```bash
git checkout develop
git pull origin develop
git checkout -b feature/ten-tinh-nang  # Ví dụ: feature/login-page, fix/header-bug
```

### Bước 2: Commit & Push

Tuân thủ **Conventional Commits** để lịch sử rõ ràng:

- `feat: ...` (Tính năng mới)
- `fix: ...` (Sửa lỗi)
- `chore: ...` (Việc vặt: update deps, config...)
- `refactor: ...` (Sửa code nhưng không đổi logic)

```bash
git add .
git commit -m "feat: thêm trang đăng nhập"
git push -u origin feature/ten-tinh-nang
```

### Bước 3: Merge vào Develop (Tích hợp)

Tạo Pull Request (PR):

- **Base**: `develop` ⟵ **Compare**: `feature/...`
- Chờ **Vercel CI** báo xanh và **Reviewer** approve.
- **Bấm Merge**: Chọn chế độ **SQUASH AND MERGE**.

**Lý do**: Để gom gọn các commit nháp của bạn thành 1 dòng duy nhất trên develop.

### Bước 4: Release lên Main (Deploy Production)

Khi develop đã ổn định và sẵn sàng phát hành:

Tạo Pull Request (PR):

- **Base**: `main` ⟵ **Compare**: `develop`
- **Bấm Merge**: Chọn chế độ **CREATE A MERGE COMMIT**.

**Lưu ý**: Không chọn Squash. Chúng ta cần giữ dấu mốc merge để đồng bộ ngược sau này.

### 5. Đồng bộ ngược (Sync Back) - BẮT BUỘC

Sau mỗi lần Release (develop → main), lịch sử của main sẽ có thêm một "Merge Commit" mà develop không có. Cần đồng bộ ngay để tránh conflict tương lai.

**Cách thực hiện:**

```bash
# 1. Về develop và cập nhật
git checkout develop
git pull origin develop

# 2. Lấy code mới nhất từ server main
git fetch origin

# 3. Merge main về develop (Tạo merge commit)
git merge origin/main

# 4. Đẩy lên server
git push origin develop
```

**Nếu GitHub chặn push trực tiếp vào develop**: Hãy tạo PR **Base**: `develop` ⟵ **Compare**: `main` và chọn **Create a merge commit**.

---

## 3. Supabase & Database

**Vị trí**: Tất cả migration file phải nằm trong `supabase/migrations/`.

**Đổi tên file**: Bắt buộc dùng lệnh `git mv` để Git nhận diện việc đổi tên, tránh mất lịch sử hoặc tạo file trùng lặp.

```bash
git mv supabase/migrations/old_name.sql supabase/migrations/new_name.sql
```

**Không sửa file cũ**: Tuyệt đối không sửa nội dung file migration đã merge vào main. Hãy tạo file migration mới để thay đổi DB.

---

## 4. Troubleshooting (Sự cố thường gặp)

### 4.1 CI Vercel không chạy (Pending/Error)

Thử đẩy một commit rỗng để kích hoạt lại:

```bash
git commit --allow-empty -m "ci: trigger build"
git push
```

### 4.2 Nút Merge bị mờ / "This branch is out-of-date"

Nhánh của bạn đã cũ so với develop. Hãy cập nhật nhánh của bạn:

```bash
git checkout feature/cua-ban
git fetch origin
git rebase origin/develop
git push --force-with-lease
```

### 4.3 Lỡ tay commit thẳng vào develop/main?

Đừng push. Hãy dùng lệnh sau để lùi commit nhưng giữ lại code (đưa code về trạng thái staged):

```bash
git reset --soft HEAD~1
```

Sau đó chuyển sang nhánh mới và commit lại.

---

## 5. Sơ đồ quy trình (Cheat Sheet)

```mermaid
gitGraph
   commit id: "init"
   branch develop
   checkout develop
   commit id: "start"

   %% Feature Flow
   branch feature/A
   checkout feature/A
   commit id: "code..."
   checkout develop
   merge feature/A type: SQUASH id: "feat: A (Squash)"

   %% Release Flow
   checkout main
   merge develop id: "Release v1.0 (Merge Commit)"

   %% Sync Back Flow
   checkout develop
   merge main id: "chore: sync back"
```

---

## 6. Quick Reference Commands

```bash
# Bắt đầu feature mới
git checkout develop && git pull && git checkout -b feature/ten-feature

# Push và tạo PR
git add . && git commit -m "feat: mo ta tinh năng" && git push -u origin feature/ten-feature

# Sync back sau release
git checkout develop && git pull && git fetch origin && git merge origin/main && git push

# Rebase feature với develop mới
git checkout feature/ten-feature && git fetch origin && git rebase origin/develop
```

---

## 7. Môi trường

- **Production**: `main` branch → Production URL
- **Staging/Preview**: `develop` branch → Preview URL
- **Development**: `feature/*` branches → Feature preview URLs

---

## 8. Branch Protection Rules

### Main Branch Rules:
```
✅ Require PR reviews (2 reviewers)
✅ Require status checks (strict mode)
✅ Require linear history
✅ Require up-to-date branches
❌ Allow force pushes
❌ Allow deletions
✅ Include administrators
```

### Develop Branch Rules:
```
✅ Require PR reviews (1 reviewer)
✅ Require status checks (loose mode)
❌ Require linear history (allows merge commits)
✅ Allow force pushes (team-only)
❌ Allow deletions
❌ Include administrators (allows bypass)
```

---

## 9. GitHub Actions Automation

Team có thể sử dụng GitHub Actions cho auto-sync:

**Cách sử dụng:**
1. Vào **Actions tab** → **"Sync Develop From Main"**
2. **Use workflow from**: `main`
3. **Sync method**: `rebase` (khuyến nghị) hoặc `merge`
4. Click **Run workflow**

**Features:**
- ✅ PAT validation và force-push support
- ✅ Automatic conflict resolution
- ✅ Fallback mechanisms
- ✅ PR creation với detailed labels

---

## 10. Pre-flight Check

Luôn kiểm tra trước khi bắt đầu tính năng mới:

```bash
# Kiểm tra divergence status
git fetch origin
git switch develop
git pull
git rev-list --left-right --count origin/main...origin/develop
# Expected: 0 N (main không ahead của develop)

# Nếu left > 0: cần sync develop với main trước
```

---

**Lưu ý quan trọng**: Luôn thực hiện **sync back** sau mỗi release để đảm bảo develop branch luôn up-to-date với main và tránh conflicts trong tương lai.