---
layout: post
title: When logging met AOP with Fody
description: Are you tired of manually logging all entry and exit points of your code? How to use Fody to log every entry and exit method!
---

How many times have you had to log the entry and the exit of every single method in a service or in a class? So, your code ends up entangled with lots of `Log.XXX` lines. Something like this:

```csharp
abstract class Beverage
{
    private int _capacity = 10;

    public int Drink(int count)
    {
        Log.Info($"Init {nameof(Drink)}");

        try
        {
            if (count > _capacity)
                throw new ArgumentException("Not enouhg beers");
        }
        catch (Exception e)
        {
            Log.Error(e);

            throw;
        }

        Enumerable.Range(1, count)
                  .ToList()
                  .ForEach(t => Drinking(t));

        _capacity -= count;

        Log.Info($"Exit {nameof(Drink)}: {_capacity}");

        return _capacity;
    }

    public abstract void Drinking(int soFar);
}

class Beer : Beverage
{
    public override void Drinking(int current)
    {
        Log.Info($"Init {nameof(SomeMethod)}");

        // I have drunk {current} beers so far
        SomeMethod();

        Log.Info($"Exit {nameof(SomeMethod)}");
    }

    private void SomeMethod()
    {
        Log.Info($"Init {nameof(SomeMethod)}");
        // Do some logic here
        Log.Info($"Exit {nameof(SomeMethod)}");
    }
}
```

But, there are a couple of problems with this approach. First, the code is less readable and full of boilerplate code. Second, there is no separation between generic code and problem specific code. Last, any developer could forget to log new methods or get tired of logging things at all. Happy debugging, later on!

Wait!. Life is too short to log our code like that. There must be a smarter way. AOP (Aspect Oriented Programming) to the rescue! AOP can help you to cache things, to retry actions, and, in general, to isolate boilerplate code from our codebase.

You could use [MethodBoundaryAspect.Fody](https://github.com/vescon/MethodBoundaryAspect.Fody). This is an add-in of Fody, a free (*gratis* and *libre*) AOP library. It logs the entry, the exit and the exceptions of every method in your class. To start using Fody, first add **MethodBoundaryAspect.Fody** nuget. Then, create a custom attribute inheriting from *OnMethodBoundaryAspect* to do all the logging.

```csharp
public sealed class CustomLogAttribute : OnMethodBoundaryAspect
{
    public override void OnEntry(MethodExecutionArgs args)
    {
        Log.Info($"Init: {args.Method.DeclaringType.FullName}.{args.Method.Name} [{args.Arguments.Length}] params");
        foreach (var item in args.Method.GetParameters())
        {
            Log.Debug($"{item.Name}: {args.Arguments[item.Position]}");
        }
    }

    public override void OnExit(MethodExecutionArgs args)
    {
        Log.Info($"Exit: [{args.ReturnValue}]");
    }

    public override void OnException(MethodExecutionArgs args)
    {
        Log.Error($"OnException: {args.Exception.GetType()}: {args.Exception.Message}");
    }
}
```
 And finally, annotate your class.
 
 ```csharp
abstract class Beverage
{
    private int _capacity = 10;

    public int Drink(int count)
    {
        // All log statements removed...
    }

    public abstract void Drinking(int soFar);
}

[CustomLog]
class Beer : Beverage
{
    public Beer(string name) : base(name, 10)
    {
    }

    public override void Drinking(int current)
    {
        // I have drunk {current} beers so far
        SomeMethod();
    }

    private void SomeMethod()
    {
        // Do some logic here
    }
}
 ```   

That's it, you have logged your class with a single attribute, instead of lots `Log.XXX`. Your code is more readable and straight to the point. Now, it's time to go and try to remove all boilerplate code from our code base.