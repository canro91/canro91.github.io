---
layout: post
title: "4 Ideas To Build a Code Review Culture Your Team Will Love"
tags: codereview
---

After sharing two strategies for faster code reviews, I got a comment on Medium that captured the struggle of building a code review culture.

Here it is:

> _I am trying to get my team to craft smaller PRs as a means to faster reviews, but I am always bombarded with questions like these:_
>
> _How can someone review the first without knowing what it will be used for? How can the reviewer have the context for the change? And what if the reviewer suggests changes to the 3rd PR that will incur changes to the second or the first?_
>
> _I get the questions, and I get the pushback, but how can we find a happy middle ground?_

I've had the same questions as the ones in the comment. I realized how painful code reviews are only after reviewing PRs. That was what made me adopt [those two strategies]({% post_url 2025-09-04-FasterCodeReviews %}) I had already shared.

Here are my two cents to make code reviews smoother and find that "happy middle ground:"

## #1. Have clear guidelines on what to review

Code reviews are pointless if we only discuss variable names or nitpick on code style.

The easy fix to avoid discussing formatting:

1. [Automate code style and conventions]({% post_url 2025-03-10-AutomateCodeStyle %}) with `dotnet format`, prettier, or similar tools.
2. Use a sample class or module to show naming styles and conventions, instead of documentation nobody ever updates.

Instead of focusing on nitpicks, define the goal of your code reviews. Is it to mentor newcomers, enforce good practices, find bugs? Or all of the above?

## #2. Always give and ask for context

At a previous team, we had the guideline to always include a JIRA ticket number in the PR title. You can adopt that one.

If you're a reviewee, always include a good title and a short description, even if you're linking to your JIRA ticket. Often, JIRA tickets only describe business requirements, not technical details.

Now if you're a reviewer, feel free to pass a PR to the right team member if you don't have enough context. Or you could take it as an advantage and approach the review process from a beginner's perspective.

## #3. Reduce ceremonies (or make PRs easy to open and merge)

At another past job, we had to fill out a form with every review.

It was a stupid rule to comply with a company certification or something. And on top of that, we didn't have a web-based collaborative tool. The reviewer had to sit with the reviewee, go through the code, and fill out a form with the "findings." And that was for every round of review. Arrggg!

Make PRs easy to open, review, and merge.

## #4. Involve all team members

To create awareness and spread change, involve all team members, even informally.

To involve your team, steal this guideline from a past job. We only merged PRs after approvals:
- From a "default" reviewer. This was someone in charge only of code reviews across the whole company. I know most companies can't afford this role.
- From the repository owner, if the PR went to a codebase from another team.
- From the team leader
- From another team member

I was only after my stint as a code reviewer that I learned to [give valuable feedback]({% post_url 2022-12-05-LeadingQuestionsOnCodeReviews %}) and clean my PRs.

Code reviews should be everyone's responsibility.

## Parting thought

Let me tell you, making this kind of change is hard.

As a default code reviewer, it took me months to see people picking up the practices I was preaching, like short PRs and using Conventional Comments.

To spread the change, enforce it (like reject large PRs) or lead by example. The first one is faster. Or try combining the two: a hard rule after an educational campaign. It takes time, but it starts with one PR.
