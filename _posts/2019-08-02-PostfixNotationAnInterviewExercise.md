---
layout: post
title: Postfix Notation&colon; An Interview Exercise
tags: tutorial interview csharp
---

You are applying for your first position or for a new job. You have already sent your CV and your LinkedIn profile. You have gone through initial interviews. Now, the technical interview. You are asked to complete a coding exercise: evaluate an expression in postfix notation. _Relax! It's time to show your skills!_

## What is Postfix Notation?

Math and some programming languages use the infix notation. It places the operator between the two operands. And, it uses parenthesis to group operations. For example, `a + b` and `(a + b)*c`.

Unlinke infix notation, **postfix notation places the operator after the two operands. And, it doesn't use any parenthesis to group expresions**. For example, `a b +` , and  `a b + c *`. Postfix expressions are evaluated from left to right. The expression `2 3 1 * + 9 -`  in postfix notation is equivalent to `(2 + (3 * 1)) - 9`.

## Interview Question

> Write a C# program to evaluate a postfix mathematical expression. For example, `1 1 +`, `1 1 1 + +`, `1 1 + 2 3 * -`.

During your technical interview, don't rush to start coding right away. Follow the next steps:

* Understand the problem
* Come up with some examples. _What's the simplest case? Any edge cases?_
* Ask clarification questions. _Do you need to validate your input values?_
* Think out loud your solution.
* Make assumptions on the input. Start with the simplest case and work through a complete solution.

<figure>
<img src="https://images.unsplash.com/photo-1484632105053-8662f3194e7f?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop" alt="a pile of empty dishes" />

<figcaption>To evaluate a postfix expression, we need a stack. <span>Photo by <a href="https://unsplash.com/@brookelark?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Brooke Lark</a> on <a href="https://unsplash.com/photos/KyUmKlXrhAM?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## Solution Strategy: A Stack

To evaluate a postfix expression, you need a stack.

A stack is a pile-like data structure. Stacks support two operations: add something to the pile, **push**, and remove something from the pile, **pop**.

In our solution to evaluate a postfix notation, a stack will hold either values from the input or already computed values.

This is the pseudocode to evaluate a postfix expression:

```
Create an stack
Split input string
foreach splitted value:
    if it's an operand:
        push it to the stack
    if it's an operator:
        pop the two operands from the stack
        perfom the operation and push the result back to the stack
return value in the stack
```

Let's evaluate the expression `2 3 1 * + 9 -` by hand. Let's start by the inner operations.

```
STEP 1:
2 3 1 * + 9 -
2 (3 1 *) + 9 -
2 3 + 9 -

STEP 2:
(2 3 +) 9 -
5 9 -
-4
```

## Let's C#!!!

Now, head to Visual Studio or Visual Studio Code and create a new project. This is how we evaluate a postfix expression in C#.

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
            tokens.Push(t);
        else if (_operatorRegex.IsMatch(t))
        {
            var t1 = tokens.Pop().ToString();
            var t2 = tokens.Pop().ToString();
            var op = t;

            var result = EvaluateSingleExpression(t2, t1, op);
            if (result != null)
                tokens.Push(result);
        }
    }
    if (tokens.Count > 0)
       return tokens.Pop().ToString();

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

Voila! That's how we can evaluate postfix expressions in C#. For more tips to prepare yourself for your next interview, check [my interview tips]({% post_url 2019-09-29-RemoteInterviewTips %}). Also, check my post on [the difference between Func and Action in C#]({% post_url 2019-03-22-WhatTheFuncAction %}). That's another common interview question.

_Happy coding!_
