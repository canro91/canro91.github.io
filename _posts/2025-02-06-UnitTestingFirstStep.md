---
layout: post
title: "Essential First Steps for Unit Testing in C#"
tags: misc
---

Today I got a question from Pierre on my contact page about unit testing. Here's an edited version of his question:
 
> _I'm stuck at square one: how do you invoke the Unit Tests? Where are the tests stored? Are they compiled into the Release code? Is there one function that calls the whole cascade of unit tests? Nobody seems to address this very basic, indispensable first step._

I slightly covered some of those questions on my post to [write your first unit tests with MSTest]({% post_url 2021-03-15-UnitTesting101 %}). I tried to write a beginner-friendly introduction to unit testing. But, Pierre is right. I forgot to answer those questions.

So here I go:

## 1. Are unit tests compiled into our Release code?

First things first. We don't ship unit tests to our end users. And, no. They're not compiled into our release code.

We write unit tests as part of our development process. Let's say unit tests are code written for developers by developers.

The best analogy? Writing unit tests is like crashing cars as part of their security tests in a factory. Well, car makers don't ship crashed cars. Unit tests are like those crashed cars. We use them to test the cars we're shipping to our users, but don't ship them to our end users.

## 2. Where to put our unit tests

The convention I follow is to put unit tests in separate projects, named after the project where the code under test is, using "Tests" as a suffix.

For example, if our code to test is under a project called `Acme.CoolProject`, we should put our tests into a project `Acme.CoolProject.Tests`. And inside the test project, we should use folders with the same name as the code under test.

Now about the folder structure to put our tests, I've seen and used two options:

#1. **Using a `src` and `test` folders at the root of the solution**, like this

```
Acme.CoolProject.sln
 |-src/
 |---Acme.CoolProject.Api/
 |-tests/
 |---Acme.CoolProject.Api.Tests/
```

#2. **Using a `src` and `test` folders inside folders per project**, like this

```
Acme.CoolProject.sln
 |-Api/
 |---src/
 |-----Acme.CoolProject.Api/
 |---tests/
 |-----Acme.CoolProject.Api.Tests/
```

From the two options, the first one is the most common and it's my go-to folder structure.

For the actual tests names, I've found these [four test naming conventions]({% post_url 2021-04-12-UnitTestNamingConventions %}).

## 3. How to invoke our unit tests

There are three options to invoke our tests—Again, we as developers, are the ones who invoke tests, not our end users:

#1. **Directly from your IDE**: Testing frameworks come with test runners that discover and run our tests. So we can simply press a button inside Visual Studio or our IDE to run one test, all tests inside a folder, or all the tests inside our solution.

#2. **From the command line**: Thanks to [.NET CLI]({% post_url 2022-12-15-CreateProjectStructureWithDotNetCli %}), we can simply run `dotnet test` inside a folder to run all the tests inside that folder.

#3. **From a deployment tool**: If we're using a continuous integration and deployment tool, like GitHub Actions or Jenkins, we can run our tests as part of the deployment workflow to make sure we're not shipping broken code. These tools default to the .NET CLI to run the tests under the hood.

So there's no one function that calls the whole cascade of unit tests, but a button on your IDE.

Et voilà!

To read more about unit testing, check [four common mistakes when writing your first unit tests]({% post_url 2021-03-29-UnitTestingCommonMistakes %}) and the rest of the series [Unit Testing 101]({% post_url 2021-08-30-UnitTesting %}).
