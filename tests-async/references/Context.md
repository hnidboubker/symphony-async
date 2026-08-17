# tests-async Context

## Role

`tests-async` is the **test orchestrator** for the Symphony Async ecosystem. It sits between `symphony-orchestrator` (top-level orchestrator) and the specialized testing skills (`tdd-async`, `bdd-async`).

```
symphony-orchestrator
      ↓
tests-async     ← ORCHESTRATOR
      ↓
tdd-async / bdd-async  ← SPECIALIZED SKILLS
      ↓
TUnit                ← TEST FRAMEWORK
```

It does **not** implement TDD or BDD. It:
1. Inspects the project
2. Detects the testing context
3. Determines the strategy (TDD / BDD / Both)
4. Invokes the appropriate specialized skill
5. Executes TUnit tests
6. Validates results
7. Returns PASS/FAIL to `symphony-orchestrator`

## Relationship with tdd-async

- `tdd-async` implements **strict Red-Green-Refactor** TDD
- Uses TUnit with `await Assert.That(...)`
- Returns: `TDD_PASSED` / `TDD_FAILED`
- `tests-async` delegates to it when:
  - User explicitly says "TDD"
  - Task is technical implementation, bug fix, algorithm, refactoring, regression
  - Unit-level behavior needs coverage

## Relationship with bdd-async

- `bdd-async` implements **Given-When-Then** BDD
- Translates business requirements into TUnit tests
- Uses domain/business language in test names
- Returns: `BDD_PASSED` / `BDD_FAILED`
- `tests-async` delegates to it when:
  - User explicitly says "BDD"
  - Task involves business behavior, user journeys, acceptance criteria
  - Domain scenarios need validation

## Relationship with TUnit

- **Only** TUnit is used for automated tests
- No xUnit, NUnit, MSTest, SpecFlow, Cucumber
- Preferred command: `dotnet test`
- Test discovery: inspect `*.sln`, `*.slnx`, `*.csproj` for TUnit projects
- Do not assume test project naming conventions

## Relationship with test-fixer-async

- `test-fixer-async` automatically diagnoses and fixes failing async C#/.NET tests
- Uses iterative loop: Run tests → Analyze failure → Identify root cause → Apply minimal fix → Run tests again
- Returns: `TEST_FIXER_STARTED` / `TEST_FIXER_COMPLETED` / `TESTS_FAILED` (if unfixable)
- `tests-async` delegates to it when:
  - Tests fail after `tdd-async`, `bdd-async`, or `tests-async` execution
  - Need to fix root cause without weakening assertions or hiding failures

## Strategy Selection

### Prefer BDD When
- Business behavior
- User behavior
- Business rules
- Acceptance criteria
- User journeys
- Domain scenarios
- Externally observable behavior

### Prefer TDD When
- Implementing a technical component
- Fixing a technical defect
- Algorithmic behavior
- Refactoring
- Internal application logic
- Unit-level behavior
- Regression testing

### Explicit User Intent (Priority)
- "TDD" → use `tdd-async`
- "BDD" → use `bdd-async`
- Never override explicit choice unless impossible

### Ambiguous Cases
Inspect:
1. Task description
2. Existing tests
3. Project architecture
4. Existing testing conventions
5. Business acceptance criteria

If still ambiguous, **ask the user**:
> Which testing strategy should be used?
> 1. TDD
> 2. BDD
> 3. Both

### Both Mode
Order:
1. BDD scenario (business behavior)
2. TDD implementation (technical coverage)
3. TUnit validation

No meaningless duplication. BDD = business behavior. TDD = implementation coverage.

## Test Execution

After delegation, run tests and capture:
- Total tests
- Passed
- Failed
- Skipped
- Duration
- Failure messages
- Test project

**Never hide failures.**

## Failure Handling

Return `TESTS_FAILED` with:
- Testing mode
- Failing project
- Failing tests
- Error information

**STOP** the Symphony pipeline. Do not continue to release.

## Success Handling

Return `TESTS_PASSED` with:
- Testing mode
- Test project
- Test count
- Passed count
- Skipped count
- Command used

## Symphony Contract States

| State | Description |
|-------|-------------|
| `TESTS_NOT_REQUIRED` | No automated testing needed |
| `TEST_STRATEGY_SELECTED` | TDD/BDD/Both chosen |
| `TDD_STARTED` | tdd-async invoked |
| `BDD_STARTED` | bdd-async invoked |
| `TESTS_RUNNING` | TUnit executing |
| `TESTS_PASSED` | All tests green |
| `TESTS_FAILED` | One or more tests red |
| `TESTS_BLOCKED` | No suitable TUnit project |
| `ALLOW_RELEASE` | Quality gate passed |
| `STOP` | Quality gate failed |

### Success Output
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

### Failure Output
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

If no automated tests exist and task requires testing:
- Return `TESTS_BLOCKED`
- Explain no suitable TUnit project found

If task genuinely requires no testing:
- Return `TESTS_NOT_REQUIRED` with explanation

## Test Isolation

- Deterministic and isolated
- No test execution order dependency
- No shared mutable state
- No global state
- No test-to-test dependency
- No machine-specific state

## No Test Manipulation

Never:
- Delete failing tests
- Weaken assertions
- Skip tests without justification
- Modify tests to match broken implementation
- Hide failures
- Disable test projects
- Remove coverage without explanation

## Symphony Integration

### Must NOT Invoke
- `symphony-orchestrator`
- `commit-async`
- `auto-release`
- `readme-async`

### May Delegate To
- `tdd-async`
- `bdd-async`

### Orchestrator Hierarchy
```
symphony-orchestrator (top)
      ↓
tests-async (test gate)
      ↓
tdd-async / bdd-async (specialized)
      ↓
TUnit (framework)
```

## Release Gate

Pipeline:
```
commit
    ↓
tests-async
    ↓
PASS
    ↓
auto-release
```

If `TESTS_FAILED` → `STOP` (block `auto-release`)
If `TESTS_PASSED` → `ALLOW_RELEASE`

## Cascade Safety

**Forbidden:**
```
tests-async → symphony-orchestrator → tests-async → ...
```

- Never invoke itself
- Never invoke `auto-release` directly
- Never invoke `readme-async` directly
- Top-level orchestration = `symphony-orchestrator`

## Constraints

Do not introduce:
- npm / Node.js
- semantic-release
- SpecFlow / Cucumber
- xUnit / NUnit / MSTest

Unless project explicitly requires them.

Do not:
- Modify unrelated skills
- Bypass specialized skills
- Implement TDD/BDD logic in tests-async
- Create recursive execution
- Auto-commit / auto-push / auto-release