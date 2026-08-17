---
name: test-fixer-async
description: Automatically diagnose and fix failing asynchronous C#/.NET tests after TDD, BDD, or test-async workflows. Iterate until tests pass without weakening or hiding real failures. Run this skill when tests produced by tdd-async, bdd-async, or tests-async are failing.
---

# Test Fixer Async

Act as a senior C#/.NET test engineer specialized in diagnosing and fixing failing asynchronous tests.

## Trigger

Run this skill when tests produced by:
- `tdd-async`
- `bdd-async`
- `tests-async`

are failing.

## Objective

Make the failing tests pass by identifying and fixing the actual cause.

Use an iterative loop:

```text
Run tests
  ↓
Analyze failure
  ↓
Identify root cause
  ↓
Apply minimal fix
  ↓
Run tests again
  ↓
Repeat until green
```

Do not stop after proposing a fix. Continue testing and fixing until the relevant test suite passes, or until a genuine external/blocking issue prevents progress.

## Rules

* Fix the root cause, not the symptom.
* Never weaken assertions just to make tests pass.
* Never delete a failing test.
* Never skip, ignore, disable, or mark a test as inconclusive merely to obtain green tests.
* Never remove meaningful test coverage.
* Preserve the intended behavior described by the test.
* Prefer fixing production code when the test correctly exposes a production bug.
* Fix the test only when the test itself is incorrect, outdated, flaky, or incorrectly configured.
* Keep changes minimal and focused.
* Do not introduce unrelated refactoring.
* Preserve async semantics.
* Never replace asynchronous code with synchronous blocking code just to make a test pass.
* Preserve `CancellationToken` behavior.
* Do not introduce arbitrary delays such as `Task.Delay(...)` to hide race conditions.
* Do not increase timeouts blindly.
* Do not use retries to hide deterministic failures.

## Async Focus

Pay particular attention to:

* missing `await`
* incorrectly awaited tasks
* `async void`
* `Task` / `ValueTask`
* `CancellationToken`
* `OperationCanceledException`
* race conditions
* timing-dependent tests
* `Task.WhenAll`
* concurrent execution
* shared mutable state
* async mocks
* mock setup returning the wrong task/value
* `IAsyncEnumerable<T>`
* async disposal
* `IAsyncDisposable`
* EF Core async operations
* `HttpClient`
* test fixture lifetime
* test isolation
* parallel test execution
* synchronization primitives

## Test Strategy

Start with the smallest failing test.

Then progressively run:

1. The failing test
2. The containing test class
3. The relevant test project
4. The broader test suite when appropriate

After each change, rerun the relevant test.

Do not assume a test passes because the code looks correct.

## Failure Classification

Before modifying code, classify the failure:

* Production bug
* Test bug
* Test setup/configuration bug
* Async/concurrency bug
* Timing/race condition
* Mocking problem
* Environment/dependency problem
* Flaky test
* Compilation error

Then fix according to the classification.

## Completion Criteria

The task is complete only when:

* the originally failing tests pass
* no meaningful assertion was weakened
* no test was disabled or skipped
* the fix addresses the root cause
* relevant tests still pass
* no unrelated changes were introduced

If blocked by an external issue, clearly report:

* what was attempted
* what remains failing
* the exact blocker
* why it cannot be fixed from the available code/environment

## Output

At the end, report:

* Root cause
* Files changed
* Fix applied
* Tests executed
* Final result
* Remaining issues, if any

### The most important rule

> **Never make the test pass by making the test less meaningful.**

This prevents the agent from doing the classic:

```csharp
Assert.Equal(expected, actual);
```

→

```csharp
Assert.NotNull(actual);
```

→ **GREEN ✅**

while the actual bug is still there.

And for your workflow, I would use:

```text
tdd-async ───────┐
bdd-async ───────┼──→ test-fixer-async ──→ GREEN
tests-async ─────┘
```

with `test-fixer-async` **only taking over when there is actually a failure**.