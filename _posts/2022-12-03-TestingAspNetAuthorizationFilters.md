---
layout: post
title: "TIL: How to test an ASP.NET Authorization Filter"
tags: todayilearned asp.net
cover: Cover.png
cover-alt: "Coffee machine"
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

These days I needed to work with a microservice for one of my clients. In that microservice, instead of validating incoming requests with the built-in model validations or FluentValidation, they use authorization filters. I needed to write some tests for that filter. This is what I learned.

Apart from validating the integrity of the incoming requests, the filter also validated that the referenced object in the request body matched the same "client."

## A weird filter scenario

The filter looked something like this,

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Mvc.Filters;
using Newtonsoft.Json;
using MyWeirdFilterScenario.Controllers;

namespace MyWeirdFilterScenario.Filters;

public class MyAuthorizationFilter : IAsyncAuthorizationFilter
{
    private readonly Dictionary<string, Func<AuthorizationFilterContext, Task<bool>>> _validationsPerEndpoint;

    private readonly IClientRepository _clientRepository;
    private readonly IOtherEntityRepository _otherEntityRepository;

    public MyAuthorizationFilter(IClientRepository clientRepository,
                                 IOtherEntityRepository otherEntityRepository)
    {
        _clientRepository = clientRepository;
        _otherEntityRepository = otherEntityRepository;

        // Register validations per action name here
        // vvvvv
        _validationsPerEndpoint = new Dictionary<string, Func<AuthorizationFilterContext, Task<bool>>>(StringComparer.OrdinalIgnoreCase)
        {
            { nameof(SomethingController.Post),  ValidatePostAsync },
            // Register validations for other methods here...
        };
    }

    public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
    {
        var actionName = ((ControllerActionDescriptor)context.ActionDescriptor).ActionName;

        try
        {
            var validation = _validationsPerEndpoint[actionName];
            var isValid = await validation(context);
            //                  ^^^^^^^^^^
            // Grab and run the validation for the called endpoint
            if (!isValid)
            {
                context.Result = new BadRequestResult();
                return;
            }
        }
        catch (Exception)
        {
            // Log bad things here...
            context.Result = new BadRequestResult();
        }
    }

    private async Task<bool> ValidatePostAsync(AuthorizationFilterContext context)
    {
        var request = await GetRequestBodyAsync<AnyPostRequest>(context);
        //                  ^^^^^^^^^^^^^^^^^^^
        // Grab the request body
        if (request == null || request.ClientId == default)
        {
            return false;
        }

        var client = await _clientRepository.GetByIdAsync(request.ClientId);
        //  ^^^^^^
        // Check our client exists...
        if (client == null)
        {
            return false;
        }

        var otherEntity = await _otherEntityRepository.GetByIdAsync(request.OtherEntityId);
        if (otherEntity == null || otherEntity.ClientId != client.Id)
        //  ^^^^^^^^^^^
        // Check we're updating our own entity...
        {
            return false;
        }

        // Doing something else here...

        return true;
    }

    // A helper method to grab the request body from the AuthorizationFilterContext
    private static async Task<T?> GetRequestBodyAsync<T>(AuthorizationFilterContext context)
    {
        var request = context.HttpContext.Request;
        request.EnableBuffering();
        request.Body.Position = 0;

        var body = new StreamReader(request.Body);
        var requestBodyJson = await body.ReadToEndAsync();

        request.Body.Position = 0;

        if (string.IsNullOrEmpty(requestBodyJson))
        {
            return default;
        }

        var settings = new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore };
        var requestBody = JsonConvert.DeserializeObject<T>(requestBodyJson, settings);
        return requestBody;
    }
}
```

On the `OnAuthorizationAsync()` method, this filter grabbed the validation method based on the called method name. And, inside the validation method, it checked that the request had a valid "clientId" and the referenced entity belonged to the same client. This is to prevent any client from updating somebody else's entities.

Also, notice we needed to use the `EnableBuffering()` and reset the body's position before and after reading the body from the `AuthorizationFilterContext`.

On the controller side, we registered the filter with an attribute like this,

```csharp
using Microsoft.AspNetCore.Mvc;
using RecreatingFilterScenario.Filters;

namespace MyAuthorizationFilter.Controllers;

[ApiController]
[Route("[controller]")]
[ServiceFilter(typeof(MyAuthorizationFilter))]
//                    ^^^^^^^^^^^
public class SomethingController : ControllerBase
{
    [HttpPost]
    public void Post(AnyPostRequest request)
    {
        // Beep, beep, boop...
        // Doing something with request
    }

