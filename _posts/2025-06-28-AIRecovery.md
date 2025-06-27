---
layout: post
title: "A Quick Recovery Guide for AI-Dependent Coders"
tags: coding
---

Technology makes us lazy.

That's not an opinion but a fact. We can't do mental math, find addresses, or memorize phone numbers anymore. That's the problem with relying too much on a piece of tech. Smartphones, I'm looking at you.

The same thing happens in coding, with AI and vibe-coding.

I'm guilty too. I've been [experimenting with AI]({% post_url 2025-06-19-CodingWithAI %}) to offload my plate of boring tasks. And when I can't think of an answer immediately, I'm tempted to go straight to the genie in the bottle to grant me a coding wish.

And I'm not alone in this. Recently, I found this question on [Reddit](https://www.reddit.com/r/csharp/comments/1ll2vzs/how_to_stop_relying_on_chatgpt/),

> _"It's been a while since I coded on C#/Unity so I'm very rusty on the concepts and relying too much on ChatGPT makes me feel like I haven't learned anything and can't write code on my own without doing basic mistakes... How do I learn everything back? Isn't there a way to refresh my mind? A really good video on YouTube or something? I want to stop using AI and code on my own."_

For the original poster and anyone else who wants to break free from AI, here are 10 ideas to try:

## 0. Ban AI.

Think of [AI as calculators in math classes]({% post_url 2025-03-31-AIAndCalculators %}). You can't use them until you know the procedure you want to automate by hand.

## 1. Study your main language syntax.

Get to know the syntax of your language of choice: write variables, functions, loops, classes...

For that, grab a textbook or watch a _"all you need to know about X in 4 hours"_ YouTube videos. But [don't just passively consume them]({% post_url 2024-11-02-PassiveLearning %}), recreate the examples and projects from them. By typing them out. No Control C + Control V.

## 2. Know your standard library.

Get familiar with your standard library:
* Write a variable and see what your editor or IDE suggests.
* What methods can you use with that type?
* Look at their signature and docstring.

## 3. Study SQL.

No matter how powerful ORMs are, we can't escape from SQL.

We've had SQL since the early 70s and chances are we're still using SQL another decade or two.

Learn to create tables, write queries aggregating results, and learn about JOINs. Download a light version of the StackOverflow database and play with it, if you want realistic examples.

## 4. Build a toy project from scratch.

OK, I'm not talking about reinventing the wheel to write your own text editor or something.

I'm talking about building a recipe catalog, a todo app, or a wrapper around a free API. And build it from scratch: right click, then create new folder in your editor or IDE, and so on. It will teach you a lot.

## 5. Find your own answers.

When you get an error message (you will if you follow #4), resist the urge of going back to AI or simply asking a friend.

Try to figure out errors and exceptions on your own. Start by googling the error message. There's a thing called Google that finds web pages with answers to our questions. Sure, it's old-school but it builds real muscle. Remember, AI is still banned. (See #0)

## 6. Learn the most common data structures.

80% of the time, you'll only need lists and dictionaries. But there are more data structures.

Learn to use them and how to implement them. You won't have to implement them from scratch at your daily job, but it will stretch your problem-solving muscles.

## 7. Study a textbook on Math for Computer Science.

Unless you're working on niche domains, you won't need advanced Math.

But grab a book on Discrete Math (or Math for Computer Science) and study a chapter or two. Again, to sharpen your thinking.

## 8. Practice rubber-duck debugging.

You will get stuck a lot. That's a feature of being a coder, not a bug.

When that happens,
1. Grab pen and paper
2. Go through your program line by line
3. Talk out loud

## 9. Read the official documentation.

Pull out the Mozilla's Web Docs, Microsoft Learn, and any other official source for your language of choice, and not only read it, but come up with your own examples and think of how you can use what you're reading in your own code.

AI is a blessing for learning. Ask any veteran who learned from reference manuals, language specifications, and magazines, they'll tell you. Just don't let AI think for you. OK, let's slightly lift the AI ban, [don't use it to generate code]({% post_url 2025-03-24-NewCodersAndAI %}). Use it as your copilot, not as your captain.

If you're new at coding, [stop chasing shiny objects]({% post_url 2025-01-30-ChasingShinyObjects %}) and follow these [10 tips every new coder should know to succeed]({% post_url 2025-03-08-TipsForNewCoders %}).
