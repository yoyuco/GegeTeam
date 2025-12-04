#!/bin/bash

# GitHub CLI commands to set up branch protection rules
# Usage: ./setup-branch-protection.sh

echo "Setting up branch protection rules..."

# Main Branch Protection
echo "Configuring main branch protection..."
gh api --method PUT repos/yoyuco/GegeTeam/branches/main/protection \
  --field 'required_status_checks={"strict":true,"contexts":["Vercel"]}' \
  --field 'enforce_admins=true' \
  --field 'required_pull_request_reviews={"required_approving_review_count":2,"dismiss_stale_reviews":true,"require_code_owner_reviews":false,"require_last_push_approval":true}' \
  --field 'restrictions=null' \
  --field 'allow_force_pushes=false' \
  --field 'allow_deletions=false' \
  --field 'required_linear_history=true' \
  --field 'allow_fork_syncing=false' \
  --field 'required_conversation_resolution=true'

echo "Main branch protection configured!"

# Develop Branch Protection
echo "Configuring develop branch protection..."
gh api --method PUT repos/yoyuco/GegeTeam/branches/develop/protection \
  --field 'required_status_checks={"strict":false,"contexts":["Vercel"]}' \
  --field 'enforce_admins=false' \
  --field 'required_pull_request_reviews={"required_approving_review_count":1,"dismiss_stale_reviews":false,"require_code_owner_reviews":false,"require_last_push_approval":false}' \
  --field 'restrictions=null' \
  --field 'allow_force_pushes=true' \
  --field 'allow_deletions=false' \
  --field 'required_linear_history=false' \
  --field 'allow_fork_syncing=false' \
  --field 'required_conversation_resolution=false'

echo "Develop branch protection configured!"
echo "Branch protection setup complete! 🎉"