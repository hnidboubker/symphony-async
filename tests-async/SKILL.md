---
name: tests-async
description: Orchestrates TDD and BDD testing workflows using TUnit and coordinates test validation for Symphony Async.
---

# tests-async

**tests-async** is the TEST ORCHESTRATOR of the Symphony Async ecosystem.

It does not implement TDD or BDD itself.

Its responsibility is to determine which testing workflow should be used, orchestrate the appropriate specialized skill, execute the required test validation, and return a clear result to `symphony-async`.

## Architecture

```
                    symphony-async
                          │
                          ▼
                     tests-async
                          │
                 ┌────────┴────────┐
                 │                 │
                 ▼                 ▼
             tdd-async         bdd-async
                 │                 │
                 └────────┬────────┘
                          ▼
                        TUnit
                          │
                    PASS / FAIL
                          │
                          ▼
                    symphony-async
```

## Core Responsibility

The workflow is:

```
Detect testing context
        ↓
Choose testing strategy
        ↓
Invoke specialized skill
        ↓
Run TUnit tests
        ↓
Analyze result
        ↓
Return PASS / FAIL
```

## Testing Strategy

The skill must determine whether the task is better suited for TDD or BDD.

**Prefer BDD** when the request is primarily about:

- business behavior;
- user behavior;
- business rules;
- acceptance criteria;
- user journeys;
- domain scenarios;
- externally observable behavior.

**Prefer TDD** when the request is primarily about:

- implementing a technical component;
- fixing a technical defect;
- algorithmic behavior;
- refactoring;
- internal application logic;
- unit-level behavior;
- regression testing.

## Explicit User Intent

Explicit user intent always has priority.

If the user explicitly says:

> "TDD"

use:

`tdd-async`

If the user explicitly says:

> "BDD"

use:

`bdd-async`

Do not override an explicit user choice unless the requested workflow is impossible.

## Ambiguous Cases

If the intent is ambiguous, inspect:

1. task description;
2. existing tests;
3. project architecture;
4. existing testing conventions;
5. presence of business acceptance criteria.

If the correct strategy cannot be determined confidently, ask the user:

> Which testing strategy should be used?

Options:

1. TDD
2. BDD
3. Both

Do not silently choose a strategy when the distinction materially affects the work.

## Both Mode

If the user requests both:

```
BDD
    ↓
TDD
    ↓
TUnit
```

Use BDD to define the expected business behavior.

Then use TDD to drive the implementation of the behavior.

The preferred order is:

1. BDD scenario;
2. TDD implementation;
3. TUnit validation.

Do not duplicate meaningless tests.

The BDD test should represent the business behavior.

The TDD tests should provide the appropriate lower-level implementation coverage.

## Delegation

Do not recreate the logic of `tdd-async`, `bdd-async`, or `test-fixer-async`.

When TDD is selected:

Invoke:

`tdd-async`

When BDD is selected:

Invoke:

`bdd-async`

When tests fail after `tdd-async`, `bdd-async`, or `tests-async`:

Invoke:

`test-fixer-async`

The specialized skill owns its own workflow.

`tests-async` owns orchestration and validation.

## TUnit

All automated tests must use TUnit.

Do not introduce:

- xUnit;
- NUnit;
- MSTest;
- SpecFlow;
- Cucumber;

unless the existing project explicitly requires them.

Use the existing project's TUnit conventions.

The preferred command is:

```bash
dotnet test
```

When multiple test projects exist:

1. identify the relevant project;
2. run the smallest relevant test scope;
3. run the complete relevant test suite when appropriate.

## Test Discovery

Inspect the repository before running tests.

Look for:

- `*.sln`
- `*.slnx`
- `*.csproj`

and test projects.

Identify projects using TUnit.

Do not assume that the test project is named:

`*.Tests`

It may use another naming convention.

## Test Execution

Run the appropriate tests after the delegated skill completes.

Capture:

