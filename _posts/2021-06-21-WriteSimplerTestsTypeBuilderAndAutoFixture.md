---
layout: post
title: "Write simpler tests with Type Builders and AutoFixture"
tags: tutorial csharp showdev
cover: Cover.png
cover-alt: "Write simpler tests with Type Builders and AutoFixture"
---

Writing tests for services with lots of collaborators can be tedious. I know. You will end up with complex Arrange parts and lots of fakes. Let's see three alternatives to write simpler tests with builder methods, Type Builders and AutoFixture.

**To write simpler tests for services with lots of collaborators, use builder methods to create only the fakes needed in every test. As an alternative, use auto-mocking with a type builder or libraries like AutoFixture to create a service with its collaborators replaced by test doubles using a mocking library.**

To show these three alternatives, let's bring back our `OrderService` class. We used it to show the [difference between stubs and mocks]({% post_url 2021-05-24-WhatAreFakesInTesting %}). Again, the `OrderService` checks if an item has stock available to then charge a credit card.

This time, let's add an `IDeliveryService` to create a shipment order and an `IOrderRepository` to keep track of order status. With these two changes, our `OrderService` will look like this:

```csharp
public class OrderService
{
    private readonly IPaymentGateway _paymentGateway;
    private readonly IStockService _stockService;
    private readonly IDeliveryService _deliveryService;
    private readonly IOrderRepository _orderRepository;

    public OrderService(IPaymentGateway paymentGateway,
                        IStockService stockService,
                        IDeliveryService deliveryService,
                        IOrderRepository orderRepository)
    {
        _paymentGateway = paymentGateway;
        _stockService = stockService;
        _deliveryService = deliveryService;
        _orderRepository = orderRepository;
    }

    public OrderResult PlaceOrder(Order order)
    {
        if (!_stockService.IsStockAvailable(order))
        {
            throw new OutOfStockException();
        }

        // Process payment, ship items, and store order status...

        return new PlaceOrderResult(order);
    }
}
```

Let's write a test to check if the payment gateway is called when we place an order. We're using [Moq to write fakes]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}). This test will look like this:

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;

namespace WithoutAnyBuilders
{
    [TestClass]
    public class OrderServiceTestsBefore
    {
        [TestMethod]
        public void PlaceOrder_ItemInStock_CallsPaymentGateway()
        {
            var stockService = new Mock<IStockService>();
            stockService.Setup(t => t.IsStockAvailable(It.IsAny<Order>()))
                        .Returns(true);
            var paymentGateway = new Mock<IPaymentGateway>();
            var deliveryService = new Mock<IDeliveryService>();
            var orderRepository = new Mock<IOrderRepository>();
            var service = new OrderService(paymentGateway.Object,
                                           stockService.Object,
                                           deliveryService.Object,
                                           orderRepository.Object);

            var order = new Order();
            service.PlaceOrder(order);

            paymentGateway.Verify(t => t.ProcessPayment(It.IsAny<Order>()));
        }
    }
}
```

Sometimes, we need to create fakes for our collaborators even when the tested behavior doesn't need them.

## 1. Builder methods

One easy alternative to writing simpler tests is to use builder methods.

With a builder method, we only create the fakes we need inside our tests. And, inside the builder method, we create "empty" fakes for the collaborators we don't need for the tested scenario.

We've used this idea of builder methods to [write better tests by making our tests less noisy]({% post_url 2020-11-02-UnitTestingTips %}) and more readable.

Our test with a builder method looks like this:

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;

namespace WithBuilderMethod
{
    [TestClass]
    public class OrderServiceTestsBuilder
    {
        [TestMethod]
        public void PlaceOrder_ItemInStock_CallsPaymentGateway()
        {
            var stockService = new Mock<IStockService>();
            stockService.Setup(t => t.IsStockAvailable(It.IsAny<Order>()))
                        .Returns(true);
            var paymentGateway = new Mock<IPaymentGateway>();
            // We add a new MakeOrderService method
            var orderService = MakeOrderService(stockService.Object, paymentGateway.Object);
            //                 ^^^^^

            var order = new Order();
            orderService.PlaceOrder(order);

            paymentGateway.Verify(t => t.ProcessPayment(order));
        }

        // Notice we only pass the fakes we need
        private OrderService MakeOrderService(IStockService stockService, IPaymentGateway paymentGateway)
        //                   ^^^^^
        {
            var deliveryService = new Mock<IDeliveryService>();
            var orderRepository = new Mock<IOrderRepository>();
            var service = new OrderService(paymentGateway,
                                            stockService,
                                            deliveryService.Object,
                                            orderRepository.Object);

            return service;
        }
    }
}
```

