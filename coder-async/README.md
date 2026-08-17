# Coder Async

Production-quality asynchronous C#/.NET code skill.

## Purpose

Implement correct, idiomatic asynchronous C#/.NET code using modern async/await patterns, proper cancellation handling, concurrency control, and resource lifetime management.

## When to use

Use this skill when:
- Writing new asynchronous C#/.NET code
- Refactoring existing synchronous code to async
- Fixing async/await related bugs
- Adding cancellation support
- Implementing concurrent operations
- Working with I/O-bound operations (HTTP, database, filesystem, messaging)
- Implementing async streams (`IAsyncEnumerable<T>`)

## Core Principles

### Async/Await
- Use `async`/`await` for all I/O-bound operations
- Never block with `.Result`, `.Wait()`, or `.GetAwaiter().GetResult()`
- Propagate `CancellationToken` through the call chain

### Cancellation
- Accept `CancellationToken` in async methods that support cancellation
- Pass tokens to downstream async operations
- Check for cancellation at appropriate points
- Don't silently swallow `OperationCanceledException`

### Concurrency
- Only use concurrency when operations are genuinely independent
- Use `Task.WhenAll` for parallel independent operations
- Avoid `Task.Run` for I/O-bound work
- Consider `SemaphoreSlim` for limiting concurrency

### Resource Lifetime
- Use `await using` / `IAsyncDisposable` for async resources
- Dispose resources in the correct order
- Don't leak tasks or unobserved exceptions

### Modern C#
- Use `ValueTask` only when there's a measurable benefit
- Prefer `IAsyncEnumerable<T>` for streaming results
- Use pattern matching and modern language features

## Installation

### Via script (from cloned repo)

```bash
# From the skill source directory
./scripts/install.sh [target-project-path]

# Or on Windows PowerShell
.\scripts\install.ps1 [target-project-path]
```

All methods copy the skill to `<target-project>/.claude/skills/coder-async/`.

## Usage

The skill is invoked automatically by the symphony-async orchestrator when C#/.NET async code implementation is needed. It can also be invoked directly:

```bash
# From the skill directory
cat SKILL.md | claude-code
```

## Workflow

1. **Inspect** - Read existing code and understand architecture
2. **Design** - Plan async flow, cancellation, concurrency
3. **Implement** - Write minimal, correct async code
4. **Validate** - Compile, run tests, review async patterns
5. **Report** - Document what was implemented and key decisions

## Quality Gates

Before completing work, the skill verifies:
- No synchronous blocking on async operations
- Cancellation properly propagated
- No unnecessary `Task.Run` for I/O
- Concurrency is intentional and safe
- Resources correctly disposed
- Exceptions not accidentally swallowed
- Code follows project conventions

## Related Skills

- `refact-async` - Improves existing async code
- `tests-async` - Creates and runs async tests
- `tdd-async` - TDD for async code
- `bdd-async` - BDD for async behavior
- `test-fixer-async` - Fixes tests for async code