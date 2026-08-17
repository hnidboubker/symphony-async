# BDD Context

## Project Scripts

For the `symphony-orchestrator` project, use the scripts from `tdd-async/scripts/` to bootstrap the test environment.

## TUnit

TUnit is the testing and assertion framework.

- Use `[Test]` attribute
- Use `await Assert.That(actual).IsEqualTo(expected)`
- Do not assume xUnit or NUnit APIs

## Test Organization

BDD tests use business behavior naming:

```csharp
[Test]
public async Task GivenX_WhenY_ThenZ()
{
    // Given
    // When
    // Then
}
```

## Symphony States

| State | Meaning |
|-------|---------|
| `BDD_SCENARIO_IDENTIFIED` | Scenario has been identified |
| `BDD_TEST_CREATED` | Test has been created |
| `BDD_TEST_FAILED` | Test fails before implementation |
| `BDD_TEST_PASSED` | Test passes |
| `BDD_COMPLETED` | BDD cycle complete |