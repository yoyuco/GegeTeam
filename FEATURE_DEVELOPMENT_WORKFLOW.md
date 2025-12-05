# Feature Development Workflow - Enhanced Git Workflow 2025

Hướng dẫn hoàn chỉnh cho quy trình phát triển tính năng mới sử dụng Enhanced Git Workflow 2025.

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Pre-flight Checks](#pre-flight-checks)
3. [Feature Development](#feature-development)
4. [Pull Request Process](#pull-request-process)
5. [Release Process](#release-process)
6. [Sync Process](#sync-process)
7. [Cleanup](#cleanup)
8. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

```bash
# 1. Cập nhật develop branch
git fetch origin
git switch develop
git pull

# 2. Tạo feature branch
git switch -c feature/<feature-name>-$(date +%Y%m%d-%H%M)

# 3. Development và commit
git add .
git commit -m "feat: implement feature description"

# 4. Push và tạo PR
git push -u origin feature/<feature-name>-$(date +%Y%m%d-%H%M)
# → Tạo PR trên GitHub (base: develop, compare: feature branch)

# 5. Sau khi merge vào develop và release:
# → Tạo PR develop → main
# → Merge (squash & merge)
# → Sync develop với main (dùng GitHub Actions)
```

---

## ✈️ Pre-flight Checks

Trước khi bắt đầu tính năng mới:

```bash
# 1. Kiểm tra divergence status
git fetch origin
git switch develop
git pull
git rev-list --left-right --count origin/main...origin/develop

# Expected: 0 N (main không ahead của develop)
# Nếu left > 0: cần sync develop với main trước

# 2. Kiểm tra trạng thái working directory
git status
# Phải là: "working tree clean"

# 3. Kiểm tra branches hiện có
git branch -a
# Hiểu rõ cấu trúc branches
```

### 🔧 Sync develop nếu cần:

**Option A: GitHub Actions (Recommended)**
1. Vào Actions tab → "Sync Develop From Main"
2. Use workflow from: `main`
3. Sync method: `rebase`
4. Run workflow

**Option B: Manual**
```bash
git checkout develop
git fetch origin
git rebase origin/main
git push --force-with-lease
```

---

## 💻 Feature Development

### Step 1: Tạo Feature Branch

```bash
# Format: feature/<description>-YYYYMMDD-HHMM
git switch -c feature/user-authentication-20251204-1338

# Windows PowerShell:
git switch -c feature/user-authentication-$(Get-Date -Format "yyyyMMdd-HHmm")
```

### Step 2: Development Guidelines

#### Commit Message Format:
```bash
# Features
git commit -m "feat: add user login functionality"

# Fixes
git commit -m "fix: resolve authentication timeout issue"

# Tests
git commit -m "test: add unit tests for login validation"

# Documentation
git commit -m "docs: update API documentation"

# Refactoring
git commit -m "refactor: simplify authentication service"

# Configuration
git commit -m "chore: update dependencies for auth service"
```

#### Best Practices:
- **Commit thường xuyên**: Mỗi logical change nên có commit riêng
- **Atomic commits**: Một commit chỉ làm một việc
- **Clear messages**: Mô tả rõ ràng "what" và "why"
- **Test local**: Chạy tests trước khi commit

### Step 3: Development Process

```bash
# Ví dụ development flow:
git add src/components/LoginForm.vue
git commit -m "feat: create login form component"

git add src/services/auth.js
git commit -m "feat: implement JWT authentication service"

git add tests/auth.test.js
git commit -m "test: add authentication unit tests"

git add README.md
git commit -m "docs: update authentication documentation"
```

---

## 🔀 Pull Request Process

### Step 1: Push Feature Branch

```bash
git push -u origin feature/user-authentication-20251204-1338
```

### Step 2: Create Pull Request

1. **GitHub UI**:
   - Click "New pull request"
   - Base: `develop`
   - Compare: `feature/user-authentication-20251204-1338`

2. **PR Template**:
   ```markdown
   ## Description
   Implement user authentication system with login, logout, and JWT token management.

   ## Changes
   - [x] Login form component
   - [x] Authentication service
   - [x] JWT token handling
   - [x] Unit tests
   - [x] Documentation

   ## Testing
   - [x] Manual testing completed
   - [x] All unit tests pass
   - [x] Integration tests pass

   ## Checklist
   - [x] Code follows project standards
   - [x] Self-review completed
   - [x] Ready for review
   ```

3. **PR Labels**:
   - `feature` - For new features
   - `bug` - For bug fixes
   - `enhancement` - For improvements
   - `documentation` - For docs only
   - `tests` - For test-only changes

### Step 3: Review Process

#### Reviewer Guidelines:
- **Code Quality**: Check coding standards
- **Logic**: Verify implementation correctness
- **Tests**: Ensure adequate test coverage
- **Documentation**: Check if docs are updated
- **Security**: Review for potential security issues

#### Author Responsibilities:
- **Address feedback**: Implement reviewer suggestions
- **Update PR**: Add clarifications if needed
- **Communicate**: Explain technical decisions

### Step 4: Merge

**Merge Type**: **Squash & Merge** (không dùng Create merge commit)

- **Why Squash & Merge**:
  - Clean linear history trên develop
  - Comprehensive commit message
  - Easier to track features

---

## 🚀 Release Process

Khi develop có đủ features để release:

### Step 1: Pre-release Checks

```bash
# 1. Kiểm tra divergence
git fetch origin
git rev-list --left-right --count origin/main...origin/develop
# Expected: X N (X > 0 có features mới)

# 2. Kiểm tra quality
git log --oneline develop --not main
# Review commits going to production

# 3. Run tests
npm test
# hoặc appropriate test command
```

### Step 2: Create Release PR

1. **GitHub UI**:
   - Click "New pull request"
   - Base: `main`
   - Compare: `develop`

2. **Release PR Template**:
   ```markdown
   ## Release Notes

   ### Features
   - **User Authentication**: Complete login/logout system with JWT
   - **Performance**: 50% faster API response times
   - **UI Improvements**: Enhanced user dashboard

   ### Bug Fixes
   - Fixed navigation menu positioning on mobile
   - Resolved memory leak in data processing

   ### Breaking Changes
   - None

   ### Dependencies
   - Updated vue-router to v4.2.0
   - Added jsonwebtoken package

   ### Testing
   - All tests passing
   - Manual QA completed
   - Performance tests passed

   ### Deployment
   - [x] Database migrations ready
   - [x] Environment variables configured
   - [x] Rollback plan prepared
   ```

3. **PR Labels**:
   - `release` - For production releases
   - `hotfix` - For emergency fixes
   - `breaking` - For breaking changes

### Step 3: Merge to Production

**Verification Checklist**:
- [ ] All CI checks pass (Vercel, tests, etc.)
- [ ] Code review completed
- [ ] Documentation updated
- [ ] Migration scripts ready
- [ ] Rollback plan in place

**Merge Type**: **Squash & Merge**

---

## 🔄 Sync Process

Sau khi release (merge develop → main), cần sync develop lại với main:

### Option A: GitHub Actions (Recommended)

1. Vào **Actions tab**
2. Chọn **"Sync Develop From Main"**
3. **Use workflow from**: `main`
4. **Sync method**: `rebase`
5. Click **Run workflow**

### Option B: Manual Sync

#### Rebase Method (Clean History)
```bash
git checkout develop
git fetch origin
git rebase origin/main
git push --force-with-lease
```

#### PR-based Method (Safe)
```bash
git checkout -b sync/main-to-develop-$(date +%Y%m%d-%H%M) origin/develop
git fetch origin && git rebase origin/main
git push -u origin sync/main-to-develop-*
# → Tạo PR trên GitHub: base=develop, compare=sync/...
# → Squash & merge
```

### Option C: Legacy Merge
```bash
git checkout -b sync/main-to-develop-$(date +%Y%m%d-%H%M) origin/develop
git merge --no-ff origin/main
git push -u origin sync/main-to-develop-*
# → Tạo PR và Create a merge commit
```

### Verify Sync
```bash
git fetch origin
git rev-list --left-right --count origin/main...origin/develop
# Expected: 0 N (main không ahead của develop)
```

---

## 🧹 Cleanup

### Local Cleanup
```bash
# Xóa feature branches đã merge
git branch -d feature/user-authentication-20251204-1338

# Xóa remote branches
git push origin --delete feature/user-authentication-20251204-1338

# Cleanup sync branches
git branch -d sync/main-to-develop-20251204-1338
git push origin --delete sync/main-to-develop-20251204-1338
```

### Periodic Cleanup
```bash
# List all branches
git branch -a

# Clean up old feature branches (older than 1 month)
git branch -d $(git branch --merged | grep 'feature/' | grep -v 'develop\|main')

# Remote cleanup
git remote prune origin
```

---

## 🔧 Troubleshooting

### Common Issues

#### 1. "Changes must be made through a pull request"
**Solution**: Tạo PR ngược để sync:
```bash
# Dùng GitHub Actions sync hoặc tạo PR manual
```

#### 2. "Merging is blocked: Missing successful active Preview deployment"
**Solution**:
```bash
# Check Vercel deployment
git commit --allow-empty -m "ci: trigger preview"
git push
```

#### 3. Merge Conflicts
**Resolution**:
```bash
# Với GitHub Actions: Auto-resolve
# Manual:
git status
# -> Resolve conflicts in files
# -> git add .
# -> git commit
```

#### 4. Force Push Blocked
**Solution**: Dùng PR-based sync method thay vì rebase

#### 5. Branch Divergence Issues
**Check status**:
```bash
git fetch origin
git log --oneline --graph origin/main...origin/develop
```

### Recovery Commands

#### Reset Feature Branch
```bash
# Reset to match develop
git checkout develop
git pull
git checkout feature/user-authentication-20251204-1338
git reset --hard origin/develop
```

#### Abort Failed Rebase
```bash
git rebase --abort
```

#### Abort Failed Merge
```bash
git merge --abort
```

### Emergency Procedures

#### Hotfix to Production
```bash
# Create hotfix from main
git checkout main
git pull
git checkout -b hotfix/critical-fix-$(date +%Y%m%d-%H%M)

# Fix and test
# ...

# Direct PR to main (emergency)
git push -u origin hotfix/critical-fix-*
# PR: hotfix → main (Squash & Merge)
```

#### Rollback Production
```bash
git checkout main
git log --oneline -10
git revert [commit-hash]
git push origin main
```

---

## 📚 Additional Resources

### Documentation Files
- **`CONTRIBUTING.md`** - Complete contribution guidelines
- **`WORKFLOW_QUICK_GUIDE.md`** - Quick reference
- **`MANUAL_SYNC_GUIDE.md`** - Backup sync procedures
- **`IMPLEMENTATION_CHECKLIST.md`** - Setup checklist

### GitHub Actions
- **Actions Tab** → "Sync Develop From Main"
- **Trigger**: Manual with branch selection
- **Methods**: `rebase` (preferred) or `merge`

### Branch Protection Rules
- **Main**: Linear history, required reviews, status checks
- **Develop**: Allow force pushes, merge commits allowed

### Conventional Commits
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation
- `style:` - Formatting, styling
- `refactor:` - Code refactoring
- `test:` - Tests
- `chore:` - Maintenance, configuration

---

## 🎯 Best Practices Summary

### Daily Development
1. **Start with sync**: Luôn sync develop trước khi bắt đầu
2. **Feature branches**: Short-lived (< 3 days)
3. **Atomic commits**: Mỗi commit làm một việc rõ ràng
4. **Test locally**: Chạy tests trước khi push
5. **Clear PRs**: Fill templates, request reviews

### Release Process
1. **Quality checks**: Tests, reviews, documentation
2. **Release PR**: Detailed changelog
3. **Squash merge**: Clean history
4. **Sync back**: Maintain branch consistency

### Team Collaboration
1. **Code reviews**: Thorough and constructive
2. **Communication**: Explain decisions and trade-offs
3. **Documentation**: Keep docs updated
4. **Continuous improvement**: Learn from issues

---

## 🆘 Help & Support

### Getting Help
- **GitHub Issues**: Create issue with `workflow` label
- **Team Communication**: Discuss complex changes before PR
- **Code Reviews**: Ask for help when stuck
- **Documentation**: Check guides before asking

### Commands Cheat Sheet
```bash
# Quick sync check
git fetch origin && git rev-list --left-right --count origin/main...origin/develop

# Create feature branch
git switch -c feature/<name>-$(date +%Y%m%d-%H%M)

# Emergency sync
git checkout develop && git fetch origin && git rebase origin/main && git push --force-with-lease

# Create PR from command line
gh pr create --title "Description" --body "Details" --base develop --head feature/branch
```

---

**Enhanced Git Workflow 2025** - Built for efficient, scalable, and maintainable development. 🚀