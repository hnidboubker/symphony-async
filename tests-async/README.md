# tests-async

The TEST ORCHESTRATOR for the Symphony Async ecosystem.

## What it is

`tests-async` is the testing gateway that coordinates testing workflows. It does not implement TDD or BDD itself. Instead, it determines which testing strategy is appropriate and delegates to the specialized skills.

## Why it exists

Testing strategies (TDD vs BDD) serve different purposes:

| Strategy | Focus | When to use |
|----------|-------|-------------|
| **BDD** | Business behavior, user journeys, acceptance criteria | Features, domain rules, user-facing changes |
| **TDD** | Technical components, algorithms, refactoring, regressions | Implementation, bug fixes, internal logic |

`tests-async` makes this decision explicit and orchestrates the workflow.

## Architecture

```
                    symphony-async
                          │
                          ▼
                     tests-async
                     /         \
                    ▼           ▼
               tdd-async     bdd-async
                    \           /
                     \         /
                      ▼       ▼
                         TUnit
                           │
                      PASS / FAIL
                           │
                           ▼
                     symphony-async
```

## TDD vs BDD

### BDD (Behavior-Driven Development)

Use when the request involves:

- Business rules and acceptance criteria
- User journeys and scenarios
- Domain behavior visible to stakeholders
- "Given → When → Then" patterns

Delegates to: `bdd-async`

### TDD (Test-Driven Development)

Use when the request involves:

- Implementing a technical component
- Fixing a defect
- Algorithmic behavior
- Refactoring
- Regression testing
- Internal application logic

Delegates to: `tdd-async`

### Both Mode

When both are requested:

1. BDD defines the expected business behavior
2. TDD drives the implementation
3. TUnit validates both

## TUnit

All automated tests use TUnit exclusively.

- No xUnit, NUnit, MSTest, SpecFlow, or Cucumber unless the project already uses them
- Preferred command: `dotnet test`
- TUnit-native assertions: `await Assert.That(...)`

## Delegation

```
tests-async orchestrates:
├── Detect context (solution, projects, existing tests)
├── Select strategy (TDD / BDD / Both)
├── Delegate to specialized skill
│   ├── tdd-async → Red-Green-Refactor
│   └── bdd-async → Given-When-Then scenarios
├── Execute TUnit tests
├── Analyze results
└── Return PASS/FAIL to symphony-async
```

## Symphony Integration

`tests-async` is a quality gate in the Symphony pipeline:

```
commit
    ↓
tests-async
    ↓
PASS
    ↓
auto-release
```

### Contract States

| State | Meaning |
|-------|---------|
| `TESTS_NOT_REQUIRED` | No testing needed for this task |
| `TEST_STRATEGY_SELECTED` | TDD/BDD/Both chosen |
| `TDD_STARTED` | tdd-async invoked |
| `BDD_STARTED` | bdd-async invoked |
| `TESTS_RUNNING` | TUnit executing |
| `TESTS_PASSED` | All tests green |
| `TESTS_FAILED` | One or more tests red |
| `TESTS_BLOCKED` | No test project found |
| `ALLOW_RELEASE` | Gate passed |
| `STOP` | Gate failed |

### Success Example

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

### Failure Example

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

## No Test Manipulation

- Never delete failing tests
- Never weaken assertions to pass
- Never skip tests without justification
- Never hide failures
- Never modify tests to match broken implementation

A failing test is a signal that must be reported.

## Cascade Safety

No recursive workflows:

```
tests-async → symphony-async → tests-async  ❌ FORBIDDEN
```

`symphony-async` remains the top-level orchestrator. `tests-async` never invokes itself, `auto-release`, `commit-async`, or `readme-async`.