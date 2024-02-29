---
layout: post
title: "What are fakes in unit testing? Mocks vs Stubs"
tags: tutorial csharp
cover: Cover.png
cover-alt: "What are fakes in unit testing"
---

Do you know what are fakes? Are stubs and mocks the same thing? Do you know if you need any of them? Once I made the exact same questions. Let's see what are fakes in unit testing.

**In unit testing, fakes or test doubles are classes or components that replace external dependencies. Fakes simulate successful or failed scenarios to test the logic around the real dependencies they replace.**

The best analogy to understand fakes are flight simulators. With a flight simulator, teachers create flight and environment conditions to train and test their pilot students in controlled scenarios.

Fakes are like flight simulators. Fakes return values, throw exceptions or record method calls to test the code around it. They create the conditions to test our code in controlled scenarios.

<figure>
<img src="https://images.unsplash.com/photo-1581089780002-02ddf16f57e4?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjE4MzU0Nzgx&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Female aerospace engineer conducts flight simulator" />

<figcaption>Fakes are like flight simulators. Photo by <a href="https://unsplash.com/@thisisengineering?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">ThisisEngineering RAEng</a> on <a href="https://unsplash.com/s/photos/flight-simulator?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## An example of Fakes

Let's move to an example. In our last post when we wrote [tests that use DateTime.Now]({% post_url 2021-05-10-WriteTestsThatUseDateTimeNow %}), we slightly covered the concept of fakes. In that post, we wrote a validator for credit cards. It looks something like this:

```csharp
public class CreditCardValidator : AbstractValidator<CreditCard>
{
    public CreditCardValidator(ISystemClock systemClock)
    {
        // Rest of code here...
        var now = systemClock.Now;
    }
}

public interface ISystemClock
{
    System.DateTime Now { get; }
}

public class SystemClock : ISystemClock
{
    public DateTime Now
        => DateTime.Now;
}
```

We created a `ISystemClock` interface with a `Now` property to replace `DateTime.Now` inside our validator. Then, in the unit tests, instead of using `SystemClock` with the real date and time, we wrote a `FixedDateClock` class to always return the same date and time.

This is one of the tests where wrote that uses the `FixedDateClock` class.

```csharp
[TestClass]
public class CreditCardValidationTests
{
    [TestMethod]
    public void CreditCard_ExpiredYear_ReturnsInvalid()
    {
        var when = new DateTime(2021, 01, 01);
        var clock = new FixedDateClock(when);
        //              ^^^^^
        var validator = new CreditCardValidator(clock);

        var request = new CreditCardBuilder()
                        .WithExpirationYear(when.AddYears(-1).Year)
                        .Build();
        var result = validator.TestValidate(request);

        result.ShouldHaveAnyValidationError();
    }
}
```

Well, that `FixedDateClock` is a fake. It replaces the `SystemClock` holding the real date and time with a testable alternative. With that fake in place, we make our tests use any date and time we want instead of the real date and time.

To be more precise, the `FixedDateClock` is a stub. But, let's find out about stubs and mocks.

## What's the difference between Mocks and Stubs?

Now that we know what fakes are, let's see two types of fakes: mocks and stubs. This is the difference between them.

**Both mocks and stubs are fakes or test doubles. Stubs provide values or exceptions to the code under test and mocks are used to assert that a method was called with the right parameters**.

### OrderService example

To better understand the difference between mocks and stubs, let's use another example. Let's process online orders with an `OrderService` class. 

This `OrderService` checks if an item has stock available to then charge a credit card. Imagine it uses an online payment processing software and a microservice to find the stock of an item. We use two interfaces, `IPaymentGateway` and `IStockService`, to represent the two dependencies. Something like this, 

```csharp
public class OrderService 
{
    private readonly IPaymentGateway _paymentGateway;
    private readonly IStockService _stockService;

    public OrderService(IPaymentGateway paymentGateway, IStockService stockService)
    {
        _paymentGateway = paymentGateway;
        _stockService = stockService;
    }

    public OrderResult PlaceOrder(Order order)
    {
        if (!_stockService.IsStockAvailable(order))
        {
            throw new OutOfStockException();
        }

        _paymentGateway.ProcessPayment(order);

        return new PlaceOrderResult(order);
    }
}
```

To test the `OrderService` class, we should check two things:
* It should throw an exception if the purchased item doesn't have stock.
* It should take a payment if the purchased item has enough stock.

Let's write a test for the scenario of an item in stock.

### Fake for available stock

First, we need a fake that returns if there's stock available for any order. Let's call it: `AlwaysAvailableStockService`. It looks like this:

