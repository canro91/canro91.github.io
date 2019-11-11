---
layout: post
title: Time complexity&colon; An interview exercise II
---

You nailed it at your [first interview]({% post_url 2019-08-02-PostfixNotationAnInterviewExercise %}). You impressed the interviewer with your answers. Now, another interview. This time, it's the interviewer's boss turn.

The interviewer asks you to introduce yourself. You answer using the elevator pitch you prepared. Then, he suggests to start a whiteboard exercise. You open Notepad++, VSCode or your favorite editor. And, there you go.

## The problem

> _Given two array of integers, find a pair of elements, one from each array, that adds up to zero. The size and the order of the elements aren't specified. They may be sorted or not_

## Time complexity

Time complexity is a mechanism to compare the performance of two algorithms as the input grows. Time complexity measures the number of operations instead of seconds or milliseconds. An algorithm with small number of operations will beat another that makes the same task with a larger amount of operations.

Well-known algorithms and common patterns of code have already a time complexity associated. For example, performing an assignment or checking if a dictionary contains a key have **constant time**. Looping through the elements of an array has **linear time**. Dealing with matrices using two nested arrays has **quadratic time**. Dividing an array into halves each time (_do you remember binary search?_) has **logarithmic time**.

Time complexity uses a mathematical notation to describe the complexity of an algorithm, **Big O notation**. It assigns a function (_you remember functions from Math class, right?_) to the complexity of each algorithm. So, constant time is `O(1)`, linear time is `O(n)`, quadratic time is `O(n^2)` and logarithmic time is `O(logn)`. You could use [this cheatsheet](https://www.bigocheatsheet.com/) to find the complexity and BigO notation of well-know algorithms.

## The solution

### First approach

Your first and obvious approach is to roll two loops and check every pair of elements. It would be slow, if the arrays are big, but it will get the task done.

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

The interviewer asks you about the time complexity of this solution. Since, you have to traverse the second array per every element in the first array, you will end up with `n x m` operations. So, you answer quadratic time or `O(n^2)`. Right!

### Better

Then, he asks you to do better. A linear solution. To have a linear solution, you will have to get rid of traversing the second array. So the problem will be solved if you know if any element in the first array has its inverse in the second array. If you create a look-up or a set from the second array, you can only traverse the first array and check for the inverse. Since, checking if a set contains an element has constant time, you will have a linear solution or `O(n)`.

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

Here it is! Another interview! Now you have in your toolbox time complexity. Not only for next interviews, but for everyday programming.