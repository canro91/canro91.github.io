---
layout: post
title: Tips and Tricks for Better Code Reviews
tags: productivity career
---

You're new to code reviews? You don't know what to look for in a code review? You feel frustrated with your code review? It's true that code reviews can be frustrating for the reviewer and the reviewee. Let's see how to improve our code reviews.

**Code review is a stage of the software development process where a piece of code is examined to find bugs, security flaws and other issues. Often reviewers follow a coding standard and style guide while reviewing code.**

> TL;DR
> 1. For the reviewer: Be nice. Remember you are reviewing the code, not the writer.
> 2. For the reviewee: Don't take it personal. Every code review is an opportunity to learn.
> 3. For all the dev team: Reviews take time too. Add them to your estimates.

## Advantages of Code Reviews

**Code reviews are a great tool to identify bugs before the code head to the QA team or your end users**. Sometimes you need another pair of eyes to spot unnoticed things in your code.

Also, **code reviews ensure the quality of the code doesn't degrade as the project moves forward**. They help to spread knowledge inside a team and mentor newcomers or juniors.

Now that we know what code reviews are good for, let' see what to look for during code reviews and tips for each role in the review process.

## What to look for in a code review?

Are you new to code reviews and you don't know what it's going to be reviewed in the code you wrote? Or have you been asked to review somebody else's code and you don't know what to look for? You can take a look at this:

Does the code...

* Compile in somebody else’s machine? If you have a Continuous Integration/Continuous Deployment (CI/CD) tool, you can spot if the code is compiling and all tests are passing.
* Include unit or integration tests? 
* Introduce new bugs?
* Follow current standards?
* Reimplement things? Some logic is already implemented in the standard library or in a extension method?
* Build things the hard way?
* Kill performance?
* Have duplication? Has code been copied and pasted?

It's a good idea to have a checklist next to you while reviewing code. You could create your own checklist or start using [Doctor McKayla Code Review Checklist](https://www.michaelagreiler.com/code-review-checklist-2/).

<figure>
<img src="https://images.unsplash.com/photo-1553877522-43269d4ea984?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop&ixid=eyJhcHBfaWQiOjF9" alt="Tips and tricks for better code reviews" width="800">
<figcaption><span>Photo by <a href="https://unsplash.com/@charlesdeluvio?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Charles Deluvio</a> on <a href="https://unsplash.com/s/photos/review?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## For the reviewer

Before you start any review, make sure to understand the requirements. Start by looking at the [unit tests]({% post_url 2021-03-15-UnitTesting101 %}), they should be like documentation.

It's a good idea to look at the diff of the code twice. One for the general picture and another one for the details.

* **Be humble**. We all have something to learn.
* **Take out the person when giving feedback**. Remember you are reviewing the code, not the author.
* **Be clear**. You may be reviewing code from juniors, mid-level or seniors. Even from non-native speakers of your language. Everybody doesn’t have the same level of experience as you. Obvious things for you aren’t obvious for somebody else. 
* **Give actionable comments**. Don't use tricky questions to make the author change something. Give clear and actionable comments, instead. For example, _what do you thing about this method name?_ vs _I think X would be a better name for this method. Could we change it?_
* **Always give at least one positive remark**. For example: _It looks good to me (LGTM)_, _good choice of names_.
* **Use questions instead of commands or orders**. For example, _Could this be changed?_ vs _Change it_. And, don't forget the magic word: _please_.
* **Use "we" instead of "you"**. You're part of development process too. You're also responsible for the code you're reviewing.
* **Instead of showing an ugly code, teach**. Link to resources to explain even more. Use blog posts and StackOverflow questions.
* **Review only the code that has changed**. Don't say things like: _Now you're there, change that method over there too_.
* **Find bugs, instead of style issues**. Rely on linters, compiler warnings and IDE extensions to find sytling issues.

Recently, I found out about [conventional comments](https://conventionalcomments.org/). The basic idea of this convention is to prefix comments with labels to show the type of comments (suggestion, nitpick, question) and the nature of them (blocking, non-blocking, if-minor).

## For the reviewee

Before asking someone to review your code, review your own code. Check if all tests are passing, classes and methods follow naming conventions, new code comply to styling guidelines.

It's a good idea to wait for the CI/CD to build and run all tests before asking someone to review your changes or assign reviewers in a tool. This will save time to your reviewers and you.

* **Don't take it personal**. It's the code under review, not you. Breathe!
* **Find in every review an opportunity to learn**. Identify what comments you get often and [avoid them on your next reviews]({% post_url 2020-09-02-TwoRecurringReviewComments %}). 
* **Give context**. Make sure the reviewer have enough context to review the code. Write an explanatory title and a description of what your code does and what decisions you made.
* **Keep your work short and focused**. Don't make the reviewer go through thousand of lines of code in a single review session. Don't change business logic and formatting/styling in the same set of changes.
* **Keep all the discussion online**. If you contacted the reviewer by chat or email, bring relevant comments to the reviewing tool for other to see them.

## For team management

* Code reviews should be the highest priority.
* **Code reviews are as important as writing code**. They take time too. Add them to your estimates.
* Have as reviewer someone familiar with the code being reviewed.
* **Have at least two reviewers**. For example, pick one reviewer, then he will pick another one until the two of them agree.

Voilà! You may feel frustrated with code reviews, either as reviewer or reviewee. Sometimes, reviews could end up being a discussion about styling issues and naming variables. I know, I've been there...But, be humble and nice! Every code review is a chance to learn something new.

These are some of the resources I used to compile this list of tips.

* [Code Review Etiquettes 101](https://www.youtube.com/watch?v=Z0j1m7qwk3M)
* [10 tips for reviewing code you don’t like](https://developers.redhat.com/blog/2019/07/08/10-tips-for-reviewing-code-you-dont-like/)
* [Code Reviews and the Company Goal](https://blog.codereview.chat/2019/06/27/code-reviews-and-your-company-goal.html)
* [The Code Review Bottleneck](https://blog.codereview.chat/2019/07/15/the-code-review-bottleneck.html)
* [How to code review](https://rcoh.me/posts/how-to-code-review/)
* [Bringing A Healthy Code Review Mindset To Your Team](https://www.smashingmagazine.com/2019/06/bringing-healthy-code-review-mindset/)
* [Productive code reviews](https://spin.atomicobject.com/2019/10/31/productive-code-reviews/)
* [A Zen Manifesto for Effective Code Reviews](https://www.freecodecamp.org/news/a-zen-manifesto-for-effective-code-reviews-e30b5c95204a/)

_Happy coding!_
