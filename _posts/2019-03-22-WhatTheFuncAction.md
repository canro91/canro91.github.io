---
layout: post
title: What the Func, Action?
description: What's the difference between Func and Action? How do I use them? This is a frequently asked question and a tricky subject. Here it is another take.
tags: tutorial csharp
---

What's the difference between `Func` and `Action`? It all starts with delegates. A delegate is a pointer to a method with certain parameters and possibly a return type. In other words, it's a variable that can hold any method with that signature. `Func` and `Action` are built-in delegate types.

Delegates are helpful when working with _higher-order functions_. This is, functions that take functions as parameter and return another function. For example, Javascript's callbacks or Python's decorators.

Here's the thing. The difference between `Func` and `Action` is the return type. On one hand, `Action` has no return type, a void method. But, on the other hand, `Func` has a return type. For example:

* `Action<Employee>` is a void method that receives `Employee`.
* `Action` is a void method without parameters.
* `Func<Employee, string>` represents a method that receives an `Employee` and returns an `string`.
* `Func<string>` doesn't have any parameters and returns `string`.

## How to use a method?

You have already used `Func`, if you have used LINQ. But, in general, you use them as _lambda expressions_. A lambda expression is an anonymous method. It’s a shorthand notation to write a method without a name and only the parameter types.

For example: Find the employees who have worked for more than ten years.

```csharp
Func<Employee, bool> p = (t) => t.YearsWorked >= 10;
allEmployees.Where(p);
```
Or just simply

```csharp
allEmployees.Where(t => t.YearsWorked >= 10);
```

## How to declare a method?

To a declare a method that uses `Func` or `Action`, you have to use it like a regular paramater and later call `Invoke` on it or put parenthesis around the name passing the appropiate variables.

```csharp
public Employee DoSomething(Func<Employee, string> f)
{
    // Create an employee
    var employee = new Employee();
    
    // string result = f.Invoke(employee);
    string result = f(employee);
}
```

## A real-world example

`Func` and `Action` are great as small factory methods. They can be used in helper or utility methods to separete business logic from generic code. Here is an example of `Func` in [Insight.Database](https://github.com/jonwagner/Insight.Database) to create a [ReliableConnection](https://github.com/jonwagner/Insight.Database/wiki/ReliableConnection-and-Cloud-Databases), a database connection that automatically retries on certain errors.

This is the method that does the actual retry and uses `Func` for the operation to retry. (Some of the code has been removed for brevity)

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

In summary, `Func` and `Action` represent just the signature of a method. A method with no body. You can define or pass around the body later.

_Happy Funcy time!_


