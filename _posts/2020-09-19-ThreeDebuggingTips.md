---
layout: post
title: In case of emergency, break the glass. Three debugging tips
tags: career
---

What do you do when you're facing a problem or have to fix a bug? Bang your head against the wall, smash your display? Here you have three debugging tips.

## 1. Isolate your problem

A coworker always says "Isolate your problem!" when you ask him for help. He's right!

Start by removing all irrelevant parts from your problem. Is the problem in your database layer? In your JavaScript code? In your API controllers? Create an unit or integration test to recreate the conditions of your problem and the input that triggers it.

## 2. Stop and think

One of my takeaways from the book [Pragmatic Thinking and Learning]({% post_url 2020-05-07-PragmaticThinkingAndLearning %}) is thinking how to deliberately create the bug you're facing. Run experiments to test your hypothesis.

Debugging is thinking. Pen and paper are your friends. 

Sometimes you have to explain your problem to somebody else. And, the answer seems to come by magic. You don't have anyone around?-you said. Think out loud or explain it to a rubber duck.

<figure>
<img src="https://images.unsplash.com/photo-1669236767457-e1aa4678eadb?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixlib=rb-4.0.3&q=80&w=600&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA" width="600" />

<figcaption>Your best debugging friend. Photo by <a href="https://unsplash.com/@_allieastorga_?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Allison Astorga</a> on <a href="https://unsplash.com/photos/a-yellow-rubber-ducky-E_HNTeajpG4?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a></figcaption>
</figure>

## 3. Find how others have solved your problem

Chances are somebody else has already faced and solved the same problem or a similar one. If you look out there, you might find an StackOverflow answer or a GitHub issue. Don't blindly copy and paste any code without understanding it first. And, always prefer battle-tested solutions.

Voilà! These are three tips I have learned to use when facing an issue or figuring out how to solve a bug. One final tip: step away from your keyboard. That would make the diffuse mode of your brain to work.

Are you curious about problem solving and learning in general? Check my takeaways from the book [Pragmatic Thinking and Learning]({% post_url 2020-05-07-PragmaticThinkingAndLearning %}) and the book [Ultralearning]({% post_url 2020-07-14-UltralearningTakeaways %}).

_Happy debugging!_



 