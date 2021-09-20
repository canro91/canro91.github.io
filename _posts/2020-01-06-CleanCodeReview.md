---
layout: post
title: "Clean Code: Takeaways"
tags: books
---

Clean Code will change the way you code. It doesn't teach how to code in a particular language. But, it teaches how to produce code easy to read, grasp and maintain. Although code samples are in Java, all concepts can be translated to other languages.

The Clean Code starts defining what it's clean Code by collecting quotes from book authors and other well-known people in the field. It covers the subject of Clean Code from variables to functions to architectural design. This book is based on the premise that **code should be optimized to be read**.

These are the three chapters I found instructive. The whole book is instructive. But, I could only read a few chapters, I would read these ones.

## Naming

The first concept after the definition of Clean Code is naming things. This chapter encourages names that reveal intent and are easy to pronounce. And, to avoid punny or funny names.

Instead of writing `int d; // elapsed time in days`, write `int elapsedTimeInDays`. 

Instead of writing, `genymdhms`, write `generationTimestamp`.

Instead of writing, `HolyHandGrenade`, write `DeleteItems`.

## Comments

Clean Code is better than bad code with comments.

We all have heard that commenting our code is the right thing to do. But, this chapter shows what actually needs comments.

Have you seen this kind of comment before? `i++; // Increment i` Have you written them? I did once.

**Don't use a comment when a function or variable can be used.**

Don't keep the list of changes and authors in comments at the top of your files. That's what [version control systems]({% post_url 2020-05-29-HowToVersionControl %}) are for.

## Functions

There is one entire chapter devoted to functions. It recommends to write short and concise functions.

**"Functions should do one thing. They should do it well"**.

This chapter discourages functions with boolean parameters. They will have to handle the true and false scenarios. Then, they won't do only one thing.

Voilà! These are the three chapters I find the most instructive and more challenging. If you could only read a few chapters, read those ones. Clean Code should be an obligatory reading for every single developer. Teachers should, at least, point students to this book. This book doesn't deserve to be read, it deserves to be studied. If you're new to the Clean Code concept, grab a copy and study it.

If you're interested in my takeaways of other books, take a look at [Clean Coder]({% post_url 2020-06-15-CleanCoder %}) and [The Art of Unit Testing]({% post_url 2020-03-06-TheArtOfUnitTestingReview %}).

_Happy reading!_