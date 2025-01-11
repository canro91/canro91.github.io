---
layout: post
title: "Testing DateTime.Now Revisited: .NET 8.0 TimeProvider"
tags: tutorial csharp
cover: Cover.png
cover-alt: "An old alarm clock" 
---

Starting from .NET 8.0, we have new abstractions for time. We don't need a custom `ISystemClock` interface. There's one built-in. Let's learn how to use the new `TimeProvider` class to write tests that use `DateTime.Now`.

**.NET 8.0 added the TimeProvider class to abstract date and time. It has a virtual method GetUtcNow() that sets the current time inside tests. It also has a non-testable implementation for production code.**

Let's play with the `TimeProvider` by revisiting [how to write tests that use DateTime.Now]({% post_url 2021-05-10-WriteTestsThatUseDateTimeNow %}).

Back in the day, we wrote two tests to validate expired credit cards. And we wrote an `ISystemClock` interface to control time inside our tests. These are the tests we wrote:

```csharp
using FluentValidation;
using FluentValidation.TestHelper;

namespace TimeProviderTests;

[TestClass]
public class CreditCardValidationTests
{
    [TestMethod]
    public void CreditCard_ExpiredYear_ReturnsInvalid()
    {
        var when = new DateTime(2021, 01, 01);
        var clock = new FixedDateClock(when);
        var validator = new CreditCardValidator(clock);
        //                                      ^^^^^
        // Look, ma! I'm going back in time

        var creditCard = new CreditCardBuilder()
                        .WithExpirationYear(DateTime.UtcNow.AddYears(-1).Year)
                        .Build();
        var result = validator.TestValidate(creditCard);

        result.ShouldHaveAnyValidationError();
    }

    [TestMethod]
    public void CreditCard_ExpiredMonth_ReturnsInvalid()
    {
        var when = new DateTime(2021, 01, 01);
        var clock = new FixedDateClock(when);
        var validator = new CreditCardValidator(clock);
        //                                      ^^^^^
        // Look, ma! I'm going back in time again

        var creditCard = new CreditCardBuilder()
                        .WithExpirationMonth(DateTime.UtcNow.AddMonths(-1).Month)
                        .Build();
        var result = validator.TestValidate(creditCard);

        result.ShouldHaveAnyValidationError();
    }
}

public interface ISystemClock
{
    DateTime Now { get; }
}

public class FixedDateClock : ISystemClock
{
    private readonly DateTime _when;

    public FixedDateClock(DateTime when)
    {
        _when = when;
    }

    public DateTime Now
        => _when;
}

public class CreditCardValidator : AbstractValidator<CreditCard>
{
    public CreditCardValidator(ISystemClock systemClock)
    {
        var now = systemClock.Now;
        // Beep, beep, boop
        // Using now to validate credit card expiration year and month...
    }
}
```

We wrote a `FixedDateClock` that extended `ISystemClock` to freeze time inside our tests. The thing is, we don't need them with .NET 8.0.

## 1. Use TimeProvider instead of ISystemClock

Let's get rid of our old `ISystemClock` by making our `CreditCardValidator` receive `TimeProvider` instead, like this:

```csharp
public class CreditCardValidator : AbstractValidator<CreditCard>
{
    // Before:
    // public CreditCardValidator(ISystemClock systemClock)
    // After:
    public CreditCardValidator(TimeProvider systemClock)
    //                         ^^^^^
    {
        var now = systemClock.GetUtcNow();
        // or
        //var now = systemClock.GetLocalNow();
        
        // Beep, beep, boop
        // Rest of the code here...
    }
}
```

The `TimeProvider` abstract class has the `GetUtcNow()` method to override the current UTC date and time. Also, it has the `LocalTimeZone` property to override the local timezone. With this timezone, `GetLocalNow()` returns the "frozen" UTC time as a local time.

If we're working with `Task`, we can use the `Delay()` method to create a task that completes after, well, a delay. Let's use the short delays in our tests to [avoid making our tests slow]({% post_url 2023-05-29-SpeedingUpSomeTests %}). Nobody wants a slow test suite.

With the `TimeProvider`, we can control time inside our tests by injecting a fake. But for production code, let's use `TimeProvider.System`. It uses `DateTimeOffset.UtcNow` under the hood.

