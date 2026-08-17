---
name: bdd-async
description: Transforms business requirements into behavior-driven TUnit tests using Given-When-Then scenarios for C#/.NET projects.
---

# bdd-async

Behavior-Driven Development skill for TUnit. Describes observable business behavior using Given → When → Then. TUnit is the testing framework.

## Workflow

```
Business Requirement
    ↓
Identify Business Behavior
    ↓
Given → When → Then
    ↓
Write TUnit Test
    ↓
Run Test → Implement / Fix → Run Test → PASS
```

## Step 1 — Understand the Business Requirement

Before writing code:

1. Read the requirement.
2. Identify the actor.
3. Identify the initial context.
4. Identify the business action.
5. Identify the expected result.
6. Identify important business rules.
7. Identify relevant edge cases.
8. Inspect existing tests and domain language.

Translate the requirement into a scenario.

**Example:**

```gherkin
Feature: Customer discount

Scenario: Premium customer receives a discount

Given the customer is premium
When the customer purchases an item
Then a 20% discount is applied
```

## Step 2 — Create the TUnit Test

Represent the scenario as a readable TUnit test.

```csharp
[Test]
public async Task PremiumCustomer_WhenPurchasingItem_Receives20PercentDiscount()
{
    // Given
    var customer = Customer.CreatePremium();
    var product = new Product(100m);

    // When
    var total = pricingService.CalculateTotal(customer, product);

    // Then
    await Assert.That(total).IsEqualTo(80m);
}
```

Clearly expose Given / When / Then. Use comments when they improve readability — but not mechanically when code is already self-explanatory.

## Business Language

BDD tests must use domain/business language.

**Preferred:**
`PremiumCustomer_WhenPurchasingItem_Receives20PercentDiscount`

**Avoid:**
`CalculateTotal_Returns80`

Tests describe behavior, not implementation details.

## Given

Establishes the initial context: customer state, user state, permissions, account state, database state, configuration, domain objects, external service state. Keep minimal and relevant.

## When

The primary business action. Prefer one action per scenario. Avoid combining unrelated actions.

```csharp
var result = await checkoutService.CheckoutAsync(customer, product);
```

## Then

Verifies observable business outcomes. TUnit assertions must be awaited.

```csharp
await Assert.That(result.Total).IsEqualTo(80m);
await Assert.That(result.Discount).IsEqualTo(20m);
```

## Scenario Coverage

For important business behavior, consider: happy path, validation failures, authorization failures, boundary conditions, business rule violations, important exceptional behavior. Focus on meaningful business behavior — do not generate meaningless combinations.

## Unit vs Integration

BDD does not automatically mean end-to-end. Choose the smallest appropriate test level.

| Level | Pattern |
|-------|---------|
| Domain behavior | TUnit unit test |
| Application behavior | TUnit integration test |
| API behavior | TUnit API/integration test |
| Critical user journey | TUnit end-to-end test |

Inspect the project before choosing.

## TUnit

Use TUnit-native functionality only.

- Use `[Test]`
- Use `await Assert.That(...)`
- Do not assume xUnit or NUnit APIs
- Do not introduce another BDD framework
- Do not use `.Result` or `.Wait()` to hide async behavior

## Async

Use async/await naturally.

```csharp
[Test]
public async Task RegisteredUser_WhenLoggingInWithValidCredentials_IsAuthenticated()
{
    // Given
    var user = await userRepository.CreateAsync(...);

    // When
    var result = await authenticationService.LoginAsync(...);

    // Then
    await Assert.That(result.IsAuthenticated).IsTrue();
}
```

## Test Naming

Use names that resemble business scenarios.

```
RegisteredUser_WhenLoggingInWithValidCredentials_IsAuthenticated
AnonymousUser_WhenAccessingPrivateResource_IsRejected
ExpiredSubscription_WhenAccessingPremiumFeature_IsDenied
```

Avoid: `TestLogin`, `Test1`, `ShouldReturnTrue`

## Observable Behavior

Do not couple BDD tests unnecessarily to: private methods, internal implementation, exact database queries, internal variable names, implementation-specific algorithms. Test observable behavior only.

## Scenario Independence

Each scenario must be independent and deterministic. Do not depend on: execution order, shared mutable state, previous scenarios, machine-specific state, external state unless explicitly controlled.

## Symphony Integration

`bdd-async` is an independent skill. It must not directly invoke: `commit-async`, `tdd-async`, `auto-release`, `readme-async`, `symphony-orchestrator`. `symphony-orchestrator` controls the orchestration.

When used by Symphony, return:

```
BDD_PASSED
```

or:

```
BDD_FAILED
```

Possible intermediate states:
- `BDD_SCENARIO_IDENTIFIED`
- `BDD_TEST_CREATED`
- `BDD_TEST_FAILED`
- `BDD_TEST_PASSED`
- `BDD_COMPLETED`

Include: test project, scenario, test command, number of tests, passed, failed, skipped, relevant failure information. Never hide failures.

## Safety Rules

Never: delete tests because they fail, weaken assertions, hide failures, skip tests without justification, test private implementation details unnecessarily, introduce another test framework, modify unrelated code.

## Core Principle

TEST BUSINESS BEHAVIOR, NOT IMPLEMENTATION.

Use: Given → When → Then. TUnit is the testing framework. Keep this skill independent from `tdd-async`.