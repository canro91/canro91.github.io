---
layout: post
title: "How to create test values with the Builder pattern"
tags: tutorial csharp
cover: Cover.png
cover-alt: How to create test values with the Builder pattern
---

Last time, we learned [how to write good unit tests]({% post_url 2020-11-02-UnitTestingTips %}) by reducing noise inside our tests. One way to reduce noise is to use builder methods. In that post, we used a builder method to simplify the complex setup scenarios of our tests. Let's use the Builder pattern to create test values for our unit tests.

**With the Builder pattern, an object creates another object. A builder has methods to change some properties of an object and a method to return an object ready to use. The Builder pattern is useful to create input values inside unit tests**.

## Without Builders

To see the Builder pattern in action, let's validate credit cards. We will use the [FluentValidation](https://fluentvalidation.net/) library to create a validator class. We want to check if a credit card is expired or not. We can write these tests.

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

            var creditCard = new CreditCard
            {
                CardNumber = "4242424242424242",
                ExpirationYear = DateTime.Now.AddYears(-1).Year,
                ExpirationMonth = DateTime.Now.Month,
                Cvv = 123
            };
            var result = validator.TestValidate(creditCard);

            result.ShouldHaveAnyValidationError();
        }

        [TestMethod]
        public void CreditCard_ExpiredMonth_ReturnsInvalid()
        {
            var validator = new CreditCardValidator();

            var creditCard = new CreditCard
            {
                CardNumber = "4242424242424242",
                ExpirationYear = DateTime.Now.Year,
                ExpirationMonth = DateTime.Now.AddMonths(-1).Month,
                Cvv = 123
            };
            var result = validator.TestValidate(creditCard);

            result.ShouldHaveAnyValidationError();
        }
    }
}
```

In these tests, we used the `TestValidate()` and `ShouldHaveAnyValidationError()` methods from FluentValidation to write better assertions.

In each test, we created a `CreditCard` object and modified one single property for the given scenario. We had duplication and magic values when initializing the `CreditCard` object.

From [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}), we learned our test should be deterministic. We shouldn't rely on `DateTime.Now` on our tests, but let's keep it for now.

## Object mothers

In our tests, we should give enough details to our readers, but not too many details to make our tests noisy. We should keep the details at the right level.

In our previous tests, we only cared for the expiration year and month in each test. We can abstract the creation of the `CreditCard` objects to avoid repetition.

One alternative to abstract the creation of `CreditCard` objects is to use an object mother.

**An object mother is a factory method or property holding a ready-to-use input object. Each test changes this object to match the scenario under test**. 

For our example, we can create a `CreditCard` property with valid defaults and tweak it inside each test.

Our tests with an object mother for credit cards will look like this. Notice the `CreditCard` property in our test class and how we update its values from test to test.

```csharp
[TestClass]
public class CreditCardValidationTests
{
    [TestMethod]
    public void CreditCard_ExpiredYear_ReturnsInvalid()
    {
        var validator = new CreditCardValidator();

        // Instead of creating a new card object each time,
        // we rely on this new CreditCard property
        var request = CreditCard;
        request.ExpirationYear = DateTime.Now.AddYears(-1).Year;
        var result = validator.TestValidate(request);

        result.ShouldHaveAnyValidationError();
    }

    [TestMethod]
    public void CreditCard_ExpiredMonth_ReturnsInvalid()
    {
        var validator = new CreditCardValidator();

        var request = CreditCard;
        request.ExpirationMonth = DateTime.Now.AddMonths(-1).Month;
        var result = validator.TestValidate(request);

        result.ShouldHaveAnyValidationError();
    }

    // We have this new property to hold a valid credit card
    private CreditCard CreditCard
        => new CreditCard
        {
            CardNumber = "4242424242424242",
            ExpirationYear = DateTime.Now.Year,
            ExpirationMonth = DateTime.Now.Month,
            Cvv = 123
        };
}
```

<figure>
<img src="https://images.unsplash.com/photo-1519645261061-3cee4d216668?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjE3MDYwMTA3&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Lego technic toy truck" />

<figcaption>Let's use the Builder pattern. Photo by <a href="https://unsplash.com/@markusspiske?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Markus Spiske</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Builders

Object mothers are fine if you don't have lots of variations of the object being constructed. But, since this is a post on Builder pattern, let's create a Builder for credit cards.

**A Builder is a regular class with two types of methods: a `Build()` method and one or more `WithX()` methods.**

The `Build()` method returns the object the builder builds.

The `WithX()` methods update one or more properties of the object being built. In this name, the `X` refers to the property the method changes. These `WithX()` methods return a reference to the builder. This way, we can chain many `WithX()` methods one after the other, one for each parameter we want to change.

For our example, let's create a `CreditCardBuilder` with three methods: `WithExpirationYear()`, `WithExpirationMonth()` and `Build()`.

```csharp
public class CreditCardBuilder
{
    private string _cardNumber;
    private int _expirationYear;
    private int _expirationMonth;
    private int _cvv;

