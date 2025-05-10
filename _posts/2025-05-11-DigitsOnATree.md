---
layout: post
title: "How To Find All 3-Digit Numbers In A Binary Tree"
tags: csharp interview
---

This is an exercise I failed to solve in a past interview a long time ago, in a galaxy far, far away. I ran out of time and didn't finish it.

Off the top of my head, the exercise was something like this:

> Find all 3-digit numbers you can create by visiting a binary tree. To create a 3-digit number, given a node, visit either the left or right subtree, and concatenate the value you find in three nodes.

The next tree has 4 3-digit numbers.

```
        1
       / \
      /   \
     2     7
    / \   /
   5   9 4
  /
 3
```

They are 125, 129, 253, and 174. No, 127 is not a valid number here. We should visit one subtree at a time.

To finally close the open-loop in my mind, here's my solution.

## Let's solve the simplest scenario first

If we have a tree with only the root node and the left subtree only with leaves, we could write a function to "walk" that simple tree like this,

```csharp
List<int> Walk(int root, Tree subTree)
{
    if (subTree == null) return [];

    var candidate = root * 100 + subTree.Value * 10;

    List<int> result = [];
    if (subTree.Left != null) result.Add(candidate + subTree.Left.Value);
    if (subTree.Right != null) result.Add(candidate + subTree.Right.Value);
    return result;
}
```

Here `root` is the value of the root node and `subTree` is either the left or right subtree of our root node.

If we call `Walk()` with our example tree,

```
        1
       / .
      /   .
     2     .
    / \   .
   5   9 .
```

The root is 1, the node in the left subtree is 2, and the node in the left subtree again is 5, then the 3-digit number is calculated as `1*100 + 2*10 + 5`.

`Walk()` passing only the root node and the left subtree of our sample tree returns,

```csharp
//        1
//       / .
//      /   .
//     2     .
//    / \   .
//   5   9 .

Walk(1, new Tree(2,
            new Tree(5, null, null),
            new Tree(6, null, null)));
// List<int>(2) { 125, 129 }
```

That will only work for a simple tree.

## Let's cover more complex trees

With `Walk()`, we only find numbers by visiting one node in a simple tree, so let's use recursion to visit all other nodes.

Here's a recursive function `Digits()` that uses `Walk()`,

```csharp
List<int> Digits(Tree aTree)
{
    if (aTree == null) return [];
	
    return Walk(aTree.Value, aTree.Left)
           // ^^^
           // We visit the left subtree from the root
              .Concat(Walk(aTree.Value, aTree.Right))
              //      ^^^^
              // We visit the right subtree from the root
			  
              .Concat(Digits(aTree.Left))
              //      ^^^^^
              // Find digits on the left subtree
              .Concat(Digits(aTree.Right))
              //      ^^^^^
              // Find digits on the right subtree
              .ToList();
}
```

`Digits()` starts visiting the left and right subtrees from the root node. Then, it recursively calls itself for the left and right subtrees and concatenates all the intermediary lists.

## All the pieces in one single place

Here's my complete solution,

```csharp
record Tree(int Value, Tree Left, Tree Right);

List<int> Walk(int root, Tree subTree)
{
    if (subTree == null) return [];

    var candidate = root * 100 + subTree.Value * 10;

    List<int> result = [];
    if (subTree.Left != null) result.Add(candidate + subTree.Left.Value);
    if (subTree.Right != null) result.Add(candidate + subTree.Right.Value);
    return result;
}

List<int> Digits(Tree aTree)
{
    if (aTree == null) return [];
	
    return Walk(aTree.Value, aTree.Left)
              .Concat(Walk(aTree.Value, aTree.Right))
			  
              .Concat(Digits(aTree.Left))
              .Concat(Digits(aTree.Right))
              .ToList();
}

var tree1 =
    new Tree(1,
        new Tree(2,
            new Tree(5,
                new Tree(3, null, null),
                null),
            new Tree(9, null, null)),
        new Tree(7,
            new Tree(4, null, null),
            null));
Digits(tree1)
// List<int>(4) { 125, 129, 174, 253 }
```

Et voilà!

I know it's too late. Months have passed since then, but I wanted to solve it anyway. Don't ask me what company asked me to solve that. I can't remember. Wink, wink!

For other interviewing exercises, check [how to evaluate a postfix expression]({% post_url 2019-08-02-PostfixNotationAnInterviewExercise %}), [how to solve the two-sum problem]({% post_url 2019-08-29-TimeComplexity %}), and [how to shift the elements of an array]({% post_url 2019-09-16-RotatingArray %}).
