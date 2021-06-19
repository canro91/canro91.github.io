---
layout: post
title: Visual Studio snippets for Moq
tags: productivity visualstudio showdev
---

These days, I use Moq a lot. There are things I like and I don't like about [creating fakes with Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}). But it's simple and easy to use.

I use the same four Moq methods all the time. Setup, ReturnAsync, ThrowsAsync and Verify. That's all you need. I decided to create snippets inside Visual Studio to avoid typing the same method names every time. These are the snippets I use.

### Create a Mock with Moq

Use `mn` to create a Mock. It expands to `var mock = new Mock<>();`.

<figure>
<img src="https://raw.githubusercontent.com/canro91/VSMoqSnippets/master/assets/NewMock.gif" alt="mn to create a Mock" width="400" height="300">
<figcaption>Use mn to create a Mock</figcaption>
</figure>

### Setup and Return

With a mock instance, use `mr` to `Setup` a method to `Return` something.

<figure>
<img src="https://raw.githubusercontent.com/canro91/VSMoqSnippets/master/assets/Return.gif" alt="mr to Setup/Return" width="400" height="300">
<figcaption>Use mr to Setup/Return</figcaption>
</figure>

### Setup and ThrowsException

If you want to throw an exception from your mock, use `mt`.

<figure>
<img src="https://raw.githubusercontent.com/canro91/VSMoqSnippets/master/assets/Throw.gif" alt="mt to Setup/ThrowsException" width="400" height="300">
<figcaption>Use mt to Setup/ThrowsException</figcaption>
</figure>

Also, you can use `mra` and `mta` for the asynchronous version of `Return` and `ThrowsException` respectively.

If you want to use the same snippets I use, download the snippets file from [VSMoqSnippets](https://github.com/canro91/VSMoqSnippets) repository.

To load snippets into Visual Studio, from the "Tools" menu, choose "Code Snippets Manager" and import the snippets file.

[![canro91/VSMoqSnippets - GitHub](https://gh-card.dev/repos/canro91/VSMoqSnippets.svg)](https://github.com/canro91/VSMoqSnippets)

Voilà! Those are the snippets I use for Moq. Check [my Visual Studio setup]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}) for more settings and extensions. Do you want to learn more about fakes? Read [what are fakes in unit testing]({% post_url 2021-05-24-WhatAreFakesInTesting %}) and these [tips for better stubs and mocks]({% post_url 2021-06-07-TipsForBetterStubsAndMocks %}). 

_Happy coding!_
