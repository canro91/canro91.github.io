---
layout: post
title: "Monday Links: Staging, Work, and Types"
tags: mondaylinks
cover: Cover.png
cover-alt: "A pile of folded newspapers on a desktop"
---

## A career-ending mistake

Jumping from place to place until we retire? Hopefully, with good pay raises? Being in a team closing Jira tickets and issues until we get bored? Based on the article, the biggest mistake is _"not planning the end of our careers."_ The right time to decide the end of our careers is now. The article shows three career alternatives: independent, senior individual contributor (IC), and management. [Read full article](https://bitfieldconsulting.com/golang/career)

## Why we don't use a staging environment

I have lived in almost all the situations described in this post. I worked for a company where we waited months to merge from our staging branch to the production branch. Merge conflicts were a nightmare! Patches going directly to the production environment made things more complicated. Often people forgot to merge patches back to the other environments. Arrrggg!

Did I mention that we had multiple staging environments? I remember our most-senior team member advocating for ideas like the ones in this post: Getting rid of the "just-in-case" staging environment, merging and publishing everything to production, and using feature flags.

Oh, I forgot to mention the "do-not-merge-or-touch-staging" times when the Sales team was demoing the product in the same environment. The whole development team had to wait for hours...If we only had had only one environment: production...[Read full article](https://squeaky.ai/blog/development/why-we-dont-use-a-staging-environment)

<figure>
<img src="https://images.unsplash.com/photo-1577895048405-4a186fea845b?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY1MDkyNTQ2NQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Someone working in a store circa 1954" />

<figcaption>He decided to go independent...Photo by <a href="https://unsplash.com/@museumsvictoria?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Museums Victoria</a> on <a href="https://unsplash.com/s/photos/store?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Algebraic Data Types in Haskell

This article might seem intimidating at first because of the Haskell syntax. But, it's a good introduction to Sum and Product types. Custom types are useful when designing business-related entities in our domain. That's precisely the main premise of [Domain Modeling Made Functional]({% post_url 2021-12-13-DomainModelingMadeFunctional %}): encode business rules, restrictions, and errors using the type system. [Read full article](https://serokell.io/blog/algebraic-data-types-in-haskell)

## Maybe you should do less "work"

It contains good points about learning new things at work and making the most value of our working hours. Being efficient, developing other skills, and growing your network. [Read full article](https://www.johnwhiles.com/posts/work.html)

## How to Quiet Your Mind Chatter

You just finished a Zoom call with one of your clients or your boss. But, you kept the conversation going in your head role-playing what you could have said differently.

We all have experienced that inner voice to imagine different endings to our conversations. Quoting the artcile, _"what chatter does is take a stressful experience and prolong it... What makes stress bad is when it’s prolonged over time, and that’s what chatter really does."_ The article shows two strategies to deal with chatter. [Read full article](https://nautil.us/how-to-quiet-your-mind-chatter-9641/)

Voilà! Those are this month Monday Links. Do you have a career plan? How many environment do you have between developers' machines and Production? Three? Do you use your work time to sharpen your skills?

In the meantime, check my <a href="https://www.educative.io/courses/getting-started-linq-c-sharp" target="_blank" rel="noopener noreferrer">Getting Started with LINQ course</a> where I cover from what LINQ is to its most recent methods and overlaod in .NET6. Don't miss the previous [Monday Links on Blog, Error Messages and Recruiters]({% post_url 2022-04-25-MondayLinks %}).

_Happy coding!_