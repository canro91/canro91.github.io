---
layout: post
title: "The Art of Readable Code: Takeaways"
tags: books
cover: Cover.png
cover-alt: "The Art of Readable Code: Takeaways"
---

The Art of Readable Code is the perfect companion for the [Clean Code]({% post_url 2020-01-06-CleanCodeReview %}). It contains simple and practical tips to improve your code at the function level. It isn't as dogmatic as Clean Code. Tips aren't as strict as the ones from Clean Code. But, it still deserves to be read.

These are some of my notes on The Art of Readable Code.

## 1. Code should be easy to understand

Code should be written to minimize the time for someone else to understand it. Here, understanding means solving errors, spotting bugs, and making changes.

It's good to write compact code. But, compact doesn't always mean more readable.

```c
assert((!bucket = FindBucket(key)) || !bucket->IsOccupied());

// vs
bucket = FindBucket(key)
if (bucket != NULL) assert(!bucket->IsOccupied())
```

## 2. Surface-level improvements

### Packing info into names

**If something is critical to understand, put it in a name.**

Choose specific words for your method names. For example, does `def GetPage(url)` get the page from the network, a cache or a database? Use `FetchPage(url)` or `DownloadPage(url)` instead.

Avoid empty names like `retval`, `tmp`, `foo`. Instead, use a variable name that describes the value. In the next code sample, use `sum_squares` instead of `retval`.
	
```javascript
function norm(v) {
	var retval = 0;
	for (var i = 0; i < v.length; i++) {
		retval += v[i] *v [i]; // sum_squares = v[i] * v[i];
	}
	return retval;
}
```
	
Variables `i`, `j`, `k` don't always work for loop indices. Prefer more concrete names. Indices could be misused or interchanged.

Use concrete over abstract names. Instead of `--run-locally`, use `--extra-logging` or `--use-local-database`.

Attach extra information to your names. For example, encode units. Prefer `delay_secs` over `delay`, `size_mb` over `size` and `degrees` over `angle`. Also, encode extra information. Prefer `plaintext_password` over `password`.

Do not include needless words in your names. Instead of `ConvertToString`, use `ToString`.

<figure>
<img src="https://images.unsplash.com/photo-1605402756180-75934835ce13?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzNjM4ODA1Mg&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="'Your Name Here' Sign on the Side of a Building" />

<figcaption>What name would you put in that sign? Photo by <a href="https://unsplash.com/@austinkirk?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Austin Kirk</a> on <a href="https://unsplash.com/s/photos/name?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

### Names can't be misconstructed

Make your names resistant to misinterpretation. Does a method on arrays named `filter` pick or get rid of elements? If it picks elements, use `select()`. And, if it gets rid of elements, use `exclude()`.

```javascript
// Does results have elements that satisfy the condition? Or elements that don't?
results = Database.all_objects.filter("year <= 2011")
```

Use Min and Max for inclusive limits. Put min or max in front of the thing being limited. For example,
	
```c
if shopping_cart.num_items() > MAX_ITEMS_IN_CART:
	Error()
```

Use First and Last for inclusive limits. What's the result of `print integer_range(start=2, stop=4)`? Is it `[2,3]` or `[2,3,4]`? Prefer First and Last. For example, `print integer_range(first=2, last=4)` to mean `[2,3,4]`.

Use Begin and End for inclusive/exclusive ranges. For example, to find all events on a date, prefer `PrintEventsInRange("OCT 16 12:00am", "OCT 17 12:00am")` instead of `PrintEventsInRange("OCT 16 12:00am", "OCT 16 11:59.999am")`.

For booleans variables, make clear what true or false means. Use is, has, can, should, need as prefixes. For example, `SpaceLeft()` or `HasSpaceLeft()`.

Avoid negated booleans. For example, instead of `disable_ssl = false`, use `use_ssl = true`.

Don't create false expectation. With these two names `GetSize()` and `ComputeSize()`, we expect `GetSize()` to be a lightweight operation.

### Aesthetics

Similar code should look similar. Pick a meaningful order and maintain it. If the code mentions A, B, and C, don't say B, C, and A in other places.

```python
details = request.POST.get('details')
location = request.POST.get('location')
phone = request.POST.get('phone')

if phone: rec.phone = phone
if location: rec.location = location
if details: rec.details = details
```

Organize declarations into blocks, like sentences. Break code into paragraphs.

### Knowing what to comment

Don't comment what can be derived from code. `GOOD CODE > BAD CODE + COMMENTS`.

Comment the why's behind a decision. Anticipate likely questions and comment the big picture. Comment why you choose a particular value or what it's a valid range. For example, `MAX_THREADS = 8; // Up to 2*num of procs`

### Making comments precise and compact

Use comments to show examples of input and output values.
	
```java
// Strip("ab", "a") == "b"
String Strip(String str, String chars)
```
	
