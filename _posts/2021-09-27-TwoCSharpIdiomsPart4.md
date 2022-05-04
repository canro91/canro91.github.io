---
layout: post
title: "Two C# idioms: On defaults and switch"
tags: tutorial csharp
series: C# idioms
cover: Cover.png
cover-alt: "Two C# idioms"
---

In this part of the C# idioms series, we have one idiom to write more intention-revealing defaults and another idiom to convert mapping code using a `switch` to a more compact alternative using a dictionary.

## Use intention-revealing defaults

When initializing variables to default values, use intention-revealing alternatives.

Are you initializing a string variable to later assign it? Use `""`. Do you want to return an empty string from a method? Use `string.Empty`.

The same is true for collections. If you're initializing a collection to later add some elements, use the normal constructors like `new string[length];` or `new List<string>();`.

But, if you want to return an empty collection. Use `Array.Empty<string>()` or `Enumerable.Empty<string>()`.

## Replace switch with a dictionary

Replace `switch` mapping two types with a dictionary.

Turn every value in the `case` statements into a key in the dictionary. And, turn the returned value in every `case` into the value of the matching key in the dictionary.

To replace the `default` case, take advantage of the `TryGetValue()` or `GetValueOrDefault()` methods.

Before, to map from a credit card brand name in strings to a `CardType` enum, we did this,

```csharp
public static CardType MapToCardType(string cardBrand)
{
    CardType cardType;

    switch (cardBrand)
    {
        case "Visa":
            cardType = CardType.Visa;
            break;

        case "Mastercard":
            cardType = CardType.MasterCard;
            break;

        case "American Express":
            cardType = CardType.AmericanExpress;
            break;

        default:
            cardType = CardType.Unknown;
            break;
    }
    return cardType;
}
```

After, replacing the `switch` with a `Dictionary`,

```csharp
public static CardType MapToCardType(string cardBrand)
{
    var cardTypeMappings = new Dictionary<string, CardType>
    {
        { "Visa", CardType.Visa },
        { "Mastercard", CardType.Mastercard },
        { "American Express", CardType.AmericanExpress }
    };
    return cardTypeMappings.TryGetValue(cardBrand, out var cardType)
                ? cardType
                : CardType.Unknown;
}
```

### C# 8.0 and Dictionaries

Also, we can use the newer `switch` syntaxt from [C# version 8.0]({% post_url 2021-09-13-TopNewCSharpFeatures %}) to write more compact `switch`. 

Starting from C# version 8.0, `switch` are expressions. It means we can assign `switch` to variables and use `switch` as returned values.

Notice how we use a discard `_` in the `default` case to throw an exception.

```csharp
public static CardType MapToCardType(string cardBrand)
{
    return cardBrand switch
    {
      "Visa" => CardType.Visa,
      "MasterCard" => CardType.MasterCard,
      "American Express" => CardType.AmericanExpress,
      _ => CardType.Unknown
    };
}
```

Voilà! These are the C# idioms for today. Remember to use intention-revealing defaults and take advantage of the new C# features for `switch`.

If you want to check more C# recent features, check [my Top 16 newest C# features]({% post_url 2021-09-13-TopNewCSharpFeatures %}). To get rid of exceptions when working with dictionaries, check [Idioms on Dictionaries]({% post_url 2020-08-01-AnotherTwoCSharpIdiomsPart3 %}).

And, don't miss the other C# Idioms.

_Happy coding!_