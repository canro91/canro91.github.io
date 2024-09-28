---
layout: post
title: "TIL: How to Use the Specification Pattern in C# to Simplify Repositories"
tags: todayilearned csharp
cover: Cover.png
cover-alt: "A checklist" 
---

Repositories are the least SOLID part of our codebases.

When we work with Domain-Driven Design, we take care of our business domain and forget about our data-access layer. We end up dumping, in a single interface, every combination of methods and parameters to retrieve our entities from the database. This way, we break the Single Responsibility Principle and Interface Segregation Principle. You see? They're the least SOLID part.

Our repositories become so bloated that to use one specific method from a repository, we end up depending on a huge interface with lots of other single-use methods. `GetOrdersById`, `GetOrdersByDate`, `GetLineItemsByOrderId`...

## The Specification Pattern Simplifies Repositories

With the Specification pattern, we extract the "query logic" to another object and away from our repositories.

Instead of making our repositories more specific by adding more methods (`_repo.GetOrderById(123456)`), the Specification pattern makes repositories more general (`_repo.FirstOrDefault(new OrderById(123456))`).

Think of a Specification as the query logic and the query parameters to retrieve objects.

Specifications make more sense when using [Domain-Driven Design]({% post_url 2022-10-03-HandsOnDDDTakeaways %}). With Specifications, we encapsulate the LINQ queries, scattered all over our code, inside well-named objects that we keep inside our Domain layer.

Here's how to use the [Ardalis.Specification NuGet package](https://github.com/ardalis/Specification) to create a specification and retrieve a list of movies by their release year:
	
```csharp
using Ardalis.Specification; // <--
using Ardalis.Specification.EntityFrameworkCore; // <--
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddScoped(typeof(Repository<>)); // <--
builder.Services.AddDbContext<MoviesContext>(options =>
    options.UseInMemoryDatabase("MovieDb"));

var app = builder.Build();

app.MapGet("/movies/{releaseYear}", async (int releaseYear, Repository<Movie> repo) =>
{
    var byReleaseYear = new MoviesByReleaseYear(releaseYear); // <--
    var movies = await repo.ListAsync(byReleaseYear); // <--
        
    // As an alternative, with Ardalis.Specification we can
    // use a specification directly with a DbContext:
    //var movies = await aDbContext.Movies
    //                .WithSpecification(byReleaseYear)
    //                .ToListAsync();

    return Results.Ok(movies);
});

app.MapPost("/movies", async (Movie movie, Repository<Movie> repo) =>
{
    await repo.AddAsync(movie);
    await repo.SaveChangesAsync();
    // Or, simply with a DbContext:
    //await aDbContext.Movies.AddAsync(movie);
    //await anyDbContext.SaveChangesAsync();

    return Results.Created($"/movies/{movie.Id}", movie);
});

app.Run();

public class MoviesByReleaseYear : Specification<Movie>
//           ^^^^^
{
    public MoviesByReleaseYear(int releaseYear)
    {
        Query
            .Where(m => m.ReleaseYear == releaseYear)
            .OrderBy(m => m.Name);
    }
}

public record Movie(int Id, string Name, int ReleaseYear);

public class Repository<T> : RepositoryBase<T> where T : class
//           ^^^^^
{
    public Repository(MoviesContext dbContext) : base(dbContext)
    {
    }
}

public class MoviesContext : DbContext
{
    public MoviesContext(DbContextOptions<MoviesContext> options)
        : base(options)
    {
    }

    public DbSet<Movie> Movies { get; set; }
}
```

Ardalis.Specification provides a `RepositoryBase<T>` class that wraps our `DbContext` object and exposes the database operations using Specification objects. The `ListAsync()` receives a specification, not an `IQueryable` object, for example.

Our `Repository<T>` is simply a class definition without query logic. Just a couple of lines of code.

Now the query logic is inside our `MoviesByReleaseYear`. Ardalis.Specification translates those filtering and ordering conditions to the right chain of Entity Framework Core methods.

Our repositories are way simpler and the query logic is abstracted to another object.

## A Naive Implementation of the Specification Pattern

The best way to understand a piece of code is to recreate a minimal version.

Here's a naive and bare-bones implementation of an in-memory repository that filters a list using a specification object:

```csharp
var movies = new[]
{
    new Movie("Terminator 2", 1991),
    new Movie("Totoro", 1988),
    new Movie("Saving Private Ryan", 1998)
};
var repo = new InMemoryRepo<Movie>(movies); // <--
var found = repo.List(new ByReleaseYearSpec(1998)); // <--
// Output:
// [ Movie { Name = Saving Private Ryan, ReleaseYear = 1998 } ]

public record Movie(string Name, int ReleaseYear);

public class ByReleaseYearSpec : Spec<Movie> // <--
{
    public ByReleaseYearSpec(int releaseYear)
    {
        Where(movie => movie.ReleaseYear == releaseYear);
    }
}

public abstract class Spec<T> // <--
{
    public Func<T, bool>? Predicate { get; set; }

    public void Where(Func<T, bool> predicate)
    {
        Predicate = predicate;
    }
}

public class InMemoryRepo<T>
{
    private readonly IEnumerable<T> _items;

    public InMemoryRepo(IEnumerable<T> items)
    {
        _items = items;
    }

    public IEnumerable<T> List(Spec<T> spec)
    //                    ^^^^  
    {
        var evaluator = new SpecEvaluator();
        return evaluator.ApplySpec(_items, spec).ToList();
    }
}

public class SpecEvaluator
{
    public IEnumerable<T> ApplySpec<T>(IEnumerable<T> items, Spec<T> spec)
    {
        // The original implementation uses some "evaluators" to:
        // 1. Check if the spec has a certain shape and 
        // 2. Apply that shape to the input "query"
        //
        // For example, WhereEvaluator checks if the spec has a Where clause and
        // applies it.
        // 
        // This SpecEvaluator would be a Composite of smaller
        // evaluators that look for a certain shape
        if (spec.Predicate != null)
        {
            return items.Where(spec.Predicate);
        }
                
        return items;
    }
}
```

All the magic is inside the `InMemoryRepo` and the `SpecEvaluator` classes.

In the original implementation, the [SpecEvaluator](https://github.com/ardalis/Specification/blob/main/Specification.EntityFrameworkCore/src/Ardalis.Specification.EntityFrameworkCore/Evaluators/SpecificationEvaluator.cs) takes the parameters from the filters inside our specification (like Where, OrderBy, Skip, and Take) and apply them using EntityFramework Core methods into the `IQueryable` object that represents our database query.

Voilà! That's how to use the Specification pattern to make our repositories more SOLID. With the Specification pattern, our repositories have a slim interface and a single responsibility: to turn specifications into database calls.

For more C# content, check [how to create test data with the Builder pattern]({% post_url 2021-04-26-CreateTestValuesWithBuilders %}), [how to use the Decorator pattern with a real example]({% post_url 2021-02-10-DecoratorPattern %}), and [how to use the Pipeline pattern: An assembly line of steps]({% post_url 2020-02-14-PipelinePattern %}). 