```c
// CategoryType -> (score, weight)
typdef hash_map<int, pair<float, float>>
```

Use named parameters or use comments to make the same effect. Prefer `connect(timeout: 10, use_ssl: false)` over `connect(10, false)`. In languages without named parameters, use `connect(/*timeout_ms=*/10, /*use_ssl=*/false)`.
	
## 3. Simplifying loops and logic

### Making control flow easy to read

When doing conditionals,  write the changing variable first, followed by an operator and by stable expression. Prefer `if (length >= 10)` over `if (10 <= length)`.

When doing if-then-else, treat the positive case first or the simplest case or the most interesting case first.

Use the ternary operator `?:` with simple statements, not to squeeze logic into a single line. For example, `time_str += (hour > 12) ? "pm" : "am"`

Avoid do-while loops. Do-while loops break the convention of keeping the condition first. Use while instead.

### Breaking down giant expressions

Write explaining variables and summary variables. For example,
	
```python
if line.split(':')[0] == 'root':
  # ...

# vs

username = line.split(':')[0]
if username == 'root':
	# ...
```

Use De Morgan's Laws. For example,

```python
if (!(file_exists && !is_protected))
	Error()

# vs

if (!file_exists || is_protected)
	Error()
```
	
Eliminate intermediate results. **Do your task as quickly as possible**. For example, avoid writing functions like this
		
```javascript
var remove_one = function() {
  var index = null;
  // find index
  if (index != null)
    // remove
}
```

<figure>
<img src="https://images.unsplash.com/photo-1627873828946-44e8b5261d2d?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzNjU2NTM5OA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Bunch of pencils organized by color" />

<figcaption>Let's keep our code organize, shall we? Photo by <a href="https://unsplash.com/@lucasgwendt?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Lucas George Wendt</a> on <a href="https://unsplash.com/s/photos/organized?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 4. Reorganizing your code

### Extracting unrelated problems

**Separate the generic code from the specific code**. Extract pure utility code into libraries or a set of functions.

Simplify existing interfaces. You should never have to settle for an interface that's less than ideal. 

To separate generic code from specific code, ask yourself:

  * What is the high-level goal of this code?
  * Is every line working to that goal? Or is it solving an unrelated problem?
  * If enough lines are working on an unrelated problem, extract that code into a separated function

For example, this code doesn't separate generic from specific code

```javascript
ajax.post({
	url: 'url',
	data: data,
	on_sucess: function(response) {
		// format_pretty
		var str = "{\n";
		for (var key in response)
			str += "-" + key + ":" + response[key];
		str += "}\n";
		alert(str);
	}
});
```

Now, `format_pretty` takes care of generic code.

```javascript
ajax.post({
	url: 'url',
	data: data,
	on_sucess: function(response) {
		format_pretty(response);
	}
});
```

### One thing at a time

List all the things your code is doing. And try to separate every task into a separate function.

Defragment your code to do one type of thing at a time. For example, initialize to default values, then calculate some data and lastly update some other values.

### Writing less code

**The most readable code is no code at all**.

Keep your codebase as small and lightweight as possible. Create as much utility code to remove duplication. Remove unused code. Keep your project separated into isolated sub-projects

Know the capabilities of your libraries. Every once in a while spend 15 minutes reading the names of all functions/modules/types in your standard libraries. **Write less code as possible**.

For example, don't be tempted to write your own de-duplicate code in Python.

```python
def unique(elements):
	tmp = {}
	for e in elements:
		tmp[e] = None
	return tmp.keys()
	
unique([2, 1, 2])
# vs
unique = list(set([2, 1, 2]))
```

## 5. Testing and readability

Tests should be easy to understand. Coders are afraid of changing code, so coders don't add new tests.

* Hide less important details from the user, so he can focus only on the important ones.
* Create the minimal test statement. Most tests can be reduced to: "given an input, expect this output." **Ideally a unit test is just 3-line long**.
* Create mini-languages.
* Choose the simplest set of inputs that exercise your code. Prefer clean and simple test values. **Embrace the Least astonishing principle**.
* Write smaller test cases, instead of a single perfect one-size-fits-all test case. Every test pushes your code in a different direction.
* Test names should indicate a unit of work (or code under test), situation or bug being tested, and expected result.

Voilà! These are some of my notes. One tip I started to practice after reading this book was to "extract unrelated problems."

The Art of Readable Code is a good starting point to introduce the concept of readability and clean code to your team. These tips and tricks are a good reference for code standards and reviews.

If you're interested in other books, take a look at my takeaways from [Clean Coder]({% post_url 2020-06-15-CleanCoder %}), [Clean Code]({% post_url 2020-01-06-CleanCodeReview %}) and [Domain Modeling Made Functional]({% post_url 2021-12-13-DomainModelingMadeFunctional %}).

_Happy reading!_