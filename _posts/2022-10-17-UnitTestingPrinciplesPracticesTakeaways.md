---
layout: post
title: "Unit Testing Principles, Practices, and Patterns: Takeaways"
tags: books
cover: Cover.png
cover-alt: "<PutYourCoverAltHere>" 
---

This book won't teach you how to write a unit test step by step. But, it will teach you how unit testing fits the larger picture of a software project. Also, this book shows how to write integration tests and test the database. These are my takeaways.

## 1. What is a unit test?

"The goal of unit testing is to enable sustainable growth of the software project." "It's easy to fall into the trap of writing unit tests for the sake of unit testing without a clear picture of whether it helps the project."

A successful test suite has the following properties:

* It's integrated into the development cycle,
* It targets only the most important parts of your codebase: the domain model,
* It provides maximum value with minimum maintenance costs.

A unit test is an automated test with three attributes:

1. It verifies a small portion of behavior (a unit),
2. does it quickly, and,
3. in isolation from other tests

There are two groups of developers with different views about "isolation": the London school and the Classical school.

For **the London school**, isolation means writing separate tests for separate classes. If a class has collaborators, we should test it using test doubles for every collaborator.

On the other hand, for **the Classical school**, it's not the code that needs to be tested in isolation, but the tests. They should run in isolation from each other. It's ok to test more than one class at a time if the tests don't affect others by sharing state.

> "A test—whether a unit test or an integration test—should be a simple sequence of steps with no branching"

A good unit test has these four attributes:

1. **Protection against regressions**: "Code that represents complex business logic is more important than boilerplate code."
2. **Resistance to refactoring**: "The more the test is coupled to the implementation details of the system under test (SUT), the more false alarms it generates."
3. **Fast feedback**: "The faster the tests, the more of them you can have in the suite and the more often you can run them."
4. **Maintainability**: "How hard is to read a test" and "how hard is to run a test."

<figure>
<img src="https://images.unsplash.com/photo-1537090357686-51aaa968f2ab?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY2NDIzNzg1Ng&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Car cashed into a wall" />

<figcaption>That's a failing test. Photo by <a href="https://unsplash.com/@gareth_harrison?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Gareth Harrison</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 2. What code to test?

Not all code is created equal and worth the same.

{% include image.html name="TypesOfCode.png" alt="Types of Code based on complexity and number of dependencies" caption="Types of Code by Complexity and Number of Dependencies" width="350px" %}

There are four types of code:

1. **Domain logic and algorithms**: Complex code by nature
2. **Trivial code**: Constructors without parameters and one-line properties
3. **Controllers**: Code with no business logic that coordinates other pieces
4. **Overcomplicated code**: Complex code with too many dependencies

**Write unit tests for your domain model and algorithms. It gives you the best return for your efforts. Don't test trivial code. Those tests have a close-to-zero value.**

> "Your goal is a test suite where each test adds significant value to the project. Refactor or get rid of all other tests. Don’t allow them to inflate the size of your test suite"

## 3. What is an integration test? And how to test the database?

An integration test is any test that is not a unit test. In the sense of verifying a single behavior, doing it quickly and in isolation from other tests.

Write integration tests to cover the longest happy path and use the same code that the "controllers" use.

Before writing integration tests for the database:

* Keep the database in the source control system. It keeps track of changes and makes the code the single source of truth
* Make reference data part of the database schema
* Have every developer roll a separate instance
* Use migration-based database delivery. Store your migrations in your version control system.

When writing integration tests for the database:

* Separate database connections from transactions. Use repositories and transactions.
* Don't reuse database transactions or units of work between sections of the test. Integration tests should replicate the production environment as closely as possible. This means the Act part shouldn't share connections or database context with anyone else.
* Clean up data at the beginning of each test. Create a base class and put all the deletion scripts there.
* Don't use in-memory databases. They don't have the same set of features. Use the same database system as production.
* Extract technical, non-business-related parts into helper methods. For Arrange parts, use object mothers. And, for Assert parts, create extension methods for data assertions, like, `userFromDb.ShouldExist()`.
* Test only the most complex or important read operations. Forget about the rest.
* Don't test repositories directly. Test them as part of an overarching integration test suite.

Voilà! These are my takeaways. Although this book has "Unit Testing" in its title, I really liked it covers integration tests, especially testing the database and data-access layer. I'd say this isn't a book for beginners. You would take more out of this book if you read [The Art Of Unit Testing]({% post_url 2020-03-06-TheArtOfUnitTestingReview %}) first.

If you want to read more about unit testing, check my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where I cover from what unit testing is to unit testing best practices.

{%include ut201_course.html %}

_Happy testing!_