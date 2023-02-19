---
layout: post
title: "I stopped using leading or tricky questions in Code Reviews"
tags: codereview
cover: Cover.png
cover-alt: "Reading a book using a finger"
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

Recently, I have found posts online suggesting "leading" questions during code reviews to make the reviewee change something about his code. This is what I've learned to do instead.

**During code reviews, don't use leading questions to suggest code changes. Instead, leave unambiguous comments and distinguish between questions, actionable items, and nice-to-haves.**

## Don't use leading questions to ask for changes

For example, let's imagine we wrote a method and forgot to check for nulls. Something like this,

```csharp
public void DoSomething(OneParam oneParam, AnotherParam anotherParam)
{
    var anything = UsingOneParam(oneParam.SomeProperty);
    // ...
}
```

If our reviewer follows that advice to use "pushy" questions, we could receive comments like _"what if oneParam is null?"_ or "_could oneParam or anotherParam be null?_"

I don't like these comments. We can't tell if they're genuine questions or actionable items. Is the reviewer asking a clarification question or "pushing" us in a different direction?

We can reach out to the reviewer via email or chat to ask him to further explain his intention. But what if we and our reviewer are in different time zones? Or parts of the world? Any interaction will take about 24 hours between our message asking for clarification and an answer from the reviewer. It's frustrating and time-consuming. Arrrggg!

<figure>
<img src="https://images.unsplash.com/photo-1620662736427-b8a198f52a4d?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY2ODcyMzYyMA&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="The Thinker" />

<figcaption>That's a tricky question. Let me think about it. Photo by <a href="https://unsplash.com/@tingeyinjurylawfirm?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Tingey Injury Law Firm</a> on <a href="https://unsplash.com/s/photos/question?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Use unambiguous and intentional comments

Instead of leading or pushy questions, let's leave unambiguous comments. Also, let's distinguish between questions, actionable items, and nice-to-haves.

Let's go back to the previous example and leave an unambiguous comment. Like this one: _"is it possible that oneParam could be null? If that's the case, please let's add the appropriate null checks. Something like `if (oneParam == null) throw ...`"_ With this comment, it's clear we're suggesting a change.

We can show the intention of our comments using [Conventional Comments](https://conventionalcomments.org/). With this convention, we add keywords like "question," "suggestion" or "nitpick" to show what we meant with our comments. I've been using it for months in one of my client's projects and I've seen how other reviewers have started to pick it too.

For example, we can turn our previous comment into these two depending on our intention:
* _"**question:** Is it possible that oneParam could be null?"_
* _"**suggestion:** Let's add the appropriate null checks if oneParam could be null."_

Now it's clear the reviewer meant two different things.

Voilà! That's why I don't like "leading" questions in code reviews. Let's always prefer clear and unambiguous comments. And, let's show the intention behind them. We can review code from people with different experience levels and even non-native speakers of our language.

Ah! Another thing, let's not forget about the magic word when writing comments: "please."

If you want to read more about code reviews, check these [Tips and Tricks for Better Code Reviews]({% post_url 2019-12-17-BetterCodeReviews %}) and these [lessons I learned about as code reviewer]({% post_url 2022-12-19-LessonsAsReviewer %}). And if you're interested in unit testing, this lesson came up during  a code review session: [how to use simple test values to write good unit tests]({% post_url 2022-12-14-SimpleTestValues %}).

_Happy coding!_