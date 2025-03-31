---
layout: post
title: "An Easy Mnemonic to Format Dates As Strings in C#"
tags: csharp
---

Is it `MM` or `mm` for months when formatting dates? Is it `yyyy-MM-dd` or `yyyy-mm-dd`?

I always forgot which one to use...until I figured out an easy mnemonic.

## MM vs mm

Ask yourself: Which one represents a larger time frame? Months or minutes? 

Since one month is larger than one minute, it's `M` for months. An uppercase m is larger than a lowercase m. Write, `anyDate.ToString("yyyy-MM-dd")`.

## mm vs fff

Then, what is it for milliseconds? Isn't it `mm`?

Now, ask yourself: Which one is faster? One minute or one millisecond?

Since one millisecond is faster, write `f` instead of `m`. Write `anyDate.ToString("hh:mm:ss.fff")`.

Easy, peasy now!
