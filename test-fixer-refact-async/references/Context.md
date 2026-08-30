# Async Context for Test Fixer Refact Async

This document contains detailed async/await patterns, common pitfalls, and debugging strategies for C#/.NET async tests.

## Common Async Pitfalls

### Blocking Async Code
```csharp
// BAD - Blocks thread pool thread
var result = Task.Run(() => DoWork()).Result;
var result = DoWorkAsync().GetAwaiter().GetResult();

// GOOD - Properly async
var result = await DoWorkAsync();
```

### Incorrect Cancellation Propagation
```csharp
// BAD - Ignores cancellation
public async Task DoWorkAsync() {
    await Task.Delay(1000); // No cancellation token
    await _service.ProcessAsync();
}

// GOOD - Propagates cancellation
public async Task DoWorkAsync(CancellationToken cancellationToken = default) {
    await Task.Delay(1000, cancellationToken);
    await _service.ProcessAsync(cancellationToken);
}
```

### Fire-and-Forget Operations
```csharp
// BAD - No error handling, no tracking
_ = DoWorkAsync();

// GOOD - Properly tracked
var task = DoWorkAsync();
_tasks.Add(task);
task.ContinueWith(t => _tasks.Remove(t));
```

### Unnecessary Task.Run
```csharp
// BAD - Wraps already async code
public async Task<int> GetValueAsync() {
    return await Task.Run(() => _repository.GetValueAsync());
}

// GOOD - Direct await
public async Task<int> GetValueAsync() {
    return await _repository.GetValueAsync();
}
```

## Concurrency Patterns

### Task.WhenAll - Parallel Independent Operations
```csharp
// GOOD - Truly independent operations
var results = await Task.WhenAll(
    _service.GetUsersAsync(),
    _service.GetOrdersAsync(),
    _service.GetProductsAsync()
);
```

### Task.WhenAll - Avoid for Dependent Operations
```csharp
// BAD - Sequential dependency hidden as parallel
var user = await _service.GetUserAsync(id);
var orders = await _service.GetOrdersAsync(user.Id); // Depends on user
// Don't use Task.WhenAll here!
```

### SemaphoreSlim for Controlled Concurrency
```csharp
private readonly SemaphoreSlim _semaphore = new(3);

public async Task ProcessItemsAsync(IEnumerable<Item> items) {
    var tasks = items.Select(async item => {
        await _semaphore.WaitAsync();
        try {
            await ProcessItemAsync(item);
        } finally {
            _semaphore.Release();
        }
    });
    await Task.WhenAll(tasks);
}
```

## Testing Async Code

### Async Test Methods
```csharp
// xUnit
[Fact]
public async Task ShouldProcessOrderAsync() {
    // Arrange
    var order = CreateOrder();
    
    // Act
    var result = await _processor.ProcessAsync(order);
    
    // Assert
    result.Should().BeSuccessful();
}
```

### Testing Cancellation
```csharp
[Fact]
public async Task ShouldCancelWhenTokenTriggered() {
    // Arrange
    using var cts = new CancellationTokenSource();
    cts.CancelAfter(TimeSpan.FromMilliseconds(50));
    
    // Act & Assert
    await Assert.ThrowsAsync<OperationCanceledException>(
        () => _service.LongRunningAsync(cts.Token)
    );
}
```

### Testing Exceptions
```csharp
[Fact]
public async Task ShouldThrowWhenInvalidInput() {
    // Act
    var act = () => _service.ProcessAsync(null);
    
    // Assert
    await act.Should().ThrowAsync<ArgumentNullException>();
}
```

### Mocking Async Methods (Moq)
```csharp
// BAD - Returns Task directly
_mock.Setup(x => x.GetAsync()).Returns(Task.FromResult(value));

// GOOD - Returns Task<T> properly
_mock.Setup(x => x.GetAsync()).ReturnsAsync(value);
_mock.Setup(x => x.GetAsync()).Returns(Task.FromResult(value));

// For async callbacks
_mock.Setup(x => x.ProcessAsync(It.IsAny<Data>()))
    .ReturnsAsync((Data d) => ProcessData(d));
```

