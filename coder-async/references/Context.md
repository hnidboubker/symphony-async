# Coder Async - Context

## Role

`coder-async` is a specialized skill for implementing production-quality asynchronous C#/.NET code. It focuses exclusively on writing correct async/await patterns, cancellation handling, concurrency control, and resource lifetime management.

## Scope

### What coder-async does:
- Implements new asynchronous C#/.NET functionality
- Refactors synchronous code to async patterns
- Adds cancellation token support
- Implements concurrent operations with `Task.WhenAll`
- Creates async streams with `IAsyncEnumerable<T>`
- Handles external I/O (HTTP, database, filesystem, messaging)
- Ensures proper resource disposal with `IAsyncDisposable`

### What coder-async does NOT do:
- Does not orchestrate workflows (that's `symphony-async`)
- Does not write tests (that's `tests-async`, `tdd-async`, `bdd-async`)
- Does not fix tests (that's `test-fixer-async`)
- Does not perform general refactoring (that's `refact-async`)
- Does not handle commits, releases, or documentation

## Architecture Position

```
symphony-async (orchestrator)
    │
    ├── tests-async
    │     ├── tdd-async
    │     └── bdd-async
    │
    ├── coder-async  ← this skill
    │
    ├── refact-async
    │
    ├── commit-async
    │
    ├── auto-release
    │
    └── readme-async
```

## Contracts

### Input (from symphony-async or direct invocation):
- Task description requiring async C#/.NET implementation
- Existing codebase context
- Project conventions and patterns

### Output (to symphony-async):
- Implemented async code
- Report of:
  - What was implemented
  - Important async decisions made
  - Files changed
  - Tests/validation performed
  - Any remaining concerns

## Key Design Decisions

### Cancellation Token Propagation
All async methods that support cancellation must accept and propagate `CancellationToken`:
```csharp
public async Task<Result> ExecuteAsync(CancellationToken cancellationToken = default)
```

### Concurrency Safety
Only introduce concurrency when:
- Operations are independent
- Shared state is thread-safe
- Dependencies support concurrent access
- Failure behavior remains correct

### Resource Management
- Use `await using` for `IAsyncDisposable` resources
- Dispose in reverse order of acquisition
- Never leak unobserved tasks

### Modern .NET Patterns
- Target framework determines available features
- `ValueTask` only when allocation avoidance is measurable
- `IAsyncEnumerable<T>` for streaming scenarios
- Pattern matching for result handling

## Integration with Symphony

When `symphony-async` detects C#/.NET implementation work:
1. It invokes `coder-async` for the implementation
2. Then `tests-async` for test generation/execution
3. Then `commit-async`, `auto-release`, `readme-async` as per normal flow

## Quality Gates

Before reporting completion, `coder-async` verifies:
- [ ] No `.Result`, `.Wait()`, `.GetAwaiter().GetResult()` blocking
- [ ] No `Task.Run` for I/O-bound operations
- [ ] CancellationToken properly propagated
- [ ] Concurrency intentional and safe
- [ ] Resources correctly disposed (`await using`)
- [ ] No unobserved exceptions
- [ ] Code follows project conventions
- [ ] Implementation is minimal

## Error Handling

- Preserve exception semantics (don't wrap unnecessarily)
- Don't swallow `OperationCanceledException`
- Let exceptions propagate naturally unless explicit handling is required
- Use `try`/`finally` for cleanup, not `catch`/`throw`

## Project Conventions to Follow

- Target framework version
- Naming conventions (Async suffix for async methods)
- Error handling patterns
- Logging patterns
- Dependency injection patterns
- Configuration patterns

## Related Documentation

- [SKILL.md](../SKILL.md) - Main skill definition
- [README.md](../README.md) - Usage documentation
- [scripts/install.sh](../scripts/install.sh) - Installation script