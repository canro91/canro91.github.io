---
layout: post
title: "TIL: Always Use a Culture When Parsing Numeric Strings in C#"
tags: todayilearned csharp
---

This week, I reinstalled the operating system of my computer. The new version uses Spanish instead of English. After that, some unit tests started to break in one of my projects. The broken tests verified the formatting of currencies. This is what I learned about parsing numeric strings and unit testing.

**To have a set of always-passing unit tests, use a default culture when parsing numeric strings. Add a default culture to the Parse() and ToString() methods on decimals. As an alternative, wrap each test in a method to change the current culture during its execution**.

## Failing to parse numeric strings

Some of the failing tests looked like the one below. These tests verified the separator for each supported currency in the project.

```csharp
[TestMethod]
public void ToCurrency_IntegerAmount_FormatsAmountWithTwoDecimalPlaces()
{
    decimal value = 10M;
    var result = value.ToCurrency();

    Assert.AreEqual("10.00", result);
}
```

And this was the `ToCurrency()` method.

```csharp
public static string ToCurrency(this decimal amount)
{
    return amount.ToString("0.00");
}
```

The `ToCurrency()` method didn't specify any culture. Therefore, it used the user's current culture. And, the tests expected `.` as the separator for decimal places. That wasn't the case for the culture I started to use after reinstalling my operating system. It was `,`. That's why those tests failed.

## Use a default culture when parsing

To make my failing tests always pass, no matter the culture, I added a default culture when parsing numeric strings.

**Always add a default culture when parsing numeric strings.**

For example, you can create `ToCurrency()` and `FromCurrency()` methods like this:
    
```csharp
public static class FormattingExtensions
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

Notice that I added a second parameter of type `CultureInfo`, which defaults to "en-US."

## Alternatively: Use a wrapper in your tests

As an alternative to adding a default culture, I could run each test inside a wrapper that changes the user culture to the one needed and revert it when the test finishes.

Something like this,

```csharp
static string RunInCulture(CultureInfo culture, Func<string> action)
{
    var originalCulture = Thread.CurrentThread.CurrentCulture;
    Thread.CurrentThread.CurrentCulture = culture;
    
    try
    {
        return action();
    }
    finally
    {
        Thread.CurrentThread.CurrentCulture = originalCulture;
    }
}
```

Then, I could refactor the tests to use the `RunInCulture` wrapper method, like this,

```csharp
private readonly CultureInfo DefaultCulture
  = new CultureInfo("en-US");

[TestMethod]
public void ToCurrency_IntegerAmount_FormatsAmountWithTwoDecimalPlaces()
{
    RunInCulture(DefaultCulture, () =>
    {
        decimal value = 10M;
        var result = value.ToCurrency();

        Assert.AreEqual("10.00", result);
    });
}
```

Voilà! That's what I learned after reinstalling my computer's operating system and running some unit tests. I learned to use a default culture in all of my parsing methods. If you change your computer locale, all your tests continue to pass?

If you're new to unit testing, read [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}), [4 common mistakes when writing unit tests]({% post_url 2021-03-29-UnitTestingCommonMistakes %}) and [4 test naming conventions]({% post_url 2021-04-12-UnitTestNamingConventions %}). Don't miss the rest of my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where I also cover mocking, assertions, and best practices.

{%include ut201_course.html %}

_All tests turned green!_