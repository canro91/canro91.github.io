---
layout: post
title: In case of emergency, break the glass. Three debugging tips
tags: career
---

What do you do when you're facing a problem or have to fix a bug? Here you have three debugging tips.

## Isolate your problem

A coworker always says _Isolate your problem!_ when you ask him for help. He's right!

Start by removing all irrelevant parts from your problem. Is the problem in your database layer? In your JavaScript code? In your API controllers? Create an unit or integration test to recreate the conditions of your problem and the input that triggers it.

## Stop and think

One of [my takeaways from the book Pragmatic Thinking and Learning]({% post_url 2020-05-07-PragmaticThinkingAndLearning %}) is thinking how to deliberately create the bug you're facing. Run experiments to test your hypothesis.

Debugging is thinking. Pen and paper are your friends. But, sometimes you have to explain your problem to somebody else. And, the answer seems to come by magic. _You don't have anyone around?_ Think out loud or explain it to a rubber duck.

<figure>
<img src="https://source.unsplash.com/LhqLdDPcSV8/800x400" width="800" />
<figcaption>Photo by <a href="https://unsplash.com/@timothycdykes?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Timothy Dykes</a> on <a href="https://unsplash.com/s/photos/debug?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Find how others have solved your problem

Chances are somebody else has already faced and solved the same problem or a similar one. If you look out there, you might find an StackOverflow answer or a GitHub issue. Don't blindly copy and paste any code without understanding it first. And, always prefer battle-tested solutions.

_Happy debugging!_



 