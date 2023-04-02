---
layout: post
title: "Domain Modeling Made Functional: Takeaways"
tags: books
cover: Cover.png
cover-alt: "Domain Modeling Made Functional: Takeaways"
---

If you are curious about the functional world, but you found it too hard to start, this book is a good place to start. These are my notes and takeaways from "Domain Modeling Made Functional" by Scott Wlaschin. 

**"Domain modeling made functional" teaches to start coding only after understanding the domain. And to capture requirements, constraints, and business rules using types in the system.**

This book covers from Domain-Driven Design (DDD) to type systems to refining an existing domain model. It's a jump to functional world designing a system to price and ship orders in a supply store. No jargon or weird concepts needed.

All the code samples are in F#. Most of the time, they're easy to understand. Since F# has a better type inference than C#, types aren't explicit all the time while writing functions. Some code listings are hard to translate to C#.

To follow the code using C#, I had to rely upon libraries like [OneOf](https://github.com/mcintyre321/OneOf) and [Optional](https://github.com/nlkl/Optional) to bring discriminated unions and option types, not built into the C# language yet.

## DDD and Ubiquitous language

**The goal of DDD is to share the business model between developers and domain experts**. In DDD, the business domain drives the design. Not the database schema. Don't rush to think in terms of database tables.

**Write code using the same vocabulary from the business domain**. Domain experts or product owners don't think in integers or strings. But, in business concepts like OrderId, ProductCode. When in doubt, ask your domain expert what an `OrderBase`, `OrderHelper` mean.

## Types everywhere

A type is a name for all possible input and output values in a function. For example, Math functions from one set to another.

There are two ways to construct types: AND types and OR types. An AND type is a combination of other types. And an OR type is a choice between a known set of types. OR types are also called discriminated unions or choice types.

For example, a meal is a combination of an entrée, a main course, and a dessert. And, a dessert is either a cake or a flan. To represent a meal, we need an AND type. And for a dessert, an OR type.

These would be the `Meal` and `Dessert` types in F#,

```fsharp
type Meal = {
  Entree: EntreeInfo
  MainCourse: MainCourseInfo
  Dessert: DessertInfo
}

type DessertInfo =
  | Cake
  | Flan
```

In the Object-Oriented (OO) world, types are like classes without behavior or single-method interfaces. Types represent a set of functions too. AND types are regular classes with properties. While OR types are enums with, possibly, members of different types.

<figure>
<img src="https://images.unsplash.com/photo-1631856954913-c751a44490ec?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzNDE2NzI1Mw&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="plumbing supplies in Home Depot" />

<figcaption>Who needs plumbing supplies? Photo by <a href="https://unsplash.com/@oksdesign?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Oxana Melis</a> on <a href="https://unsplash.com/s/photos/hardware-store?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Restrictions, Errors, and Invalid State

### Restrictions

**Express restrictions in your design and enforce constraints with new types**.

To represent unit quantities in orders, don't use a plain integer. Unit is a concept in the business domain. It should be in a separate type, like `UnitQuantity`.

To restrict unit quantities between 1 and 1000, create a private constructor in the `UnitQuantity` type and only expose a factory method with the validation.

To enforce that an order should have at least one line item, create a `NonEmptyList` instead of a possibly empty `List`.

To represent optional values, use `Option<T>` instead of `null` values.

### Errors and Exceptions: Signature method honesty

**Make errors part of your domain**. Follow the Signature Method honesty: document all possible outputs in the signature of types.

For example, a `Divide` function shouldn't throw an exception. Instead write, `int Divide(int a, NonZeroInt b);`

Stay away from exceptions and instead use a `Result` type to wrap failed and successful types.

For example, to check addresses return `Result<CheckedAddress, AddressValidationError>`. It means either a valid address or a validation error.

```fsharp
type CheckAddressExists = UnvalidatedAddress -> Result<CheckedAddress, AddressValidationError>

type AddressValidationError = 
  | InvalidFormat of string
  | AddressNotFound of string
```

To work with exceptions in third-party code, wrap that code in a function that catches exceptions and returns a `Result`. Don't catch all exceptions, only those relevant to the domain. Like, timeouts or failed logins.

### Make illegal state unrepresentable

**Convert a design with two choices to a design with one type per choice**. Booleans are generally a bad design choice.

To represent validated emails, don't create a `CustomerEmail` with an `IsVerified` flag. Instead, create separate types, `VerifiedEmailAddress` and `UnverifiedEmailAddress`.

With types, we don't need unit tests for invalid situations, we have compile-time unit tests. Also, types better document the business domain.

