# GitHub CLI (gh) Login Setup

This document summarizes how to set up login credentials using GitHub CLI.

## Basic Login

### Interactive Login

```bash
gh auth login
```

When you run this command, the following options will be displayed:

1. Select **GitHub.com**
2. Select **Authentication method**:
   - **HTTPS** - Use browser or token
   - **SSH** - Use SSH key
3. Select **Authentication protocol**:
   - **Login with a web browser** (recommended) - Browser opens automatically
   - **Paste an authentication token** - Use a pre-created Personal Access Token

```sh
% gh auth login
? Where do you use GitHub? GitHub.com
? What is your preferred protocol for Git operations on this host? HTTPS
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Login with a web browser

! First copy your one-time code: {one-time-code}
Press Enter to open https://github.com/login/device in your browser...
✓ Authentication complete.
- gh config set -h github.com git_protocol https
✓ Configured git protocol
✓ Logged in as shun968
! You were already logged in to this account
```

## Check Authentication Status

Check current login status:

```bash
gh auth status
```

Display logged-in user information:

```bash
gh api user
```

## Logout

```bash
gh auth logout
```

## Managing Multiple Accounts

When using multiple GitHub accounts:

```bash
# First account
gh auth login --hostname github.com

# Second account (e.g., GitHub Enterprise Server)
gh auth login --hostname enterprise.github.com
```

Switch authentication:

```bash
gh auth switch
```

## Common Commands

### Clone Repository

```bash
gh repo clone owner/repo-name
```

### Create Repository

```bash
gh repo create repo-name --public
```

### Create Pull Request

```bash
gh pr create
```

### Create Issue

```bash
gh issue create
```

## Troubleshooting

### Authentication Errors

1. Check authentication status:

   ```bash
   gh auth status
   ```

2. Re-login:

   ```bash
   gh auth logout
   gh auth login
   ```

3. Check token expiration:
   - Check token expiration on GitHub settings page
   - Generate a new token if necessary

### Permission Errors

- Verify that Personal Access Token includes required scopes
- If organization SSO authentication is required, enable SSO with the token

## Reference Links

- [GitHub CLI Official Documentation](https://cli.github.com/manual/)
- [GitHub CLI Authentication Guide](https://cli.github.com/manual/gh_auth_login)
- [Create Personal Access Token](https://github.com/settings/tokens)
