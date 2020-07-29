---
layout: post
title: Postfix Notation&colon; An Interview Exercise
tags: tutorial interview csharp
---

You are applying for your first position or for a new job. You have already sent your CV and your LinkedIn profile. You have gone through initial interviews. Now, the technical interview. You are asked to complete a coding exercise. Maybe, you are nervous because there are some algorithms, a method in the standard library or a pattern you forgot. Relax! It's time to show your skills!

## Interview Question

> Write a C# program to evaluate an postfix mathematical expression. For example, `1 1 +`, `1 1 1 + +`, `1 1 + 2 3 * -`.

Before starting to code:

* Understand the problem
* Come up with some examples. What's the simplest case? Edge cases?
* Ask clarification questions.
* Think out loud your solution.
* Make assumptions on the input.

## What is Postfix Notation?

From Math and some programming languages, you are used to the **infix notation**. You place the operator between the two operands, `a + b` and use parenthesis to group operations, `(a + b)*c`. But, **postfix notation** places the operator after the two operands, `a b +` , and doesn't use any parenthesis, `a b + c *`, so expressions are evaluated from left to right. For example, `2 3 1 * + 9 -` is equivalent to `(2 + (3 * 1)) - 9`.


## Solution Strategy: An Stack

To solve this problem, you need an stack. An stack is a pile-like data structure. Stacks support two operations: add something to the pile, **push**, and remove something from the pile, **pop**. In the solution, an stack will hold values from the input or already computed values.

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

So, this is the evaluation of the given example:

```
2 3 1 * + 9 -
2 (3 1 *) + 9 -
2 3 + 9 -

(2 3 +) 9 -
5 9 -
-4
```


## Let's CSharp it!!!

Now, head to VS or VSCode  and create a new project:

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