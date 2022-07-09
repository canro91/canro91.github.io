---
layout: post
title: "My Top 16 newest C# features by version"
tags: tutorial csharp
cover: Cover.png
cover-alt: "My Top 16 newest C# features"
---

C# is a language in constant evolution. It has changed a lot since its initial versions in the early 2000's. Every version brings new features to write more concise and readable code. These are some C# features I like the most and use often. Hope you find them useful too.

Let's start with the best C# features by version, starting from version 6.

## C# 6.0

### String interpolation: $"Hello, {name}"

Before with `string.Format()`, we could miss a parameter or add them in the wrong order. If we forgot a parameter, we will get a `FormatException`.

With string interpolation, we can inline variables directly in the string we want to build. To use string interpolation, before the opening quote of your string, let's add `$` and wrap our variables around `{}`.

Before with `string.Format()`,

```csharp
string.Format("Hello, {0} {1}", title, name);
```

But, if we forgot to add one parameter,

```csharp
string.Format("Hello, {0} {1}", title/*, I forgot to add the name parameter*/);
// ^^^
// System.FormatException:
//    Index (zero based) must be greater than or equal to zero and less than the size of the argument list.
```

After with string interpolation,

```csharp
$"Hello, {title} {name}";
```

Now, it's clearer if we're missing a parameter or if we have them in the wrong order.

### Null-conditional (?.) and null-coalescing operators (??)

Starting from C# 6.0, we have two new operators: null-conditional `?.` and null-coalescing `??` operators. These two new operators helps us to get rid of null values and `NullReferenceException`.

With the null-conditional `?.` operator, we access a member's object if the object isn't null. Otherwise, it returns null.

The null-coalescing `??` operator evaluates an alternative expression if the first one is null.

Before,

```csharp
string name = ReadNameFromSomewhere();
if (name == null)
{
    name = "none";
}
else
{
    name.Trim();
}
```

After,

```csharp
string name = ReadNameFromSomewhere();
name?.Trim() ?? "none";
```

It executes `Trim()` only if `name` isn't null. Otherwise, `name?.Trim()` returns `null`. But, with the `??` operator, the whole expression returns "none".

### Expression body definition (=>)

Now, one-line functions are truly one liners. We can use `=>` to declare the body of methods and properties in a single line of code.

Before,

```csharp
public int MeaningOfLife()
{
    return 42;
}
```

After,

```csharp
public int MeaningOfLife()
    => 42;
```

### nameof expression

As its name implies, the `nameof` operator returns the name of a variable, type or member as a string. It makes renaming things easier.

Before without `nameof`,

```csharp
public void SomeMethod(string param1)
{
    if (string.IsNullOrEmpty(param1))
        throw new ArgumentNullException("param1");
}
```

After with `nameof`,

```csharp
public void SomeMethod(string param1)
{
    if (string.IsNullOrEmpty(param1))
        throw new ArgumentNullException(nameof(param1));
}
```

## C# 7.X

### Throw expressions

Now, throws are expressions. It means we can use them inside conditionals and null coalescing expressions.

We can combine the `??`, `throw` and `nameof` operators to check required parameters inside constructors. For example,

```csharp
public class Movie
{
    private readonly string _title;
    private readonly Director _director;

    public Movie(string title, Director director)
    {
        _title = title;
        _director = director ?? throw new ArgumentNullException(nameof(director));
    }
}
```

Notice, how the `??` operator evaluates the expression on the right, which is a throw.

```csharp
new Movie("Titanic", null);
// ^^^
// System.ArgumentNullException: Value cannot be null.
// Parameter name: director
```

### out variables

We can inline the variable declaration next to the `out` keyword using the `var` keyword.

Before, we had to declare a variable in a separate statement,

```csharp
int count = 0;
int.TryParse(readFromKey, out count);
```

After, inlining the variable declaration,

```csharp
int.TryParse(readFromKey, out var count);
```

Instead of declaring a variable, we can use discards `_` to ignore the output value. For example,

```csharp
int.TryParse(readFromKey, out _);
```

I'm not a big fan of methods with `out` references. But, with this feature I like them a bit more. I prefer tuples.

### Tuples

Speaking of tuples...Now we can access tuple members by name. We don't need to use `Item1` or `Item2` anymore.

We can declare tuples wrapping its members inside parenthesis. For example, to declare a pair of coordinates, it would be `(int X, int Y) origin = (0, 0)`.

We can use named members when declaring methods and deconstructing returned values.

Before,

```csharp
Tuple<string, string> Greet() { }

var greeting = Greet();
var name = greeting.Item1;
```

