---
layout: post
title: TIL&colon; Always Use a Culture When Parsing Numeric Strings in C#
tags: todayilearned csharp
---

This week, I reinstalled the operating system of my computer. The new version uses Spanish, instead of English. After that, lots of unit tests started to break in one of my projects. The broken tests verified the formatting of currencies. Some of the these tests looked like the one below.

```csharp
[TestMethod]
public void ToCurrency_IntegerAmount_FormatsAmountWithTwoDecimalPlaces()
{
    decimal value = 10M;
    var result = value.ToCurrency();

    Assert.AreEqual("10.00", result);
}
```

And, this was the `ToCurrency` method.

```csharp
public static string ToCurrency(this decimal amount)
{
    return amount.ToString("0.00");
}
```

The `ToCurrency` method didn't specify any culture. It used the user current culture. And, the test expected `.` as the separator for decimal places. It wasn't the case for the culture I was using. The separator for my locale was `,`. That's why those tests failed.

**To have a set of always passing unit tests, use a default culture when parsing numeric strings**. Instead of using a plain `Parse` and `ToString` on decimals, add a default culture with these two methods. As an alternative, you could wrap your tests in a helper method to set the appropriate culture to run your tests.

For example, you can create `ToCurrency` and `FromCurrency` methods like this:
    
```csharp
public static class FromattingExtensions
{
    private static CultureInfo DefaultCulture
        = new CultureInfo("en-US");

    public static string ToCurrency(this decimal amount)
    {
        return amount.ToString("0.00", DefaultCulture);
    }

    public static decimal FromCurrency(this string amount)
    {
        return decimal.Parse(amount, DefaultCulture);
    }
}
```

_All tests turned green!_
