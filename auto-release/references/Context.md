# auto-release Context

This skill is part of the Symphony Orchestrator orchestration pipeline. It is responsible for automated release management based on Conventional Commits.

## Architecture Position

```
symphony-orchestrator (orchestrator)
    │
    ├── commit-async
    │
    ├── tests-async
    │
    ├── auto-release ← THIS SKILL
    │
    └── readme-async
```

## Responsibilities

1. **Find latest release** - Locate the most recent semantic version tag
2. **Analyze commits** - Parse Conventional Commits since the last release
3. **Determine release level** - PATCH, MINOR, or MAJOR based on commit types
4. **Calculate next version** - Apply semantic versioning rules
5. **Generate/update CHANGELOG.md** - Create structured changelog entries
6. **Create Git tag** - Create annotated release tag locally
7. **Return results** - Machine-readable output for symphony-async

## Constraints

- No npm, Node.js, semantic-release, or external release frameworks
- Python 3 + Git only (standard library)
- No automatic tag pushing (orchestrator decides)
- No working tree modifications without explicit permission
- No direct invocation of other skills

## Integration Contract

**Input**: None (reads Git history directly)

**Output** (machine-readable):
- `NO_RELEASE` - No commits requiring release
- `RELEASE_PROPOSED` - Release determined but not created
- `RELEASE_CREATED` - Release tag and changelog created
- `RELEASE_BLOCKED` - Working tree has conflicts
- `RELEASE_FAILED` - Tag already exists or other error
- `CHANGELOG_UPDATED` - Changelog modified, needs commit
- `TAG_CREATED` - Tag created successfully

On success, also returns:
```
previous_version: vX.Y.Z
release_version: vX.Y.Z
release_level: patch|minor|major
tag: vX.Y.Z
changelog_updated: true|false
```

## File Structure

```
auto-release/
├── references/
│   └── Context.md          ← This file
├── scripts/
│   ├── install.sh          ← Bash installer
│   ├── install.ps1         ← PowerShell installer
│   └── release.py          ← Main release engine
├── SKILL.md                ← Skill definition
└── README.md               ← Documentation
```