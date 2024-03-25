---
layout: post
title: "How to Test Logging Messages with FakeLogger"
tags: tutorial csharp
cover: Cover.png
cover-alt: "A pile of wood logs" 
---

Starting from .NET 8.0, we have a better alternative to test logging and logging messages. We don't need to roll our own mocks anymore. Let's learn how to use the new `FakeLogger<T>` inside our unit tests.

**.NET 8.0 added a FakeLogger, an in-memory logging provider for unit testing. It exposes methods and properties, like LatestRecord, to inspect the log entries recorded inside unit tests.**

Let's revisit our post about [unit testing logging messages]({% post_url 2022-12-04-TestingLoggingAndLogMessages %}). In that post, we used a `Mock<ILogger<T>>` to test we logged the exception message thrown inside a controller method. This was the controller we wanted to test,

```csharp
using Microsoft.AspNetCore.Mvc;

namespace FakeLogger.Controllers;

[ApiController]
[Route("[controller]")]
public class SomethingController : ControllerBase
{
    private readonly IClientService _clientService;
    private readonly ILogger<SomethingController> _logger;

    public SomethingController(IClientService clientService,
                               ILogger<SomethingController> logger)
    {
        _clientService = clientService;
        _logger = logger;
    }

    [HttpPost]
    public async Task<IActionResult> PostAsync(AnyPostRequest request)
    {
        try
        {
            // Imagine that this service does something interesting...
            await _clientService.DoSomethingAsync(request.ClientId);

            return Ok();
        }
        catch (Exception exception)
        {
            _logger.LogError(exception, "Something horribly wrong happened. ClientId: [{clientId}]", request.ClientId);
            //      ^^^^^^^^
            // Logging things like good citizens of the world...

            return BadRequest();
        }
    }
}

// Just for reference...Nothing fancy here
public interface IClientService
{
    Task DoSomethingAsync(int clientId);
}

public record AnyPostRequest(int ClientId);
```

<figure>
<img src="https://images.unsplash.com/photo-1624782460910-df75c1f7a0bc?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTcxMTA1MjUwMw&ixlib=rb-4.0.3&q=80&w=600" alt="A pile of cut wood logs">

<figcaption>Photo by <a href="https://unsplash.com/@jatin_graphix?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Jatin Jangid</a> on <a href="https://unsplash.com/photos/brown-and-gray-brick-wall-1f0DB1u7p8Q?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a></figcaption>
</figure>


## 1. Creating a FakeLogger

Let's test the `PostAsync()` method, but this time let's use the new `FakeLogger<T>` instead of a [mock with Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}).

To use the new `FakeLogger<T>`, let's install the NuGet package: `Microsoft.Extensions.Diagnostics.Testing` first.

Here's the test,

```csharp
using FakeLogger.Controllers;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Testing;
//    ^^^^^
using Moq;

namespace FakeLogger.Tests;

[TestClass]
public class SomethingControllerTests
{
    [TestMethod]
    public async Task PostAsync_Exception_LogsException()
    {
        var clientId = 123456;

        var fakeClientService = new Mock<IClientService>();
        fakeClientService
            .Setup(t => t.DoSomethingAsync(clientId))
            .ThrowsAsync(new Exception("Expected exception..."));
        //               ^^^^^
        // 3...2...1...Boom...

        // Look, ma! No mocks here...
        var fakeLogger = new FakeLogger<SomethingController>();
        //                   ^^^^^
        var controller = new SomethingController(
                                fakeClientService.Object,
                                fakeLogger);
                                // ^^^^^

        var request = new AnyPostRequest(clientId);
        await controller.PostAsync(request);

        // Warning!!!
        //var expected = $"Something horribly wrong happened. ClientId: [{clientId}]";
        //Assert.AreEqual(expected, fakeLogger.LatestRecord.Message);
        //       ^^^^^^^^
        // Do not expect exactly the same log message thrown from PostAsync()
        
        // Even better:
        fakeLogger.VerifyWasCalled(LogLevel.Error, clientId.ToString());
        //         ^^^^^
    }
}
```

We needed a `using` for `Microsoft.Extensions.Logging.Testing`. Yes, that's different from the NuGet package name.

We wrote `new FakeLogger<SomethingController>()` and passed it around. That's it.

## 2. Asserting on FakeLogger

`FakeLogger<T>` has a property `LatestRecord` with the last entry we logged. Its type is `FakeLogRecord` and contains a `Level`, `Message`, and `Exception`. And if there are no logs recorded, `LatestRecord` throws an `InvalidOperationException` with "No records logged" as the message.

But, for [the Assert part]({% post_url 2021-07-19-WriteBetterAssertions %}) of our test, we followed the lesson from our previous post on [testing logging messages]({% post_url 2022-12-04-TestingLoggingAndLogMessages %}): **do not expect exact matches of logging messages in assertions**. Otherwise, any change in the structure of our logging messages will make our test break, even when the business logic is still the same.

Instead of expecting exact matches of the logging messages, we wrote an extension method `VerifyWasCalled()`, receiving a log level and a substring. Here it is,

```csharp
public static void VerifyWasCalled<T>(this FakeLogger<T> fakeLogger, LogLevel logLevel, string message)
{
    var hasLogRecord = fakeLogger
        .Collector
        // ^^^^^
        .GetSnapshot()
        // ^^^^^
        .Any(log => log.Level == logLevel
                    && log.Message.Contains(message, StringComparison.OrdinalIgnoreCase));
                    // ^^^^^

    if (hasLogRecord)
    {
        return;
    }

    // Output:
    //
    // Expected log entry with level [Warning] and message containing 'Something else' not found.
    // Log entries found:
    // [15:49.229, error] Something horribly wrong happened. ClientId: [123456]
    var exceptionMessage = $"Expected log entry with level [{logLevel}] and message containing '{message}' not found."
        + Environment.NewLine
        + $"Log entries found:"
        + Environment.NewLine
        + string.Join(Environment.NewLine, fakeLogger.Collector.GetSnapshot().Select(l => l));

    throw new AssertFailedException(exceptionMessage);
}
```

First, we used `Collector` and `GetSnapshot()` to grab a reference to the collection of log entries recorded. Then, we checked we had a log entry with the expected log level and message. Next, we wrote a handy exception message showing the log entries recorded.

Voilà! That's how to write tests for logging messages using `FakeLogger<T>` instead of mocks.

If we only want to create a logger inside our tests without asserting anything on it, let's use `NullLogger<T>`. But, if we want to check we're logging exceptions, like good citizens of the world, let's use the new `FakeLogger<T>` and avoid tying our tests to details like the log count and the exact log messages. That makes our tests harder to maintain. In any case, we can roll mocks to test logging.

If you want to read more about unit testing, check [How to write tests for HttpClient using Moq]({% post_url 2022-12-01-TestingHttpClient %}), [how to test an ASP.NET Authorization Filter]({% post_url 2022-12-03-TestingAspNetAuthorizationFilters %}) and [how to write good unit tests: Use simple test values]({% post_url 2022-12-14-SimpleTestValues %}). Don't miss my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where we cover from what a unit test is, to fakes and mocks, to other best practices.

Happy testing!