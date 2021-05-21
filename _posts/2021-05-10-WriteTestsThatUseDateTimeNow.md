---
layout: post
title: "How to write tests that use DateTime.Now"
tags: tutorial csharp
cover: Cover.png
cover-alt: "How to write tests that use DateTime.Now"
---

In our last post about using [builders to create test data]({% post_url 2021-04-26-CreateTestValuesWithBuilders %}), we wrote a validator for expired credit cards. We used `DateTime.Now` all over the place. Let's see how to write better unit tests that use the current time.

**To write tests that use DateTime.Now, create a wrapper for DateTime.Now and use a fake or test double with a fixed date. As alternative, create a setter or an optional constructor to pass a reference date**.

Let's continue where we left off. Last time, in our post about the [the Builder pattern]({% post_url 2021-04-26-CreateTestValuesWithBuilders %}), we wrote two tests to check if a credit card was expired. These are the tests we wrote that time.

```csharp
using FluentValidation.TestHelper;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace UsingBuilders
{
    [TestClass]
    public class CreditCardValidationTests
    {
        [TestMethod]
        public void CreditCard_ExpiredYear_ReturnsInvalid()
        {
            var validator = new CreditCardValidator();

            var creditCard = new CreditCardBuilder()
                            .WithExpirationYear(DateTime.Now.AddYears(-1).Year)
                            .Build();
            var result = validator.TestValidate(request);

            result.ShouldHaveAnyValidationError();
        }

        [TestMethod]
        public void CreditCard_ExpiredMonth_ReturnsInvalid()
        {
            var validator = new CreditCardValidator();

            var creditCard = new CreditCardBuilder()
                            .WithExpirationMonth(DateTime.Now.AddMonths(-1).Month)
                            .Build();
            var result = validator.TestValidate(request);

            result.ShouldHaveAnyValidationError();
        }
    }
}
```

These two tests rely on the current date and time. Every time you run tests that rely on the current date and time, you will have a different date and time. It means, you will have different test values and tests each time you run these tests.

We want our tests to be deterministic. We learned that from [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}). Using `DateTime.Now` in our tests isn't a good idea.

To replace the `DateTime.Now` in our tests, we need seams.

**A seam is a place to introduce testable behavior in our code under test**.

Let's see two techniques from the books [The Art of Unit Testing](https://www.manning.com/books/the-art-of-unit-testing-second-edition) ([My takeaways here]({% post_url 2020-03-06-TheArtOfUnitTestingReview %})) and [97 things every programmer should know](https://www.oreilly.com/library/view/97-things-every/9780596809515/) to introduce seams in our code to replace `DateTime.Now`.

**Two techniques to introduce seams in code are using interfaces to declare dependencies in the constructor of a class and an optional setter methods to plug in testable values.**

<figure>
<img src="https://images.unsplash.com/37/tEREUy1vSfuSu8LzTop3_IMG_2538.jpg?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjE3MjMwNDA1&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="A clock alarm" />

<figcaption>Photo by <a href="https://unsplash.com/@sonjalangford?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Sonja Langford</a> on <a href="https://unsplash.com/s/photos/time?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Use a fake or test double

To make our tests more reliable, we can create an abstraction for the current time and make our validator depend on it. Later, we can pass a fake or double with a hardcoded date in our tests.

Let's create a `ISystemClock` interface and a default implementation. The `ISystemClock ` will have a `Now` property for the current date and time.

```csharp
public interface ISystemClock
{
    DateTime Now { get; }
}

public class SystemClock : ISystemClock
{
    public DateTime Now
        => DateTime.Now;
}
```

Our `CreditCardValidator` will receive in its constructor a reference to `ISystemClock`. Now, instead of using `DateTime.Now` in our validator, it will use the `Now` property from the clock.

```csharp
public class CreditCardValidator : AbstractValidator<CreditCard>
{
    public CreditCardValidator(ISystemClock systemClock)
    {
        // Rest of code here...
        var now = systemClock.Now;
    }
}
```

Next, let's create a testable clock and use it in our tests.

```csharp
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
```

Notice we named our fake clock `FixedDateClock` to show it returns the `DateTime` object you pass to it.

Our tests with the testable clock implementation will look like this.

