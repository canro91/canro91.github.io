---
layout: post
title: The Art of Unit Testing&colon; Four Takeaways
tags: books
---

This is THE book to learn how to write unit tests. It starts from the definition of an unit test to how to implement them at your organization. Although, it covers extensively the subject, it doesn't advocate writing unit tests before or after the production code.

The main takeaway from this book is that you should treat your tests as production code. Sometimes, tests aren't treated as code that needs to be taken care of. You should have test reviews, instead of only code reviews. Your tests are your safety net, so do not let them rot.

## Naming convention

**Use `UnitOfWork_Scenario_ExpectedBehaviour` for your test names**. You can read it as follow: when calling `UnitOfWork` with `Scenario`, then `ExpectedBehaviour`. A [Unit of Work](https://osherove.com/blog/2005/4/3/naming-standards-for-unit-tests.html?rq=unit%20test) is any logic exposed through public methods that returns value, changes the state of the system or makes an external invocation.
	
With this naming convention is clear the logic under test, the inputs and the expected result. You will end up with long test names, but it's OK to have long test names for the sake of readability.

## Builders vs `SetUp` 

**Use builders instead of `SetUp` methods**. Tests should be isolated from other tests. Sometimes, `SetUp` methods create shared state among your tests. You will find tests that passes in isolation but don't pass alongside other tests and tests that need to be run many times to pass. 

Often `SetUp` methods end up with initialization for only some tests. Tests should create their own world. So, initialize what's need inside every test using builders.

## Safe green zone

**Keep a set of always passing unit tests**. You will need some configurations for your integration tests: a database, environment variables or some files in a folder. Integration tests will fail if those configurations aren't in place. So, developers could ignore some failing tests, and real issues, because of those configurations. 

Therefore, separate your unit tests from your integration tests. You will distinguish between a missing setup and an actual problem with your code. A failing test should mean a real problem, not a false positive.

## Organization of your tests

**Have a unit test project per project and a test class per class**. You should easily find tests for your classes and methods. To achieve this:

* Create separate projects for your unit and integration tests. Add the suffix `UnitTests` and `IntegrationTests` accordingly. For example, for a project `Library`, name your tests projects `Library.UnitTests` and `Library.IntegrationTests`.

* Create tests inside a file with the same name as the tested code adding the suffix `Tests`. For `MyClass`, your tests should be inside `MyClassTests`. Also, you can group features in separate files adding the name of the feature as suffix. For example, `MyClassTests.AnAwesomeFeature`.

## Conclusion

Unit testing is a broad subject. [The Art of Unit Testing](https://www.manning.com/books/the-art-of-unit-testing-second-edition) cover almost all you need to know about it. The main lesson is your tests should be readable, maintainable and trust-worthy. Remember the next person reading your tests will be you.