With the `MakeOrderService()` method, we only deal with the mocks we care about in every test. The ones for `IStockService` and `IPaymentService`.

<figure>
<img src="https://images.unsplash.com/photo-1512207736890-6ffed8a84e8d?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjIzNjkyODcw&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Men at work" />

<figcaption>Let's use builders to write simpler tests. Photo by <a href="https://unsplash.com/@ripato?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Ricardo Gomez Angel</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
  </figcaption>
</figure>

## 2. Auto-mocking with TypeBuilder

Builder methods are fine. But, we can use a special builder to create testable services with all its collaborators replaced by fakes or test doubles. This way, we don't need to create builder methods for every combination of services we need inside our tests.

Let me introduce you to `TypeBuilder`. This is a helper class I've been using in one of my client's projects to create services inside our unit tests.

This `TypeBuilder` class uses reflection to find all the parameters in the constructor of the service to build. And, it uses [Moq to build fakes]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}) for each parameter.

`TypeBuilder` expects a single constructor. But, you can easily extend it to pick the one with more parameters.

```csharp
public class TypeBuilder<T>
{
    private readonly Dictionary<Type, object> _instances = new Dictionary<Type, object>();
    private readonly Dictionary<Type, Mock> _mocks = new Dictionary<Type, Mock>();

    public T Build()
    {
        Type type = typeof(T);
        ConstructorInfo ctor = type.GetConstructors().First();
        ParameterInfo[] parameters = ctor.GetParameters();

        var args = new List<object>();
        foreach (var param in parameters)
        {
            Type paramType = param.ParameterType;

            object arg = null;

            if (_mocks.ContainsKey(paramType))
            {
                arg = _mocks[paramType].Object;
            }
            else if (_instances.ContainsKey(paramType))
            {
                arg = _instances[paramType];
            }

            if (arg == null)
            {
                if (!_mocks.ContainsKey(paramType))
                {
                    Type mockType = typeof(Mock<>).MakeGenericType(paramType);
                    ConstructorInfo mockCtor = mockType.GetConstructors().First();
                    var mock = mockCtor.Invoke(null) as Mock;

                    _mocks.Add(paramType, mock);
                }

                arg = _mocks[paramType].Object;
            }

            args.Add(arg);
        }

        return (T)ctor.Invoke(args.ToArray());
    }

    public TypeBuilder<T> WithInstance<U>(U instance, bool force = false) where U : class
    {
        if (instance != null || force)
        {
            _instances[typeof(U)] = instance;
        }

        return this;
    }

    public TypeBuilder<T> WithMock<U>(Action<Mock<U>> mockExpression) where U : class
    {
        if (mockExpression != null)
        {
            var mock = Mock<U>();
            mockExpression(mock);

            _mocks[typeof(U)] = mock;
        }

        return this;
    }

    public Mock<U> Mock<U>(object[] args = null, bool createInstance = true) where U : class
    {
        if (!_mocks.TryGetValue(typeof(U), out var result) && createInstance)
        {
            result = args != null
                ? new Mock<U>(args)
                : new Mock<U>();

            _mocks[typeof(U)] = result;
        }

        return (Mock<U>)result;
    }
}
```

Let's rewrite our sample test to use the `TypeBuilder` class.

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;

