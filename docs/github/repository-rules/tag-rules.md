# GitHub Repository Rules - Tag Configuration

This document summarizes how to configure tag-related rules for repositories
using GitHub CLI (gh).

## Prerequisites

- GitHub CLI (`gh`) is installed
- You have administrator permissions for the repository
- Authentication is complete (`gh auth login` has been executed)

## Repository Rules Basics

GitHub CLI uses the `gh api` command to call the GitHub API and configure
repository rules.

### Check Current Rulesets

```bash
# Get list of rulesets for current repository
gh api repos/{owner}/{repo}/rulesets

# Get details of specific ruleset
gh api repos/{owner}/{repo}/rulesets/{ruleset_id}
```

## Tag Protection Rules Configuration

### 1. Create Tag Protection Rules (Using JSON File)

To configure tag protection rules, create a JSON file and send it using the
`gh api` command.

**Example: `tag-protection-ruleset.json`**

```json
{
  "name": "Tag Protection Rules",
  "target": "tag",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": {
    "ref_name": {
      "include": [
        "refs/tags/**"
      ],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "tag_name_pattern",
      "parameters": {
        "name": "v*",
        "negate": false
      }
    },
    {
      "type": "deletion",
      "parameters": {}
    }
  ]
}
```

**Ruleset creation command:**

```bash
gh api repos/{owner}/{repo}/rulesets \
  --method POST \
  --input tag-protection-ruleset.json
```

### 2. Tag Name Pattern Configuration

Configure rules to enforce specific patterns for tag names.

#### Example: Enforce Semantic Versioning

```json
{
  "name": "Semantic Versioning Tag Rule",
  "target": "tag",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/tags/**"]
    }
  },
  "rules": [
    {
      "type": "tag_name_pattern",
      "parameters": {
        "name": "^v?[0-9]+\\.[0-9]+\\.[0-9]+(-[a-zA-Z0-9]+)?$",
        "negate": false
      }
    }
  ]
}
```

**Command example:**

```bash
# Create ruleset from JSON file
gh api repos/{owner}/{repo}/rulesets \
  --method POST \
  --input semantic-version-tag-rule.json
```

### 3. Tag Deletion Restriction

Configure rules to restrict tag deletion.

```json
{
  "name": "Prevent Tag Deletion",
  "target": "tag",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/tags/**"]
    }
  },
  "rules": [
    {
      "type": "deletion",
      "parameters": {}
    }
  ]
}
```

### 4. Tag Creation Review Requirements

Configure rules to require reviews for tag creation.

```json
{
  "name": "Tag Creation Review Required",
  "target": "tag",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/tags/**"]
    }
  },
  "rules": [
    {
      "type": "required_reviewers",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false
      }
    }
  ]
}
```

## Common Tag Rule Combinations

### Complete Tag Protection Ruleset Example

```json
{
  "name": "Comprehensive Tag Protection",
  "target": "tag",
  "enforcement": "active",
  "bypass_actors": [
    {
      "actor_id": 123456,
      "actor_type": "OrganizationAdmin"
    }
  ],
  "conditions": {
    "ref_name": {
      "include": ["refs/tags/**"],
      "exclude": ["refs/tags/dev-*", "refs/tags/test-*"]
    }
  },
  "rules": [
    {
      "type": "tag_name_pattern",
      "parameters": {
        "name": "^v[0-9]+\\.[0-9]+\\.[0-9]+$",
        "negate": false
      }
    },
    {
      "type": "deletion",
      "parameters": {}
    },
    {
      "type": "required_reviewers",
      "parameters": {
        "required_approving_review_count": 1
      }
    }
  ]
}
```

**Apply command:**

```bash
gh api repos/{owner}/{repo}/rulesets \
  --method POST \
  --input comprehensive-tag-protection.json
```

## Ruleset Management

### Update Ruleset

```bash
# Get ruleset ID
RULESET_ID=$(gh api repos/{owner}/{repo}/rulesets --jq '.[0].id')

# Update ruleset
gh api repos/{owner}/{repo}/rulesets/$RULESET_ID \
  --method PUT \
  --input updated-ruleset.json
```

### Delete Ruleset

```bash
# Get ruleset ID
RULESET_ID=$(gh api repos/{owner}/{repo}/rulesets --jq '.[0].id')

# Delete ruleset
gh api repos/{owner}/{repo}/rulesets/$RULESET_ID \
  --method DELETE
```

### Disable Ruleset (Temporarily disable without deleting)

```json
{
  "enforcement": "disabled"
}
```

```bash
gh api repos/{owner}/{repo}/rulesets/$RULESET_ID \
  --method PUT \
  -F enforcement=disabled
```

## Rule Types List

Available rule types for tag protection rules:

| Rule Type | Description | Parameter Example |
|-----------|-------------|-------------------|
| `tag_name_pattern` | Specify tag name pattern | `{"name": "v*"}` |
| `deletion` | Prohibit tag deletion | `{}` |
| `required_reviewers` | Reviews | `{"required_approving_review_count": 1}` |
| `required_status_checks` | Status checks | `{"required_status_checks": []}` |
| `non_fast_forward` | Prohibit non-fast-forward | `{}` |

## Practical Examples

### Example 1: Allow Only Release Tags

```bash
cat > release-tag-rule.json << 'EOF'
{
  "name": "Release Tags Only",
  "target": "tag",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/tags/**"]
    }
  },
  "rules": [
    {
      "type": "tag_name_pattern",
      "parameters": {
        "name": "^release/v[0-9]+\\.[0-9]+\\.[0-9]+$",
        "negate": false
      }
    },
    {
      "type": "deletion",
      "parameters": {}
    }
  ]
}
EOF

gh api repos/{owner}/{repo}/rulesets \
  --method POST \
  --input release-tag-rule.json
```

### Example 2: Exclude Pre-release Tags

```bash
cat > production-tag-rule.json << 'EOF'
{
  "name": "Production Tags Only",
  "target": "tag",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/tags/**"],
      "exclude": ["refs/tags/*-alpha*", "refs/tags/*-beta*", "refs/tags/*-rc*"]
    }
  },
  "rules": [
    {
      "type": "tag_name_pattern",
      "parameters": {
        "name": "^v[0-9]+\\.[0-9]+\\.[0-9]+$",
        "negate": false
      }
    }
  ]
}
EOF

gh api repos/{owner}/{repo}/rulesets \
  --method POST \
  --input production-tag-rule.json
```

## Troubleshooting

### Rules Not Applied

1. **Check ruleset status:**

   ```bash
   gh api repos/{owner}/{repo}/rulesets --jq '.[] | {id, name, enforcement, target}'
   ```

2. **Check if enforcement is `active`:**
   - `active`: Rule is enabled
   - `disabled`: Rule is disabled
   - `evaluate`: Evaluation only (warnings only)

3. **Check if conditions are correctly configured:**
   - Verify that `include` and `exclude` patterns are as intended

### Permission Errors

- Verify you have administrator permissions for the repository
- Verify that Personal Access Token has appropriate scopes (`repo`,
  `admin:repo`)

### JSON Syntax Errors

```bash
# Check JSON syntax
cat ruleset.json | jq .

# Fix if there are errors
```

## Reference Links

- [GitHub CLI Official Documentation](https://cli.github.com/manual/)
- [GitHub API - Repository Rulesets](https://docs.github.com/en/rest/repos/rules)
- [GitHub Repository Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
