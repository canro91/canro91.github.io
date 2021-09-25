---
layout: post
title: Another two C# idioms
tags: tutorial csharp
series: C# idioms
cover: Cover.png
cover-alt: Two C# idioms - Part 2
---

In this part of the C# idioms series, we have one idiom to organize versions of commands, events or view models. And another idiom, on coditionals inside `switch` statements.

## Separate versions of commands and events using namespaces and static classes

Sometimes you need to support versions of your objects to add new properties or remove old ones. Think of, commands and queries when working with Command Query Responsibility Segregation (CQRS), or request and response view models in your API projects.

One alternative to organize classes by version is to encode the version number in the class name itself. For example, `DoSomethingCommandV2`. 

**For better organization, separate your commands and queries inside a namespace named with the version number.**

```csharp
namespace Commands.V2
{
  public class DoSomethingCommand
  {
  }
}
```

But, someone could use one version instead of the other by mistake. Imagine someone writing the class name and using `Ctrl + .` in Visual Studio to resolve the `using` statement blindly.

**Another option to group classes by vesion is to wrap your commands and queries inside an static, partial class named after the version number.**

```csharp
namespace Commands
{
    public static partial class V2
    {
        public class DoSomethingCommand
        {
        }
    }
}
```

When using static classes to separate classes by version, you will use the version number up front. Something like, `V2.DoSomethingCommand`. This time, it's obvious which version is used.

But, if you use a partial classes and you keep your commands and events in different projects, you will end up with a name conflict. There will be two `V2` classes in different projects. Then you would need to use an `extern alias` to differentiate between the two.

Finally, you can take the best of both worlds, namespaces and wrapper static classes.

```csharp
namespace Commands.V2
{
    public static partial class V2
    {
        public class DoSomethingCommand
        {
        }
    }
}
```

<figure>
<img src="https://images.unsplash.com/photo-1531280518436-9f2cc0fff88a?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzMjU5NDk2Mg&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Notebooks grouped by color" />

<figcaption>Keep versions of your classes organized. Photo by <a href="https://unsplash.com/@jubalkenneth?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Jubal Kenneth Bernal</a> on <a href="https://unsplash.com/s/photos/folder?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Conditional cases in switch statements

When working with `switch` statements, you can use a `when` clause instead of an `if/else` in your `case` expressions.

Before, we used `if` inside switches

```csharp
switch (myVar)
{
  case aCase:
    if (someCondition)
    {
      DoX();
    }
    else
    {
      DoY();
    }
    break;
    
    // other cases...
}
```

After, we use `when` in our `case` expressions

```csharp
switch (myVar)
{
  case aCase when someCondition:
      DoX();
      break;
  
  case aCase:
      DoY();
      break;
      
  // other cases...
}
```

Order is important when replacing `if/else` inside cases with `when` clauses. The `case/when` should be higher than the corresponding `case` without `when`.

Voilà! Keep your command, queries and view models organized by versions with namespaces, static classes or both. Use `when` in switch statements.

Don't miss the [previous C# idioms]({% post_url 2019-11-19-TwoCSharpIdioms %}) to refactor conditionals and [the next two C# idioms]({% post_url 2020-08-01-AnotherTwoCSharpIdiomsPart3 %}) to get rid of exception when working with dictionaries.

_Happy C# time!_
