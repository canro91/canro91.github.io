---
layout: post
title: "TIL: Dictionary keys are converted to lowercase too on serialization"
tags: csharp todayilearned asp.net
cover: Cover.png
cover-alt: "Dictionary keys"
---

Today, I needed to pass a dictionary between two ASP.NET Core 6.0 API sites. To my surprise, on the receiving side, I got the dictionary with all its keys converted to lowercase instead of PascalCase. I couldn't find any element on the dictionary, even though the keys had the same names on each API site. This is what I learned about serializing dictionary keys.

## Serialization with Newtonsoft.Json

It turns out that the two API sites were using Newtonsoft.Json for serialization. Both of them used the `CamelCasePropertyNamesContractResolver` when adding Newtonsoft.Json.

Something like this,

```csharp
using Newtonsoft.Json.Serialization;
using Newtonsoft.Json;

var builder = WebApplication.CreateBuilder(args);
builder.Services
    .AddControllers()
    .AddNewtonsoftJson(options =>
    // ^^^^^
    {
        options.SerializerSettings.NullValueHandling
            = NullValueHandling.Ignore;

        options.SerializerSettings.ContractResolver
            = new CamelCasePropertyNamesContractResolver();
            //    ^^^^^
            // This is what I mean
    });

var app = builder.Build();
app.MapControllers();
app.Run();
```

**With CamelCasePropertyNamesContractResolver, Newtonsoft.Json writes property names in camelCase. But, Newtonsoft.Json treats dictionary keys like properties too.**

That was the reason why I got my dictionary keys in lowercase. I used one-word names and Newtonsoft.Json made them camelCase.

To prove this, let's create a simple controller that read and writes a dictionary. Let's do this,

```csharp
using Microsoft.AspNetCore.Mvc;

namespace LowerCaseDictionaryKeys.Controllers;

[ApiController]
[Route("[controller]")]
public class DictionaryController : ControllerBase
{
    [HttpPost]
    public MyViewModel Post(MyViewModel input)
    {
        return input;
        //     ^^^^^
        // Just return the same input
    }
}

public class MyViewModel
{
    public IDictionary<string, string> Dict { get; set; }
}
```

Now, let's notice in the output from Postman how the request and the response differ. The keys have a different case. Arggg!

{% include image.html name="Before.png" alt="Postman request and response bodies" caption="Postman request and response bodies" width="500px" %}

## 1. Configure Newtonsoft.Json naming strategy

**To preserve the case of dictionary keys with Newtonsoft.Json, configure the ContractResolver setting with CamelCaseNamingStrategy class and set its ProcessDictionaryKeys property to false.**

When registering Newtonsoft.Json, in the `SerializerSettings` option, let's do:

```csharp
using Newtonsoft.Json.Serialization;
using Newtonsoft.Json;

var builder = WebApplication.CreateBuilder(args);
builder.Services
    .AddControllers()
    .AddNewtonsoftJson(options =>
    // ^^^^^
    {
        options.SerializerSettings.NullValueHandling
            = NullValueHandling.Ignore;

        options.SerializerSettings.ContractResolver
            = new CamelCasePropertyNamesContractResolver
            {
                NamingStrategy = new CamelCaseNamingStrategy
                {
                    ProcessDictionaryKeys = false
                    // ^^^^^
                    // Do not change dictionary keys casing
                }
            };
    });

var app = builder.Build();
app.MapControllers();
app.Run();
```

For more details, see Newtonsoft.Json docs to [Configure NamingStrategy dictionary serialization](https://www.newtonsoft.com/json/help/html/NamingStrategySkipDictionaryKeys.htm).

After changing the naming strategy, let's see the response of our sample controller. That's what I wanted!

{% include image.html name="After.png" alt="Postman request and response after changing NamingStrategy" caption="Postman request and response bodies" width="500px" %}

### What about System.Text.Json?

To maintain case of dictionary keys with System.Text.Json, let's set the `DictionaryKeyPolicy` property inside the `JsonSerializerOptions` to `JsonNamingPolicy.CamelCase`.

In our `Program.cs` class, let's write,

```csharp
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);
builder.Services
    .AddControllers()
    .AddJsonOptions(options =>
    // ^^^^^
    {
        options.JsonSerializerOptions
            .DictionaryKeyPolicy = JsonNamingPolicy.CamelCase;
            // ^^^^^
    });

var app = builder.Build();
app.MapControllers();
app.Run();
```

For more naming policies, see Microsft docs to [customize property names and values with System.Text.Json](https://docs.microsoft.com/en-us/dotnet/standard/serialization/system-text-json-customize-properties#camel-case-dictionary-keys).

## 2. Use a comparer with dictionaries

Another alternative is to use a dictionary with a comparer that ignores case of keys.

On the receiving API site, let's add an empty constructor on the request view model to initialize the dictionary with a comparer to ignore cases.

In my case, I was passing a metadata dictionary between the two sites. I could use a `StringComparer.OrdinalIgnoreCase` to create a dictionary ignoring the case of keys.

This way, no matter the case of keys, I could find them when using the `TryGetValue()` method.

```csharp
public class MyViewModel
{
    public MyViewModel()
    {
        Dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        //                                    ^^^^^
    }

    public Dictionary<string, string> Dict { get; set; }
}
```

Voilà! That's how we can configure the case of dictionary keys when serializing requests and how to read dictionaries with keys no matter the case of its keys.

If you want to read about ASP.NET Core, check [how to add a caching layer]({% post_url 2020-06-29-HowToAddACacheLayer %}) and [how to read your appsettings.json configuration file]({% post_url 2020-08-21-HowToConfigureValues %}). To avoid KeyNotFoundException and other exceptions when working with dictionaries, check my [idioms on dictionaries]({% post_url 2020-08-01-AnotherTwoCSharpIdiomsPart3 %}).

_Happy C# time_