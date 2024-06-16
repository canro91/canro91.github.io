---
layout: post
title: "Ten tips to solve your next interview coding challenge"
tags: interview career
cover: Cover.png
cover-alt: "Ten tips to solve your next interview coding challenge"
---

While applying for a new job, often we're given a coding challenge. A medium-size coding task to finish in a couple of hours or days. These are my tips to solve your next interview coding challenge.

**When solving interview coding challenges, write code as cleanly as possible. Write good and consistent names. Keep your solution under version control. And document major design choices and installation instructions.**

> TL;DR
> 1. Follow good practices and stick to coding standards.
> 2. Keep your solution under version control.
> 3. Write a README file with installation instructions.

## Stick to standards

Follow good practices and stick to coding standards. [Write clean code]({% post_url 2020-01-06-CleanCodeReview %}).

**1. Write descriptive names**. Don't use `Information` or `Info` as name suffixes, like `AccountInfo`. Keep names consistent all over your code. If you used `AddAccount` in one place, don't use `AccountAdd` anywhere else. 

**2. Use one single "spoken" language**. Write variables, functions, classes, and all other names in the same language. Don't mix English and your native language if your native language isn't English. Always prefer the language you will be using at the new place.

**3. Don't keep commented-out code**. And don't have extra blank lines. [Use linters and extensions]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}) for this.

**4. Use third-party libraries to solve common problems**. But don't keep unused libraries or NuGet packages.

**5. Have clearly separated responsibilities**. Use separate classes, maybe Services and Repositories. But stay away from [Helper and Utility classes full of static methods]({% post_url 2022-12-07-BanningSomeNamingConventions %}). Often, they mean you have wrong abstractions.

**6. Add unit or integration tests**, at least for the main parts of your solution.

If you're new to unit testing or want to learn more, don't miss my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where I cover from what unit testing is to mocking to best practices.

<figure>
<img src="https://images.unsplash.com/photo-1512902990232-3ff067da0597?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzMDAzNzQ0OQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Framed wall art" />

<figcaption>Write code you would print and hang on a wall. Photo by <a href="https://unsplash.com/@lefty_kasdaglis?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Lefty Kasdaglis</a> on <a href="https://unsplash.com/s/photos/picture-wall?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Version Control your solution

Keep your solution under version control. [Use Git]({% post_url 2020-05-29-HowToVersionControl %}).

**7. Write small and incremental commits.**

**8. Write good commit messages**. Don't use "Uploading changes," "more changes," or anything among those lines.

**9. Use GitHub, GitLab, or any hosting service,** unless you got different instructions for your challenge.

## Write a good README file

Write a good README file for your solution. Don't miss this one! Seriously!

**10. Add installation instructions**. Make it as easy as possible for the one reviewing your work to install and run your solution. For example, use Docker or deploy your solution to a free hosting provider.

**11. Add how to test your solution**. Maybe, some step-by-step instructions with screenshots or a Postman collection with the endpoints to hit. You get the idea!

**12. Tell what third-party tools you used**. Include what libraries, NuGet packages, or third-party APIs you used.

**13. Document any major design choices**. Did you choose any architectural patterns? Any storage layer? Tell why.

Voilà! These are my best tips to rock in your next coding challenge. Remember, it's your time to shine. Write as clean code as possible. And keep things consistent. Good luck!

If you want to see how I followed these tips on a real coding challenge, check [SignalChat](https://github.com/canro91/SignalChat) on my GitHub account. It's a simple browser-based chat application using ASP.NET Core and SignalR.

[![canro91/SignalChat - GitHub](https://gh-card.dev/repos/canro91/SignalChat.svg)](https://github.com/canro91/SignalChat)

Get ready for your next interview with these [tips for remote interviews]({% post_url 2019-09-29-RemoteInterviewTips %}). And, to prepare for your technical interviews, check [how to evaluate a postfix expression]({% post_url 2019-08-02-PostfixNotationAnInterviewExercise %}), [how to solve the two-sum problem]({% post_url 2019-08-29-TimeComplexity %}), and [how to shift array elements]({% post_url 2019-09-16-RotatingArray %}). These are real questions I got in previous interviews.

_Happy coding!_