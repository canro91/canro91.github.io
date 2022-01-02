---
layout: post
title: "Postfix Notation: An Interview Exercise"
tags: tutorial interview csharp
---

You are applying for your first position or for a new job. You are asked to complete a coding exercise: evaluate an expression in postfix notation. Let's see what is postfix notation and how to evaluate postfix expressions in C#.

## What is Postfix Notation?

Math and some programming languages use the infix notation. It places the operator between the two operands. And, it uses parenthesis to group operations. For example, `a + b` and `(a + b)*c`.

**Unlinke infix notation, postfix notation places the operator after the two operands. And, it doesn't use any parenthesis to group expresions. For example, a b + , and  a b + c * are two expression in postfix notation.**

Postfix expressions are evaluated from left to right. The expression `2 3 1 * + 9 -`  in postfix notation is equivalent to `(2 + (3 * 1)) - 9`.

## Interview Question

This is your interview question: Write a C# program to evaluate a postfix mathematical expression. For example, `1 1 +`, `1 1 1 + +`, `1 1 + 2 3 * -`.

During your technical interview, don't rush to start coding right away. Follow the next steps:

* Understand the problem
* Come up with some examples. _What's the simplest case? Any edge cases?_
* Ask clarification questions. _Do you need to validate your input values?_
* Think out loud your solution. Your interviewer wants to see your thought process.
* Make assumptions on the input. Start with the simplest case and work through a complete solution.

<figure>
<img src="https://images.unsplash.com/photo-1484632105053-8662f3194e7f?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop" alt="a pile of empty dishes" />

<figcaption>To evaluate a postfix expression, we need a stack. <span>Photo by <a href="https://unsplash.com/@brookelark?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Brooke Lark</a> on <a href="https://unsplash.com/photos/KyUmKlXrhAM?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## Evaluate postfix expressions

To evaluate a postfix expression, you need a stack.

**A stack is a pile-like data structure**. Stacks support two operations: add something to the pile, **push**, and remove something from the pile, **pop**.

When evaluating a postfix notation, we use a stack to hold either values from the input or already computed values.

This is the pseudocode to evaluate a postfix expression:

1. Create an stack
2. Split input string
3. If the first splitted value is a number, push it to the stack.
4. But, if it's an operator, pop the two operands from the stack. Do the Math operation and push the result back to the stack.
5. Go to next splitted value and repeat
6. Finally, return value in the stack

### Let's C#!!!

Now, head to Visual Studio or Visual Studio Code and create a new project. This is how we evaluate a postfix expression in C#.

First, let's split the input string with the `Split()` method. To identify the operators and operands, we can use either string comparisons or regular expressions. Let's use regular expressions.

```csharp
Regex _operandRegex = new Regex(@"-?[0-9]+");
Regex _operatorRegex = new Regex(@"[+\-*\/]");
        
public string Evaluate(string postfixExpression)
{
    var tokens = new Stack();
    string[] rawTokens = postfixExpression.Split(' ');
    foreach (var t in rawTokens)
    {
        if (_operandRegex.IsMatch(t))
        {
            tokens.Push(t);
        }
        else if (_operatorRegex.IsMatch(t))
        {
            var t1 = tokens.Pop().ToString();
            var t2 = tokens.Pop().ToString();
            var op = t;

            var result = EvaluateSingleExpression(t2, t1, op);
            if (result != null)
            {
                tokens.Push(result);
            }
        }
    }
    if (tokens.Count > 0)
    {
       return tokens.Pop().ToString();
    }

    return "";
}

private static string EvaluateSingleExpression(string value1, string value2, string op)
{
    var operand1 = Convert.ToDouble(value1);
    var operand2 = Convert.ToDouble(value2);

    if (op == "+")
    {
        var result = operand1 + operand2;
        return Convert.ToString(result);
    }
    // Similar logic for other operators

    return null;
}
```

Voila! That's how we can evaluate postfix expressions in C#. For more tips to prepare yourself for your next interview, check [my interview tips]({% post_url 2019-09-29-RemoteInterviewTips %}). Also, check my post on [the difference between Func and Action in C#]({% post_url 2019-03-22-WhatTheFuncAction %}) and [how to solve the two-sum problem]({% post_url 2019-08-29-TimeComplexity %}). Those are another two common interview questions.

_Happy coding!_
