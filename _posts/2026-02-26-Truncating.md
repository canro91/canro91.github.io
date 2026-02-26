---
layout: post
title: "BugOfTheDay: Entity Framework Core And SQL Server Have Different Takes On Truncating Strings"
tags: csharp sql bugoftheday
---

A subtle detail easy to forget when working with legacy applications that use stored procedures.

## Stored procedures swallow long strings

If you're inserting a long string into a shorter column, SQL Server truncates the parameters with no complaints,

```sql
USE Movies;
GO
CREATE TABLE Movies (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(10) NOT NULL /* <-- A 10 here */
);
GO
CREATE PROCEDURE InsertMovie
    @Name NVARCHAR(10) /* <-- Notice the "10" here */
AS
BEGIN
    INSERT INTO Movies (Name)
    VALUES (@Name);
END;
GO
/* @Name is a NVARCHAR(10), but the value is longer than 10 */
EXEC InsertMovie @Name = 'ThisMovieNameIsWayTooLongForTheColumn';
GO
```

The stored procedure "swallowed" that long parameter. No complaints! But wait to see what Entity Framework does.

## Entity Framework doesn't validate or truncate

Now, if we try to do the same inside a unit test,

```csharp
using Microsoft.EntityFrameworkCore;

namespace LookMaWhatEntityFrameworkDoes;

public class Movie
{
    public int Id { get; set; }
    public string Name { get; set; }
}

public class MovieContext : DbContext
{
    public MovieContext(DbContextOptions<MovieContext> options) : base(options)
    {
    }

    public DbSet<Movie> Movies { get; set; }
}

[TestClass]
public class MovieTests
{
    [TestMethod]
    public async Task TruncateItPlease()
    {
        const string connectionString = $"Server=(localdb)\\MSSQLLocalDB;Database=Movies;Trusted_Connection=True;";

        var options = new DbContextOptionsBuilder<MovieContext>()
            .UseSqlServer(connectionString)
            .LogTo(Console.WriteLine)
            .Options;

        using (var context = new MovieContext(options))
        {
            context.Movies.Add(
                new Movie
                {
                    Name = "RememberThatNameInTheDBHasSize10"
                }
            );
            context.SaveChanges();
            //      ^^^^^
            // Test method LookMaWhatEntityFrameworkDoes.MovieTests.TruncateItPlease threw exception: 
            // Microsoft.Data.SqlClient.SqlException: 
            // String or binary data would be truncated in table 'Movies.dbo.Movies', column 'Name'. Truncated value: 'RememberTh'.
        }

        using (var context = new MovieContext(options))
        {
            var movies = context.Movies.ToList();

            Assert.IsNotNull(movies);
        }
    }
}
```

Entity Framework Core blows in your face. At least, it tells you the table and column names, and the value being truncated.

Another subtle detail worth remembering. Et voilà!

Here's another Entity Framework gotcha: [Nullable foreign keys]({% post_url 2026-01-13-NullableJoiningProperty %})