## EF Core Async Patterns

### Proper Async Queries
```csharp
// GOOD - Fully async
var users = await _context.Users
    .Where(u => u.IsActive)
    .ToListAsync(cancellationToken);

// GOOD - Streaming for large results
await foreach (var user in _context.Users
    .Where(u => u.IsActive)
    .AsAsyncEnumerable()
    .WithCancellation(cancellationToken)) {
    // Process each user
}
```

### Avoiding Tracking Issues in Tests
```csharp
// In test setup - use NoTracking for read-only
var user = await _context.Users
    .AsNoTracking()
    .FirstAsync(u => u.Id == id);
```

## HttpClient Patterns

### Proper HttpClient Usage
```csharp
// GOOD - Single static HttpClient or IHttpClientFactory
private readonly HttpClient _httpClient;

public async Task<Result> CallApiAsync(Request request) {
    var response = await _httpClient.PostAsJsonAsync("/api/endpoint", request);
    response.EnsureSuccessStatusCode();
    return await response.Content.ReadFromJsonAsync<Result>();
}
```

### Testing with HttpClient
```csharp
// Use TestServer or MockHttpMessageHandler
var handler = new MockHttpMessageHandler();
handler.When(HttpMethod.Post, "/api/endpoint")
    .Respond("application/json", "{\"success\":true}");

var client = new HttpClient(handler);
```

## IAsyncEnumerable Patterns

### Producer
```csharp
public async IAsyncEnumerable<int> GenerateNumbersAsync(
    [EnumeratorCancellation] CancellationToken cancellationToken = default) {
    for (int i = 0; i < 100; i++) {
        cancellationToken.ThrowIfCancellationRequested();
        yield return i;
        await Task.Delay(10, cancellationToken);
    }
}
```

### Consumer
```csharp
await foreach (var number in GenerateNumbersAsync(cancellationToken)) {
    // Process
}
```

## IAsyncDisposable Patterns

### Implementation
```csharp
public class AsyncResource : IAsyncDisposable {
    private readonly HttpClient _client = new();
    
    public async ValueTask DisposeAsync() {
        await _client.DisposeAsync();
        // Other async cleanup
    }
}
```

### Usage
```csharp
await using var resource = new AsyncResource();
await resource.DoWorkAsync();
```

## Debugging Async Tests

### Common Failure Patterns

1. **Deadlock** - `.Result`/`.Wait()` on async code in sync context
2. **Race Condition** - Shared state accessed without synchronization
3. **Cancellation Not Propagated** - Token not passed through call chain
4. **Exception Swallowed** - Fire-and-forget without observation
5. **Resource Leak** - `IAsyncDisposable` not awaited
6. **Incorrect Mock Setup** - Async method returns wrong Task type

### Diagnostic Commands
```bash
# Run specific test with detailed output
dotnet test --filter "FullyQualifiedName~TestName" --logger "console;verbosity=detailed"

# Run with parallelization disabled for debugging
dotnet test --filter "FullyQualifiedName~TestName" --no-parallel

# Collect crash dumps on failure
dotnet test --collect:"XPlat Code Coverage"
```

## Refactoring Checklist for Async Code

- [ ] All async methods accept `CancellationToken`
- [ ] Cancellation tokens propagated through entire call chain
- [ ] No blocking calls (`.Result`, `.Wait()`, `.GetAwaiter().GetResult()`)
- [ ] No unnecessary `Task.Run` wrapping async code
- [ ] `Task.WhenAll` only for truly independent operations
- [ ] `IAsyncDisposable` properly implemented and awaited
- [ ] `IAsyncEnumerable` uses `[EnumeratorCancellation]`
- [ ] Exceptions properly handled and not swallowed
- [ ] No fire-and-forget without error handling
- [ ] SemaphoreSlim/Channels used for controlled concurrency
- [ ] EF Core queries use async variants (`ToListAsync`, etc.)
- [ ] HttpClient reused via `IHttpClientFactory` or static
- [ ] Tests verify async behavior (cancellation, exceptions, ordering)