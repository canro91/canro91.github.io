---
layout: post
title: How to create fakes with Moq. And what I don't like about it
tags: tutorial csharp showdev
---

A recurring task when we write unit tests is creating replacements for collaborators. If we're writing unit tests for an order delivery system, we don't want to charge a credit card every time we run our tests. This is how we can create fakes using Moq.

**Fakes or test doubles are testable replacements for dependencies and external systems. Fakes could return a fixed value or throw an exception to test the logic around the dependency they replace. Fakes can be created manually or with a mocking library like Moq.**

Think of fakes or test doubles like body or stunt doubles in movies. They substitute an actor in life-threatening scenes without showing their face. In unit testing, fakes replace external components.

## How to write your own fakes

We can write our own fakes by hand or use a mocking library.

If we apply the [Dependency Inversion Principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle), the D of SOLID, our dependencies are well abstracted using interfaces. Each service receives its collaborators instead of building them directly.

To create a fake, we create a class that inherits from an interface. Then, on Visual Studio, from the "Quick Refactorings" menu, we choose the "Implement interface" option. Et voilà! We have our own fake.

But, if we need to create lots of fake collaborators, a mocking library can make things easier. Mocking libraries are an alternative to writing our own fakes manually. They offer a friendly API to create fakes for an interface or an abstract class. Let's see Moq, one of them!

## Moq, a mocking library

[Moq](https://github.com/Moq/moq4) is a mocking library that _" is designed to be a very practical, unobtrusive and straight-forward way to quickly setup dependencies for your tests"_.

> Moq, _" the most popular and friendly mocking library for .NET"_
>
> From [moq](https://github.com/Moq/moq4#moq)

### Create fakes with Moq...Action!

Let's see Moq in action! Let's start with an `OrderService` that uses an `IPaymentGateway` and  `IStockService`. This `OrderService` checks if an item has stock available to charge a credit card when placing a new order. Something like this, 

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

To test this service, let's create replacements for the real payment gateway and stock service. We want to check what the `OrderService` class does when there's stock available and when there isn't.

For our test name, let's follow the naming convention from [The Art of Unit Testing]({% post_url 2020-03-06-TheArtOfUnitTestingReview %}). With this naming convention, a test name shows the entry point, the scenario, and the expected result separated by underscores.

Of course, that's not the only naming convention. There are other ways to [name our tests]({% post_url 2021-04-12-UnitTestNamingConventions %}).

```csharp
[TestClass]
public class OrderServiceTests
{
  [TestMethod]
  public void PlaceOrder_StockAvailable_CallsProcessPayment()
  {
    var fakePaymentGateway = new Mock<IPaymentGateway>();

    var fakeStockService = new Mock<IStockService>();
    fakeStockService.Setup(t => t.IsStockAvailable(It.IsAny<Order>()))
                    .Returns(true);
    var orderService = new OrderService(fakePaymentGateway.Object, fakeStockService.Object);

    var order = new Order();
    orderService.PlaceOrder(order);

    fakePaymentGateway.Verify(t => t.ProcessPayment(order), Times.Once);
  }
}
```

What happened here? First, it creates a fake for `IPaymentGateway` with `new Mock<IPaymentGateway>()`. Moq can create fakes for classes too.

Then, it creates another fake for `IStockService`. This fake returns `true` when the method `IsStockAvailable` is called with any order as a parameter.

Next, it uses the `Object` property of the `Mock` class to create instances of the fakes. With these two instances, it builds the `OrderService`.

Finally, using the `Verify` method, it checks if the method `ProcessPayment` was called once. A passing test now!

### Cut!...What I don't like about Moq

Moq is easy to use. We can start using it in minutes! We only need to read the README and quickstart files in the documentation. But...

For Moq, everything is a mock: `Mock<T>`. Strictly speaking, everything isn't a mock. There's a [difference between stubs and mocks]({% post_url 2021-05-24-WhatAreFakesInTesting %}).

The [XUnit Tests Patterns](http://xunitpatterns.com/Mocks,%20Fakes,%20Stubs%20and%20Dummies.html) book presents a detailed category of fakes or doubles: fakes, stubs, mocks, dummies, and spies. And, The Art of Unit Testing book reduces this classification to only three types: fakes, stubs, and mocks.

Other libraries use `Fake`, `Substitute`, or `Stub`/`Mock` instead of only `Mock`.

Moq has chosen this simplification to make it easier to use. But, this could lead us to misuse the term "mock." So far, I have deliberately used the word "fake" instead of "mock" for a reason.

For Moq, `MockRepository` is a factory of mocks. We can verify all mocks created from this factory in a single call. But, a repository is a pattern to abstract creating and accessing records in a data store. We will find `OrderRepository` or `EmployeeRepository`. Are `MockSession` or `MockGroup` better alternatives? Probably. Naming is hard anyway.

### Conclusion

Voilà! That's how we create fakes and mocks with Moq. Moq is a great library! It keeps its promise. It's easy to set up dependencies in our tests. We need to know only a few methods to start using it. We only need: `Setup`, `Returns`, `Throws`, and `Verify`. It has chosen to lower the barrier of writing tests. Give it a try! _To mock or not to mock!_

If you use Moq often, avoid typing the same method names all the time with [these snippets I wrote for Visual Studio]({% post_url 2021-02-22-VisualStudioMoqSnippets %}).

For more tips on writing unit tests, check my posts on how to write good unit tests by [reducing noise]({% post_url 2020-11-02-UnitTestingTips %}) and [writing failing tests]({% post_url 2021-02-05-FailingTest %}).  And don't miss the rest of my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where I cover more subjects like this one.

_Happy mocking time!_