After,

```csharp
(string Salutation, string Name) Greet() { }

var greeting = Greet();
var name = greeting.Name;
```

Even better,

```csharp
(string Salutation, string Name) Greet() { }

var (Salutation, Name) = Greet();
```

Do you remember discards? We can use them with tuples too.

```csharp
(_, string name) = Greet();
```

### Asynchronous Main methods

Now, `async` Main methods are available in Console applications.

Before,

```csharp
public static int Main(string[] args)
{
    return DoSomethingAsync().GetAwaiter().GetResult();
}
```

After,

```csharp
public static async Task<int> Main(string[] args)
{
    await DoSomethingAsync();
}
```

### Pattern matching

With pattern matching, we have more flexibility in control flow structures like `switch` and `if`. Let's see a couple of examples.

On one hand, we can avoid casting types inside `if` statements.

Before without pattern matching, we needed to cast types,

```csharp
var employee = CreateEmployee();
if (employee is SalaryEmployee)
{
    var salaryEmployee = (SalaryEmployee)employee;
    DoSomething(salaryEmployee);
}
```

After, with pattern matching, we can declare a variable in the condition,

```csharp
if (employee is SalaryEmployee salaryEmployee)
{
    DoSomething(salaryEmployee);
}
```

On another hand, we can use a `when` clause inside `switch`.

Before, we had to rely on `if` statements inside the same `case`, like this

```csharp
var employee = CreateEmployee();
switch (employee)
{
    case SalaryEmployee salaryEmployee:
        if (salaryEmployee.Salary > 1000)
        {
            DoSomething(salaryEmployee);
        }
        else
        {
            DoSomethingElse(salaryEmployee);
        }
        break;

    // other cases...        
}
```

Now, with pattern matching, we can have separate cases,

```csharp
var employee = CreateEmployee();
switch (employee)
{
    case SalaryEmployee salaryEmployee when salaryEmployee.Salary > 1000:
        DoSomething(salaryEmployee);
        break;

    case SalaryEmployee salaryEmployee:
        DoSomethingElse(salaryEmployee);
        break;

    // other cases...
}
```

I found it more readable this way. Let's keep the conditional case before the one without conditions.

<figure>
<img src="https://images.unsplash.com/photo-1569783899817-a49d2d25287c?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjIwNjc4MTQx&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Tools on a workbench" />

<figcaption>Photo by <a href="https://unsplash.com/@oxaroxa?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Oxa Roxa</a> on <a href="https://unsplash.com/s/photos/tools?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>


## C# 8.0

### switch expressions

Speaking of `switch` statements, starting from C# 8.0 `switch` are expressions. It means we can assign a `switch` to a variable or return a `switch` from a method.

Before a `switch` looked like this one,

```csharp
CardType cardType;

switch (cardBrand)
{
    case "Visa":
        cardType = CardType.Visa;
        break;

    case "MasterCard":
        cardType = CardType.MasterCard;
        break;
        
    case "American Express":
        cardType = CardType.AmericanExpress;
        break;
        
    default:
        throw new ArgumentException(cardBrand);
}
```

After with `switch` as expressions,

```csharp
CardType cardType = cardBrand switch
{
    "Visa" => CardType.Visa,
    "MasterCard" => CardType.MasterCard,
    "American Express" => CardType.AmericanExpress,
    _ => throw new ArgumentException(cardBrand)
};
```

Switch expressions are more compact, right? Did you notice we assigned the result of the `switch` to the `cardType` variable? Cool!

### Indices and ranges

If you have used negative indices in Python, you would find this feature familiar. In Python, we use  negative indices to reference elements from the end of lists.

We have a similar feature in C#, not with negative indices, but with the **index from end** operator, `^`. 

With the index from end operator, the last element of an array would be `array[^1]`.

Before, we had to substract from the length of the array to access an element from the end. The last element of an array was `array[array.Length - 1]`.

```csharp
var helloWorld = new string[] { "Hello", ", ", "world!" };
helloWorld[helloWorld.Length - 1]; // "world!"
```

After, with the index from end operator,

```csharp
var helloWorld = new string[] { "Hello", ", ", "world!" };
helloWorld[^1]; // "world!"
```

In the same spirit, we have ranges. An array without its last element would be `array[0..^1]`

```csharp
var helloWorld = new string[] { "Hello", ", ", "world!" };
string.Join("", helloWorld[0..^1]); // Hello,
```

### Null-coalescing assignment (??=)

