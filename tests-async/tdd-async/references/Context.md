# TUnit Reference

This document provides reference information for TUnit, the testing framework used by `tdd-async`.

## Installation

Add TUnit to your test project:

```bash
dotnet add package TUnit
```

## Basic Test Structure

```csharp
using TUnit.Assertions;
using TUnit.Assertions.Extensions;

[Test]
public async Task MethodName_WhenCondition_ExpectedResult()
{
    // Arrange
    var sut = new SystemUnderTest();

    // Act
    var result = await sut.MethodAsync();

    // Assert
    await Assert.That(result).IsNotNull();
}
```

## Assertions

All assertions in TUnit are awaited:

```csharp
// Equality
await Assert.That(actual).IsEqualTo(expected);
await Assert.That(actual).IsNotEqualTo(expected);

// Null checks
await Assert.That(actual).IsNull();
await Assert.That(actual).IsNotNull();

// Boolean
await Assert.That(actual).IsTrue();
await Assert.That(actual).IsFalse();

// Collections
await Assert.That(collection).HasCount(expectedCount);
await Assert.That(collection).Contains(expectedItem);
await Assert.That(collection).DoesNotContain(unexpectedItem);

// Strings
await Assert.That(actual).IsEqualTo(expected);
await Assert.That(actual).Contains(expectedSubstring);
await Assert.That(actual).StartsWith(expectedPrefix);
await Assert.That(actual).EndsWith(expectedSuffix);

// Exceptions
await Assert.That(async () => await sut.MethodAsync())
    .ThrowsAsync<ExpectedExceptionType>();

// Async
await Assert.That(task).CompletesWithin(TimeSpan.FromSeconds(5));
```

## Test Attributes

```csharp
[Test]                    // Basic test
[Test]                    // Async test (method returns Task)
[Arguments]               // Data-driven test with inline arguments
[Matrix]                  // Combinatorial test data
[MethodDataSource]        // Data from a method
```

## Data-Driven Tests

### Arguments

```csharp
[Test]
[Arguments(1, 2, 3)]
[Arguments(5, 5, 10)]
public async Task Add_WithNumbers_ReturnsSum(int a, int b, int expected)
{
    var calculator = new Calculator();
    var result = calculator.Add(a, b);
    await Assert.That(result).IsEqualTo(expected);
}
```

### Matrix

```csharp
[Test]
[Matrix(new[] { 1, 2 }, new[] { 10, 20 })]
public async Task Multiply_WithNumbers_ReturnsProduct(int a, int b)
{
    var calculator = new Calculator();
    var result = calculator.Multiply(a, b);
    await Assert.That(result).IsEqualTo(a * b);
}
```

### MethodDataSource

```csharp
[Test]
[MethodDataSource(nameof(GetTestData))]
public async Task ComplexOperation_WithData_ReturnsExpected(string input, int expected)
{
    var service = new ComplexService();
    var result = await service.ProcessAsync(input);
    await Assert.That(result).IsEqualTo(expected);
}

public static IEnumerable<object[]> GetTestData()
{
    yield return new object[] { "input1", 10 };
    yield return new object[] { "input2", 20 };
}
```

## Test Lifecycle

```csharp
public class MyTests
{
    // Runs before each test
    public MyTests()
    {
        // Setup
    }

    // Runs after each test (implement IAsyncDisposable)
    public async ValueTask DisposeAsync()
    {
        // Cleanup
    }
}
```

## Running Tests

```bash
# Run all tests
dotnet test

# Run specific test project
dotnet test path/to/testproject.csproj

# Run tests with filter
dotnet test --filter "FullyQualifiedName~MyTests"

# Run with verbosity
dotnet test --verbosity normal

# Run in specific configuration
dotnet test --configuration Release
```

## Best Practices

1. **Test Naming**: Use `Method_WhenCondition_ExpectedResult` format
2. **Async/Await**: Always use async/await naturally, never `.Result` or `.Wait()`
3. **Isolation**: Tests must be independent and deterministic
4. **Minimal Implementation**: In GREEN phase, implement only what makes the test pass
5. **Refactor**: After GREEN, improve code while keeping tests passing

## Common Patterns

### Testing Async Methods

```csharp
[Test]
public async Task GetDataAsync_WhenCalled_ReturnsData()
{
    var service = new DataService();
    var result = await service.GetDataAsync();
    await Assert.That(result).IsNotNull();
}
```

### Testing Exceptions

```csharp
[Test]
public async Task Divide_ByZero_ThrowsDivideByZeroException()
{
    var calculator = new Calculator();
    await Assert.That(async () => calculator.Divide(10, 0))
        .ThrowsAsync<DivideByZeroException>();
}
```

### Testing Collections

```csharp
[Test]
public async Task GetItems_ReturnsAllItems()
{
    var service = new ItemService();
    var items = await service.GetItemsAsync();
    
    await Assert.That(items).HasCount(3);
    await Assert.That(items).Contains(item1);
    await Assert.That(items).Contains(item2);
}
```

## Integration with TDD Workflow

This reference supports the `tdd-async` skill workflow:

1. **RED**: Write failing test using patterns above
2. **GREEN**: Implement minimum code to pass
3. **REFACTOR**: Improve using these patterns as guide

See `SKILL.md` for the complete workflow.