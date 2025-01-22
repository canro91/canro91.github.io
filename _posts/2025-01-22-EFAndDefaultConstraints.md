---
layout: post
title: "TIL: Configure Default Values for Nullable Columns With Default Constraints in EntityFramework Core"
tags: csharp todayilearned
---

**TL;DR**: For nullable columns with default constraints, you have to tell EntityFramework the default value of the mapping property via C#. Otherwise, when you create a new record, it will have NULL instead of the default value in the database. You're welcome! Bye!

## Let's create a dummy table with one nullable column but with a defualt constraint

Let's create a new `Movies` database with one table called `Movies`, with an Id, a name, and a director name as optional, but with a default value. Like this,

```sql
CREATE DATABASE Movies;
GO
USE Movies;
GO
CREATE TABLE Movies (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    DirectorName NVARCHAR(100) DEFAULT 'ThisIsADefaultValue'
);
GO
```

## Let's create a new record (without the nullable column) and read it back

Now to prove a point, let's use EntityFramework Core to insert a new movie without passing a director name and read it back.

What will be the value of `DirectorName` once we read it back? Null? The value inside the default constraint? Make your bets!

Here we go,

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace TestProject1;

[TestClass]
public class EntityFrameworkAndDefaults
{
    [TestMethod]
    public void TestInsertAndReadMovie()
    {
        const string connectionString = $"Server=(localdb)\\MSSQLLocalDB;Database=Movies;Trusted_Connection=True;";

        var dbContextOptions = new DbContextOptionsBuilder<MoviesContext>()
                .UseSqlServer(connectionString)
                .Options;

        using (var context = new MoviesContext(dbContextOptions))
        {
            var inception = new Movie
            {
                Name = "Inception"
                // No director name here...
                // ^^^^^
            };
            context.Movies.Add(inception);
            context.SaveChanges();
        }

        using (var context = new MoviesContext(dbContextOptions))
        {
            var movie = context.Movies.FirstOrDefault(m => m.Name == "Inception");

            Assert.IsNotNull(movie);
            Assert.AreEqual("ThisIsADefaultValue", movie.DirectorName);
            //     ^^^^^^^^
            //     Assert.AreEqual failed. Expected:<ThisIsADefaultValue>. Actual:<(null)>. 
            //
            // Whaaaaat!
        }
    }
}

public class MoviesContext : DbContext
{
    public DbSet<Movie> Movies { get; set; }

    public MoviesContext(DbContextOptions<MoviesContext> options)
        : base(options)
    {
    }
}

public class Movie
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public string? DirectorName { get; set; }
}
```

Ok, to my surprise that test fails. `movie.DirectorName` isn't `"ThisIsADefaultValue"`. It's null.

I was expecting to see the value from the default constraint in the database. But, no. Wah, wah, wah, Wahhhhhhh...

## Here you have it EntityFramework. Can I get my default value now?

We have to tell EntityFramework Core the default value of our column, like this,

```csharp
public class MoviesContext : DbContext
{
    public DbSet<Movie> Movies { get; set; }

    public MoviesContext(DbContextOptions<MoviesContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // For simplicity, let keep it here...
        modelBuilder.Entity<Movie>(entity =>
        {
            entity
                .Property(e => e.DirectorName)
                .HasDefaultValueSql("ThisIsADefaultValue");
                // ^^^^^
                // Here you have it EntityFramework Core
                // Can I get my default value now?
        });
    }
}
```

This behavior only adds up to my love and hate relationship with EntityFramework Core.

Et voilà!

{% include 7day_email_course_longer.html %}
