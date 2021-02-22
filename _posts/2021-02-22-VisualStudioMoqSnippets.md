---
layout: post
title: Visual Studio snippets for Moq
tags: productivity visualstudio showdev
---

These days, I use Moq a lot. There are things [I like and I don't like]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}) about Moq. But it's simple and easy to use.

I use the same three or four Moq methods all the time. I decided to create snippets inside Visual Studio to avoid typing the same method names every time. These are the snippets I use.

## Snippets

### Create a `Mock`

<figure>
<img src="https://raw.githubusercontent.com/canro91/VSMoqSnippets/master/assets/NewMock.gif" alt="mn to create a Mock" width="400" height="300">
<figcaption>Use mn to create a Mock</figcaption>
</figure>

### `Setup` and `Return`

<figure>
<img src="https://raw.githubusercontent.com/canro91/VSMoqSnippets/master/assets/Return.gif" alt="mr to Setup/Return" width="400" height="300">
<figcaption>Use mr to Setup/Return</figcaption>
</figure>

### `Setup` and `ThrowsException`

<figure>
<img src="https://raw.githubusercontent.com/canro91/VSMoqSnippets/master/assets/Throw.gif" alt="mt to Setup/ThrowsException" width="400" height="300">
<figcaption>Use mt to Setup/ThrowsException</figcaption>
</figure>

Also, you can use `mra` and `mta` for the asynchronous version of `Return` and `ThrowsException` respectively.

If you want to use the same snippets I use, donwload the snippets file from [VSMoqSnippets](https://github.com/canro91/VSMoqSnippets) repository. Head to Visual Studio. From the "Tools" menu, choose "Code Snippets Manager" and import the snippets file.

[![canro91/VSMoqSnippets - GitHub](https://gh-card.dev/repos/canro91/VSMoqSnippets.svg)](https://github.com/canro91/VSMoqSnippets)

Voilà! Those are the snippets I use for Moq. For tips on writing unit tests, check my post on [how to write good unit tests]({% post_url 2020-11-02-UnitTestingTips %}). Also, check [my Visual Studio setup]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}) for more settings and extensions inside Visual Studio.

_Happy coding!_
