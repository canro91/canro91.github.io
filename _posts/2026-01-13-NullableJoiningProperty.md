---
layout: post
title: "TIL: What Entity Framework Core Do With Nullable Foreign Keys"
tags: csharp todayilearned
---

In another episode of _Adventures with Entity Framework..._

I expected `Include()` to always translate to an INNER JOIN. But with nullable "joining" properties, EF Core uses a LEFT JOIN.

Here's my replicated scenario with movies and directors.

**#1. Let's create a Movies and Directors table with no foreign keys between them.**

```sql
USE Movies;
GO
CREATE TABLE Movies (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL
);
GO
CREATE TABLE Directors (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    MovieId INT NULL, /* <- A nullable column here */
    /* And no constraint here. I'm a legacy app */
);
GO
```

**#2. Let's store (and retrieve) one movie and its director and an orphan director.**

```csharp
using Microsoft.EntityFrameworkCore;

namespace NullableForeignKeys;

public class Movie
{
    public int Id { get; set; }
    public string Name { get; set; }
    public List<Director> Directors { get; set; }
}

public class Director
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int? MovieId { get; set; }
	//     ^^^^
	// A nullable property here
    public Movie Movie { get; set; }
}

public class MovieContext : DbContext
{
    public MovieContext(DbContextOptions<MovieContext> options) : base(options)
    {
    }

    public DbSet<Movie> Movies { get; set; }
    public DbSet<Director> Directors { get; set; }
}

[TestClass]
public class MovieTests
{
    [TestMethod]
    public async Task NullableForeignKey()
    {
        const string connectionString = $"Server=(localdb)\\MSSQLLocalDB;Database=Movies;Trusted_Connection=True;";

        var options = new DbContextOptionsBuilder<MovieContext>()
            .UseSqlServer(connectionString)
            .Options;

        using (var context = new MovieContext(options))
        {
			// An orphan director
            context.Directors.Add(new Director
            {
                Name = "Quentin Tarantino"
            });
			// A movie and its director
            context.Movies.Add(new Movie
			{
				Name = "Titanic",
				Directors =
				[
					new Director
					{
						Name = "James Cameron",
					}
				]
			});
            context.SaveChanges();
        }

        using (var context = new MovieContext(options))
        {
            // Imagine a query with filters on director and movie
            var directors = await context.Directors
                    .Include(d => d.Movie)
                    // I thought this would retrieve
                    // directors with movies
                    .ToListAsync();

            foreach (var d in directors)
            {
                Assert.IsNotNull(d);
                Assert.IsNotNull(d.Movie);
                //     ^^^^^
                // This one breaks...
            }
        }
    }
}
```

In this legacy app, child entities could exist without parents. The real query also applied filters on both entities.

Now let's look at the SQL EF Core generated:

```sql
SELECT [d].[Id], [d].[MovieId], [d].[Name], [m].[Id], [m].[Name]
      FROM [Directors] AS [d]
      LEFT JOIN [Movies] AS [m] ON [d].[MovieId] = [m].[Id]
```

Notice the LEFT JOIN. Using `int Movie` instead produces an INNER JOIN.

**Lesson:** JOIN type depends on the joining property's nullability, not on `Include()` itself.