    // Other methods here...
}
```

And, to make it work, we also need to register our filter in the dependencies container.

<figure>
<img src="https://images.unsplash.com/photo-1585047209652-ab8537bf6d6d?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY2ODcyMzIzNg&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Morning Brew" />

<figcaption>Photo by <a href="https://unsplash.com/@krsp?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Kris Gerhard</a> on <a href="https://unsplash.com/s/photos/coffee-filter?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## How to test an ASP.NET async authorization filter

**To test an ASP.NET async filter, create a new instance of the filter passing the needed dependencies as stubs. Then, when calling the OnAuthorizationAsync() method, create a AuthorizationFilterContext instance attaching the request body inside a DefaultHttpContext.**

Like this,

```csharp
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Routing;
using Moq;
using Newtonsoft.Json;
using RecreatingFilterScenario.Controllers;
using RecreatingFilterScenario.Filters;
using System.Text;

namespace MyWeirdFilterScenario.Tests;

[TestClass]
public class MyAuthorizationFilterTests
{
    [TestMethod]
    public async Task OnAuthorizationAsync_OtherEntityWithoutTheSameClient_ReturnsBadRequest()
    {
        var sameClientId = 1;
        var otherClientId = 2;
        var otherEntityId = 123456;

        var fakeClientRepository = new Mock<IClientRepository>();
        fakeClientRepository
            .Setup(t => t.GetByIdAsync(sameClientId))
            .ReturnsAsync(new Client(sameClientId));

        var fakeOtherEntityRepository = new Mock<IOtherEntityRepository>();
        fakeOtherEntityRepository
            .Setup(t => t.GetByIdAsync(otherEntityId))
            .ReturnsAsync(new OtherEntity(otherClientId));

        var filter = new MyAuthorizationFilter(fakeClientRepository.Object, fakeOtherEntityRepository.Object);
        //  ^^^^^^
        // Create an instance of our filter with two fake dependencies

        var request = new AnyPostRequest(sameClientId, otherEntityId);
        var context = BuildContext(request);
        //            ^^^^^^^^^^^^
        // Create an AuthorizationFilterContext
        await filter.OnAuthorizationAsync(context);

        Assert.IsNotNull(context.Result);
        Assert.AreEqual(typeof(BadRequestResult), context.Result.GetType());
    }

    private AuthorizationFilterContext BuildContext(AnyPostRequest? request)
    {
        var httpContext = new DefaultHttpContext();

        var json = JsonConvert.SerializeObject(request);
        var stream = new MemoryStream(Encoding.UTF8.GetBytes(json));
        httpContext.Request.Body = stream;
        httpContext.Request.ContentLength = stream.Length;
        httpContext.Request.ContentType = "application/json";
        // ^^^^^^^^
        // Attach a JSON body

        var actionDescriptor = new ControllerActionDescriptor
        {
            ActionName = nameof(SomethingController.Post)
            // ^^^^^^^
            // Use the endpoint name
        };
        var actionContext = new ActionContext(httpContext, new RouteData(), actionDescriptor);
        return new AuthorizationFilterContext(actionContext, new List<IFilterMetadata>());
    }
}
```

Let's unwrap it. First, we created an instance of `MyAuthorizationFilter` passing the dependencies as [fakes using Moq]({% post_url 2021-05-24-WhatAreFakesInTesting %}). As stubs, to be precise.

To call the `OnAuthorizationAsync()` method, we needed to create an `AuthorizationFilterContext`. This context required an `ActionContext`. We used a Builder method, `BuildContext()`, to keep things clean.

Then, to create an `ActionContext`, we needed to attach the request body as JSON to a `DefaultHttpContext` and set the action descriptor with our method name. Since we didn't read any route information, we passed a default `RouteData` instance.

Notice that we needed to use a `MemoryStream` to pass our request object as JSON and set the content length and type. [Source](https://stackoverflow.com/questions/65076535/unit-test-middleware-how-to-add-a-httprequest-to-a-httpcontext-in-net-core-3-1).

With the `BuildContext()` method in place, we got the Arrange and Act parts of our sample test. The next step was to assert on the context result.

Voilà! That's what I learned about unit testing ASP.NET authorization filters. Again, a Builder method helped to keep things simple and easier to reuse.

If you want to read more about unit testing, check [How to write tests for HttpClient using Moq](% post_url 2022-12-01-TestingHttpClient %) and my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where we cover from what a unit test is, to fakes and mocks, to best practices.

_Happy testing!_