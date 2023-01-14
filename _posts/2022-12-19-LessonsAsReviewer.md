---
layout: post
title: "Lessons I learned as a code reviewer"
tags: career codereview
cover: Cover.png
cover-alt: "Two engineers reading a report" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

In the past month, for one of my clients, I became a default reviewer. I had the chance to check everybody else's code and advocate for change. After dozens of Pull Requests (PRs) reviewed, these are the lessons I learned.

I've noticed that most of the comments fall into two categories. I will call them "babysitting" and "surprising solution."

## 1. Babysitting

In these projects, before opening a PR, we have to cover all major code changes with tests, have zero analyzer warnings, and format all C# code. But try to guess what the most common comments are. Things like "please write tests to cover this method," "address analyzers warnings," and "run CodeMaid to format this code."

As a reviewee, before opening a PR, wear the reviewer hat and review your own code. It's frustrating when the code review process becomes a slow and expensive linting process.

To have a smooth code review, let's automate some of the things checked during the review process. We can run a linter with a Git hook before committing our files or a [Visual Studio extension]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}) to clean files every time we save our files. We can turn all warnings into errors.

## 2. Surprising solution

Apart from making developers follow conventions, the next most common comments are clarification comments. Things like "why did you do that? Possibly, this is a simpler way." Often, it's easy when there's a clear and better solution. Like when a developer used semaphores to prevent concurrent access to dictionaries. We have concurrent collections for that.

As a reviewee, use the PR description and comments to give enough context to avoid unnecessary discussion. The most frustrating PRs are the ones with only a ticket number in their title. Show the entry point of your changes, tell why you chose a particular design, and signal places where you aren't sure if there's a better way. 

Voilà! These are some of the lessons I learned after being a reviewer. The next time you open a PR, review your own code first and give enough context to your reviewers.

But, the one thing to improve code reviews is to use short PRs. PRs everyone could review in 10 or 15 minutes without too much discussion. As a reviewer, I wouldn't mind reviewing multiple short PR's in a working session than reviewing one single long PR that exhausts all my mental energy.

Also as a reviewer, I learned to stop using [leading or tricky questions]({% post_url 2022-12-05-LeadingQuestionsOnCodeReviews %}). And I taught to [use simple test values to write good unit tests]({% post_url 2022-12-14-SimpleTestValues %}).

If you're new to code reviews, check these [Tips for better code reviews]({% post_url 2019-12-17-BetterCodeReviews %}).

_Happy coding!_