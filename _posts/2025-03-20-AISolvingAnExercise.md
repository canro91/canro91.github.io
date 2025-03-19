---
layout: post
title: "I Asked Phind and Copilot to Solve an Interview Exercise—Their Solutions Surprised Me"
tags: csharp interview
---

Did AI kill the tech interview?

Truth is hiring and interviewing have been broken for years. There wasn't much left to kill. In over 10 years, I've witnessed all types of interviews: casual conversations, interrogation-like conversations with rapid-fire questions, [take-home coding exercises]({% post_url 2021-11-22-CodingChallengeTips %}), and the infamous LeetCode exercises.

I asked [Phind](https://www.phind.com/) and [Copilot](https://copilot.microsoft.com/) to solve an interview exercise. I might or might not have been asked that exercise when [applying to a FAANG]({% post_url 2024-05-27-ApplyingToFaang %}).

Here's the "made-up" problem:

> _You're given a string containing the words "one" and "two", and the symbols "+" and "-" representing a math expression. Write a C# function called "Evaluate" to evaluate that expression after replacing "one" with 1 and "two" with 2. Assume the underlying expression is well-formed. For example, "one+one" should return 2, "two-two-one-two" should return -3, and "one+two-one-one+two+one" should return 4._

I'm using that exact same problem statement as a prompt for both Phind and Copilot. I know...I could have a more advanced prompt.

## In this corner, with over 10 years of C# experience, me:

Here's my "pure string evaluation" solution:

```csharp
private int Evaluate(string str)
{
    var first = str[..3];
    var result = first == "one" ? 1 : 2;

    var index = 3;
    var lastOperation = '+';
    while (index < str.Length)
    {
        var substring = str.Substring(index);
        if (substring.StartsWith('+'))
        {
            lastOperation = '+';
            index++;
        }
        else if (substring.StartsWith('-'))
        {
            lastOperation = '-';
            index++;
        }
        else if (substring.StartsWith("one"))
        {
            result = lastOperation == '+' ? result + 1 : result - 1;
            index += 3;
        }
        else if (substring.StartsWith("two"))
        {
            result = lastOperation == '+' ? result + 2 : result - 2;
            index += 3;
        }
    }

    return result;
}
```

OK, that's ugly and has lots of repetition. I looped through the string to identify if I was visiting a number or a symbol and stored the last known number and operation.

Nothing fancy! Probably I wouldn't have hired myself with that solution. But, hey, "it works on my machine."

And, let's see what Phind and Copilot do. Place your bets...Drum rolls...

## In this corner, with its "largest and most performant model to date," Phiiiiind

Here's Phind's exact solution (here's [my conversation](https://www.phind.com/search/cm8gf90xt0000356sfvlvirfn) but I don't know how long it's stored though):

```csharp
public static class WordNumberEvaluator
{
    private const string ONE = "one";
    private const string TWO = "two";

    /// <summary>
    /// Evaluates a mathematical expression containing word numbers 'one' and 'two'.
    /// </summary>
    /// <param name="expression">The expression to evaluate</param>
    /// <returns>The numerical result of the expression</returns>
    public static int Evaluate(string expression)
    {
        // Replace word numbers with digits
        string processed = expression
            .Replace(ONE, "1")
            .Replace(TWO, "2");

        // Use DataTable.Compute to evaluate the expression
        var dataTable = new DataTable();
        var result = dataTable.Compute(processed, String.Empty);

        return Convert.ToInt32(result);
    }
}

public class Program
{
    public static void Main()
    {
        Console.WriteLine(WordNumberEvaluator.Evaluate("one+one"));       // Outputs: 2
        Console.WriteLine(WordNumberEvaluator.Evaluate("two-two-one-two")); // Outputs: -3
        Console.WriteLine(WordNumberEvaluator.Evaluate("one+two-one-one+two+one")); // Outputs: 4
    }
}
```

Phind surprised me a lot.

1. It used a `DataTable` to evaluate expressions. I didn't know `DataTable` could do that. I wouldn't have thought about that in a real interview.
2. It added docstring comments and two comments to explain its solution.

But that didn't surprise me as much as seeing all the tests turning green when I ran its solution. For a moment, I thought using a `DataTable` was a hallucination. [A veteran coder warned me about them]({% post_url 2025-02-24-AVeteranOnAI %}) the other day.

OK, the thing was Phind referenced 4 sources. Two of them were Medium posts talking about evaluating math expressions, but nothing inside them related to the solution it used.

## And in this corner, backed by Microsoft, Copiiiiilot

Here's Copilot's solution:

```csharp
using System;
using System.Data;

class Program
{
    static void Main()
    {
        Console.WriteLine(Evaluate("one+one")); // Output: 2
        Console.WriteLine(Evaluate("two-two-one-two")); // Output: -3
        Console.WriteLine(Evaluate("one+two-one-one+two+one")); // Output: 4
    }

    public static int Evaluate(string expression)
    {
        // Replace "one" and "two" with their numeric equivalents
        expression = expression.Replace("one", "1").Replace("two", "2");

        // Use DataTable to evaluate the expression
        DataTable table = new DataTable();
        return Convert.ToInt32(table.Compute(expression, string.Empty));
    }
}
```

OK, I used Copilot on a browser, not inside my Visual Studio or Visual Studio Code. Same trick with `DataTable`. I wasn't impressed the second time.

Not even in my dreams, (and I don't dream about code) I would have thought about using `DataTable` as the trick under my sleeve here, especially with a clock-ticking on a platform like LeetCode or with a hiring manager looking at my screen.

Did AI kill the tech interview? I'd say yes, at least for data structure and algorithm questions. OK, I only tried it with one coding exercise, but that's still a yes.