namespace WithTypeBuilder
{
    [TestClass]
    public class OrderServiceTestsTypeBuilder
    {
        [TestMethod]
        public void PlaceOrder_ItemInStock_CallsPaymentGateway()
        {
            // 1. Create a builder
            var typeBuilder = new TypeBuilder<OrderService>();
            // 2. Configure a IStockService fake with Moq
            typeBuilder.WithMock<IStockService>(mock =>
            {
              mock.Setup(t => t.IsStockAvailable(It.IsAny<Order>()))
                  .Returns(true);
            });
            // 3. Build an OrderService instance
            var service = typeBuilder.Build();

            var order = new Order();
            service.PlaceOrder(order);

            // Retrieve a fake from the builder
            typeBuilder.Mock<IPaymentGateway>()
                  .Verify(t => t.ProcessPayment(It.IsAny<Order>()));
          }
    }
}
```

This is what happened. First, we create a builder with `var typeBuilder = new TypeBuilder<OrderService>();`.

Then, to register a custom fake, we used the method `WithMock<T>()`. And inside it, we configured the behavior of the fake.

In our case, we created a fake `StockService` that returns `true` for any order. We did that in these lines:

```csharp
typeBuilder.WithMock<IStockService>(mock =>
{
    mock.Setup(t => t.IsStockAvailable(It.IsAny<Order>()))
        .Returns(true);
});
```

After that, with the method `Build()` we got an instance of the `OrderService` class with fakes for all its parameters. But, the fake for `IStockService` has the behavior we added in the previous step.

Finally, in the Assert part, we retrieved a fake from the builder with `Mock<T>()`. We use it to verify if the payment gateway was called or not. We did this here:

```csharp
typeBuilder.Mock<IPaymentGateway>()
            .Verify(t => t.ProcessPayment(It.IsAny<Order>()));
```

This `TypeBuilder` class comes in handy to avoid creating builders manually for every service in our unit tests.

Did you notice in our example that we didn't have to write fakes for all collaborators? We only did it for the `IStockService`. The `TypeBuilder` took care of the other fakes.

## 3. Auto-mocking with AutoFixture

If you prefer a more battle-tested solution, let's replace our `TypeBuilder` with AutoFixture.

### What AutoFixture does

From its docs, [AutoFixture](https://autofixture.github.io/) _"is a tool designed to make Test-Driven Development more productive and unit tests more refactoring-safe"_.

AutoFixture creates test data for us. It helps us to simplify the Arrange parts of our tests.

To start using AutoFixture, let's install its NuGet package `AutoFixture`.

For example, we can create orders inside our tests with:

```csharp
Fixture fixture = new Fixture();
fixture.Create<Order>();
```

AutoFixture will initialize all properties of an object to random values. Optionally, we can hardcode our own values if we want to.

### AutoMoq

AutoFixture has integrations with mocking libraries like Moq to create services with all its parameters replaced by fakes. To use these integrations, let's install the NuGet package `AutoFixture.AutoMoq`.

Let's rewrite our sample test, this time to use AutoFixture with AutoMoq. It will look like this: 

```csharp
using AutoFixture;
using AutoFixture.AutoMoq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;

namespace WithAutoFixture
{
    [TestClass]
    public class OrderServiceTestsAutoFixture
    {
        // 1. Create a field for AutoFixture
        private readonly IFixture Fixture = new Fixture()
                            .Customize(new AutoMoqCustomization());

        [TestMethod]
        public void PlaceOrder_ItemInStock_CallsPaymentGateway()
        {
            var stockedService = Fixture.Freeze<Mock<IStockService>>();
            //                   ^^^^^
            // 2. Use Freeze to create a custom fake
            stockedService.Setup(t => t.IsStockAvailable(It.IsAny<Order>()))
                          .Returns(true);
            var paymentGateway = Fixture.Freeze<Mock<IPaymentGateway>>();
            var service = Fixture.Create<OrderService>();
            //            ^^^^^
            // 3. Use Create to grab an auto-mocked instance

            var order = new Order();
            service.PlaceOrder(order);

            paymentGateway.Verify(t => t.ProcessPayment(order));
        }
    }
}
```

Notice this time, we used a field in our test to hold a reference to AutoFixture `Fixture` class. Also, we needed to add the `AutoMoqCustomization` behavior to make AutoFixture a type builder.

To retrieve a fake reference, we used the `Freeze()` method. We used these references to plug the custom behavior for the `IStockService` fake and to verify the `IPaymentGateway` fake.

Voilà! That's how we can use a `TypeBuilder` helper class and AutoFixture to simplify the Arrange parts of our tests. If you prefer a simple solution, use the `TypeBuilder` class. But, if you don't mind adding an external reference to your tests, use AutoFixture. Maybe, you can use it to create test data too.

If you want to know what fakes and mocks are, check [What are fakes in unit testing: mocks vs stubs]({% post_url 2021-05-24-WhatAreFakesInTesting %}) and learn these [5 tips to write better stubs and mocks]({% post_url 2021-06-07-TipsForBetterStubsAndMocks %}). Are you new to mocking libraries? Read my post on [how to write fakes with Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}).

_Happy testing!_