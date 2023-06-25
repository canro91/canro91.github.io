---
layout: post
title: "TIL: How to automatically insert and update audit fields with OrmLite"
tags: todayilearned csharp showdev
cover: Cover.png
cover-alt: "Alarm clocks lined up" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

These days I had to work with [OrmLite](https://docs.servicestack.net/ormlite/). I had to follow the convention of adding audit fields in all of the database tables. Instead of adding them manually, I wanted to populate them when using OrmLite `SaveAsync()` method. This is how to automatically insert and update audit fields with OrmLite.

## 1. Create a 1-to-1 mapping between two tables

Let's store our favorite movies. Let's create two classes, `Movie` and `Director`, to represent a one-to-one relationship between movies and their directors.

```csharp
public interface IAudit
{
    DateTime CreatedDate { get; set; }

    DateTime UpdatedDate { get; set; }
}

public class Movie : IAudit
{
    [AutoIncrement]
    public int Id { get; set; }

    [StringLength(256)]
    public string Name { get; set; }

    [Reference]
    // ^^^^^^^
    public Director Director { get; set; }

    [Required]
    public DateTime CreatedDate { get; set; }

    [Required]
    public DateTime UpdatedDate { get; set; }
}

public class Director : IAudit
{
    [AutoIncrement]
    public int Id { get; set; }

    [References(typeof(Movie))]
    // ^^^^^^
    public int MovieId { get; set; }
    //         ^^^^^
    // OrmLite expects a foreign key back to the Movie table

    [StringLength(256)]
    public string FullName { get; set; }

    [Required]
    public DateTime CreatedDate { get; set; }

    [Required]
    public DateTime UpdatedDate { get; set; }
}
```

Notice we used OrmLite `[Reference]` to tie every director to his movie. With these two classes, OrmLite expects two tables and a foreign key from `Director` pointing back to `Movie`. Also, we used `IAudit` to add the `CreatedDate` and `UpdateDate` properties. We will use this interface in the next step.

## 2. Use OrmLite Insert and Update Filters

To automatically set `CreatedDate` and `UpdatedDate` when inserting and updating movies, let's use OrmLite `InsertFilter` and `UpdateFilter`. With them, we can manipulate our records before putting them in the database.

Let's create a unit test to show how to use those two filters,

```csharp
using ServiceStack.DataAnnotations;
using ServiceStack.OrmLite;

namespace OrmLiteAuditFields;

[TestClass]
public class PopulateAuditFieldsTest
{
    [TestMethod]
    public async Task SaveAsync_InsertNewMovie_PopulatesAuditFields()
    {
        OrmLiteConfig.DialectProvider = SqlServerDialect.Provider;
        OrmLiteConfig.InsertFilter = (command, row) =>
        //            ^^^^^
        {
            if (row is IAudit auditRow)
            {
                auditRow.CreatedDate = DateTime.UtcNow;
                //       ^^^^^
                auditRow.UpdatedDate = DateTime.UtcNow;
                //       ^^^^^
            }
        };
        OrmLiteConfig.UpdateFilter = (command, row) =>
        //            ^^^^^
        {
            if (row is IAudit auditRow)
            {
                auditRow.UpdatedDate = DateTime.UtcNow;
                //       ^^^^^
            }
        };

        var connectionString = "...Any SQL Server connection string here...";
        var dbFactory = new OrmLiteConnectionFactory(connectionString, SqlServerDialect.Provider);

        using var db = dbFactory.Open();

        var movieToInsert = new Movie
        {
            Name = "Titanic",
            // We're not setting CreatedDate and UpdatedDate here...
            Director = new Director
            {
                FullName = "James Cameron"
                // We're not setting CreatedDate and UpdatedDate here, either...
            }
        };
        await db.SaveAsync(movieToInsert, references: true);
        //       ^^^^^
        // We insert "Titanic" for the first time
        // With "references: true", we also insert the director

        var insertedMovie = await db.SingleByIdAsync<Movie>(movie.Id);
        Assert.IsNotNull(insertedMovie);
        Assert.AreNotEqual(default, insertedMovie.CreatedDate);
        Assert.AreNotEqual(default, insertedMovie.UpdatedDate);
    }
}
```

Notice we defined the `InsertFilter` and `UpdateFilter` and inside them, we checked if the row to be inserted or updated implemented the `IAudit` interface, to then set the audit fields with the current timestamp.

To insert a movie and its director, we used `SaveAsync()` with the optional parameter `references` set to `true`. We didn't explicitly set the `CreatedDate` and `UpdatedDate` properties before inserting a movie.

Internally, OrmLite `SaveAsync()` either inserts or updates an object if it exists in the database. It uses the property annotated as the primary key to find if the object already exists in the database.

Instead of using filters, we can use `[Default(OrmLiteVariables.SystemUtc)]` to annotate our audit fields. With this attribute, OrmLite will create a default constraint. But, this will work only for the first insertion. Not for future updates on the same record.

## 3. Add [IgnoreOnUpdate] for future updates

To support future updates using the OrmLite `SaveAsync()`, we need to annotate the `CreatedDate` property with the attribute `[IgnoreOnUpdate]` in the `Movie` and `Director` classes. Like this,

```csharp
public class Movie : IAudit
{
    [AutoIncrement]
    public int Id { get; set; }

    [StringLength(256)]
    public string Name { get; set; }

    [Reference]
    public Director Director { get; set; }

    [Required]
    [IgnoreOnUpdate]
    // ^^^^^^^^^^^^
    public DateTime CreatedDate { get; set; }

    [Required]
    public DateTime UpdatedDate { get; set; }
}

public class Director : IAudit
{
    [AutoIncrement]
    public int Id { get; set; }

    [References(typeof(Movie))]
    public int MovieId { get; set; }

    [StringLength(256)]
    public string FullName { get; set; }

    [Required]
    [IgnoreOnUpdate]
    // ^^^^^^^^^^^^
    public DateTime CreatedDate { get; set; }

    [Required]
    public DateTime UpdatedDate { get; set; }
}
```

Internally, when generating the SQL query for an UPDATE statement, OrmLite doesn't include properties annotated with `[IgnoreOnUpdate]`. [Source](https://github.com/ServiceStack/ServiceStack.OrmLite/blob/f0a8241e6a88d56b73b11ea9c16656e8015256ea/src/ServiceStack.OrmLite/OrmLiteDialectProviderBase.cs#L822) Also, OrmLite has similar attributes for insertions and queries: `[IgnoreOnInsertAttribute]` and `[IgnoreOnSelectAttribute]`

Let's modify our previous unit test to insert and update a movie,

```csharp
using ServiceStack.DataAnnotations;
using ServiceStack.OrmLite;

namespace OrmLiteAuditFields;

[TestClass]
public class PopulateAuditFieldsTest
{
    [TestMethod]
    public async Task SaveAsync_InsertNewMovie_PopulatesAuditFields()
    {
       // Same OrmLiteConfig as before...
        var connectionString = "...Any SQL Server connection string here...";
        var dbFactory = new OrmLiteConnectionFactory(connectionString, SqlServerDialect.Provider);

        using var db = dbFactory.Open();

        var movieToInsert = new Movie
        {
            Name = "Titanic",
            // We're not setting CreatedDate and UpdatedDate here...
            Director = new Director
            {
                FullName = "James Cameron"
                // We're not setting CreatedDate and UpdatedDate here, either...
            }
        };
        await db.SaveAsync(movieToInsert, references: true);
        //       ^^^^^
        // 1.
        // We insert "Titanic" for the first time
        // With "references: true", we also insert the director

        await Task.Delay(1_000);
        // Let's give it some time...

        var movieToUpdate = new Movie
        {
            Id = movie.Id,
            //   ^^^^^
            Name = "The Titanic",
            // We're not setting CreatedDate and UpdatedDate here...
            Director = new Director
            {
                Id = movie.Director.Id,
                //   ^^^^^
                FullName = "J. Cameron"
                // We're not setting CreatedDate and UpdatedDate here, either...
            }
        };
        await db.SaveAsync(movieToUpdate, references: true);
        //       ^^^^^
        // 2.
        // To emulate a repository method, for example,
        // We're creating a new Movie object updating
        // movie and director names using the same Ids
    }
}
```

Often, when we work with repositories to abstract our data access layer, we update objects using the identifier of an already-inserted object and another object with the properties to update. Something like, `UpdateAsync(movieId, aMovieWithSomePropertiesChanged)`.

Notice this time, after inserting a movie for the first time, we created a separate `Movie` instance (`movieToUpdate`) keeping the same ids and updating the other properties. We used the same `SaveAsync()` as before.

At this point, if we don't annotate the `CreatedDate` properties with `[IgnoreOnUpdate]`, we get the exception: _"System.Data.SqlTypes.SqlTypeException: SqlDateTime overflow. Must be between 1/1/1753 12:00:00 AM and 12/31/9999 11:59:59 PM."_

We don't want to change the `CreatedDate` on updates. That's why in the `UpdateFilter` we only change `UpdatedDate`. Since we're using a different `Movie` instance in the second `SaveAsync()` call, `CreatedDate` stays uninitialized when OrmLite runs the UPDATE statement in the database. That's why we got that exception.

Voilà! That's how to automate audit fields with OrmLite. After reading the OrmLite source code, I found out about these filters and attributes. I learned the lesson of reading our source code dependencies from a [past Monday Links episode]({% post_url 2022-01-17-MondayLinks %}).

For more content, check [How to create a CRUD API with ASP.NET Core and Insight.Database]({% post_url 2020-05-01-InsightDatabase %}) and [How to keep your database schema updated with Simple.Migrations]({% post_url 2020-08-15-Simple.Migrations %}). To read more about OrmLite, check [How to pass a DataTable as a parameter with OrmLite]({% post_url 2023-06-26-PassDataTableOrmLite %}).

_Happy coding!_