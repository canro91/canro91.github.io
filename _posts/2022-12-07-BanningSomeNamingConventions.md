---
layout: post
title: "I'm banning Get, Set, and other method and class names"
tags: csharp
cover: Cover.png
cover-alt: "Necklace with names"
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

Names are important in programming. Good names could be the difference between a developer nodding his head in agreement or making funny faces in a "Wait, whaaaat?" moment. Names are so important that the [Clean Code]({% post_url 2020-01-06-CleanCodeReview %}) and [The Art of Readable Code]({% post_url 2021-12-20-TheArtOfReadableCodeReview %}) devote entire chapters to the subject. These are some words I'm banning from my method and class names.

## 1. Get and Set in method names

I wish I could remember what Kevlin Henney's presentation has this idea. He argues that "Get" and "Set" are some words with more meanings in an English dictionary. Then why do we use them in our code when our names should be the least ambiguous as possible? He has a point!

These days I [reviewed a pull request]({% post_url 2022-12-05-LeadingQuestionsOnCodeReviews %}) that had a code block that reminded me about this point. It looked like this,

```csharp
public record RoomCharge(
    ReceiptId ReceiptId,
    RoomId RoomId,
    ReservationId? ReservationId = null)
{
    public void SetReservationId(ReservationId reservationId)
    //          ^^^^^
    {
        ReservationId = reservationId;
    } 
}
```

Maybe `WithReservationId()` or simply `ReservationId()` would be better alternatives. Even an old auto-implemented property would get our backs covered here.

<figure>
<img src="https://images.unsplash.com/photo-1568630341816-3087686712dc?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY2ODcyNDE0MA&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Danger do not entry sign" />

<figcaption>Do not cross. Photo by <a href="https://unsplash.com/@bailey_i?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Issy Bailey</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 2. Utility and Helper classes

The next names I'm banning are the "Utility" and "Helper" suffixes in class names. Every time I see them, I wonder if the author (and I) missed an opportunity to create domain entities or better named classes.

In one of my client's projects, I had to work with a class that looked like this,

```csharp
public static class MetadataHelper
{
    public static void AddFeeRates(Fee fee, PaymentRequest request, IDictionary<string, string> metadata)
    {
        // Doing something with 'fee' and 'request' to populate 'metadata'...
    }

    public static void AddFeeRates(Fee fee, StripePaymentIntent paymentIntent, IDictionary<string, string> metadata)
    {
        // Doing something with 'fee' and 'paymentIntent' to populate 'metadata'...
    }
}
```

It was a class that generated some payment metadata based on payment fees and requests. Somebody took the easy route and dumped everything in a static `MetadataHelper` class.

Instead, we could write a non-static `PaymentMetadata` class to wrap the metadata dictionary. Like this,

```csharp
public class PaymentMetadata
{
    private readonly IDictionary<string, string> _metadata;

    public PaymentMetadata(IDictionary<string, string> baseMetadata)
    {
        _metadata = baseMetadata;
    }

    public void AddFeeRates(Fee fee, PaymentRequest request)
    {
        // Doing something with 'fee' and 'request' to expand 'metadata'...
    }

    public void AddFeeRates(Fee fee, StripePaymentIntent paymentIntent)
    {
        // Doing something with 'fee' and 'paymentIntent' to expand 'metadata'...
    }

    public IDictionary<string, string> ToDictionary()
        => _metadata;
}
```

**If a concept is important inside the business domain, we should promote it out of helper classes.**

Often, we use Utility and Helper classes to dump all kinds of methods we couldn't find a good place for.

## 3. Constants classes

This isn't exactly a name. But the last thing I'm banning is Constant classes. I learned this lesson after reading [Domain Modeling Made Functional]({% post_url 2021-12-13-DomainModelingMadeFunctional %}).

Recently, I found some code that looked like this,

```csharp
public static class Constants
{
    public static class TransactionTypeId
    {
        public const int RoomCharge = 1;
        public const int PaymentMethod = 2;
        public const int Tax = 3;
    }

    public const string OtherConstant = "Anything";
    public const string AnythingElse = "Anything";
}
```

It was a class full of unrelated constants. Here, I only showed five of them. Among those, I found the types of transactions in a reservation management system.

On the caller side, a method that expects any of the `TransactionTypeId` uses an `int` parameter. For example,

```csharp
public void ItUsesATransactionTypeId(int transactionTypeId)
//                                   ^^^
{
    // Beep, beep, boop...
}
```

But, any `int` won't work. Only those inside the Constants class are the valid ones.

This gets worse when Constant classes start to proliferate, and every project of a solution has its own Constants class. Arggggg!

Instead of Constants classes, let's use enums to restrict the values we can pass to methods. Or, at least, let's move the constants closer to where they're expected, not in a catch-all class. With an enum, the compiler helps us to check if we are passing a "good" value.

Using an enum, our previous example looks like this,

```csharp
public enum TransactionTypeId
{
    RoomCharge,
    PaymentMethod,
    Tax
}

public void ItUsesATransactionTypeId(TransactionTypeId transactionTypeId)
//                                   ^^^^^^^^^^^^
{
    // Beep, beep, boop...
}
```

Voilà! These are the names I'm banning in my own code. And I wish I could ban them in code reviews too. Are you also guilty of any of the three? I've been there and done that.

Speaking about names, check [How to name your unit tests]({% post_url 2021-04-12-UnitTestNamingConventions %}) to write more descriptive test names and [A real-world case of primitive obsession]({% post_url 2020-12-10-PrimitiveObsession %}) to learn to enforce business constraints and rules with domain entities.

_Happy naming!_