    public CreditCardBuilder WithExpirationYear(int year)
    {
        _expirationYear = year;

        return this;
    }

    public CreditCardBuilder WithExpirationMonth(int month)
    {
        _expirationMonth = month;

        return this;
    }

    // Other WithX methods

    public CreditCard Build()
    {
        return new CreditCard
        {
            CardNumber = _cardNumber,
            ExpirationYear = _expirationYear,
            ExpirationMonth = _expirationMonth,
            Cvv = _cvv
        };
    }
}
```

In our builder, we have one field for each property of the `CreditCard` class. We can create as many `WithX()` methods as properties we need to use in our tests.

### Initialize values inside Builders

To initialize the properties without corresponding `WithX()` methods, we can create a special `WithTestValues()` method to use valid defaults. Another option is to initialize all the fields on the builder directly.

Let's stick to the safe defaults out-the-box for our example.

```csharp
public class CreditCardBuilder
{
    private string _cardNumber = "4242424242424242";
    private int _expirationYear = DateTime.Now.Year;
    private int _expirationMonth = DateTime.Now.Month;
    private int _cvv = 123;

    // All WithX() methods

    public CreditCard Build()
    {
        return new CreditCard
        {
            CardNumber = _cardNumber,
            ExpirationYear = _expirationYear,
            ExpirationMonth = _expirationMonth,
            Cvv = _cvv
        };
    }
}
```

Now that we have a `CreditCardBuilder`, let's update our two sample tests to use it. Notice, when we use the Builder pattern, the last method in the chain of calls is always the `Build()` method.

```csharp
[TestClass]
public class CreditCardValidationTests
{
    [TestMethod]
    public void CreditCard_ExpiredYear_ReturnsInvalid()
    {
        var validator = new CreditCardValidator();

        // Now, instead of creating cards with the new keyword and using an object mother,
        // we use a builder for credit cards
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
```

### Composing Builders

With the Builder pattern, we can compose many builders to make our tests easier to read.

To show composition with builders, let's book a room online. If we use an expired credit card when booking a room, our code will throw an exception. Let's write a test for that.

```csharp
[TestClass]
public class BookRoomTests
{
    [TestMethod]
    public void BookRoom_ExpiredCreditCard_ThrowsException()
    {
        var service = new BookingService();

        var request = new BookingRequestBuilder()
                        .WithGuest("John Doe")
                        .WithCreditCard(new CreditCardBuilder()
                                            .ExpiredCreditCard()
                                            .Build())
                        .Build();

        Assert.ThrowsException<InvalidCreditCardException>(() => service.BookRoom(request));
    }
}
```

Notice this time, we have a `BookingRequestBuilder` to create booking requests. This builder has two methods: `WithGuest()` and `WithCreditCard()`. Instead of creating credit cards directly, we used the `CreditCardBuilder` again. We created a new method `ExpiredCreditCard()` to build expired credit cards.

We can simplify even further our `WithCreditCard()` method to receive a credit card builder, not a credit card object. Like this.

```csharp
[TestClass]
public class BookRoomTests
{
    [TestMethod]
    public void BookRoom_ExpiredCreditCard_ThrowsException()
    {
        var service = new BookingService();

        // Notice WithCreditCard() receives a builder this time
        var request = new BookingRequestBuilder()
                        .WithGuest("John Doe")
                        .WithCreditCard(new CreditCardBuilder()
                                            .ExpiredCreditCard())
                        .Build();

        Assert.ThrowsException<InvalidCreditCardException>(() => service.BookRoom(request));
    }
}
```

Voilà! That's how we can use the Builder pattern to create test data for our unit tests. I hope you have more readable tests using the Builder pattern after reading this post. Remember, in your tests you should give enough details to your readers, but not too many to make your tests noisy.

We used `DateTime.Now` in our tests, let's see how to handle that in a future post.

If you're new to unit testing, read [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}) to write your first unit tests in C# and  learn how to name your test with [these 4 naming conventions]({% post_url 2021-04-12-UnitTestNamingConventions %}).

For more advanced tips on unit testing, check my post on [how to write good unit tests]({% post_url 2020-11-02-UnitTestingTips %}) and [always write failing tests]({% post_url 2021-02-05-FailingTest %}).

_Happy testing!_