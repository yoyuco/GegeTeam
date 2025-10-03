# Contributing Guidelines

Hướng dẫn quy trình làm việc với Git cho team GegeTeam.

## 📋 Git Flow Strategy

```
main (production)
  ↑
develop (staging)
  ↑
feature/*, fix/*, hotfix/*
```

### Branch Types

- **`main`**: Nhánh production, chỉ chứa code đã release
- **`develop`**: Nhánh staging, tích hợp tất cả features mới
- **`feature/*`**: Nhánh phát triển tính năng mới
- **`fix/*`**: Nhánh sửa lỗi thông thường
- **`hotfix/*`**: Nhánh sửa lỗi khẩn cấp trên production

---

## 🚀 Quy trình làm việc chuẩn

### 1. Bắt đầu feature/fix mới

```bash
# Checkout develop và cập nhật
git checkout develop
git pull origin develop

# Tạo nhánh mới
git checkout -b feature/ten-tinh-nang
# hoặc
git checkout -b fix/ten-loi
```

### 2. Làm việc và commit

```bash
# Làm việc với code...

# Kiểm tra code
pnpm lint
pnpm type-check  # Nếu có

# Add và commit
git add .
git commit -m "feat: mô tả ngắn gọn tính năng"

# Push lên remote
git push -u origin feature/ten-tinh-nang
```

### 3. Tạo Pull Request

1. Truy cập: https://github.com/yoyuco/GegeTeam/pulls
2. Click **New pull request**
3. Chọn: `base: develop` ← `compare: feature/ten-tinh-nang`
4. Điền title và description:
   ```
   Title: feat: thêm filter UI cho ServiceBoosting

   Description:
   ## Thay đổi
   - Loại bỏ labels khỏi filter form
   - Thêm width cố định cho inputs
   - Căn giữa các elements

   ## Test plan
   - [ ] Kiểm tra filter hiển thị đúng
   - [ ] Test trên Chrome/Firefox
   - [ ] Chạy pnpm lint
   ```
5. Assign reviewers (nếu có)
6. Click **Create pull request**

### 4. Review và Merge

- **Reviewer**: Review code, comment, approve
- **Author**: Fix comments nếu có
- Sau khi approved: **Merge pull request** vào `develop`
- **Xóa nhánh** sau khi merge

### 5. Deploy lên Production

```bash
# Sau khi test kỹ trên develop
git checkout main
git pull origin main
git merge develop

# Tag version
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main
git push origin v1.0.0
```

---

## 📝 Commit Message Convention

Sử dụng [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <description>

[optional body]

[optional footer]
```

### Types

- **feat**: Tính năng mới
- **fix**: Sửa lỗi
- **docs**: Cập nhật documentation
- **style**: Format code (không ảnh hưởng logic)
- **refactor**: Refactor code
- **test**: Thêm/sửa tests
- **chore**: Công việc maintenance (update deps, config...)

### Ví dụ

```bash
git commit -m "feat: add user authentication"
git commit -m "fix: resolve null pointer in order processing"
git commit -m "docs: update API documentation"
git commit -m "refactor: simplify filter logic"
```

---

## 🔥 Hotfix (Sửa lỗi khẩn cấp)

```bash
# Tạo từ main
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug

# Fix và test
# ...

# Merge vào main
git checkout main
git merge hotfix/critical-bug
git push origin main

# Merge về develop
git checkout develop
git merge hotfix/critical-bug
git push origin develop

# Xóa nhánh
git branch -d hotfix/critical-bug
```

---

## ⚙️ Git Configuration

### Line Endings (Windows)

```bash
# Tắt auto CRLF conversion
git config core.autocrlf false

# Hoặc set global
git config --global core.autocrlf false
```

### Editor

```bash
git config --global core.editor "code --wait"
```

---

## ✅ Checklist trước khi tạo PR

- [ ] Code chạy không lỗi
- [ ] `pnpm lint` pass
- [ ] Đã test thủ công
- [ ] Commit message rõ ràng
- [ ] Không commit file không cần thiết (.env, node_modules, ...)
- [ ] Branch được rebase/merge từ develop mới nhất

---

## 🚫 Những điều KHÔNG nên làm

❌ Commit trực tiếp vào `main` hoặc `develop`
❌ Force push (`git push -f`) lên shared branches
❌ Merge nhiều features cùng lúc
❌ Commit code chưa test
❌ Commit file có chứa secrets (.env, credentials, ...)

---

## 💡 Tips

### Sync fork với upstream

```bash
git remote add upstream https://github.com/yoyuco/GegeTeam.git
git fetch upstream
git checkout develop
git merge upstream/develop
```

### Squash commits trước khi merge

```bash
# Interactive rebase 3 commits cuối
git rebase -i HEAD~3
# Chọn 'squash' cho commits muốn gộp
```

### Stash changes tạm thời

```bash
# Lưu changes
git stash

# List stashes
git stash list

# Apply lại
git stash pop
```

---

## 🆘 Cần giúp đỡ?

- Slack: #dev-team
- Email: dev@gegeteam.com
- GitHub Issues: https://github.com/yoyuco/GegeTeam/issues

---

## 📚 Tài liệu tham khảo

- [Git Flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
