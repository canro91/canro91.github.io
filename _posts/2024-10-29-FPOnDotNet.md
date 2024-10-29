---
layout: post
title: "Using Lambda Expressions Doesn't Make Your C# Code Functional"
tags: csharp
---

C# will never become a truly functional language.

Sure, C# is borrowing features from functional languages like records, pattern matching, and switch expressions. But it doesn't make it a functional language.

At its core, C# is an Object Oriented language — with mutable state baked in. But it doesn't mean we can make it functional with a few tweaks.

That's the main takeaway from the talk "Functional Programming on .NET" by Isaac Abraham at NDC Conference 2024.

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/V9GYPOsPj4M?rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

Here are some other lessons I learned from that talk.

## Here are two misconceptions about Functional Programming

**1. "It's difficult"**

When we hear "Functional Programming" what comes to mind is obscure jargon like monad, monoids, and endofunctors. They sound like you have to grow a beard to understand them. That scares programmers away from Functional Programming.

**2. "I'm already using lambda expressions"**

Lambda expressions and other recent features are syntactic sugar to make C# less verbose. Lambda expressions simplify delegates. And we've had delegates since C# 1.0 when C# looked way less functional than today.

The truth is functional programming could be simpler and lambda expressions don't make C# functional.

## If lambda expressions and other features don't make C# functional, what is it then?

Expressions and Immutability.

Expressions mean everything has a result. Think of old-style switch/case statements vs switch expressions. We can assign the result of a switch expression to a variable, but not an old-style switch/case. If it can be assigned to the left of =, it's an expression.

```csharp
// This is not an expression
switch (cardBrand)
{
    case "Visa":
        cardType = CardType.Visa;
        break;

    case "Mastercard":
        cardType = CardType.MasterCard;
        break;

    default:
        cardType = CardType.Unknown;
        break;
}

// This is an expression
var cardType = cardBrand switch
{
    "Visa" => CardType.Visa,
    "MasterCard" => CardType.MasterCard,
    _ => CardType.Unknown
};
```

And immutability means that everything is set for life. Think of records, the `init` keyword, and private setters.

With these two concepts, to make C# functional, we should forget about classes and inheritance to go with static methods. We should forget constructor injection and go with regular method parameters. And we should separate data from behavior instead of keeping them side by side in a class that mutates state.

Following these two concepts, a dummy `Calculator` that looks like this

```csharp
public class Calculator(ILogger _logger)
{
    private int Value { get; private set; }
    public void Add(int a)
    {
        _logger.Log($"Adding {a}");
        Value += a;
    }
}
```

will look like this instead

```csharp
public static class FunctionalishCalculator
{
    public int Add(Action<string> logger, int value, int a)
    {
        logger($"Adding {a}");
        return value + a;
    }
}
```

And in F#, it will look like this

```fsharp
let add logger value a =
    logger $"Adding {a}"
    value + a
```

A few lines of code. In F#, functions don't have to live in classes. The compiler infers parameters types. And we don't need to use the `return` keyword.

## The perfect example of expressions and immutability in practice is LINQ.

LINQ is functional.

Every LINQ method returns a new collection. We don't have "void" LINQ methods. Expressions. And no LINQ methods change the input collection. Immutability.

That's why LINQ is the best of all C# features—It's functional.

Voilà! We don't need fancy features like [discriminated unions]({% post_url 2024-08-19-DiscriminatedUnionSupport %}) to adopt functional ideas in C#. Only those two fundamental concepts. Sure, new features help a lot!

Start by [keeping IO away from your core, at the edges]({% post_url 2024-08-05-IOToTheEdges %}). And go with expressions and immutability.
