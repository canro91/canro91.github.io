---
layout: post
title: What the Func, Action?
description: What's the difference between Func and Action? How do I use them? This is a frequently asked question and a tricky subject.
---

What's the difference between `Func` and `Action`? It all starts with delegates. A delegate is a pointer to a method with certain parameters and possibly a return type. In other words, it's a variable that can hold any method with that signature. `Func` and `Action` are built-in delegate types.

Delegates are helpful when working with _higher-order functions_. This is, functions that take functions as parameter and return another function. For example, Javascript's callbacks or Python's decorators.

Here's the thing. The difference between `Func` and `Action` is the return type. On one hand, `Action` has no return type, a void method. But, on the other hand, `Func` has a return type. For example:

* `Action<Employee>` is a void method that receives `Employee`.
* `Action` is a void method without parameters.
* `Func<Employee, string>` represents a method that receives an `Employee` and returns an `string`.
* `Func<string>` doesn't have any parameters and returns `string`.

## How to use a method?

You have already used `Func`, if you have already used LINQ. But, in general, you use them as _lambda expressions_. A lambda expression is an anonymous method. It’s a shorthand notation to write a method without a name and the parameter types.

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

In summary, `Func` and `Action` represent just the signature of a method. A method with no body. You can define or pass around the body later. Happy Funcy time!