Do you remember the `?.` and `??` operators? Now, there is another operator to work with `null`. The **null-coalescing assignment** operator, `??=`. It only assigns a variable if its value isn't null.

Before,

```csharp
int? magicNumber = ReadMagicNumberFromSomewhere();

if (magicNumber == null)
    magicNumber = 7;
```

After,

```csharp
int? magicNumber = ReadMagicNumberFromSomewhere();

magicNumber ??= 7;
```

### Using declarations

A variable preceded by `using` is disposed at the end of the scope. We can get rid of the parethensis  around `using` statements and the brackets wrapping its body.

Before,

```csharp
using (var reader = new StreamReader(fileName))
{
    string line; 
    while ((line = reader.ReadLine()) != null)  
    {  
        // Do something  
    }  
}
```

After,

```csharp
using var reader = new StreamReader(fileName);
string line; 
while ((line = reader.ReadLine()) != null)  
{  
    // Do something  
}
```

### Nullable reference types

With C# 8.0, all reference variables are non-nullable by default. Any attempt to dereference a nullable reference gets a warning from the compiler. Goodbye, NullReferenceException!

To declare a variable that can be null, we need to add to its type declaration an `?`. The same way we have always declared nullable value types like `int?`. For example, a nullable string would be `string? canBeNull;`

This is a breaking change. We need to turn on this feature at the project level. To do so, let's add `<Nullable>enable</Nullable>` inside the `PropertyGroup` in our csproj files.

For a console application, the csproj file with this feature turned on look like this:

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>netcoreapp3.1</TargetFramework>
    <Nullable>enable</Nullable>
  </PropertyGroup>

</Project>
```

Before, if we access a member of a null reference, we get a `NullReferenceException`.

```csharp
string name = null;
SayHi(name); // <- System.NullReferenceException
// ^^^
// System.NullReferenceException: 'Object reference not set to an instance of an object.'
// name was null.

void SayHi(string name)
  => Console.WriteLine(name.Trim());
```

But now, we get a compiler warning,

```csharp
string name = null;
// ^^^^^
// warning CS8600: Converting null literal or possible null value to non-nullable type.

string? canBeNullName = null;
SayHi(name);
// ^^^^^
// warning CS8604: Possible null reference argument for parameter 'name'
```

To get rid of the compiler warning, we have to check for null values first.

```csharp
string? canBeNullName = null;
if (canBeNullName != null)
{
    SayHi(name);
}
```

## C# 9.0

### Records

A record is an immutable reference type with built-in equality methods. When we create a record, the compiler creates `ToString`, `GetHashCode`, value-based equality methods, a copy constructor and a deconstructor.

Records are helpful to replace value-objects in our code.

```csharp
public record Movie(string Title, int ReleaseYear);
```

### Top-level statements

All the boilerplate code is now gone from `Main` methods. It gets closer to scripting languages like Python and Ruby.

Before, to write the "Hello, world!" program in C#, we needed to bring namespaces, classes, methods and arrays only to print a message out to the console.

```csharp
using System;

namespace HelloWorld
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
        }
    }
}
```

After, it boils down to only two lines.

```csharp
using System;

Console.WriteLine("Hello World!");
```

## C# 10.0

### File-scoped namespace declaration

With C# 10.0, we can simplify namespace declaration inside our classes.

Before,

```csharp
namespace Movies
{
    public class Movie
    {
        // ...
    }
}
```

After, we can reduce the level of indentations by using a semicolon on the namespace declaration,

```csharp
namespace Movies;

public class Movie
{
    // ...
}
```

### Global using statements

C# 10.0 reduces the boilerplate from our classes even further by hiding common using declarations.

Before, a "Hello, world" program looked like this,

```csharp
using System;

namespace HelloWorld
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
        }
    }
}
```

Now, with Top-level statements and global using statements, it's a single line of code,

```csharp
Console.WriteLine("Hello World!");
```

This is a feature is enabled by default, but we can turn it off in our csproj files. For example, this is the csproj file of a Console app with global using statements and nullable references.

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net6.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

</Project>
```

Voilà! These are the C# features I like the most. Which ones didn't you know about? Which ones you use most often? What features would you like to see in future versions?

Do you want to learn more about the C# language? Check my [C# Definitive Guide]({% post_url 
2018-11-17-TheC#DefinitiveGuide %}). It contains the subjects I believe all intermediate C# developers should know. Are you new to LINQ? Check my [quick guide to LINQ with examples]({% post_url 2021-01-18-LinqGuide %}). And, don't miss my [C# idioms series]({% post_url 2019-11-19-TwoCSharpIdioms %}).

_Happy coding!_