## Transformation-oriented programming

Write actions in your system as workflows or chains of transformations.

A workflow is a pipeline where the output type of every step is the input of the next one. A workflow receives commands and returns events as outputs. A command should have everything needed to start a workflow.

Put all the I/O at the edges. Call the database at the beginning or at the end of a workflow.

For example, these are the types of a `PlaceOrderWorkflow` and the types of its steps.

```fsharp
type ValidateOrder =  UnvalidatedOrder -> ValidatedOrder
type PriceOrder = ValidatedOrder -> PricedOrder
type AcknowledgeOrder = PricedOrder -> AcknowlegementSent option
type CreateEvents = PricedOrder -> PlaceOrderEvent list

type PlaceOrderWorflow = PlaceOrderCommand -> Result<PlaceOrderEvent list, PlaceOrderError>
``` 

## Challenges

After reading this book, there are two things I want to change in the codebases around me.

### 1. Replace Constants class with enums

First, don't use a `Constants` class for an exhaustive list of known values or options. Use enums instead.

```csharp
public static class Constants
{
    public static readonly string Authorize = nameof(Authorize).ToLower();
    public static readonly string Capture = nameof(Capture).ToLower();
    public static readonly string Refund = nameof(Refund).ToLower();
}

public PaymentResponse PerformOperation(string operation, PaymentRequest request)
{
    // ...
}
```

By using strings as parameters, we can pass any string to the receiving method. But, the only valid options are then ones inside the `Constants` class. Enums are better to make illegal states unrepresentable in this case.

```csharp
public enum OperationType
{
    Authorize,
    Capture,
    Refund
}

public PaymentResponse PerformOperation(OperationType operation, PaymentRequest request)
{
    // ...
}
```

### 2. Separate states, separate classes

Last challenge, don't use a single class with a boolean property to represent two states. Use two types instead.

For example, don't write a `PaymentResponse` with a `HasError` flag for failed and successful payments. Like this,

```csharp
public class PaymentResponse
{
    public bool HasError { get; set; }

    public bool ErrorMessage { get; set; }

    // ...
}
```

Instead, write two separate classes: `FailedPayment` and `SuccessfulPayment`. Like this,

```csharp
public class FailedPayment
{
    public bool HasError { get; } = true;

    public bool ErrorMessage { get; set; }

    // ...
}

public class SuccessfulPayment
{
    // No HasError and ErrorMessage...
    // ...
}
```

Also, as part of this last challenge, not only separate a class with a boolean type into two classes, but also [separate optional or nullable state to avoid NullReferenceException]({% post_url 2023-04-03-SeparateStateIntoSeparateObjects %}).

## Putting types into practice

I had the chance to practice what I've learned with this book, even before finishing it.

Here are my requirements. After getting a reservation, hotels want to charge a deposit before the guests arrive. They want to charge some nights, a fixed amount, or a percentage, either after getting the reservation or before the arrival date.

This is what I came up with. Better than a single class full of string, bool, and int properties. That would have been my approach before reading this book.

```csharp
public class Deposit 
{
    public Charge Charge { get; set; }
    public Delay Delay { get; set; }
}

public abstract class Charge {}
public class Night : Charge
{
    public int Nights { get; set; }
}
public class FixedAmount : Charge
{
    public decimal Amount { get; set; }
    public CurrencyCode Currency { get; set; }
}
public enum CurrencyCode
{
    USD,
    Euro,
    MXN,
    COP
}
public class Percentage : Charge
{
    public decimal Amount { get; set; }
}

public class Delay
{
    public int Days { get; set; }
    public DelayType DelayType { get; set; }
}
public enum DelayType
{
    BeforeCheckin,
    AfterReservation
}
```

## Parting thoughts

Voilà! These are the lessons I learned from this book. It's a good introduction to DDD and functional programming. If you're not a functional programmer, you can still take advantage of the concepts of this book in your everyday programming. I did.

You can skip the last 2 or 3 chapters. If you're new to F# and want to work with it, they contain good examples of serialization and databases. But, if you want to adopt these concepts to your OO world, you can skim these chapters for the main concepts. 

> _"A class with a boolean to represent two states is generally a smell."_

I liked that one.

For more takeaways, check [Clean Coder]({% post_url 2020-06-15-CleanCoder %}) and [The Art of Unit Testing]({% post_url 2020-03-06-TheArtOfUnitTestingReview %}). Don't miss, [A case of Primitive Obsession]({% post_url 2020-12-10-PrimitiveObsession %}), it shows how to put in place classes to replace plain primitive types.

_Happy coding!_