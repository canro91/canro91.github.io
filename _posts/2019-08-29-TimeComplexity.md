---
layout: post
title: "Time complexity: An interview exercise II"
tags: interview tutorial csharp
---

You nailed it at [evaluating postfix expressions]({% post_url 2019-08-02-PostfixNotationAnInterviewExercise %}). You impressed the interviewer with your solution. Now, you're asked about the time complexity of finding the sum of two elements in two arrays.

**Time complexity is a mechanism to compare the performance of two algorithms as the input size grows. Time complexity measures the number of operations instead of execution time. An algorithm with smaller number of operations has better time complexity than another one with a larger amount of operations.**

## Time complexity and Big-O Notation

Well-known algorithms and common patterns of code have already a time complexity associated to it.

For example, performing an assignment or checking if a dictionary contains a key have **constant time**. It means, it will always take the same amount of operations to check if a dictionary contains a key.

Looping through the elements of an array has **linear time**. Dealing with matrices using two nested loops has **quadratic time**. Dividing an array into halves each time has **logarithmic time**. _Do you remember binary search?_

Time complexity uses a mathematical notation to describe the complexity of an algorithm, called **Big-O notation**.

Big-O notation assigns a function (_you remember functions from Math class, right?_) to the complexity of an algorithm. So, constant time is `O(1)`, linear time is `O(n)`, quadratic time is `O(n^2)` and logarithmic time is `O(logn)`.

You could use [this Big-O cheatsheet](https://www.bigocheatsheet.com/) to find the complexity and BigO notation of well-know algorithms.

<figure>
<img src="https://images.unsplash.com/photo-1501139083538-0139583c060f?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Time complexity: An interview exercise" />

<figcaption><span>Photo by <a href="https://unsplash.com/@aronvisuals?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Aron Visuals</a> on <a href="https://unsplash.com/s/photos/time?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## Two number sum problem

The interview goes like this. The interviewer asks you to introduce yourself. You answer using the elevator pitch you prepared. Then, he suggests to start a whiteboard exercise. You open Notepad++, Visual Studio Code or your favorite editor. And, there you go.

> _Given two array of integers, find a pair of elements, one from each array, that adds up to zero. The size and the order of the elements aren't specified. They may be sorted or not_

## Solution

### First approach

Your first and obvious approach is to roll two loops and check every pair of elements in the two arrays. If the two arrays contain lots of elements, it would be slow. But it will get the task done.

```csharp
for (int i = 0; i < a.Length; i++)
{
    for (int j = 0; j < b.Length; j++)
    {
        if (a[i] + b[j] == 0)
        {
            Console.WriteLine("Found");
        }
    }
}
```

The interviewer asks you about the time complexity of this solution. Since, you have to traverse the second array per every element in the first array, you will end up with `n x m` operations. With `n` and `m` the lengths of each array. So, you answer your solution has quadratic time or `O(n^2)`. _Right!_

### Better

Then, he asks you to do better. He asks for a linear solution.

To have a linear solution, you will have to get rid of traversing the second array. The problem will be solved if you know if any element in the first array has its inverse in the second array.

With a dictionary or a set with the elements of the second array, you can only traverse the first array and check for its inverse in the dictionary. Since, checking if a dictionary or a set contains a key has constant time, you will have a linear solution. It will  loop through the first array only once.

```csharp
var set = new HashSet<int>(b);
for (int i = 0; i < a.Length; i++)
{
    if (set.Contains(-a[i]))
    {
        Console.WriteLine("Found");
    }
}
```

Voilà! That's how we can find the sum of two elements in linear time. Another happy interview! This time, you have in your toolbox time complexity. Not only for next interviews, but for everyday programming.

_Happy coding!_