# Manual Sync Guide (GitHub Actions Backup)

Khi GitHub Actions không available, dùng các methods sau:

## Method 1: GitHub Web UI

### Sync main → develop:
1. Mở GitHub repository
2. Click "New pull request"
3. Base: `develop`, Compare: `main`
4. Click "Create pull request"
5. Title: `sync: main to develop [manual]`
6. Description: Manual sync due to GitHub Actions issue
7. Choose merge type:
   - **Squash and merge** (recommended)
   - hoặc **Create a merge commit**

## Method 2: Git CLI (Recommended)

### Pre-flight check:
```bash
git fetch origin
git rev-list --left-right --count origin/main...origin/develop
```

### Option A: Rebase (Clean history)
```bash
git checkout develop
git fetch origin
git rebase origin/main
git push --force-with-lease
```

### Option B: PR-based (Safe)
```bash
git checkout -b sync/main-to-develop-$(date +%Y%m%d-%H%M) origin/develop
git fetch origin && git rebase origin/main
git push -u origin sync/main-to-develop-*
# Tạo PR trên GitHub UI → Squash & merge
```

## Method 3: GitHub Desktop

1. Switch to `develop` branch
2. Branch → Merge into current branch → Choose `main`
3. Commit merge
4. Push

## Troubleshooting

### "Force push blocked"
- Sử dụng Option B (PR-based)
- Hoặc contact repository admin

### "Merge conflicts"
```bash
git rebase --abort  # Cancel rebase
# Hoặc resolve:
git add .
git rebase --continue
```

### "Permission denied"
- Check repository permissions
- Contact team admin

## Auto-sync Alternatives

Khi GitHub Actions ổn định lại:
1. Xóa workflows test
2. Kiểm tra lại sync-develop.yml
3. Test với simple-sync trước
4. Enable PAT secret

## Monitor GitHub Actions Status

Check GitHub Status: https://www.githubstatus.com/