```csharp
[TestClass]
public class CreditCardValidationTests
{
    [TestMethod]
    public void CreditCard_ExpiredYear_ReturnsInvalid()
    {
        var when = new DateTime(2021, 01, 01);
        var clock = new FixedDateClock(when);
        // This time we're passing a clock implementation
        var validator = new CreditCardValidator(clock);

        var request = new CreditCardBuilder()
                        .WithExpirationYear(when.AddYears(-1).Year)
                        .Build();
        var result = validator.TestValidate(request);

        result.ShouldHaveAnyValidationError();
    }

    [TestMethod]
    public void CreditCard_ExpiredMonth_ReturnsInvalid()
    {
        var when = new DateTime(2021, 01, 01);
        var clock = new FixedDateClock(when);
        var validator = new CreditCardValidator(clock);

        var request = new CreditCardBuilder()
                        .WithExpirationMonth(when.AddMonths(-1).Month)
                        .Build();
        var result = validator.TestValidate(request);

        result.ShouldHaveAnyValidationError();
    }
}
```

With a testable clock in our tests, we replaced all the references to `DateTime.Now` with a fixed date in the past.

### Create constants for test values

To make things cleaner, let's refactor our tests. Let's use a builder method and read-only fields for the fixed dates.

```csharp
[TestClass]
public class CreditCardValidationTests
{
    private static readonly DateTime When = new DateTime(2021, 01, 01);
    private static readonly DateTime LastYear = When.AddYears(-1);
    private static readonly DateTime LastMonth = When.AddMonths(-1);

    [TestMethod]
    public void CreditCard_ExpiredYear_ReturnsInvalid()
    {
        // Notice the builder method here
        var validator = MakeValidator(When);

        var request = new CreditCardBuilder()
                        .WithExpirationYear(LastYear.Year)
                        .Build();
        var result = validator.TestValidate(request);

        result.ShouldHaveAnyValidationError();
    }

    [TestMethod]
    public void CreditCard_ExpiredMonth_ReturnsInvalid()
    {
        var validator = MakeValidator(When);

        var request = new CreditCardBuilder()
                        .WithExpirationMonth(LastMonth.Month)
                        .Build();
        var result = validator.TestValidate(request);

        result.ShouldHaveAnyValidationError();
    }

    private CreditCardValidator MakeValidator(DateTime when)
    {
        var clock = new FixedDateClock(when);
        var validator = new CreditCardValidator(clock);
        return validator;
    }
}
```

That's how we can abstract the current date and time with an interface.

## Use a parameter in a constructor

Now, let's see the second alternative. To replace the interface from our first example, in the constructor we can pass a delegate returning a reference date. Like this:

```csharp
public class CreditCardValidator : AbstractValidator<CreditCard>
{
    public CreditCardValidator(Func<DateTime> nowSelector)
    {
        // Rest of code here...
        var now = nowSelector();
    }
}
```

Or, even simpler we can pass a plain `DateTime` parameter. Like this:

```csharp
public class CreditCardValidator : AbstractValidator<CreditCard>
{
    public CreditCardValidator(DateTime now)
    {
        // Rest of code here...
    }
}
```

Let's stick to a simple parameter and update our tests.

```csharp
[TestClass]
public class CreditCardValidationTests
{
    private static readonly DateTime When = new DateTime(2021, 01, 01);
    private static readonly DateTime LastYear = When.AddYears(-1);
    private static readonly DateTime LastMonth= When.AddMonths(-1);

    [TestMethod]
    public void CreditCard_ExpiredYear_ReturnsInvalid()
    {
        var validator = new CreditCardValidator(When);

        var request = new CreditCardBuilder()
                        .WithExpirationYear(LastYear.Year)
                        .Build();
        var result = validator.TestValidate(request);

        result.ShouldHaveAnyValidationError();
    }

    [TestMethod]
    public void CreditCard_ExpiredMonth_ReturnsInvalid()
    {
        var validator = new CreditCardValidator(When);

        var request = new CreditCardBuilder()
                        .WithExpirationMonth(LastMonth.Month)
                        .Build();
        var result = validator.TestValidate(request);

        result.ShouldHaveAnyValidationError();
    }
}
```

Yeap! As simple as that. Another variation on this theme is to create a setter inside the `CreditCardValidator` to pass an optional date. Inside the validator, we should check if the optional date is present to use `DateTime.Now` or not. Something like this.

```csharp
[TestMethod]
public void CreditCard_ExpiredYear_ReturnsInvalid()
{
    var validator = new CreditCardValidator();
    validator.CurrentDateTime = When;

    var request = new CreditCardBuilder()
                    .WithExpirationYear(LastYear.Year)
                    .Build();
    var result = validator.TestValidate(request);

    result.ShouldHaveAnyValidationError();
}
```

Voilà! That's how we can write more reliable tests that use the current date and time. You can either create an interface or pass a fixed date.

If you're new to unit testing, read [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}) and [4 test naming conventions]({% post_url 2021-04-12-UnitTestNamingConventions %}). For more advanced tips on unit testing, check my posts on [how to write good unit tests]({% post_url 2020-11-02-UnitTestingTips %}) and [how to write fakes with Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}).

_Happy testing!_
