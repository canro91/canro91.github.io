---
layout: post
title: What the Func, Action? Func vs Action
description: What's the difference between Func and Action? How do I use them? This is a frequently asked question and a tricky subject. Here it is another take.
tags: tutorial csharp
cover: Cover.png
cover-alt: Func vs Action
---

What's the difference between Func and Action in C#? This is a common C# interview question. Let's find it out!

**The difference between Func and Action is the return type of the method they point to. Action references a method with no return type. And, Func references a method with a return type.**

## What are delegates?

It all starts with delegates.

**A delegate is a pointer to a method with some input parameters and possibly a return type.**

In other words, a delegate is a variable that references a method that has a given signature. Both, `Func` and `Action` are built-in delegate types.

Delegates are helpful when working with higher-order functions. This is, functions that take functions as parameter or return another function. For example, JavaScript callbacks and Python decorators are high-order functions.

Now that it's clear what delegates are, let's see some `Func` and `Action` declarations. For example,

* `Action<Employee>` holds a void method that receives `Employee` as parameter.
* `Action`, a void method without any parameters.
* `Func<Employee, string>` represents a method that receives an `Employee` and returns a `string`.
* `Func<string>` doesn't have any parameters and returns `string`.

When declaring `Func` references, the last type inside `<>` tells the return type of the method being referenced. For `Action` references, since they don't have a return type, the types inside `<>` show the input parameter types.

<figure>
<img src="https://images.unsplash.com/photo-1483821838526-8d9756a6e1ed?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop" alt="What the Func, Action?" />

<figcaption>Let's get Funcy. <span>Photo by <a href="https://unsplash.com/@greysonjoralemon?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Greyson Joralemon</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## How to use Func and Action in a method?

You have already used `Func`, if you have used LINQ. But, in general, you use them as lambda expressions.

**A lambda expression is a shorthand notation to write a method without a name, only with the body and the parameter list.**

For example, let's find the employees who have worked for more than ten years.

```csharp
var allEmployees = new List<Employee> { /* Some employees here */ };

Func<Employee, bool> p = (t) => t.YearsWorked >= 10;
allEmployees.Where(p);
```
Or just simply

```csharp
allEmployees.Where(t => t.YearsWorked >= 10);
```

## How to declare a method that receives Func or Action?

To a declare a method that uses `Func` or `Action` as an input parameter, you have to use them like regular paramaters. Then, you have to either call `Invoke` on it or put parenthesis next to the name passing the appropiate parameters.

Let's see an example of a method that uses `Func`.

```csharp
public Employee DoSomething(Func<Employee, string> f)
{
    // Create an employee
    var employee = new Employee();
    
    // string result = f.Invoke(employee);
    // Or simply
    string result = f(employee);
    
    // Do something with the result here

    return employee;
}
```

## A real-world example

`Func` and `Action` are great as small factory methods. They can be used in helper or utility methods to separete business logic from generic code.

Let's see `Func` in action! Here is an example of `Func` from [Insight.Database](https://github.com/jonwagner/Insight.Database) to create a [ReliableConnection](https://github.com/jonwagner/Insight.Database/wiki/ReliableConnection-and-Cloud-Databases), a database connection that automatically retries on certain errors.

The `ExecuteWithRetry` method retries things and uses `Func` for the operation to retry. Some of the code has been removed for brevity.

```csharp
public class RetryStrategy : IRetryStrategy
{
    public TResult ExecuteWithRetry<TResult>(IDbCommand commandContext, Func<TResult> func)
    {
        int attempt = 0;
        TimeSpan delay = MinBackOff;

        while (true)
        {
            try
            {
                return func();
            }
            catch (Exception ex)
            {
                // if it's not a transient error, then let it go
                if (!IsTransientException(ex))
                    throw;

                // if the number of retries has been exceeded then throw
                if (attempt >= MaxRetryCount)
                    throw;
                    
                // some lines removed for brevity

                // wait before retrying the command
                // unless this is the first attempt or first retry is disabled
                if (attempt > 0 || !FastFirstRetry)
                {
                    Thread.Sleep(delay);

                    // update the increment
                    delay += IncrementalBackOff;
                    if (delay > MaxBackOff)
                        delay = MaxBackOff;
                }

                // increment the attempt
                attempt++;
            }
        }
    }
}
```

And, this is how to use the method to open a connection.

```csharp
public class ReliableConnection : DbConnectionWrapper
{
    public override void Open()
    {
        RetryStrategy.ExecuteWithRetry(null, () => { InnerConnection.Open(); return true; });
    }
}
```

Voilà! That's the difference between `Func` and `Action`. Remember that they only represent the signature of a method. You can define or pass around the body later.

If you want to know more about LINQ, check my [quick guide to LINQ]({% post_url 2021-01-18-LinqGuide %}). To learn how to use Insight.Database, check [how to create a CRUD API with ASP.NET Core and Insight.Database](% post_url 2020-05-01-InsightDatabase %).

_Happy Funcy time!_
