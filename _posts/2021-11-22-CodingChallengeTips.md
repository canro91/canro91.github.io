---
layout: post
title: "Want to ace your next take-home coding exercises? Follow these 13 short tips"
tags: interview career
cover: Cover.png
cover-alt: "Ten tips to solve your next interview coding challenge"
---

Take-home coding exercises aren't rare in interviews.

I've found from 4-hour exercises to 2-day exercises to a Pull Request in an open-source project.

Even though, in my CV I have links to my GitHub profile (with some green squares, not just cricket sounds) and my personal blog (the one you're reading), I've had to finish take-home exercises.

Yes, hiring is broken!

For my last job, I had to solve a take-home challenge when applying as a C#/.NET backend software engineer. It was a decent company and I wanted to play the hiring game. So I accepted.

After I joined I was assigned to review applicants' solutions.

Here are 13 short tips to help you solve your next take-home interview exercise. These are the same guidelines I used to review other people's take-home exercises.

## Stick to standards

Follow good practices and stick to coding standards. [Write clean code]({% post_url 2020-01-06-CleanCodeReview %}).

**1. Write descriptive names**. Don't use `Information` or `Info` as name suffixes, like `AccountInfo`. Keep names consistent all over your code. If you used `AddAccount` in one place, don't use `AccountAdd` anywhere else. 

**2. Use one single "spoken" language**. Write variables, functions, classes, and all other names in the same language. Don't mix English and your native language if your native language isn't English. Always prefer the language you will be using at the new place.

**3. Don't keep commented-out code**. And don't have extra blank lines. [Use linters and extensions]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}) to keep your code tidy.

**4. Use third-party libraries to solve common problems**. But don't keep unused libraries or NuGet packages around.

**5. Have clearly separated responsibilities**. Use separate classes, maybe Services and Repositories or Commands and Queries. But stay away from [Helper and Utility classes full of static methods]({% post_url 2022-12-07-BanningSomeNamingConventions %}). Often, they mean you have wrong abstractions.

**6. Add unit or integration tests**, at least for the main parts of your solution.

If you're new to unit testing or want to learn more, don't miss my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where I cover everything from the basics of unit testing to mocking and best practices.

<figure>
<img src="https://images.unsplash.com/photo-1512902990232-3ff067da0597?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzMDAzNzQ0OQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Framed wall art" />

<figcaption>Write code you would print and hang on a wall. Photo by <a href="https://unsplash.com/@lefty_kasdaglis?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Lefty Kasdaglis</a> on <a href="https://unsplash.com/s/photos/picture-wall?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Version Control your solution

Keep your solution under version control. [Use Git]({% post_url 2020-05-29-HowToVersionControl %}).

**7. Write small and incremental commits.** Don't just use a single commit with "Finished homework" as the message.

**8. Write good commit messages**. Don't use "Uploading changes," "more changes," or anything along those lines.

**9. Use GitHub, GitLab, or any hosting service,** unless you have different instructions for your take-home exercise.

## Write a good README file

Write a good README file for your solution. Don't miss this one! Seriously!

**10. Add installation instructions**. Make it easy for reviewers to install and run your solution. Consider using Docker or deploying your solution to a free hosting provider.

**11. Add instructions to run and test your solution**. Maybe, some step-by-step instructions with screenshots or a Postman collection with the endpoints to hit. You get the idea!

**12. Tell what third-party tools you used**. Include what libraries, NuGet packages, or third-party APIs you used.

**13. Document any major design choices**. Did you choose any architectural patterns? Any storage layer? Tell why.

Voilà! These are my best tips to succeed at your next take-home interview challenge. Remember, it's your time to shine. Write code as clean as possible and maintain consistency. Good luck!

If you want to see how I followed these tips on a real take-home coding exercise, check [SignalChat](https://github.com/canro91/SignalChat) on my GitHub account. It's a simple browser-based chat application using ASP.NET Core and SignalR.

[![canro91/SignalChat - GitHub](https://gh-card.dev/repos/canro91/SignalChat.svg)](https://github.com/canro91/SignalChat)

Get ready for your next interview with these [tips for remote interviews]({% post_url 2019-09-29-RemoteInterviewTips %}). And, to prepare for your technical interviews, check [how to evaluate a postfix expression]({% post_url 2019-08-02-PostfixNotationAnInterviewExercise %}), [how to solve the two-sum problem]({% post_url 2019-08-29-TimeComplexity %}), and [how to shift array elements]({% post_url 2019-09-16-RotatingArray %}). These are real questions I got in previous interviews.

_Happy coding!_