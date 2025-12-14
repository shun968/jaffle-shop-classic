# GitHub Repository Setup Scripts

This directory contains scripts and configuration files for setting up GitHub
repositories.

## Overview

This document explains how to use the setup scripts to configure GitHub
repositories.

## Prerequisites

- GitHub CLI (`gh`) is installed
- You have administrator permissions for the repository
- Authentication is complete (`gh auth login` has been executed)

## Setup Contents

1. **Default Branch Configuration** - Set default branch (configured in
   `repository-settings.json`)
2. **Repository General Settings Configuration** - Merge methods and other
   general repository settings (configured in `repository-settings.json`)
3. **Tag Protection Ruleset Configuration** - Tag naming rules following
   Semantic Versioning
4. **Branch Protection Rules Configuration** - Protection for `main`,
   `develop`, and `release/*` branches

## Batch Setup

You can run batch setup with the following command:

```bash
./setup-repository.sh
```

Alternatively, you can execute each step manually.

## Manual Setup Procedures

### 1. Default Branch Configuration

The default branch name is configured in `repository-settings.json` under the
`default_branch` field. The script will automatically create the branch if it
doesn't exist and set it as the default.

```bash
# Default branch is read from repository-settings.json
# The script handles branch creation and setting it as default
./setup-repository.sh
```

### 2. Repository General Settings Configuration

Configure general repository settings such as merge methods. Settings are
defined in `repository-settings.json`.

**Repository Settings (`repository-settings.json`):**

| Setting | Value | Description |
|---------|-------|-------------|
| `default_branch` | `"main"` | Default branch name |
| `allow_squash_merge` | `false` | Enable/disable squash merge |
| `allow_merge_commit` | `true` | Enable/disable merge commit |
| `allow_rebase_merge` | `true` | Enable/disable rebase merge |
| `allow_auto_merge` | `false` | Enable/disable auto-merge |
| `delete_branch_on_merge` | `false` | Delete branch after merge |

### 3. Tag Protection Ruleset Configuration

Configure tag protection rules. For details, see
[Tag Rules](../../docs/github/repository-rules/tag-rules.md).

### 4. Branch Protection Rules Configuration

Protect `main`, `develop`, and `release/*` branches.

**Branch Protection Settings:**

| Setting | Main | Develop | Description |
|---------|------|---------|-------------|
| `required_status_checks.strict` | `true` | `false` | Up to date |
| `enforce_admins` | `true` | `false` | Enforce admins |
| `required_approving_review_count` | `1` | `1` | Reviews count |
| `dismiss_stale_reviews` | `true` | `true` | Dismiss stale |
| `require_code_owner_reviews` | `false` | `false` | Code owner |
| `require_last_push_approval` | `false` | `false` | Last push |
| `required_conversation_resolution` | `true` | `false` | Resolution |
| `allow_force_pushes` | `false` | `false` | Force push |
| `allow_deletions` | `false` | `false` | Deletion |
| `block_creations` | `false` | `false` | Creation |
| `lock_branch` | `false` | `false` | Lock |
| `allow_fork_syncing` | `false` | `false` | Fork sync |

Note: Settings prefixed with `required_pull_request_reviews.` are nested
under `required_pull_request_reviews` in the JSON.

**Tag Protection Settings (`tag-protection-ruleset.json`):**

| Setting | Value | Description |
|---------|-------|-------------|
| `name` | `"Tag Protection Rules"` | Ruleset name |
| `target` | `"tag"` | Target type |
| `enforcement` | `"active"` | Enforcement status |
| `conditions.ref_name.include` | `["refs/tags/**"]` | Target all tags |
| `rules[0].type` | `"deletion"` | Prevent deletion |
