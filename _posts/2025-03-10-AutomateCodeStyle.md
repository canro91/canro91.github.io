---
layout: post
title: "Always Automate Code Style (and Other Best Practices)"
tags: coding
---

At one of my previous jobs, there was a new guideline:

> _Format all SQL queries using right-aligned style._

## The problem?

During a [pull request review]({% post_url 2019-12-17-BetterCodeReviews %}), one or two managers, who didn't code anymore, decided on that guideline.

And the next day, without telling anyone else, that guideline was set in stone and enforced throughout the codebase. Guess what was the most common comment on code reviews since then? "Please properly format this SQL query."

**Lesson**: Always share new guidelines and coding style changes with the team, especially if you're planning on enforcing them on all projects. Just send an email or a quick Slack update to make sure everybody is on the same page. No need for an all-hands meeting.

## The other problem?

There was no clear way to format those files. Should every coder do it by hand? Using their favorite tool? Or using an "official" tool?

Being a lazy coder, I didn't want to format my files by hand. Copying SQL queries from Visual Studio, going to a tool page, pasting them, and copying them back was too much effort—I told you I'm lazy.

Computers are designed to do boring and repetitive work. Formatting files definitely fit that description. In one afternoon of frustration, I hacked [a Git hook to format my SQL files]({% post_url 2023-09-18-FormatSqlFilesOnCommit %}) and shared it with my team lead.

**Lesson**: Make sure to have an automated and widespread tool so anyone can follow new guidelines and coding style changes as easily as possible.

We wasted so much time on code reviews, asking people to format those files, [waiting 24 hours to finally merge things]({% post_url 2022-12-05-LeadingQuestionsOnCodeReviews %}).

For better or worse, my next project at that job didn't involve SQL. And months later, [I was let go]({% post_url 2024-12-05-HowALayoffFeels %})...so I don't know what happened to that guideline or to my tool.
