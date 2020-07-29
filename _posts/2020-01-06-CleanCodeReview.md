---
layout: post
title: A Review of Two Clean Code Books
tags: books
---

## Clean Code

[Clean Code](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882) will change the way you code. It doesn’t teach how to code in a particular language, but how to produce code easy to read, grasp and maintain. Although code samples are in Java, all concepts can be translated to other languages. This book is based on the premise that code should be optimized to be read. 

The book starts defining what it's *Clean Code* by collecting quotes from book authors and other well-known people in the field. It covers the subject of Clean Code from variables to architectural design.

Three chapters you may find very instructive are the ones about naming, comments and functions.

**Naming**. The first concept after the definition of Clean Code is naming thing. This chapter encourage names that reveal intent and are easy to pronounce. For example, `int d; // elapsed time in days` vs `int elapsedTimeInDays`, `genymdhms` vs `generationTimestamp`, `HolyHandGrenade` vs `DeleteItems`.

**Comments**. Clean Code is better than bad code with comments. Maybe you have heard about commenting your code as the right thing to do. But, this chapter shows what actually need comments. Have you seen this kind of comment before? `i++; // Increment i` Have you written them? *"Don't use a comment when a function or variable can be used"*.

**Functions**. There is one entire chapter devoted to functions. It recommends short and concise functions. *"Functions should do one thing. They should do it well"*. For example, this chapter discourages functions with boolean paramaters. They will have to handle the true and false scenarios, then it won't do only one thing.

*Clean Code* should be an obligatory reading for every single developer. Teachers should, at least, point students to this book. This book doesn’t deserve to be read, it deserves to be studied. So, grab a copy and study it.

## The Art of Readable Code

[The Art of Readable Code](https://www.amazon.com/Art-Readable-Code-Practical-Techniques/dp/0596802293), the perfect companion for the Clean Code. It isn't as dogmatic as Clean Code. It contains simple and practical tips to improve your code at the function level. Tips aren't as strict as the Clean Code ones. But, it still deserves to be read. Code samples are in Javascript, Python, C and Java.

This book presents the concept that *code should be written to minimize the time for someone else to understand the code*. Here, understand means to solve errors, to spot bugs, to make changes. Among other tips in this book, you can find:

* Attach extra information to your names. For example, encode units. `delay` vs `delay_secs`, `size` vs `size_mb`
* Avoid misunderstading from your names. For example: `results = Database.all_objects.filter("year <= 2011")` Does `filter` pick out elements? Use `select`. Or does it get rid of? Use `exclude`.
* Use min and max in your names for inclusive limits. For example, `MAX_ITEMS_IN_CART`
* Use first and last for inclusive limits. For example, `print integer_range(start=2, stop=4)` What is the result? `[2,3]` or `[2,3,4]`. Instead, `print integer_range(first=2, last=4)`
* Use begin and end for inclusive/exclusive ranges. For example: To find all events on a date `PrintEventsInRange("OCT 16 12:00am", "OCT 17 12:00am")` instead of `PrintEventsInRange("OCT 16 12:00am", "OCT 16 11:59.999am")`
* Use named parameters or try to mimic them. For example: `connect(/*timeout_ms=*/10, /*use_ssl=*/false)`
* Separate business logic from problem specific code. This encourages to keep code at a single level of abstraction and to write reusable methods.
* **The most readable code is not code at all**. This book recommend reading documentation and method signatures from your libraries and tools. So you don't roll out your own code.

*The Art of Readable Code* is a good starting point to introduce the concept of readability and clean code to your team. These tips and tricks are a good reference for code standards and reviews.