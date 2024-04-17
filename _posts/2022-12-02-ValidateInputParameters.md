---
layout: post
title: "TIL: Always check for missing configuration values inside constructors"
tags: todayilearned csharp
cover: Cover.png
cover-alt: "Warehouse full of boxes"
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

This is a lesson I learned after trying to use a shared NuGet package in one of my client's projects and getting an ArgumentNullException. I had no clue that I needed some configuration values in my appsettings.json file. This is what I learned.

**Always check for missing configuration values inside constructors. In case they're not set, throw a human-friendly exception message showing the name of the expected configuration value. For example: 'Missing Section:Subsection:Value in config file'.**

## A missing configuration value

This is what happened. I needed to import a feature from a shared Nuget package. It had a method to register its dependencies. Something like `services.AddFeature()`.

When calling an API endpoint that used that feature, I got an `ArgumentNullException`: _"Value cannot be null. (Parameter 'uriString')."_ It seemed that I was missing a URI. But what URI?

Without any XML docstrings on the `AddFeature()` method, I had no other solution than to decompile that DLL. I found a service like this one, 

```csharp
public class SomeService : ISomeService
{
    private readonly Uri _anyUri;

    public SomeService(IOptions<AnyConfigOptions> options, OtherParam otherParam)
    {
        _anyUri = new Uri(options.Value.AnyConfigValue);
        //                ^^^^^^^
        // System.ArgumentNullException: Value cannot be null. (Parameter 'uriString')
    }

    public async Task DoSomethingAsync()
    {
        // Beep, beep, boop...
        // Doing something here...
    }
}
```

There it was! The service used the [IOptions pattern to read configuration values]({% post_url 2020-08-21-HowToConfigureValues %}). And I needed an URL inside a section in the appsettings.json file. How was I supposed to know?

<figure>
<img src="https://images.unsplash.com/photo-1611329857570-f02f340e7378?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY2ODcyMzAwOQ&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Black and brown jigsaw puzzle" />

<figcaption>Missing one value... Photo by <a href="https://unsplash.com/@sigmund?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Sigmund</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## A better exception message

Then I realized that a validation inside the constructor with a human-friendly message would have saved me (and any other future developer using that NuGet package) some time. And it would have pointed me in the right direction. I mean having something like,

```csharp
public class SomeService : ISomeService
{
    private readonly Uri _anyUri;

    public SomeService(IOptions<AnyConfigOptions> options, OtherParam otherParam)
    {
        //  vvvvvvv
        if (string.IsNullOrEmpty(options?.Value?.AnyConfigValue))
        {
            throw new ArgumentNullException("Missing 'AnyConfigOptions:AnyConfigValue' in config file.");
            //                              ^^^^^^^^
            // I think this would be a better message
        }

        _anyUri = new Uri(options.Value.AnyConfigValue);
    }

    public async Task DoSomethingAsync()
    {
        // Beep, beep, boop...
        // Doing something here again...
    }
}
```

Even better, what if the `AddFeature()` method had an overload that receives the expected configuration value? Something like `AddFeature(AnyConfigOptions options)`. This way, the client of that package could decide the source of those options. Either read them from a configuration file or hardcode them.

The book "Growing Object-Oriented Software Guided by Tests" suggests having a `StupidProgrammerMistakeException` or a specific exception for this type of scenario: missing configuration values. This would be a good use case for that exception type.

Voilà! That's what I learned today: always validate configuration values inside constructors and use explicit error messages when implementing the Options pattern. It reminded me of "The given key was not present in the dictionary" and other obscure error messages. Do you write friendly and clear error messages?

To read more content about ASP.NET Core, check [how to add caching with Redis]({% post_url 2020-06-29-HowToAddACacheLayer %}) and [how to read configuration values]({% post_url 2020-08-21-HowToConfigureValues %}).

_Happy coding!_