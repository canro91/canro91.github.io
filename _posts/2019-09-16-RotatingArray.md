---
layout: post
title: Rotating an array: An interview exercise III
---

There you are. You start to feel confident in your interview. You have already gone through some exercises. Now, the interviewer challenges you with a new exercise. So, you open a new tab or create a new file in your editor. And, start!

## Problem

> _Given an array of integers and an integer k, rotate all elements k positions to the right. For example: After rotating [1,2,3,4,5,6] two positions is [5,6,1,2,3,4]_

## Solution

### Obivous one

Your first approach is to roll a loop through the array and put in another array each element shifted to the right. You have to take care of elements near the end of the array. Otherwise, you will get outside of the array and an exception will be thrown. So, you add an `if` to check you keep it inside the bounds. Something like this:

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

## Modulus operator

_You can do better. Can you remove the bound checking?_ –the interviewer says. Now, you start to use an example. If `array=[1,2,3,4,5,6]`, `k=1` and `i=5`, the last element must be the first one and so on and so forth. It reminds you the modulus operator (%). Instead of dividing two numbers, it calculates the remainder of dividing those two numbers. Since the remainder is less than the divisor, you will always be inside the size of the array if you apply the modulus with the array length. So, you modify your previous solution.

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

## Space complexity

_What is the space complexity of this solution?_ –the interviewer asks. Space complexity is a metric to compare the amount of memory required to run an algorithm in relation to the input size. If the input gets bigger, how much storage the algorithm requires? Since you are using a temporay array, the storage will be proportional to the size of the array. So, it's linear!

_Right!_ –the interviewer replies. _Can you come up with a constant solution?_ –he suggests. So, you have to get rid of the temporary array! What if you shift one element at a time and the repeat the process as many times as needed? This solution isn't the most performant, but it uses constant space. But, this time you have to do it backwards to only temporary keep one element of the array.

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

Another happy interview!

_**Bonus**_ What about a one-line declarative LINQ solution? The interview could go in a different direction?

```csharp
static int[] Shift(int[] array, int k)
	=> array.Skip(array.Length - k)
		.Concat(array.Take(array.Length - k))
		.ToArray();
```

