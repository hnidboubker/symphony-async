# test-fixer-refact-async

Fix failing C#/.NET async tests and refactor the affected code when necessary. Trigger after TDD, BDD, test-async, or refact-async when tests are failing.

## Quick Start

```bash
# Run installer to verify prerequisites
python scripts/install.py
# or
./scripts/install.sh
# or
.\scripts\install.ps1
```

## Prerequisites

- Git
- .NET SDK 8.0+
- A test project with: xUnit / NUnit / MSTest / TUnit + FluentAssertions + Moq

## Workflow

The skill implements an autonomous loop:

```
FAIL
 ↓
diagnose
 ↓
fix
 ↓
refactor if needed
 ↓
test
 ↓
FAIL ─────────┐
 ↓            │
diagnose ←────┘
 ↓
PASS
 ↓
DONE
```

## Key Principles

1. **Never just make the test pass** — Find the root cause
2. **Preserve async behavior** — No `.Result`, `.Wait()`, `Task.WaitAll()`
3. **No arbitrary `Task.Delay`** to hide synchronization problems
4. **Test integrity** — Never delete, skip, disable, or weaken tests
5. **Refactor when it helps** — Duplicated logic, complex async methods, hidden dependencies

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill definition and workflow |
| `Context.md` | Detailed async patterns, pitfalls, debugging |
| `scripts/install.py` | Cross-platform installer (Python) |
| `scripts/install.sh` | Unix/Linux/macOS installer |
| `scripts/install.ps1` | Windows PowerShell installer |

## Running Tests

```bash
# Run specific failing test
dotnet test --filter "FullyQualifiedName~TestName" --logger "console;verbosity=detailed"

# Run with no parallelization for debugging
dotnet test --filter "FullyQualifiedName~TestName" --no-parallel

# Run all tests
dotnet test
```

## Common Fixes

- **Blocking calls** → Replace `.Result`/`.Wait()` with `await`
- **Missing cancellation** → Add `CancellationToken` parameters and propagate
- **Fire-and-forget** → Track tasks or use proper async patterns
- **Wrong mock setup** → Use `ReturnsAsync()` for async methods
- **Race conditions** → Use `SemaphoreSlim`, `Channels`, or proper synchronization

## Definition of Done

- Original failing tests pass
- Related tests pass
- Root cause addressed
- Test intent preserved
- Async behavior correct
- No tests weakened or disabled
- No regressions introduced