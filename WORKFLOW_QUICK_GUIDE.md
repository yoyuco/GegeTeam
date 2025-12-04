# Git Workflow Quick Guide 2025

## 🚀 Quick Start

### 1. Feature Development
```bash
# Start new feature
git checkout develop
git pull
git checkout -b feature/your-feature-$(date +%Y%m%d-%H%M)

# Work and commit
git add .
git commit -m "feat: implement your feature"

# Push and create PR
git push -u origin feature/your-feature-*
# Open PR: feature → develop (Squash & Merge)
```

### 2. Release to Production
```bash
# Create release PR
# GitHub UI: PR develop → main (Squash & Merge)
```

### 3. Sync Develop with Main
```bash
# Option A: Rebase (Recommended - Clean History)
git checkout develop
git fetch origin
git rebase origin/main
git push --force-with-lease

# Option B: Manual PR (GitHub-compliant)
git checkout -b sync/main-to-develop-$(date +%Y%m%d-%H%M) origin/develop
git fetch origin && git rebase origin/main
git push -u origin sync/main-to-develop-*
# Open PR: sync → develop (Squash & Merge)
```

### 4. Check Sync Status
```bash
git fetch origin
git rev-list --left-right --count origin/main...origin/develop
# Expected: 0 N (left should be 0)
```

## ⚠️ Common Issues & Solutions

### "Changes must be made through a pull request"
- **Solution**: Create PR from main → develop for sync

### "Force push not allowed"
- **Solution**: Use Option B (PR-based sync) instead of rebase

### "Merge conflicts during rebase"
```bash
git rebase --abort  # Cancel rebase
# Or resolve conflicts:
git add .
git rebase --continue
```

### "PR checks failing"
```bash
git commit --allow-empty -m "ci: trigger preview"
git push
```

## 🎯 Best Practices

### Feature Branches
- Keep branches short-lived (< 3 days)
- Use descriptive names: `feature/currency-improvements`, `fix/auth-bug`
- Commit frequently with clear messages

### Pull Requests
- Fill PR template completely
- Request at least 1 review
- Wait for CI checks to pass
- Delete branch after merge

### Release Process
1. All features merged to develop
2. Develop tested and stable
3. PR develop → main
4. Deploy after merge

### Sync Process
- Sync after every production release
- Prefer rebase method for clean history
- Use PR method if force-push restricted
- Verify sync with divergence check

## 🔧 GitHub Actions Automation

### Manual Sync (Recommended)
1. Go to Actions tab in GitHub
2. Select "Auto-Sync Develop from Main"
3. Click "Run workflow"
4. Choose sync method: `rebase` or `merge`
5. Monitor progress

### Available Methods
- **rebase**: Clean history, requires force-push permissions
- **merge**: GitHub-compliant, creates PR automatically

## 📱 Mobile/Web Quick Actions

### On GitHub Mobile/Web
1. **Create PR**: Use "+" button → New pull request
2. **Review**: Use "Files changed" tab
3. **Merge**: Choose "Squash and merge"

### Quick Sync via UI
1. Open new PR
2. Base: `develop`, Compare: `main`
3. Create merge commit (legacy) OR
4. Create sync branch → Squash merge (enhanced)

## 🆘 Emergency Procedures

### Hotfix to Production
```bash
# Create hotfix from main
git checkout main
git pull
git checkout -b hotfix/critical-fix-$(date +%Y%m%d-%H%M)

# Fix and test
# ...

# Deploy directly to main (emergency PR)
git push -u origin hotfix/critical-fix-*
# Open PR: hotfix → main (Squash & Merge)
```

### Rollback Production
```bash
# Find last good commit
git log --oneline main

# Revert to safe commit
git revert [commit-hash]
git push origin main
```

## 📊 Status Commands

```bash
# Check current branch
git branch --show-current

# Check sync status
git rev-list --left-right --count origin/main...origin/develop

# Check recent commits
git log --oneline -5

# Check remote status
git remote -v
```

---

## 📞 Need Help?

- **Documentation**: [CONTRIBUTING.md](./CONTRIBUTING.md)
- **Automation**: Actions tab → "Auto-Sync Develop from Main"
- **Issues**: Create GitHub issue with "workflow" label

## 💡 Tips

1. **Always pull before branching** to avoid conflicts
2. **Use squash merge** for cleaner history
3. **Delete merged branches** to keep repo clean
4. **Check CI status** before merging
5. **Use descriptive commit messages** following conventional commits