```csharp
public class AlwaysAvailableStockService : IStockService
{
    public bool IsStockAvailable(Order order)
    {
        return true;
    }
}
```

As its name implies, it will always return stock for any order we pass. It simply returns `true`.

### Fake for payment gateway

Second, the `OrderService` works if it charges a credit card. But, we don't want to charge a real credit card every time we run our test.

Let's use a fake to record if the payment gateway was called or not. Let's name this fake: `FakePaymentGateway`. It looks like this:

```csharp
public class FakePaymentGateway : IPaymentGateway
{
    public bool WasCalled;

    public void ProcessPayment(Order order)
    {
        WasCalled = true;
    }
}
```

It has a public field `WasCalled` we set to `true` when the method `ProcessPayment()` is called. This way we can assert if the payment gateway was called.

Now that we have `AlwaysAvailableStockService` and `FakePaymentGateway` in place, let's write the actual test.

```csharp
[TestClass]
public class OrderServiceTests
{
    [TestMethod]
    public void PlaceOrder_ItemInStock_CallsPaymentGateway()
    {
        var paymentGateway = new FakePaymentGateway();
        var stockService = new AlwaysAvailableStockService();
        var service = new OrderService(paymentGateway, stockService);

        var order = new Order();
        service.PlaceOrder(order);

        Assert.IsTrue(paymentGateway.WasCalled);
        //                           ^^^^^
    }
}
```

The `AlwaysAvailableStockService` fake is there to provide a value for our test. It's a stub. And, the `FakePaymentGateway` is used to assert that the `OrderService` called the method to charge a credit card. It's a mock. Actually, we could call it `MockPaymentGateway`.

Again, stubs provides values and mocks are used to assert.

**Let's use fakes in our unit tests when we depend on external systems we don't control.** For example, third-party APIs and message queues. Let's assert the right call were made or the right messages were sent.

In our test, we used [the UnitOfWork_Scenario_ExpectedResult naming convention]({% post_url 2021-04-12-UnitTestNamingConventions %}). For the expect result part, we used the keyword "Calls". It shows we expect the `OrderService` to call a payment gateway to charge credit cards.

## Other types of fakes: dummies, stubs, spies and mocks

We learned about mocks and stubs. But, there are more types of fakes or doubles.

The book [xUnit Patterns](http://xunitpatterns.com/Mocks,%20Fakes,%20Stubs%20and%20Dummies.html) presents a broader category of fakes. It uses: dummies, stubs, spies and mocks. Let's quickly go through them.

**Dummies are used to respect the signature of methods and classes under test**. A dummy is never called inside the code under test. A `null` value or a null object, like `NullLogger`, in a class constructor are dummies when we're testing one of the class methods that doesn't use that parameter.

**Stubs feed our code under test with indirect input values**. We use stubs when the real dependencies aren't available in the test environment or when using one will have side effects. Like charging a credit card. For "xUnit Patterns" stubs are exactly the same as what we described earlier.

**Spies are observation points added to the code under test**. We use spies to check if the code under test called another component or not, and the parameters it used. According to "xUnit Patterns", mocks we wrote earlier are actually spies.

**Mocks are testable replacements that check if they were used correctly**. We use mocks when we know in advanced the parameters the code under test will use. With mocks, we set the expected parameters to be used before calling the code under test. Then, we use a verification method in the mock itself to check if the mock was called with those exact same parameters.

Let's not get confused with all these terms. Let's stick to the types of fakes presented in the book [The Art of Unit Testing]({% post_url 2020-03-06-TheArtOfUnitTestingReview %}). In there, there are only two types of fakes or test doubles: stubs and mocks. Everything else is a fake. Easier!

## Parting thoughts

Voilà! That's what fakes are in unit testing. Remember, stubs provide values for our tests and mocks assert that calls were made. That's the difference between them.

Often, we use the terms fake, stubs and mocks interchangeably. And sometimes we use the term "mocking" to mean the replacement of external components with testable equivalents. But, we have seen there's a distinction between all these terms.

If you want to start writing fakes with a mocking library, read my post on [how to write fakes with Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}). Also, check these [tips to write better stubs and mocks]({% post_url 2021-06-07-TipsForBetterStubsAndMocks %}).

If you're new to unit testing, read [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}), [4 common mistakes when writing your first tests]({% post_url 2021-03-29-UnitTestingCommonMistakes %}) and [4 test naming conventions]({% post_url 2021-04-12-UnitTestNamingConventions %}).

And don't miss the rest of my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where I cover more subjects like this one.

{%include ut201_course.html %}

_Happy testing!_