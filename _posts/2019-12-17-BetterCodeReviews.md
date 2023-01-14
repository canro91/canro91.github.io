---
layout: post
title: Tips and Tricks for Better Code Reviews
tags: productivity codereview
---

Are you new to code reviews? Do you know what to look for in a code review? Do you feel frustrated with your code review? I've been there too. Let's see some tips I learned and found to improve our code reviews.

**Code review is a stage of the software development process where a piece of code is examined to find bugs, security flaws, and other issues. Often reviewers follow a coding standard and style guide while reviewing code.**

> TL;DR
> 1. For the reviewer: Be nice. Remember you are reviewing the code, not the writer.
> 2. For the reviewee: Don't take it personally. Every code review is an opportunity to learn.
> 3. For all the dev team: Reviews take time too. Add them to your estimates.

## Advantages of Code Reviews

**Code reviews are a great tool to identify bugs before the code gets shipped to end users**. Sometimes we only need another pair of eyes to spot unnoticed issues in our code.

Also, **code reviews ensure that the quality of the code doesn't degrade as the project moves forward**. They help to spread knowledge inside a team and mentor new members.

Now that we know what code reviews are good for, let's see what to look for during code reviews and tips for each role in the review process.

## What to look for in a code review?

If we're new to code reviews and we don't know what it's going to be reviewed in our code...or if we have been asked to review somebody else code and we don't know what to look for, we can start looking at this:

Does the code:

* Compile in somebody else machine? If you have a Continuous Integration/Continuous Deployment (CI/CD) tool, we can easily check if the code is compiling and all tests are passing.
* Include unit or integration tests? 
* Introduce new bugs?
* Follow current standards?
* Reimplement things? Is some logic already implemented in the standard library or an extension method?
* Build things the hard way?
* Kill performance?
* Have duplication? Has the code been copied and pasted?

It's a good idea to have a checklist next to us while reviewing the code. We can create our own checklist or use somebody else as a reference. Like [Doctor McKayla Code Review Checklist](https://www.michaelagreiler.com/code-review-checklist-2/).

<figure>
<img src="https://images.unsplash.com/photo-1553877522-43269d4ea984?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop&ixid=eyJhcHBfaWQiOjF9" alt="Tips and tricks for better code reviews" width="800">
<figcaption><span>Photo by <a href="https://unsplash.com/@charlesdeluvio?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Charles Deluvio</a> on <a href="https://unsplash.com/s/photos/review?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## For the reviewer

Before we start any review, let's understand the context around the code we're about to review.

A good idea is to start by looking at the [unit tests]({% post_url 2021-03-15-UnitTesting101 %}) and look at the "diff" of the code twice. One for the general picture and another one for the details.

If we're a code reviewer, let's:

* **Be humble**. We all have something to learn.
* **Take out the person when giving feedback**. We are reviewing the code, not the author.
* **Be clear**. We may review code from juniors, mid-level, or seniors, even from non-native speakers of our language. Everybody has different levels of experience. Obvious things for us aren’t obvious for somebody else. 
* **Give actionable comments**. Let's not use tricky questions to make the author change something. Let's give clear and actionable comments instead. For example, _what do you think about this method name?_ vs _I think X would be a better name for this method. Could we change it?_
* **Always give at least one positive remark**. For example: _It looks good to me (LGTM)_, _good choice of names_.
* **Use questions instead of commands or orders**. For example, _Could this be changed?_ vs _Change it_.
* **Use "we" instead of "you"**. We're part of the development process too. We're also responsible for the code we're reviewing.
* **Instead of showing an ugly code, teach**. Let's link to resources to explain even more. For example, blog posts and StackOverflow questions.
* **Review only the code that has changed**. Let's stop saying things like _Now you're here, change that method over there too_.
* **Find bugs instead of style issues**. Let's rely on linters, compiler warnings, and IDE extensions to find styling issues.

Recently, I found out about [conventional comments](https://conventionalcomments.org/). With this convention, we start our comments with labels to show the type of comments (suggestion, nitpick, question) and their nature (blocking, non-blocking, if-minor).

I use Conventional Comments to avoid [tricky or pushy questions during code reviews]({% post_url 2022-12-05-LeadingQuestionsOnCodeReviews %}).

## For the reviewee

Before asking someone to review our code, let's review our own code. For example, let's check if we wrote enough tests and followed the naming conventions and styling guidelines.

It's a good idea to wait for the CI/CD to build and run all tests before asking someone to review our changes or assign reviewers in a web tool. This will save time for our reviewers and us.

If we're a reviewee, let's:

* **Stop taking it personally**. It's the code under review, not us.
* **Find in every code review an opportunity to learn**. Let's identify frequent comments and avoid them in the future. For example, this is how I avoided [some recurring comments while getting my code reviewed]({% post_url 2020-09-02-TwoRecurringReviewComments %}). 
* **Give context**. Let's give enough context to our reviews. We can write an explanatory title and a description of what our code does and what decisions we made.
* **Keep your work short and focused**. Let's not make reviewers go through thousands of lines of code in a single review session. For example, we can separate changes in business logic from formatting/styling.
* **Keep all the discussion online**. If we contact reviewers by chat or email, let's bring relevant comments to the reviewing tool for others to see them.

## For team management

If we're on the management side, let's:

* **Make code reviews have the highest priority.** We don't want to wait days until we get our code reviewed.
* **Remember code reviews are as important as writing code**. They take time too. Let's add them to our estimates.
* **Have as a reviewer someone familiar with the code being reviewed.** Otherwise, we will get styling and formatting comments. People judge what they know. That's a cognitive bias.
* **Have at least two reviewers**. For example, as reviewees, let's pick the first reviewer. Then he will choose another one until the two of them agree.

Voilà! These are the tips I've learned while reviewing other people's code and getting mine reviewed too. Code reviews can be frustrating. Especially when they end up being a discussion about styling issues and naming variables. I know, I've been there.

One of my [lessons as a code reviewer]({% post_url 2022-12-19-LessonsAsReviewer %}) is to use short and focused review sessions. I prefer to have short sessions in a day than a single long session that drains all my energy. Also, I include a suggestion or example of the change to be made in every comment. I want to leave clear and actionable comments on every code review.

Of course, I didn't come up with some of these tips. These are the resources I used to learn how to do better code reviews: [NDC's Code Review Etiquettes 101](https://www.youtube.com/watch?v=Z0j1m7qwk3M), [Russell Cohen's How to code review](https://rcoh.me/posts/how-to-code-review/), [Smashing Magazine's Bringing A Healthy Code Review Mindset To Your Team](https://www.smashingmagazine.com/2019/06/bringing-healthy-code-review-mindset/), and [FreeCodeCamp's A Zen Manifesto for Effective Code Reviews](https://www.freecodecamp.org/news/a-zen-manifesto-for-effective-code-reviews-e30b5c95204a/).

_Happy coding!_