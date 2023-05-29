---
layout: post
title: "Let's refactor a test: Speed up a slow test suite"
tags: csharp
cover: Cover.png
cover-alt: "A car speedometer" 
---

Do you have fast unit tests? This is how I speeded up a slow test suite from one of my client's projects by reducing the delay between retry attempts and initializing slow-to-build dependencies only once. There's a lesson behind this refactoring session.

**Make sure to have a fast test suite that every developer could run after every code change. The slower the tests, the less frequently they're run.**

I learned to have some metrics before rushing to optimize anything. I learned it while trying to [optimize a slow room searching feature]({% post_url 2020-09-23-TheSlowRoomSearch %}). These are the tests and their execution time before any changes:

{% include image.html name="Before.png" alt="Slow tests" caption="Slow tests" %}

Of course, I blurred some names for obvious reasons. I focused on two projects: `Api.Tests` (3.3 min) and `ReservationQueue.Tests` (18.9 sec).

I had a slower test project, `Data.Tests`. It contained integration tests using a real database. Probably those tests could benefit from [simple test values]({% post_url 2022-12-14-SimpleTestValues %}). But I didn't want to [tune stored procedures or queries]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}).

This is what I found and did to speed up this test suite.

## Step 1: Reduce delays between retries

Inside the `Api.Tests`, I found tests for services with a retry mechanism. And, inside the unit tests, I had to wait more than three seconds between every retry attempt. C'mon, these are unit tests! Nobody needs or wants to wait between retries here.

My first solution was to reduce the delay between retry attempts to zero.

### Set retryWaitSecond = 0

Some tests built retry policies manually and passed them to services. I only needed to pass `0` as a delay. Like this,

{% include image.html name="ZeroDelay.png" alt="Diff of setting retryWaitSecond variable to zero" caption="Making retryWaitSecond = 0" %}

A simple [Bash one-liner to find and replace a pattern]({% post_url 2022-12-10-ReplaceKeywordInFile %}) got my back covered here.

### Pass RetryOptions without delay

Some other tests used an `EventHandler` base class. After running a command handler wrapped in a database transaction, we needed to call other internal microservices. We used event handlers for that. This is the `EventHandlerBase`,

```csharp
public abstract class EventHandlerBase<T> : IEventHandler<T>
{
    protected RetryOptions _retryOptions;

    protected EventHandlerBase()
    {
        _retryOptions = new RetryOptions();
        //              ^^^^^
        // By default, it has:
        // MaxRetries = 2
        // RetryDelayInSeconds = 3
    }

    public async Task ExecuteAsync(T eventArgs)
    {
        try
        {
            await BuildRetryPolicy().ExecuteAsync(async () => await HandleAsync(eventArgs));
        }
        catch (Exception ex)
        {
            // Sorry, something wrong happened...
            // Log things here like good citizens of the world...
        }
    }

    private AsyncPolicy BuildRetryPolicy()
    {
        return Policy.Handle<HttpRequestException>()
            .WaitAndRetryAsync(
                _retryOptions.MaxRetries,
                (retryAttempt) => TimeSpan.FromSeconds(Math.Pow(_retryOptions.RetryDelayInSeconds, retryAttempt)),
                //                ^^^^^
                (exception, timeSpan, retryCount, context) =>
                { 
                    // Log things here like good citizens of the world...
                });
    }

    public virtual void SetRetryOptions(RetryOptions retryOptions)
    //                  ^^^^^
    {
        m_retryOptions = retryOptions;
    }

    protected abstract Task HandleAsync(T eventArgs);
}
```

Notice one thing: the `EventHandlerBase` didn't receive a `RetryOptions` in its constructor. All event handlers had, by default, a 3-second delay. Even the ones inside unit tests. Arrrgggg! And the `EventHandlerBase` used an exponential backoff. Arrrgggg! That explained why I had those slow tests.

The perfect solution would have been to make all child event handlers receive the right `RetryOptions`. But it would have required changing the Production code and probably retesting some parts of the app.

Instead, I went through all the [builder methods inside tests]({% post_url 2021-04-26-CreateTestValuesWithBuilders %}) and passed a `RetryOptions` without delay. Like this,

{% include image.html name="WithoutDelay.png" alt="Adding a RetryOptions" caption="Adding a RetryOptions" %}

After removing that delay between retries, the `Api.Tests` ran faster.

## Step 2: Initialize AutoMapper only once

Inside the `ReservationQueue.Tests`, the other slow test project, I found some tests using AutoMapper. Oh, boy! AutoMapper! I have a love-and-hate relationship with AutoMapper. I shared about AutoMapper in [a past Monday Links episode]({% post_url 2022-03-14-MondayLinks %}).

