---
layout: post
title: "I don't use 'Pushy' questions in code reviews anymore. This is what I do instead"
tags: codereview
cover: Cover.png
cover-alt: "Reading a book using a finger"
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

"Ask questions" is common advice for better code reviews.

At some point, we followed that advice and started using what I call "leading" or "pushy" questions. Questions that only hint a request for a code change.

After working on a remote software team for a couple years, I stopped using "pushy" questions on code reviews. Here's why it's a bad idea.

## "Pushy" Questions Are Time-Consuming

Let's imagine we've written a method and forgot to check for nulls. Something like this,

```csharp
public void DoSomething(OneParam oneParam, AnotherParam anotherParam)
{
    var someResult = AMethodThatUsesOneParam(oneParam.SomeProperty);
    // ...
    // Beep, beep, boop...
}
```

If we follow the advice to ask "pushy" questions, we might leave and receive comments like _"What if oneParam is null?"_ or _"Could oneParam or anotherParam be null?"_

The problem with those types of comments is we can't tell if they're genuine questions or actionable items. Is the reviewer asking a clarification question or "pushing" us in a different direction? We can't tell.

Behind those comments, there's a hidden change request. How is the code author supposed to know the reviewer is asking for a change? 

While working on a remote team, it happened more than once that I had to reach out to reviewers via email or chat to ask them to clarify their intentions behind those comments. But some reviewers were in different time zones or even on the other side of the world. All interactions took about ~24 hours between my initial message and their response.

It was frustrating and time-consuming. Arrrggg!

When it was my turn to be a code reviewer, I chose a different approach: I stopped asking those questions.

<figure>
<img src="https://images.unsplash.com/photo-1620662736427-b8a198f52a4d?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY2ODcyMzYyMA&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="The Thinker" />

<figcaption>That's a tricky question. Let me think about it. Photo by <a href="https://unsplash.com/@tingeyinjurylawfirm?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Tingey Injury Law Firm</a> on <a href="https://unsplash.com/s/photos/question?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Use Unambiguous and Intentional Comments

Instead of asking "pushy" questions, let's leave actionable and unambiguous comments that distinguish between questions, to-dos, and nice-to-haves.

Let's go back to the previous example and leave an unambiguous comment. Like this one: _"Is it possible that oneParam could be null? If that's the case, please let's add the appropriate null checks. Something like `if (oneParam == null) throw ...`"_

With that comment, it's clear we're suggesting a change.

To better show the intention behind our comments, we can use [Conventional Comments](https://conventionalcomments.org/).

With that convention, we add keywords like "question," "suggestion" or "nitpick" to clarify the purpose of our comments.

I used it for months in one of my client's projects and other reviewers started to use it too.

For example, we can turn our previous "pushy" comment into these two depending on our intention:

1. A clarification question: _"**question:** Is it possible that oneParam could be null?"_
2. A change request: _"**suggestion (blocking):** Let's add the appropriate null checks if oneParam could be null."_

Now it's clear we're referring to two different actions.

Voilà! That's why I don't like "pushy" questions in code reviews. Let's always prefer clear and direct comments without forgetting good manners of course. And let's remember we review code from people with different experience levels and even non-native speakers of our language.

After this experience, my rule of thumb for better code reviews is to write unambiguous comments and always include a suggestion with each comment.

If you want to read more about code reviews, check these [Tips and Tricks for Better Code Reviews]({% post_url 2019-12-17-BetterCodeReviews %}) and these [lessons I learned about as code reviewer]({% post_url 2022-12-19-LessonsAsReviewer %}). And if you're interested in unit testing, this lesson came up during  a code review session: [how to use simple test values to write good unit tests]({% post_url 2022-12-14-SimpleTestValues %}).

_Happy coding!_