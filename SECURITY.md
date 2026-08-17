# Security Policy

## Supported Versions

Symphony Async is a development workflow orchestration tool. Security updates are applied to the latest version on the main branch.

| Version | Supported |
|---------|-----------|
| Latest main branch | ✅ Yes |
| Older commits | ❌ No |

**Always use the latest version from the main branch** to ensure you have the most recent security fixes.

## Reporting a Vulnerability

If you discover a security vulnerability in Symphony Async, please report it responsibly:

### Preferred Method: GitHub Security Advisories

1. Go to the repository's **Security** tab
2. Click **Report a vulnerability**
3. Fill out the advisory form with details

### Alternative: Email

Send details to: **security@[project-domain].com** (replace with actual contact)

### What to Include

Please provide as much detail as possible:

- **Description** of the vulnerability
- **Steps to reproduce** the issue
- **Potential impact** (what could an attacker achieve?)
- **Affected components/skills** (commit-async, tests-async, auto-release, readme-async, symphony-orchestrator)
- **Suggested fix** (if you have one)
- **Your contact information** for follow-up

## Response Timeline

| Severity | Initial Response | Fix Target |
|----------|------------------|------------|
| Critical (RCE, data loss, privilege escalation) | 24 hours | 72 hours |
| High (auth bypass, significant data exposure) | 48 hours | 1 week |
| Medium (information disclosure, DoS potential) | 1 week | 2 weeks |
| Low (minor issues, defense-in-depth) | 2 weeks | Next release |

We will:
1. Acknowledge receipt within the initial response window
2. Validate and reproduce the issue
3. Develop and test a fix
4. Release the fix to main branch
5. Credit the reporter (unless anonymity requested)

## Security Constraints Enforced by Skills

Symphony Async is designed with security as a first-class concern. Each skill enforces specific constraints:

### commit-async
- **Explicit Approval**: Every `git commit` and `git push` requires separate, explicit user confirmation
- **No Blind Staging**: Avoids `git add .` to prevent committing unrelated or sensitive files
- **No Destructive Commands**: Strictly forbids `git reset --hard`, `git push --force`, `git clean -fd`
- **No Silent Automation**: Every step is communicated to the user; no action performed silently

### tests-async / tdd-async / bdd-async
- **No Test Manipulation**: Never deletes failing tests, weakens assertions, skips tests without justification, hides failures, or modifies tests to match broken implementation
- **Cascade Safety**: No recursive workflows (`tests-async → symphony-orchestrator → tests-async` is forbidden)
- **Isolated Execution**: Test skills never invoke other Symphony skills directly

### auto-release
- **No Tag Overwrites**: Never overwrites existing Git tags
- **No Automatic Tag Push**: Never pushes tags automatically (orchestrator decides with approval)
- **Working Tree Validation**: Checks working tree before modifying CHANGELOG.md
- **No Bypass**: Does not bypass `commit-async` for commits
- **No External Dependencies**: Uses Python standard library + Git only (no npm, Node.js, semantic-release)

### readme-async
- **No Secret Exposure**: Never exposes real secrets, tokens, passwords, API keys, or credentials; uses placeholders
- **No Destructive Commands**: Does not execute `git reset --hard`, `git push --force`, or similar
- **Minimal Changes**: Only updates what is necessary; never rewrites entire README unless required
- **No Silent Automation**: Every step is communicated; no action performed silently

### symphony-orchestrator (Orchestrator)
- **No Destructive Git**: Never executes `git reset --hard`, `git clean -fd`, `git push --force`
- **No User Data Deletion**: Never deletes user changes
- **No Unrelated File Overwrites**: Never overwrites unrelated files
- **No Automatic Conflict Resolution**: Never resolves conflicts by discarding changes
- **No Unrelated Commits**: Never commits unrelated files
- **No Silent Pushes**: Never pushes without explicit approval
- **No Infinite Loops**: Implements loop prevention (max iterations, automation detection, unstable detection)

## Secure Development Practices

### For Contributors

When contributing to Symphony Async:

1. **Never hardcode secrets** — use environment variables or secure configuration
2. **Validate all inputs** — especially file paths, user input, and external data
3. **Use safe defaults** — fail closed, not open
4. **Follow least privilege** — skills should only access what they need
5. **Audit dependencies** — minimize external dependencies; prefer standard library
6. **Test security boundaries** — verify approval gates cannot be bypassed

### For Users

When using Symphony Async:

1. **Review generated commits** — `commit-async` proposes, you approve
2. **Verify push targets** — ensure you're pushing to the intended remote
3. **Audit release tags** — `auto-release` creates tags locally; you approve push
4. **Protect your Git credentials** — use SSH keys or token-based auth with minimal scope
5. **Keep skills updated** — pull latest changes from main branch regularly

## Threat Model

### In Scope
- Local repository integrity (commits, tags, history)
- Remote push authorization
- Release version manipulation
- Documentation accuracy
- Test result integrity

### Out of Scope
- Git hosting platform security (GitHub, GitLab, etc.)
- Operating system security
- Network-level attacks
- Physical device access
- Social engineering

### Assumptions
- User controls the local machine and Git configuration
- User reviews and approves all prompted actions
- Git remotes are trusted (authenticated, authorized)
- Development environment is not actively compromised

## Security Best Practices for Users

### Git Configuration
```bash
# Require signed commits (recommended)
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_GPG_KEY_ID

# Prevent accidental force pushes
git config --global push.force false

# Show diff before commit
git config --global commit.verbose true
```

### Repository Security
- Enable branch protection rules on main branch
- Require signed commits for protected branches
- Use dependabot/renovate for dependency updates
- Enable GitHub/GitLab security scanning
- Regularly audit repository access permissions

### Credential Management
- Use SSH keys with passphrases (preferred over HTTPS tokens)
- If using tokens, scope them minimally (repo access only)
- Rotate tokens periodically
- Never commit credentials to any repository

## Vulnerability Disclosure Timeline

| Date | Action |
|------|--------|
| Day 0 | Vulnerability reported |
| Day 1 | Acknowledgment sent to reporter |
| Day 1-3 | Triage and validation |
| Day 3-7 | Fix development and testing |
| Day 7 | Fix merged to main branch |
| Day 7+ | Public disclosure (coordinated with reporter) |

## Hall of Fame

We recognize security researchers who responsibly disclose vulnerabilities:

*No vulnerabilities reported yet — be the first!*

## Contact

For security-related questions or concerns:

- **Security Advisories**: GitHub Security tab
- **General Security Questions**: Open a GitHub Discussion
- **Urgent Issues**: security@[project-domain].com

---

**Last Updated**: 2026-08-17  
**Version**: 1.0

*This security policy is a living document and will be updated as the project evolves.*