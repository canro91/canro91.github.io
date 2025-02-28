---
layout: post
title: "What Frustrates Me the Most as a C#/.NET Developer"
tags: csharp
---

C# has put a roof over my head and food on my table for more than 10 years.

At university, I learned Java. It was a relief coming from C/C++. Java didn't have all the things I hated about C. I'm looking at you, pointers.

At my first job, I had to learn C#. The first program I wrote there was a Java program with C# keywords. Oops! Java was the only language I knew at that time.

I like C# and the entire .NET ecosystem. A typed language, multi-paradigm, with good tooling and stable support.

But here are the things that frustrate me the most about .NET:

## 1. Naming

Naming is one of the two hardest parts of Computer Science. And Microsoft doesn't help that much.

On one hand, we have ".NET Core" renamed to ".NET". Everything is .NET now. Was it a marketing strategy? Dunno. Probably.

On the other hand, target framework monikers. You know, the version number we put inside our .csproj files. For some time, they were `.netcoreapp1.X`, `.netcoreapp2.X`, and `.netcoreapp3.X`. But one day, they changed it.

I imagine a conversation somewhere on Teams at Microsoft like this: 
- Let's change monikers too. Let's also use `.net` plus the version number.
- Wait, we can't do `.net4`. We already have a .NET Framework 4.0. People will get confused.
- Ok, let's jump to `.net5`.

Arrggg! Microsoft and names.

## 2. Too many releases

It's a good thing we have an evolving ecosystem.

I used to read all the release notes and tried to pick up as many new features as I could. Now? I only care about long-term versions. I don't even pay attention to the short-term ones. Something somewhere is a bit faster on an architecture I don't use at work. Sorry Microsoft!

Too many releases make it harder to keep up.

## 3. C# is getting too bloated

C# doesn't feel like a single language anymore.

It feels like three languages: one pre-2010, one around 2010, and the one we have now.

I used to closely follow every new language release. Not anymore. [C# as a language is getting less consistent]({% post_url 2024-07-08-CSharpInconsistencies %}). Too many options to create and initialize objects, for example.

Apart from [nullable references]({% post_url 2023-03-06-NullableOperatorsAndReferences %}) and pattern matching and maybe some others I can't remember now, it's more and more syntactic sugar on every release. I'm only waiting for [discriminated unions]({% post_url 2024-08-19-DiscriminatedUnionSupport %}).

The worst part is features that look the same but work differently. Yes, I'm looking at you, primary constructors. They look like records, but surprise, surprise...They work differently.

This inconsistency makes the language harder to teach and learn.

## 4. AutoMapper

Ok, there's nothing wrong with AutoMapper.

But what frustrates me is that, for some reason, we have adopted it as the de facto mapping library. And most of the time, AutoMapper ends up getting in our way.

Even AutoMapper's author recommends not to use it if we're mapping more than 80% of our fields by hand. But anyway, we use it even when we shouldn't.

Just in the past weeks, I found two scenarios that got in my way, [ignoring unmapped fields in the destination type]({% post_url 2025-01-24-IgnoringPropertiesAutoMapper %}) and [getting mappings flagged as invalid]({% post_url 2025-02-13-AutoMapperValidations %}). Sure, I know I was abusing AutoMapper.

I wanted to add EntityFramework Core to this list, but I'm starting to feel the frustration in my stomach. Probably, I'm hungry. But, frustrations aside, .NET is still my go-to platform and C#, my go-to language.
