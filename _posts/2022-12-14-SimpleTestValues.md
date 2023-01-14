---
layout: post
title: "How to write good unit tests: Use simple test values"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Lamp and picture on a desk" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

These days I had to review some code that had one method to merge dictionaries. This is one of the suggestions I gave during that review to write good unit tests.

**To write good unit tests, write the Arrange part of tests using the simplest test values that exercise the scenario under test. Avoid building large object graphs and using magic numbers in the Arrange part of tests.**

## Here are the tests I reviewed

These are two of the unit tests I reviewed. They test the `Merge()` method.

```csharp
using MyProject;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using System.Linq;

namespace MyProject.Tests;

[TestClass]
public class DictionaryExtensionsTests
{
    [TestMethod]
    public void Merge_NoDuplicates_DoesNotMergeNullAndEmptyOnes()
    {
        var me = new Dictionary<int, int>
        {
            { 1, 10 }, { 2, 20 }, { 3, 30 }
        };
        var empty = new Dictionary<int, int> { };
        var one = new Dictionary<int, int>
        {
            { 4, 40 }
        };
        var two = new Dictionary<int, int>
        {
            { 5, 50 }, { 6, 60 }, { 7, 70 }, { 8, 80}, { 9, 90 }
        };
        var three = new Dictionary<int, int>
        {
            { 10, 100 }, { 11, 110 }
        };
        var four = new Dictionary<int, int>
        {
            { 12, 120 }, { 13, 130 }, { 14, 140 }, { 15, 150 },
            { 16, 160 }, { 17, 170 }, { 18, 180 }, { 19, 190 }
        };

        var merged = me.Merge(one, empty, null, two, null, three, null, null, four, empty);
        //              ^^^^^

        Assert.AreEqual(19, merged.Keys.Count);
        var keyRange = Enumerable.Range(1, merged.Keys.Count);
        foreach (var entry in merged)
        {
            Assert.IsTrue(keyRange.Contains(entry.Key));
            Assert.AreEqual(entry.Key * 10, entry.Value);
        }
    }

    [TestMethod]
    public void Merge_DuplicateKeys_ReturnNoDuplicates()
    {
        var me = new Dictionary<int, int>
        {
            { 1, 10 }, { 2, 20 }, { 3, 30 }, { 4, 40 },
            { 5, 50 }, { 6, 60 }, { 7, 70 }
        };
        var one = new Dictionary<int, int>
        {
            { 1, 1 }, { 2, 2 }, { 8, 80 }
        };
        var two = new Dictionary<int, int>
        {
            { 3, 3 }, { 9, 90 }
        };
        var three = new Dictionary<int, int>
        {
            { 4, 4 }, { 5, 5 }, { 6, 6 }, { 7, 7 }, { 10, 100 }
        };

        var merged = me.Merge(one, two, three);
        //              ^^^^^

        Assert.AreEqual(10, merged.Keys.Count);
        var keyRange = Enumerable.Range(1, merged.Keys.Count);
        foreach (var entry in merged)
        {
            Assert.IsTrue(keyRange.Contains(entry.Key));
            Assert.AreEqual(entry.Key * 10, entry.Value);
        }
    }
}
```

Yes, those are the real tests I had to review. I slightly changed the namespaces and the test names.

## What's wrong?

Let's take a closer look at the first test. Do we need six dictionaries to test the `Merge()` method? No! And do we need 19 items? No! We can still cover the same scenario with only two single-item dictionaries without duplicate keys.

And let's write separate tests to deal with edge cases. Let's write one test to work with `null` and another one with an empty dictionary. Again two dictionaries will be enough for each test.

Having too many dictionaries with too many items made us write that funny `foreach` with a funny multiplication inside. That's why some of the values are multiplied by 10, and others aren't. We don't need that with a simpler scenario. **Unit tests should only have assignments without branching or looping logic.**

Looking at the second test, we noticed it followed the same pattern as the first one. Too many items and a weird `foreach` with a multiplication inside.

<figure>
<img src="https://images.unsplash.com/photo-1533090161767-e6ffed986c88?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY1Njk1NDExMg&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="A simple bedroom" />

<figcaption>Let's embrace simplicity. Photo by <a href="https://unsplash.com/@srosinger3997?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samantha Gades</a> on <a href="https://unsplash.com/s/photos/simplicity?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Write tests using simple test values

Let's write our tests using simple test values to prepare our scenario under test.

```csharp
[TestMethod]
public void Merge_NoDuplicates_DoesNotMergeNullAndEmptyOnes()
{
    var one = new Dictionary<int, int>
    {
        { 1, 10 }
    };
    var two = new Dictionary<int, int>
    {
        { 2, 20 }
    };

    var merged = one.Merge(two);
    //               ^^^^^

    Assert.AreEqual(2, merged.Keys.Count);

    Assert.IsTrue(merged.Contains(1));
    Assert.IsTrue(merged.Contains(2));
}

// One test to Merge a dictionary with an empty one
// Another test to Merge a dictionary with a null one

[TestMethod]
public void Merge_DuplicateKeys_ReturnNoDuplicates()
{
    var duplicateKey = 1;
    //  ^^^^^
    var one = new Dictionary<int, int>
    {
        { duplicateKey, 10 }, { 2, 20 }
        //  ^^^^^
    };
    var two = new Dictionary<int, int>
    {
        { duplicateKey, 10 }, { 3, 30 }
        //  ^^^^^
    };
    var merged = one.Merge(two);
    //               ^^^^^

    Assert.AreEqual(3, merged.Keys.Count);

    Assert.IsTrue(merged.Contains(duplicateKey));
    Assert.IsTrue(merged.Contains(2));
    Assert.IsTrue(merged.Contains(3));
}
```

Notice this time, we boiled down [the Arrange part]({% post_url 2021-07-19-WriteBetterAssertions %}) of the first test to only two dictionaries with one item each, without duplicates.

And for the second one, the one for duplicates, we wrote a `duplicateKey` variable and used it in both dictionaries as key to [make the test scenario obvious]({% post_url 2020-11-02-UnitTestingTips %}). This way, after reading the test name, we don't have to decode where the duplicate keys are.

Since we wrote simple tests, we could remove the `foreach` in the Assert parts and the funny multiplications.

The test for the `null` and empty cases are exercises left to the reader. They're not difficult to write.

Voilà! That's another tip to write good unit tests. Let's strive to have tests easier to follow with simple test values. Here we used dictionaries, but we can follow this tip when writing integration tests for the database. Often to prepare our test data, we insert multiple records when only one or two are enough to prove our point.

Also, I wrote other posts about how to write good unit tests. One to [reduce noisy tests and use explicit test values]({% post_url 2020-11-02-UnitTestingTips %}) and another one to [write a failing test first]({% post_url 2021-02-05-FailingTest %}). Don't miss my [Unit Testing 101 series]({%  post_url 2021-08-30-UnitTesting %}) where I cover more subjects like this one.

_Happy testing!_