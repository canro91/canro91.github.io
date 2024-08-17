---
layout: post
title: "It Seems the C# Team Is Finally Considering Supporting Discriminated Unions"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Three paper planes" 
---

C# is getting more and more functional with every release.

I don't mean functional in the sense of being practical or not. I mean C# is borrowing features from functional languages, like records from F#, while staying a multi-paradigm language.

Yes, C# will never be a fully functional language. And that's by design.

But, it still misses one key feature from functional languages: Discriminated Unions.

## Discriminated Unions Are a Closed Hierarchy of Classes

Think of discriminated unions like enums where each member could be an object of a different, but somehow related, type.

Let me show you an example where a discriminated union makes sense. At a past job, while working with a reservation management software, hotels wanted to charge a deposit before the guests arrived. They wanted to charge some nights, a fixed amount, or a percentage of room charges, right after getting the reservation or before the arrival date.

Here's how to represent that requirement with a discriminated union:

```csharp
public record Deposit(Charge Charge, Delay Delay);

// Of course, I'm making this up...
// This is invalid syntax
public union record Charge // <--
{
    NightCount Nights;
    FixedAmount Amount;
    Percentage Percentage;
}

public record NightCount(int Count);
public record FixedAmount(decimal Amount, CurrencyCode Currency);
public enum CurrencyCode
{
    USD,
    Euro,
    MXN,
    COP
}
public record Percentage(decimal Amount);

public record Delay(int Days, DelayType DelayType);
public enum DelayType
{
    BeforeCheckin,
    AfterReservation
}
```

Here, the `Charge` class would be a discriminated union. It could only hold one of three values: `NightCount`, `FixedAmount`, or `Percentage`.

You might be thinking it looks like a regular hierarchy of classes. And that's right. 

But, the missing piece is that discriminated unions are exhaustive. We don't need a default case when using a discriminated union inside a `switch`. And, if we add a new member to the discriminated union, the compiler will warn us about where we should handle the new member.

Discriminated unions are helpful to express restrictions, constraints, and business rules when working with Domain Driven Design. In fact, using types to represent business rules is the main idea of the book [Domain Modeling Made Functional]({% post_url 2021-12-13-DomainModelingMadeFunctional %}).

For example, discriminated unions are a good alternative when [moving I/O to the edges of our apps]({% post_url 2024-08-05-IOToTheEdges %}) and just returning decisions from our domains.

I told you that C# is borrowing some new features from functional languages. Well, if you're curious, this is how our example will look like in F# using real discriminated unions:

```fsharp
type Deposit = {
    Charge: Charge;
    Delay: Delay;
}

type Charge = // <-- Look, ma! A discriminated union
    | NightCount of int
    | FixedAmount of decimal * CurrencyCode
    | Percentage of decimal

type CurrencyCode =
    | USD
    | Euro
    | MXN
    | COP

type Delay =
    | BeforeCheckin of int
    | AfterReservation of int
```

All credits to [Phind](https://www.phind.com/search?home=true), "an intelligent answer engine for developers," for writing that F# example.

## A Proposal for a Union Keyword

It seems the C# language team is considering fully supporting discriminated unions.

In the official C# GitHub repository, there's a recent [proposal for discriminated unions](https://github.com/dotnet/csharplang/blob/18a527bcc1f0bdaf542d8b9a189c50068615b439/proposals/TypeUnions.md). The goal is to create a new type to "store one of a limited number of other types in the same place" and let C# do all the heavy work to handle variables of that new type, including checking for exhaustiveness.

The proposal suggests introducing a new `union` type for classes and structs. Our example using the `union` type will look like this:

```csharp
public union Charge
//     ^^^^^
{
    NightCount(int Count);
    FixedAmount(decimal Amount, CurrencyCode Currency);
    Percentage(decimal Amount);
}

// This is how to instantiate a union type
Charge chargeOneNight = new NightCount(1); // <--
var oneNightBeforeCheckin = new Deposit(
    chargeOneNight
    //  ^^^^^
    new Delay(1, DelayType.BeforeCheckin));

// This is how to use it inside a switch
var amountToCharge = charge switch {
    NightCount n => DoSomethingHere(n),
    FixedAmount a => DoSomethingElseHere(a),
    Percentage p => DoSomethingDifferentHere(p)
    // No need to declare a default case here...
}
```

The new `union` type will support pattern matching and deconstruction too.

Under the hood, the `union` type will get translated to a hierarchy of classes, with the base class annotated with a new `[Closed]` attribute. And, if the default `union` type doesn't meet our needs, we can use that new attribute directly.

## Two Alternatives While We Wait

The `union` type is still under discussion. We'll have to wait.

In the meantime, we can emulate this behavior using third-party libraries like [OneOf](https://github.com/mcintyre321/OneOf).

Here's how to define our `Charge` type using OneOf:

```csharp
public class Charge : OneOfBase<NightCount, FixedAmount, Percentage>
//                    ^^^^^
{
    public Charge(OneOf<NightCount, FixedAmount, Percentage> input)
        : base(input)
    {
    }
}
// Or using OneOf Source Generation:
//
//[GenerateOneOf] // <--
//public partial class Charge : OneOfBase<NightCount, FixedAmount, Percentage>
//                              ^^^^^
//{
//}

public record NightCount(int Count); // <-- No base class here
public record FixedAmount(decimal Amount, CurrencyCode Currency);
public record Percentage(decimal Amount);

// Here's how to instantiate a OneOf type
var oneNightBeforeCheckin = new Deposit(
    new Charge(new NightCount(1)),
    //         ^^^^^
    new Delay(1, DelayType.BeforeCheckin));
```

OneOf brings methods like `Match`, `Value`, and `AsT0`/`AsT1`/`AsT2` to work with and unwrap the underlying type.

Apart from third-party libraries to emulate discriminated unions, there's an alternative approach abusing records: [Discriminated Onions](https://github.com/salvois/DiscriminatedOnions).

And here's our `Charge` type using discriminated onions:

```csharp
public abstract record Charge
//     ^^^^^
{
    private Charge() { } // <--

    public record NightCount(int Count) : Charge; // <--
    public record FixedAmount(decimal Amount, CurrencyCode Currency) : Charge;
    public record Percentage(decimal Amount): Charge;

    public U Match<U>(
       //    ^^^^^
        Func<NightCount, U> onNightCount,
        Func<FixedAmount, U> onFixedAmount,
        Func<Percentage, U> onPercentage) =>
        this switch
        {
            NightCount r => onNightCount(r),
            FixedAmount c => onFixedAmount(c),
            Percentage p => onPercentage(p),
            _ => throw new ArgumentOutOfRangeException()
        };
}

// Here's how to instantiate a discriminated onion
var oneNightBeforeCheckin = new Deposit(
    new Charge.NightCount(1),
    new Delay(1, DelayType.BeforeCheckin));
```

Voilà! That's what discriminated unions are, and the official proposal to bring them to the C# language.

You see, C# is getting more functional on each release. While we wait to get it more funcy with discriminated unions, we have to go with libraries and workarounds. Let's wait to see how it goes.

For more content, read [What I Don't Like About C# Evolution]({% post_url 2024-07-08-CSharpInconsistencies %}), [An Alternative to Simplify Layering For Read-only Data Access]({% post_url 2023-08-07-TooManyLayers %}) and, [How I Choose Value Objects]({% post_url 2022-12-21-WhenToChooseValueObjects %}).