---
layout: post
title: "On Unit Testing Logging Messages"
tags: tutorial csharp
cover: Cover.png
cover-alt: "A pile of wooden logs"
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

These days I had to review some code that expected a controller to log the exceptions thrown in a service. This is how that controller looked and what I learned about testing logging messages.

**When writing unit tests for logging, assert that actual log messages contain keywords like identifiers or requested values. Don't assert that actual and expected log messages are exactly the same.** 

## Don't expect identical log messages 

The controller I reviewed looked like this,

```csharp
using Microsoft.AspNetCore.Mvc;
using OnTestingLogMessages.Services;

namespace OnTestingLogMessages.Controllers;

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

    // Other methods here...
}
```

Nothing fancy. It called an `IClientService` service and logged the exception thrown by it. Let's imagine that the controller logged a more helpful message to troubleshoot later. I wrote a funny log message here. Yes, exception filters are a better idea, but bear with me.

To test if the controller logs exceptions, we could write a unit test like this,

```csharp
using Microsoft.Extensions.Logging;
using Moq;
using OnTestingLogMessages.Controllers;
using OnTestingLogMessages.Services;

namespace OnTestingLogMessages.Tests;

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
            //           ^^^^^
            // 3...2...1...Boom...
        var fakeLogger = new Mock<ILogger<SomethingController>>();
        var controller = new SomethingController(fakeClientService.Object, fakeLogger.Object);
        //                                       ^^^^^

        var request = new AnyPostRequest(clientId);
        await controller.PostAsync(request);

        var expected = $"Something horribly wrong happened. ClientId: [{clientId}]";
        //  ^^^^^^^^
        // We expect exactly the same log message from the PostAsync
        fakeLogger.VerifyWasCalled(LogLevel.Error, expected);
    }
}
```

In that test, we used [Moq to create fakes]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}) for our dependencies, even for the `ILogger` itself. I prefer to call them fakes. There's a [difference between stubs and mocks]({% post_url 2021-05-24-WhatAreFakesInTesting %}).

By the way, [.NET 8.0 added a FakeLogger]({% post_url 2024-04-01-NET8FakeLogger %}), a logging provider for unit testing, so we don't have to rely on fakes to test logging.

In our test, we're expecting the actual log message to be exactly the same as the one from the `SomethingController`. Can you already spot the duplication? In fact, we're rebuilding the log message inside our tests. We're [duplicating the logic under test]({% post_url 2021-10-11-DontRepeatLogicInAssertions %}).

Also, let's notice we used a [custom assertion method]({% post_url 2021-08-16-WriteCustomAssertions %}) to make our assertions less verbose. `VerifyWasCalled()` is an extension method that inspects the Moq instance to check if the actual and expected messages are equal. Here it is,

```csharp
public static class MoqExtensions
{
    public static void VerifyWasCalled<T>(this Mock<ILogger<T>> fakeLogger, LogLevel logLevel, string message)
    {
        fakeLogger.Verify(
            x => x.Log(
                logLevel,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((o, t) =>
                    string.Equals(message, o.ToString(), StringComparison.InvariantCultureIgnoreCase)),
                    //     ^^^^^
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once);
    }
}
```

<figure>
<img src="https://images.unsplash.com/photo-1527190074017-f32101b5d57b?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY2ODcyMzM5Nw&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Pile of tree logs" />

<figcaption>Don't expect identical log...messages. Photo by <a href="https://unsplash.com/es/@chanphoto?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Chandler Cruttenden</a> on <a href="https://unsplash.com/s/photos/log?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Instead, expect log messages to contain keywords 

To make our unit tests more maintainable, let's check that log messages contain keywords or relevant substrings, like identifiers and values from input requests. Let's not check if they're identical to the expected log messages. Any changes in casing, punctuation, spelling or any other minor changes in the message structure will make our tests break.

Let's rewrite our test,

```csharp
using Microsoft.Extensions.Logging;
using Moq;
using OnTestingLogMessages.Controllers;
using OnTestingLogMessages.Services;

namespace OnTestingLogMessages.Tests;

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
            //           ^^^^^
            // 3...2...1...Boom...
        var fakeLogger = new Mock<ILogger<SomethingController>>();
        var controller = new SomethingController(fakeClientService.Object, fakeLogger.Object);

        var request = new AnyPostRequest(clientId);
        await controller.PostAsync(request);
        
        fakeLogger.VerifyMessageContains(LogLevel.Error, clientId.ToString());
        //         ^^^^^^^^
        // We expect the same log message to only contain the clientId
    }
}
```

This time, we rolled another extension method, `VerifyMessageContains()`,  removed the expected log message and asserted that the log message only contained only relevant subtrings: the `clientId`.

Here it is the new `VerifyMessageContains()`,

```csharp
public static class MoqExtensions
{
    public static void VerifyMessageContains<T>(this Mock<ILogger<T>> fakeLogger, LogLevel logLevel, params string[] expected)
    {
        fakeLogger.Verify(
            x => x.Log(
                logLevel,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((o, t) =>
                    expected.All(s => o.ToString().Contains(s, StringComparison.OrdinalIgnoreCase))),
                    // ^^^^^
                    // Checking if the log message contains some keywords, instead
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once);
    }
}
```

Voilà! That's how to make our test that checks logging messages more maintainable. By not rebuilding log messages inside tests and asserting that they contain keywords instead of expecting to be exact matches.

Here we dealt with logging for diagnostic purposes (logging to make troubleshooting easier for developers). But if logging were a business requirement, we should have to make it a separate "concept" in our code. Not in logging statements scatter all over the place. I learned by distinction about logging when reading [Unit Testing Principles, Practices, and Patterns]({% post_url 2022-10-17-UnitTestingPrinciplesPracticesTakeaways %}).

If you want to read more about unit testing, check [How to write tests for HttpClient using Moq]({% post_url 2022-12-01-TestingHttpClient %}), [How to test an ASP.NET Authorization Filter]({% post_url 2022-12-03-TestingAspNetAuthorizationFilters %}) and my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where we cover from what a unit test is, to fakes and mocks, to best practices.

{%include ut201_course.html %}

_Happy testing!_