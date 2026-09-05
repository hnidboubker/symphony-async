# 09 — MCP GitHub Configuration

Documents how the GitHub MCP server *would* be configured so that
`auto-issue-on-bug-detection` can create issues automatically on this repository.

**Status: not confirmed configured for this repo.** This file is a reference
procedure, not a statement that automatic issue creation is currently active here.
Confirm the config actually exists before relying on it.

## Configuration file

**Location**: `~/.claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

## GitHub token

**Generate at**: https://github.com/settings/tokens/new

**Required scopes**: `repo`, `issues`, `read:user`.

**Security**: token lives only in `claude_desktop_config.json`, never in this
repo; never commit it; never share it; revocable any time from GitHub settings;
each developer uses their own, and it is never sent to Anthropic.

## Usage flow once configured

1. Bug detected during development.
2. `auto-issue-on-bug-detection` reads the token, connects to
   `https://api.github.com`, and opens an issue on `hnidboubker/symphony-async`.
3. `issue-resolution` diagnoses, fixes, tests, stops at `READY_FOR_COMMIT`,
   referencing the issue (`Fixes #N`) in the prepared commit message.
4. Houssine reviews, then runs `git commit` / `git push` himself. GitHub closes
   the issue automatically when a commit containing `Fixes #N` is pushed.

## Troubleshooting

- **"Resource not accessible by personal access token"** — token is missing the
  `repo` scope.
- **"Bad credentials"** — token invalid or expired; regenerate.
- **Issue not created automatically** — check token presence/scopes, that Claude
  Code was restarted after config change, and that a real bug was detected.
