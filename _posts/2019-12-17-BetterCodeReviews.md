---
layout: post
title: Tips and Tricks for Better Code Reviews
tags: productivity career
---

Code reviews are a great tool to identify bugs before the code head to the QA team or the clients. Sometimes you need another pair of eyes to spot unnoticed things. Also, code reviews are great to keep the code clean as the project moves forward. They help to spread knowledge inside a team and mentor newcomers or juniors. But, it's true that code reviews can be terse and frustrating for the reviewer and the reviewee. _No worries!_ Here, you have a collected list of tips and tricks for better code reviews.

> TL;DR
> 1. For the reviewer: be nice and remember you are reviewing the code, not the writer.
> 2. For the reviewee: don't take it personal, every code review is an opportunity to learn.
> 3. For all the dev team: reviews take time too, add them to the estimates.

## What to look for in a code review?

_What should I look at?_ Are you new to code reviews and you don't know what it's going to be reviewed in the code you wrote? Or have you been asked to review somebody else's code and you don't know what to look for? You can take a look at this:

Does the code...

* Compile in somebody else’s machine? If you have a _Continuous Integration_ tool, you can spot if the code is compiling and all tests are passing.
* Include unit or integration tests? 
* Introduce new bugs?
* Follow current standards?
* Reimplement things? Some logic is already implemented in the standard library or in a extension method?
* Build things the hard way?
* Kill performance?
* Have duplication? Has code been copied and pasted?

## For the reviewer

Before you start any review, make sure to understand the requirements. Start by looking at the tests, they should be like documentation. It's a good idea to look at the diff twice: one for the general picture and another for the details.

* Be humble: We all have something to learn.
* Take out the person when giving feedback. Remember you are reviewing the code, not the author.
* Be clear: You may be reviewing code from juniors, mid-level or seniors. Even from non-native speakers of your language. Everybody doesn’t have your same level of experience. Obvious things for you aren’t obvious for somebody else. 
* Always give at least one positive remark. For example: _It looks good to me (LGTM)_
* Use questions instead of commands or orders. For example, _Could this be changed?_ vs _Change it_
* Use "we" instead of "you"
* Instead of showing an ugly code, teach. Link to resources to explain even more. For example: blog posts and StackOverflow questions.
* Review only the code that has changed.
* Find bugs while reading the code, instead of style issues.

## For the reviewee

* Don't take it personal. It's the code under review, not you
* Find in every review an opportunity to learn
* Make sure the reviewer have enough context to review the code. For example: write a description of your PR,  what it does, what decisions you made
* Keep all the discussion online. If you contacted the reviewer by chat or email, bring relevant comments online

## For team management

* Code reviews should be the highest priority
* Code reviews are as important as writing code. They take time too. Make sure to add code reviews to your estimates
* Have as reviewer someone familiar with the code being reviewed
* Have at least two reviewers. For example, pick one reviewer, then he will pick another one until the two of them agree

You may feel frustrated with code reviews, either as reviewer or reviewee. Sometimes, reviews could end up being a discussion about styling issues. _I know..._ But, be humble and nice! Every code review is a chance to learn something new.

Sources:

* [Code Review Etiquettes 101](https://www.youtube.com/watch?v=Z0j1m7qwk3M)
* [10 tips for reviewing code you don’t like](https://developers.redhat.com/blog/2019/07/08/10-tips-for-reviewing-code-you-dont-like/)
* [Code Reviews and the Company Goal](https://blog.codereview.chat/2019/06/27/code-reviews-and-your-company-goal.html)
* [The Code Review Bottleneck](https://blog.codereview.chat/2019/07/15/the-code-review-bottleneck.html)
* [How to code review](https://rcoh.me/posts/how-to-code-review/)
* [Bringing A Healthy Code Review Mindset To Your Team](https://www.smashingmagazine.com/2019/06/bringing-healthy-code-review-mindset/)
* [Productive code reviews](https://spin.atomicobject.com/2019/10/31/productive-code-reviews/)