- total tests;
- passed;
- failed;
- skipped;
- duration when available;
- failure messages;
- test project.

Do not hide test failures.

## Failure Handling

If tests fail:

Return:

```
TESTS_FAILED
```

Include:

- testing mode;
- failing project;
- failing tests;
- relevant error information.

Invoke `test-fixer-async` to attempt automatic diagnosis and repair.

If `test-fixer-async` succeeds:
- Return `TESTS_PASSED` with fix details.

If `test-fixer-async` cannot resolve:
- Return `TESTS_FAILED` with blocker details.
- Do not continue to release.
- The Symphony pipeline must stop.

## Success Handling

If all required tests pass:

Return:

```
TESTS_PASSED
```

Include:

- testing mode;
- test project;
- test count;
- passed count;
- skipped count;
- command used.

## Symphony Contract

`tests-async` must communicate a clear contract to `symphony-async`.

Possible states:

- `TESTS_NOT_REQUIRED`
- `TEST_STRATEGY_SELECTED`
- `TDD_STARTED`
- `BDD_STARTED`
- `TESTS_RUNNING`
- `TESTS_PASSED`
- `TESTS_FAILED`
- `TESTS_BLOCKED`
- `TEST_FIXER_STARTED`
- `TEST_FIXER_COMPLETED`

Example:

```
TESTS_PASSED

mode: TDD
framework: TUnit
project: MyProject.Tests
total: 42
passed: 42
failed: 0
skipped: 0
```

Another example:

```
TESTS_FAILED

mode: BDD
framework: TUnit
project: MyProject.AcceptanceTests
total: 18
passed: 17
failed: 1
skipped: 0
```

## No Tests

If the repository has no automated tests and the task requires testing:

Do not silently declare success.

Return:

```
TESTS_BLOCKED
```

Explain that no suitable TUnit test project was found.

If the task genuinely does not require automated testing, return:

```
TESTS_NOT_REQUIRED
```

with an explanation.

## Test Isolation

Tests should be deterministic and isolated.

Do not modify test execution settings merely to hide failures.

Do not disable tests to achieve a green build.

## No Test Manipulation

Never:

- delete failing tests;
- weaken assertions;
- skip tests without justification;
- modify tests solely to make them pass;
- hide test failures;
- disable test projects;
- remove coverage without explanation.

A failing test is a signal that must be reported.

## Symphony Integration

`tests-async` must NOT invoke:

- `symphony-async`;
- `commit-async`;
- `auto-release`;
- `readme-async`.

It may delegate to:

- `tdd-async`;
- `bdd-async`.

The orchestrator hierarchy is:

```
symphony-async
        ↓
tests-async
        ↓
tdd-async / bdd-async
        ↓
TUnit
```

`symphony-async` remains the top-level orchestrator.

## Release Gate

`tests-async` acts as a quality gate.

The release pipeline must follow:

```
commit
    ↓
tests-async
    ↓
PASS
    ↓
auto-release
```

If:

```
TESTS_FAILED
```

then:

```
STOP
```

Do not allow `auto-release` to execute.

If:

```
TESTS_PASSED
```

then:

```
ALLOW_RELEASE
```

Return the result to `symphony-async`.

## Cascade Safety

Do not create recursive workflows.

Never do:

```
tests-async
    ↓
symphony-async
    ↓
tests-async
    ↓
...
```

Never invoke itself.

Never invoke `auto-release` directly.

Never invoke `readme-async` directly.

The top-level orchestration remains the responsibility of `symphony-async`.

## Important Constraints

Do not introduce:

- npm
- Node.js
- semantic-release
- SpecFlow
- Cucumber
- xUnit
- NUnit
- MSTest

unless the existing project explicitly requires them.

Do not modify unrelated skills.

Do not bypass TDD or BDD specialized skills.

Do not implement TDD or BDD logic inside tests-async.

Do not create recursive skill execution.

Do not automatically commit.

Do not automatically push.

Do not automatically release.

The role of this skill is orchestration and validation.