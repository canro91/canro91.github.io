---
layout: post
title: "Rotating an array: An interview exercise III"
tags: tutorial interview csharp
---

Here you are in another interview. You start to feel confident from your last interview. You have already evaluated [postfix expressions]({% post_url 2019-08-02-PostfixNotationAnInterviewExercise %}) and solved the [two-number sum problem]({% post_url 2019-08-29-TimeComplexity %}). Now, the interviewer challenges you with a new exercise. Open a new tab or create a new file in your editor. And, start!

## Shift elements of an array

Your interviewer asks you to shift all elements of an array to the right. Here it goes,

> _Given an array of integers and an integer k, rotate all elements k positions to the right. For example: After rotating [1,2,3,4,5,6] two positions to the right is [5,6,1,2,3,4]_

## Obivous solution: loop and bound checking

Your first approach is to roll a loop through the array and put in a second array each element shifted to the right.

You have to take care of elements near the end of the array. Otherwise, you will get outside of the array and an exception will be thrown. So, you add an `if` to check you keep it inside the bounds.

Something like this:

```csharp
static int[] Shift(int[] array, int k)
{
    var result = new int[array.Length];
    for (int i = 0; i < array.Length; i++)
    {
      if ((i + k) >= array.Length)
        result[(i + k) - array.Length] = array[i];
      else
        result[i + k] = array[i];
    }
    return result;
}
```

## Modulus operator without bound checking

You can do better. Can you remove the bound checking?–the interviewer says.

Now, you start to use an example. If `array=[1,2,3,4,5,6]`, `k=1` and `i=5`, the last element must be the first one and so on and so forth. It reminds you the modulus operator (%). 

The modulus operator, instead of dividing two numbers, calculates the remainder of dividing those two numbers.

Since the remainder is less than the divisor, you will always be inside the size of the array, if you use the modulus with the array length. So, you modify your previous solution.

```csharp
static int[] Shift(int[] array, int k)
{
    var result = new int[array.Length];
    for (int i = 0; i < array.Length; i++)
    {
      result[(i + k) % array.Length] = array[i];
    }
    return result;
}
```

## Shift an array and Space complexity

What is the space complexity of this solution?–the interviewer asks.

**Space complexity is a metric to compare the amount of memory required to run an algorithm in relation to its input size. If the input gets bigger, how much storage the algorithm requires?**

Since you are using a temporay array, the storage will be proportional to the size of the array. So, it's linear!

Right!–the interviewer replies. Can you come up with a constant solution?–he suggests.

You have to get rid of the temporary array! What if you shift one element at a time and the repeat the process as many times as needed? This solution isn't the most performant, but it uses constant space.

This time you have to shift the array backwards to only keep one element of the array in a temporary variable.

```csharp
static int[] Shift(int[] array, int k)
{ 
    for (int times = 0; times < k; times++)
    {
      int tmp = array[array.Length - 1];
      for (int i = array.Length - 1; i > 0; i--)
      {
          array[i] = array[i - 1];
      }
      array[0] = tmp;
    }
        
    return array;
}
```

What about if you would've started with a one-line declarative LINQ solution? The interview could go in a different direction?

```csharp
static int[] Shift(int[] array, int k)
    => array.Skip(array.Length - k)
        .Concat(array.Take(array.Length - k))
        .ToArray();
```

Voilà! Another happy interview! Now you know how to shift the elements of an array and what space complexity is. Learn about interview types on [Remote interview. Here I go]({% post_url 2019-09-29-RemoteInterviewTips %}).

_Happy coding!_