Some of the tests inside `ReservationQueue.Tests` looked like this,

```csharp
[TestClass]
public class ACoolTestClass
{
    private class TestBuilder
    {
        public Mock<ISomeService> SomeService { get; set; } = new Mock<ISomeService>();

        private IMapper mapper = null;

        internal IMapper Mapper
        //               ^^^^^
        {
            get
            {
                if (mapper == null)
                {
                    var services = new ServiceCollection();
                    services.AddMapping();
                    //       ^^^^^

                    var provider = services.BuildServiceProvider();
                    mapper = provider.GetRequiredService<IMapper>();
                }

                return mapper;
            }
        }

        public ServiceToTest Build()
        {
            return new ServiceToTest(Mapper, SomeService.Object);
            //                       ^^^^^
        }

        public TestBuilder SetSomeService()
        {
            // Make the fake SomeService instance return some hard-coded values...
        }
    }

    [TestMethod]
    public void ATest()
    {
        var builder = new TestBuilder()
                        .SetSomeService();
        var service = builder.Build();
        
        service.DoSomething();

        // Assert something here...
    }

    // Imagine more tests that follow the same pattern...
}
```

These tests used a private `TestBuilder` class to create a service with all its dependencies replaced by fakes. Except for AutoMapper's `IMapper`.

To create `IMapper`, these tests had a property that used the same `AddMapping()` method used in the `Program.cs` file. It was an extension method with hundreds and hundreds of type mappings. Like this,

```csharp
public static IServiceCollection AddMapping(this IServiceCollection services)
{
    var configuration = new MapperConfiguration((configExpression) =>
    {
        // Literally hundreds of single-type mappings here...
        // Hundreds and hundreds...
    });

    configuration.AssertConfigurationIsValid();
    services.AddSingleton(configuration.CreateMapper());

    return services;
}
```

{% include image.html name="AddMapping.png" alt="A collapsed hundred-line AddMapping method" caption="Look at the line numbers on the left!" %}

The thing is that every single test created a new instance of the `TestBuilder` class. And, by extension, an instance of `IMapper` for every test. And creating an instance of `IMapper` is expensive. Arrrgggg!

A better solution would have been to use AutoMapper Profiles and only load the profiles needed in each test class. That would have been a long and painful refactoring session.

### Use MSTest ClassInitialize attribute

Instead of creating an instance of `IMapper` when running every test, I did it only once per test class. I used MSTest `[ClassInitialize]` attribute. It decorates a static method that runs before all the test methods of a class. That was exactly what I needed.

To learn about all MSTest attributes, check [Meziantou's MSTest v2: Test lifecycle attributes](https://www.meziantou.net/mstest-v2-test-lifecycle-attributes.htm).

My sample test class using `[ClassInitialize]` looked like this,

```csharp
[TestClass]
public class ACoolTestClass
{
    private static IMapper Mapper;
    //                     ^^^^^

    [ClassInitialize]
    // ^^^^^
    public static void TestClassSetup(TestContext context)
    //                 ^^^^^
    {
        var services = new ServiceCollection();
        services.AddMapping();
        //       ^^^^^

        var provider = services.BuildServiceProvider();
        Mapper = provider.GetRequiredService<IMapper>();
    }

    private class TestBuilder
    {
        public Mock<ISomeService> SomeService { get; set; } = new Mock<ISomeService>();

        // No more IMapper initializations here

        public ServiceToTest Build()
        {
            return new ServiceToTest(Mapper, SomeService.Object);
            //                       ^^^^^
        }

        public TestBuilder SetSomeService()
        {
            // Return some hardcoded values from ISomeService methods...
        }
    }

    // Same tests as before...
}
```

I needed to replicate this change in other test classes that used AutoMapper.

After reducing the delay between retry attempts and creating `IMapper` once per test class, these were the final execution times,

{% include image.html name="After.png" alt="List of tests inside Visual Studio" caption="Faster tests" %}

That's under a minute! They used to run in ~3.5 minutes.

Voilà! That's how I speeded up this test suite. Apart from reducing delays between retry attempts in our tests and initializing AutoMapper once per test class, the lesson to take home is to have a fast test suite. A test suite we can run after every code change. Because the slower the tests, the less frequently we run them. And we want our backs covered by tests all the time.

To read more about unit testing, check refactoring sessions to [remove duplicated emails]({% post_url 2022-12-22-TestingDuplicatedEmails %}) and [update email statuses]({% post_url 2023-05-15-TestingEmailStatusUpdates %}). And don't miss my [Unit Testing 101 series]({%  post_url 2021-08-30-UnitTesting %}) where I cover from naming conventions to best practices.

_Happy testing!_