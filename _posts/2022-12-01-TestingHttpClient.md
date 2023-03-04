---
layout: post
title: "How to write tests for HttpClient using Moq"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Car crashed in an accident"
---

_This post is part of [my Advent of Code]({% post_url 2022-12-01-AdventOfCode2022 %})._

These days I needed to unit test a service that used the built-in `HttpClient`. It wasn't as easy as creating a fake for `HttpClient`. This is how to write tests for `HttpClient` with Moq and a set of extension methods to make it easier.

**To write tests for a service that requires a HttpClient, create a fake for HttpMessageHandler and set up the protected SendAsync() method to return a HttpResponseMessage. Then, create a new HttpClient passing the fake instance of HttpMessageHandler created before.**

## How to Create a Testable HttpClient

For example, let's write a test for a `AnyService` class that receives a `HttpClient`, using MSTest and Moq,

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using Moq.Protected;
using Newtonsoft.Json;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace MyProject.Services.Tests;

[TestClass]
public class AnyServiceTests
{
    [TestMethod]
    public async Task DoSomethingAsync_ByDefault_ReturnsSomethingElse()
    {
        var fakeHttpMessageHandler = new Mock<HttpMessageHandler>();
        fakeHttpMessageHandler
                .Protected()
                // ^^^^^^^
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>()
                )
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(JsonConvert.SerializeObject(new AnyResponseViewModel()))
                    // We add the expected response here:                   ^^^^^
                });
        using var httpClient = new HttpClient(fakeHttpMessageHandler.Object);
        //                                    ^^^^^
        var service = new AnyService(client);

        var someResult = await service.DoSomethingAsync();

        // Assert something here...
        Assert.IsNotNull(someResult);
    }
}
```

Notice how we used the `Protected()` and `Setup()` methods from [Moq to create a fake]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}) for `HtttpMessageHandler`. Then, inside the `ReturnsAsync()` method, we created a response message with a response object. And, finally, we used the fake handler to create a new `HttpClient` to pass it to our `AnyService` instance.

That's how we created a fake `HttpClient`. But, as soon as we start to write more tests, all of them get bloated with lots of duplicated code. Especially, if we create new tests by copy-pasting an existing one.

We should [reduce the noise in our tests]({% post_url 2020-11-02-UnitTestingTips %}) using factory methods or builders to make our tests more readable. Let's do that!

## Some extensions methods to set up the faked HttpClient

It would be great if we could reduce [the Arrange phase]({% post_url 2021-07-19-WriteBetterAssertions %}) of our sample test to one or two lines. Something like this,

```csharp
[TestMethod]
public async Task DoSomethingAsync_ByDefault_ReturnsSomethingElse()
{
    using var client = new Mock<HttpMessageHandler>()
                  .WithSuccessfulResponse(new AnyResponseViewModel())
                  //                      ^^^^^
                  // Alternatively,
                  // .WithUnauthorizedResponse()
                  // or
                  // .WithException<HttpRequestException>()
                  .ToHttpClient();
    var service = new AnyService(client);

    var someResult = await service.DoSomethingAsync();

    // Assert something here...
    Assert.IsNotNull(someResult);
}
```

It's not that difficult to write some extension methods on top of the `Mock<HttpMessageHandler>` to simplify the creation of testable `HttpClient` instances.

In fact, here they are,

```csharp
using Moq;
using Moq.Language.Flow;
using Moq.Protected;
using Newtonsoft.Json;
using System;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace HttpMessageHandlerTests.Extensions;

public static class MockHttpMessageHandlerExtensions
{
    public static Mock<HttpMessageHandler> WithSuccessfulResponse<T>(
        this Mock<HttpMessageHandler> fakeHttpMessageHandler,
        T responseContent)
    {
        fakeHttpMessageHandler
            .GetProtectedSetup()
            .ReturnsAsync(new HttpResponseMessage
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent(JsonConvert.SerializeObject(responseContent))
            });

        return fakeHttpMessageHandler;
    }

    public static Mock<HttpMessageHandler> WithUnauthorizedResponse(
        this Mock<HttpMessageHandler> fakeHttpMessageHandler)
    {
        fakeHttpMessageHandler
            .GetProtectedSetup()
            .ReturnsAsync(new HttpResponseMessage
            {
                StatusCode = HttpStatusCode.Unauthorized,
                RequestMessage = new HttpRequestMessage()
            });

        return fakeHttpMessageHandler;
    }

    public static Mock<HttpMessageHandler> WithDelegate(
        this Mock<HttpMessageHandler> fakeHttpMessageHandler,
        Func<HttpRequestMessage, CancellationToken, HttpResponseMessage> func)
    {
        fakeHttpMessageHandler
            .GetProtectedSetup()
            .ReturnsAsync(func);

        return fakeHttpMessageHandler;
    }

    public static Mock<HttpMessageHandler> WithException<TException>(
        this Mock<HttpMessageHandler> fakeHttpMessageHandler)
        where TException : Exception, new()
    {
        fakeHttpMessageHandler
            .GetProtectedSetup()
            .Throws<TException>();

        return fakeHttpMessageHandler;
    }

    public static HttpClient ToHttpClient(this Mock<HttpMessageHandler> fakeHttpMessageHandler)
    {
        return new HttpClient(fakeHttpMessageHandler.Object);
    }

    private static ISetup<HttpMessageHandler, Task<HttpResponseMessage>> GetProtectedSetup(
        this Mock<HttpMessageHandler> fakeHttpMessageHandler)
    {
        return fakeHttpMessageHandler
            .Protected()
            .Setup<Task<HttpResponseMessage>>(
                "SendAsync",
                ItExpr.IsAny<HttpRequestMessage>(),
                ItExpr.IsAny<CancellationToken>());
    }
}
```

We can add other methods like `WithNotFoundResponse()`, `WithInternalServerResponse()` or `WithTooManyRequestsResponse()` to cover other response codes. Even, we can setup the fake `HttpMessageHandler` passing an `Uri` with a method `ForUri()`, for example.

Voilà! That's how to write tests with `HttpClient` and Moq. With some extension methods, we could have a small DSL to write more readable tests. For a more fully-featured alternative to write tests for `HttpClient`, check [mockhttp](https://github.com/richardszalay/mockhttp), _"a testing layer for Microsoft's HttpClient library."_

If you want to read more about unit testing, check my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where we cover from what a unit test is, to fakes and mocks, to best practices.

_Happy testing!_