#!/bin/bash

# -----------------------------------------------------------------------------
# GitHub Repository Initial Setup Script
# This script performs the following:
# 1. Repository settings configuration (default branch and general settings)
# 2. Tag protection ruleset configuration
# 3. Branch protection rules configuration
# -----------------------------------------------------------------------------

# Error handling and safety settings
# -e (errexit): Exit immediately if a command exits with a non-zero status
# -u (nounset): Treat unset variables as an error and exit immediately
# -o pipefail: Return value of a pipeline is the status of the last command
#              to exit with a non-zero status, or zero if no command exited
#              with a non-zero status
# This combination ensures the script stops on errors, prevents use of
# undefined variables, and properly detects errors in pipelines
set -euo pipefail

# -----------------------------------------------------------------------------
# Global Variables
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_INFO=$(gh repo view --json owner,name,defaultBranchRef -q '.owner.login + "/" + .name')
OWNER=$(gh repo view --json owner -q '.owner.login')
REPO_NAME=$(gh repo view --json name -q '.name')
CURRENT_DEFAULT=$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name')

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

# Configure repository settings (default branch and general settings)
configure_repository_settings() {
  echo "1. Repository settings configuration..."
  local REPOSITORY_SETTINGS_FILE="$SCRIPT_DIR/repository-settings.json"

  # Validate JSON file exists
  if [ ! -f "$REPOSITORY_SETTINGS_FILE" ]; then
    echo "  Error: $REPOSITORY_SETTINGS_FILE not found"
    exit 1
  fi

  # Read default branch from JSON file (required)
  local TARGET_DEFAULT_BRANCH=$(jq -r '.default_branch' "$REPOSITORY_SETTINGS_FILE")
  if [ -z "$TARGET_DEFAULT_BRANCH" ] || [ "$TARGET_DEFAULT_BRANCH" = "null" ]; then
    echo "  Error: default_branch not found in $REPOSITORY_SETTINGS_FILE"
    exit 1
  fi

  # Configure default branch
  if [ "$CURRENT_DEFAULT" != "$TARGET_DEFAULT_BRANCH" ]; then
    echo "  Creating $TARGET_DEFAULT_BRANCH branch..."
    cd "$REPO_ROOT"
    
    # Create target branch if it doesn't exist
    if ! git show-ref --verify --quiet "refs/heads/$TARGET_DEFAULT_BRANCH"; then
      if git show-ref --verify --quiet refs/heads/develop; then
        git checkout -b "$TARGET_DEFAULT_BRANCH" develop
      else
        git checkout -b "$TARGET_DEFAULT_BRANCH"
      fi
    else
      git checkout "$TARGET_DEFAULT_BRANCH"
    fi
    
    # Push to remote
    echo "  Pushing to remote..."
    git push -u origin "$TARGET_DEFAULT_BRANCH" 2>/dev/null || true
    
    # Set target branch as default branch on GitHub
    echo "  Setting $TARGET_DEFAULT_BRANCH as default branch on GitHub..."
    gh repo edit --default-branch "$TARGET_DEFAULT_BRANCH"
    
    echo "  ✓ Default branch set to $TARGET_DEFAULT_BRANCH"
  else
    echo "  ✓ Default branch is already $TARGET_DEFAULT_BRANCH"
  fi

  # Apply repository general settings
  echo "  Applying repository general settings..."
  # Exclude default_branch from API request (it's set via gh repo edit)
  local TEMP_SETTINGS=$(mktemp)
  jq 'del(.default_branch)' "$REPOSITORY_SETTINGS_FILE" > "$TEMP_SETTINGS"
  gh api "repos/$OWNER/$REPO_NAME" \
    --method PATCH \
    --input "$TEMP_SETTINGS" 2>/dev/null || echo "    Warning: Failed to apply repository settings"
  rm -f "$TEMP_SETTINGS"
  echo "  ✓ Repository general settings configured"
  echo ""
}

# Configure tag protection ruleset
configure_tag_protection() {
  echo "2. Tag protection ruleset configuration..."
  local TAG_RULESET_FILE="$SCRIPT_DIR/tag-protection-ruleset.json"

  if [ ! -f "$TAG_RULESET_FILE" ]; then
    echo "  Error: $TAG_RULESET_FILE not found"
    exit 1
  fi

  # Check for existing ruleset
  local EXISTING_RULESET=$(gh api "repos/$OWNER/$REPO_NAME/rulesets" \
    --jq ".[] | select(.name == \"Tag Protection Rules\") | .id" 2>/dev/null || echo "")

  if [ -n "$EXISTING_RULESET" ]; then
    echo "  Deleting existing tag protection ruleset..."
    gh api "repos/$OWNER/$REPO_NAME/rulesets/$EXISTING_RULESET" --method DELETE
  fi

  echo "  Creating tag protection ruleset..."
  gh api "repos/$OWNER/$REPO_NAME/rulesets" \
    --method POST \
    --input "$TAG_RULESET_FILE"

  echo "  ✓ Tag protection ruleset configured"
  echo ""
}

# Configure branch protection rules
configure_branch_protection() {
  echo "3. Branch protection rules configuration..."

  # Protect main branch
  local MAIN_PROTECTION_FILE="$SCRIPT_DIR/branch-protection-main.json"
  if [ -f "$MAIN_PROTECTION_FILE" ]; then
    echo "  Configuring main branch protection rules..."
    gh api "repos/$OWNER/$REPO_NAME/branches/main/protection" \
      --method PUT \
      --input "$MAIN_PROTECTION_FILE" 2>/dev/null || echo "    Warning: Failed to configure main branch protection rules"
    echo "  ✓ Main branch protection rules configured"
  else
    echo "  Warning: $MAIN_PROTECTION_FILE not found"
  fi

  # Protect develop branch (if exists)
  local DEVELOP_PROTECTION_FILE="$SCRIPT_DIR/branch-protection-develop.json"
  if [ -f "$DEVELOP_PROTECTION_FILE" ]; then
    if git ls-remote --heads origin develop | grep -q develop; then
      echo "  Configuring develop branch protection rules..."
      gh api "repos/$OWNER/$REPO_NAME/branches/develop/protection" \
        --method PUT \
        --input "$DEVELOP_PROTECTION_FILE" 2>/dev/null || echo "    Warning: Failed to configure develop branch protection rules"
      echo "  ✓ Develop branch protection rules configured"
    else
      echo "  develop branch does not exist, skipping"
    fi
  else
    echo "  Warning: $DEVELOP_PROTECTION_FILE not found"
  fi
}

# Print verification commands
print_verification_commands() {
  echo ""
  echo "Verification commands:"
  echo "  # Check default branch"
  echo "  gh repo view --json defaultBranchRef -q .defaultBranchRef.name"
  echo ""
  echo "  # Check repository settings"
  echo "  gh repo view --json allowSquashMerge,allowMergeCommit,allowRebaseMerge"
  echo ""
  echo "  # Check rulesets"
  echo "  gh api repos/$OWNER/$REPO_NAME/rulesets"
  echo ""
  echo "  # Check branch protection rules"
  echo "  gh api repos/$OWNER/$REPO_NAME/branches/main/protection"
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

echo "=========================================="
echo "GitHub Repository Initial Setup"
echo "=========================================="
echo "Repository: $REPO_INFO"
echo "Current default branch: $CURRENT_DEFAULT"
echo ""

# Execute configuration functions
configure_repository_settings
configure_tag_protection
configure_branch_protection

echo ""
echo "=========================================="
echo "Setup Complete"
echo "=========================================="
print_verification_commands
