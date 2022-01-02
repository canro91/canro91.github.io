---
layout: post
title: "Ten tips to solve your next interview coding challenge"
tags: interview career
cover: Cover.png
cover-alt: "Ten tips to solve your next interview coding challenge"
---

While applying for a new job, often we're given a coding challenge. A medium-size coding task to finish in a couple of hours or days. These are my tips to solve your next interview coding challenge.

**When solving interview coding challenges, write code as clean as possible. Write good and consistent names. Keep your solution under version control. And, document major design choices and installation instructions.**

> TL;DR
> 1. Follow good practices and stick to coding standards.
> 2. Keep your solution under version control.
> 3. Write a README file with installation instructions.

## 1. Stick to standards

Follow good practices and stick to coding standards. Write clean code.

**Write descriptive names**. Don't use `Information` or `Info` as name suffixes. Like, `AccountInfo`. And keep names consistent. If you used `AddAccount` in one place, don't use `AccountAdd` anywhere else. 

**Use one single "spoken" language**. Write variables, functions, classes, and all other names in the same language. Don't mix English and your native language. If your native language isn't English. Always prefer the language you will be using at the new place.

**Don't keep commented out code**. And, don't have extra blank lines. Use linters and extensions for this.

**Use third-party libraries to solve common problems**. But, don't keep unused libraries or NuGet packages.

**Have clearly separated responsibilities**. Use separate classes, maybe Services, and Repositories. But, stay away from Helper and Utility classes full of static methods. Often, they mean you have wrong abstractions.

**Add unit or integration tests**. At least for the main parts of your solution.

<div class="message">If you're new to unit testing or want to learn more, I have the <a href="/2021/08/30/UnitTesting">Unit Testing 101 series</a> and one free eBook on the subject. Don't miss them.</div>

<figure>
<img src="https://images.unsplash.com/photo-1512902990232-3ff067da0597?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzMDAzNzQ0OQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Framed wall art" />

<figcaption>Write code you would print and hang in a wall. Photo by <a href="https://unsplash.com/@lefty_kasdaglis?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Lefty Kasdaglis</a> on <a href="https://unsplash.com/s/photos/picture-wall?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 2. Version Control your solution

Keep your solution under version control. Use Git.

**Write small and incremental commits.**

**Write good commit messages**. Don't use "Uploading changes", "more changes" or anything among those lines.

<div class="message">If you're new to Git, read my <a href="/2020/05/29/HowToVersionControl">beginner's Guide to Git</a>. If you know TFS, check my <a href="/2019/11/11/GitGuideForTfsUsers">Git guide for TFS users</a>.</div>

## 3. Write a good README file

Write a good README file for your solution. Don't miss this one!

**Add installation instructions**. Make it as easy as possible for the one reviewing your work to install and run your solution. For example, deploy your solution to a hosting provider or use Docker.

**Add how to test your solution**. Maybe, some step-by-step instructions with screenshots, a Postman collection with the endpoints to hit. You get the idea!

**Tell what third-party tools you used**. Include what libraries, NuGet packages, or third-party APIs you used.

**Document any major design choices**. Did you choose any architectural patterns? Any storage layer? Tell why.

Voilà! These are my best tips to rock in your next coding challenge. Remember, it's your time to shine. Write as clean code as possible. And keep things consistent. Good luck!

Get ready for your next interview with these [tips for remote interviews]({% post_url 2019-09-29-RemoteInterviewTips %}). And, to prepare for your technical interviews, check [how to evaluate a postfix expression]({% post_url 2019-08-02-PostfixNotationAnInterviewExercise %}), [how to solve the two-sum problem]({% post_url 2019-08-29-TimeComplexity %}) and [how to shift array elements]({% post_url 2019-09-16-RotatingArray %}). These are real questions I got on previous interviews.

_Happy coding!_