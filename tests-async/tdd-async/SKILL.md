---
name: tdd-async
description: Guides C#/.NET development through a strict Red-Green-Refactor TDD workflow using TUnit.
---

# tdd-async

## Workflow

```text
Requirement
    ↓
Understand behavior
    ↓
Write failing TUnit test
    ↓
RED
    ↓
Implement minimum production code
    ↓
GREEN
    ↓
REFACTOR
    ↓
Run tests
    ↓
GREEN
```

## STEP 1 — UNDERSTAND

Before modifying code:

1. Inspect the repository.
2. Identify the relevant project.
3. Identify the relevant test project.
4. Identify existing TUnit tests.
5. Understand project conventions.
6. Identify the behavior that must be implemented.

Do not immediately write production code.

## STEP 2 — RED

Write the smallest possible TUnit test expressing the desired behavior.

Example:

```csharp
[Test]
public async Task Add_WithTwoNumbers_ReturnsSum()
{
    var calculator = new Calculator();

    var result = calculator.Add(2, 3);

    await Assert.That(result).IsEqualTo(5);
}
```

TUnit assertions must be awaited.

Use:

```csharp
await Assert.That(actual).IsEqualTo(expected);
```

Do not use xUnit, NUnit, MSTest, or another assertion syntax.

## STEP 3 — RUN RED

Run the smallest relevant test scope.

Prefer:

```bash
dotnet test
```

when appropriate.

If the repository contains multiple test projects, identify the appropriate project first.

The expected state is:

RED

The test should fail because the behavior does not yet exist or is not yet correct.

Do not modify the test simply to make it pass.

## STEP 4 — GREEN

Implement the minimum production code required to make the failing test pass.

Do not:

- over-engineer;
- implement speculative features;
- modify unrelated code;
- introduce unnecessary abstractions.

Run the test again.

Expected:

GREEN

## STEP 5 — REFACTOR

Once the test passes:

1. inspect the implementation;
2. improve naming;
3. remove duplication;
4. simplify code;
5. improve structure when justified;
6. preserve behavior.

Run the tests again.

Expected:

GREEN

## TEST NAMING

Use descriptive test names.

Preferred:

```text
Method_WhenCondition_ExpectedResult
```

Example:

```csharp
[Test]
public async Task CalculateDiscount_WhenCustomerIsPremium_Returns20Percent()
{
    ...
}
```

Avoid:

```csharp
[Test]
public async Task Test1()
{
    ...
}
```

## TEST ISOLATION

Tests must be:

- independent;
- deterministic;
- isolated;
- repeatable.

Do not rely on:

- test execution order;
- shared mutable state;
- global state;
- previous tests;
- machine-specific state.

## ASYNC TESTS

Use async/await naturally.

Example:

```csharp
[Test]
public async Task GetUserAsync_WhenUserExists_ReturnsUser()
{
    var result = await service.GetUserAsync(userId);

    await Assert.That(result).IsNotNull();
}
```

Do not use `.Result` or `.Wait()` to hide asynchronous code.

## DATA-DRIVEN TESTS

When multiple inputs represent the same behavior, prefer TUnit data-driven capabilities when appropriate.

Inspect the existing project before choosing the appropriate TUnit mechanism.

Possible mechanisms include:

```csharp
[Arguments]
[Matrix]
[MethodDataSource]
```

Use the simplest appropriate option.

## REGRESSION TESTS

When fixing a bug:

1. reproduce the bug with a failing test;
2. verify RED;
3. implement the fix;
4. verify GREEN;
5. refactor if necessary.

Never fix a regression without adding or updating a test when a meaningful automated test is possible.

## SAFETY RULES

Never:

- delete tests to make the suite pass;
- weaken assertions to make tests pass;
- skip failing tests without justification;
- modify tests to match a broken implementation;
- remove coverage without explanation;
- introduce another testing framework;
- modify unrelated code.

## SYMPHONY INTEGRATION

`tdd-async` is an independent skill.

It must not directly invoke:

- `commit-async`;
- `bdd-async`;
- `auto-release`;
- `readme-async`;
- `symphony-async`.

`symphony-async` is responsible for orchestration.

When used by Symphony, return a clear result.

Success:

```text
TDD_PASSED
```

Failure:

```text
TDD_FAILED
```

Possible intermediate states:

```text
TDD_RED
TDD_GREEN
TDD_REFACTOR
TDD_COMPLETED
```

Include:

- test project;
- test command;
- number of tests;
- passed;
- failed;
- skipped;
- relevant failure information.

Never hide failures.

## IMPORTANT

The defining workflow is:

```text
RED
↓
GREEN
↓
REFACTOR
↓
GREEN
```

The defining rule is:

```text
TEST FIRST.
IMPLEMENT SECOND.
```

Use TUnit-native patterns and the conventions already present in the repository.