<figure>
<img src="https://images.unsplash.com/photo-1557767536-34e0d6e7086c?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTcxNTg4MTM4Nw&ixlib=rb-4.0.3&q=80&w=600" alt="person holding glass ball">

<figcaption>Time from another perspective. Photo by <a href="https://unsplash.com/@nunchakouy?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Jossuha Théophile</a> on <a href="https://unsplash.com/photos/grayscale-photography-of-person-holding-glass-ball-JHjKNOPC3lc?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a></figcaption>
</figure>

## 2. Use FakeTimeProvider instead of FixedDateClock

We might be tempted to wrie a child class that extends `TimeProvider`. But, let's hold our horses. There's an option for that too.

Let's rewrite our tests after that change in the signature of the `CreditCardValidator`.

First, let's install the `Microsoft.Extensions.TimeProvider.Testing` NuGet package. It has a fake implementation of the time provider: `FakeTimeProvider`.

Here are our two tests using the `FakeTimeProvider`:

```csharp
using FluentValidation;
using FluentValidation.TestHelper;
using Microsoft.Extensions.Time.Testing;

namespace TestingTimeProvider;

[TestClass]
public class CreditCardValidationTests
{
    [TestMethod]
    public void CreditCard_ExpiredYear_ReturnsInvalid()
    {
        // Before:
        //var when = new DateTime(2021, 01, 01);
        //var clock = new FixedDateClock(when);
        var when = new DateTimeOffset(2021, 01, 01, 0, 0, 0, TimeSpan.Zero);
        var clock = new FakeTimeProvider(when);
        //              ^^^^^
        // Look, ma! No more ISystemClock
        var validator = new CreditCardValidator(clock);
        //                                      ^^^^^

        var creditCard = new CreditCardBuilder()
                        .WithExpirationYear(DateTime.UtcNow.AddYears(-1).Year)
                        .Build();
        var result = validator.TestValidate(creditCard);

        result.ShouldHaveAnyValidationError();
    }

    [TestMethod]
    public void CreditCard_ExpiredMonth_ReturnsInvalid()
    {
        // Before:
        //var when = new DateTime(2021, 01, 01);
        //var clock = new FixedDateClock(when);
        var when = new DateTimeOffset(2021, 01, 01, 0, 0, 0, TimeSpan.Zero);
        var clock = new FakeTimeProvider(when);
        //              ^^^^^
        var validator = new CreditCardValidator(clock);
        //                                      ^^^^^
        // Look, ma! I'm going back in time

        var creditCard = new CreditCardBuilder()
                        .WithExpirationMonth(DateTime.UtcNow.AddMonths(-1).Month)
                        .Build();
        var result = validator.TestValidate(creditCard);

        result.ShouldHaveAnyValidationError();
    }
}
```

The `FakeTimeProvider` has two constructors. One without parameters sets the internal date and time to January 1st, 2000, at midnight. And another one that receives a `DateTimeOffset`. That was the one we used in our two tests.

The `FakeTimeProvider` has two helpful methods to change the internal date and time: `SetUtcNow()` and `Advance()`. `SetUtcNow()` receives a new `DateTimeOffset` and `Advance()`, a `TimeSpan` to add it to the internal date and time.

If we're curious, this is the source code of [TimeProvider](https://github.com/dotnet/runtime/blob/5535e31a712343a63f5d7d796cd874e563e5ac14/src/libraries/Common/src/System/TimeProvider.cs) and [FakeTimeProvider](https://github.com/dotnet/extensions/blob/e5e1c7c88f3232bb3a096990da52fe7bf8a76996/src/Libraries/Microsoft.Extensions.TimeProvider.Testing/FakeTimeProvider.cs#L121C9-L129C6) from the official dotnet repository on GitHub.

If we take a closer look at our tests, we're "controlling" the time inside the `CreditCardValidator`. But, we still have `DateTime.UtcNow` when creating a credit card. For that, we can introduce a class-level constant `Now`. But that's an "exercise left to the reader."

Voilà! That's how to use the new .NET 8.0 abstraction to test time. We have the new `TimeProvider` and `FakeTimeProvider`. We don't need our `ISystemClock` and `FixedDateClock` anymore.

If you want to read more content, check [how to Test Logging Messages with FakeLogger]({% post_url 2024-04-01-NET8FakeLogger %}) and my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where we cover from what a unit test is, to fakes and mocks, to other best practices.

{%include ut201_course.html %}

_Happy testing!_