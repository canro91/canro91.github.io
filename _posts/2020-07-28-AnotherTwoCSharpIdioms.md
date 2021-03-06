---
layout: post
title: Another two C# idioms
tags: tutorial csharp
series: C# idioms
cover: Cover.png
cover-alt: Two C# idioms - Part 2
---

In this part of the C# idioms series, we have one idiom to organize versions of commands, events or view models. And another idiom, on coditionals inside `switch` statements.

### Separate versions of commands and events using namespaces and static classes

When working with Command Query Responsibility Segregation (CQRS), sometimes you need to support versions of your commands and queries. For example, you need to add new properties or remove old ones. You don't want to mess with your existing commands and queries. Also, it applies to request and response view models in your API projects.

One alternative is to encode the version number in the class name itself. For example, `DoSomethingCommandV2`. 

For better organization, you can group your commands and queries inside a namespace. This namespace's name will contain the version number. But, someone could use one version instead of the other by mistake. In this situation, a named alias comes handy.

```csharp
namespace Commands.V2
{
  public class DoSomethingCommand
  {
  }
}
```

Another option, you can wrap your commands and queries inside an static class, named after the version number. They will be used like : `V2.DoSomethingCommand`. This time, it's obvious which version is used.

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

But, if you use a partial class and your commands and events belong to different projects, you will end up with a name conflict. There will be two classes with the same name in different projects. Then you would need to use an `extern alias` to differentiate between the two.

Finally, you can take the best of both worlds.

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

### Conditional cases in switch statements

When working with `switch` statements, you can use a `when` clause instead of an `if/else` in your `case` expressions.

Order is important when replacing `if/else` inside cases with `when` clauses. The `case/when` should be higher than the corresponding `case` without `when`.

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
}
```

_Happy C# time!_
