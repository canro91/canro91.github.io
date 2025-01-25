---
layout: post
title: "Missed the Last 10 Years of C#? Read This (Quick) Guide"
tags: csharp asp.net
---

Here's an opinionated catch-up guide if you missed the last decade of the C#/.NET/Microsoft evolution.

#1. **C# isn't JAVA anymore.** That joke doesn't work anymore. The two languages have taken completely different paths. They don't even look the same.

#2. **There's a new runtime: .NET.** It's multiplatform and open-sourced. We have the classic one, we call it: .NET Framework, which you probably already know. And the new one was called ".NET Core." But now, it's simply ".NET" Yes, naming is hard.

#3. Speaking of the language, **the main language features are still there.** C# is an imperative side-effect-heavy language. But with every release, it's adopting more features from functional languages, like lambda expressions, pattern matching, and records. (See #7)

#4. There's excellent **support for asynchronous methods** with two keywords: `async` and `await`.

#5. **There's a whole lot of new small language features.** Apart from `async`/`await` (from C# 5.0) we haven't had a release with a single major feature. Most of the new features are syntactic sugar for existing features.

#6. **There's a new feature you shouldn't miss**: [nullable references]({% post_url 2023-03-06-NullableOperatorsAndReferences %}). It should have been called: "non-nullable references" instead. Do you remember nullable primitive types? Like `int?`? We allow a type to contain null by appending a `?` when declaring it. We can do the same for classes. So `Movie? m` can be null, but `Movie m` can't. And the compiler warns us when we're trying to use a reference that might be null. Awesome!

#7. I compiled a list of [C# features we should know about]({% post_url 2021-09-13-TopNewCSharpFeatures %}). Those are the features I like and have used the most.

#8. **A "Hello, world" is now literally one line of code.** We don't need to declare a class and a Main method for console applications. Just write your code directly in a file like in a scripting language.

#9. I stopped expanding that list with the most recent features. **C# is getting bloated** with more features that are [making the language less consistent]({% post_url 2024-07-08-CSharpInconsistencies %}). I don't like that.

#10. The same way we have a new runtime, **we have a new web framework: ASP.NET Core.** It was a full rewrite of the classic ASP.NET. There's no Global.asax, web.config, or files listed on csproj files. If you knew and used the old ASP.NET, I wrote a [guide with the difference between the two]({% post_url 2020-03-23-GuideToNetCore %}). With .NET, we have way better tooling like a [command line interface to create projects]({% post_url 2022-12-15-CreateProjectStructureWithDotNetCli %}).

#11. Well, there's Xamarin, MAUI, Blazor... But unless you're planning to do front-end work, you don't need to worry about them. Microsoft is still trying to find, create, and establish a golden hammer for the front-end side.

Sure, I'm missing a lot of other things. But you're safe catching up on those.
