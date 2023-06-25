---
layout: post
title: "TIL: How to pass a DataTable as a parameter with OrmLite"
tags: todayilearned csharp showdev
cover: Cover.png
cover-alt: "A wood table"
---

These days I use OrmLite a lot. Almost every single day. In one of my client's projects, OrmLite is the defacto ORM. Today I needed to pass a list of identifiers as a DataTable to an OrmLite `SqlExpression`. I didn't want to write plain old SQL queries and use the embedded Dapper methods inside OrmLite. This is what I found out after a long debugging session.

**To pass a DataTable with a list of identifiers as a parameter to OrmLite methods, create a custom converter for the DataTable type. Then use ConvertToParam() to pass it as a parameter to methods that use raw SQL strings.**

As an example, let's find all movies from a list of director Ids. I know a simple JOIN will get our backs covered here. But bear with me. Let's imagine this is a more involved query.

## 1. Create two entities and a table type

These are the `Movie` and `Director` classes,

```csharp
public class Movie
{
    [AutoIncrement]
    public int Id { get; set; }

    [StringLength(256)]
    public string Name { get; set; }

    [Reference]
    // ^^^^^
    public Director Director { get; set; }
}

public class Director
{
    [AutoIncrement]
    public int Id { get; set; }

    [References(typeof(Movie))]
    public int MovieId { get; set; }
    //         ^^^^^
    // OrmLite expects a foreign key back to the Movie table

    [StringLength(256)]
    public string FullName { get; set; }
}
```

In our database, let's define the table type for our list of identifiers. Like this,

```sql
CREATE TYPE dbo.IntList AS TABLE(Id INT NULL);
```

<figure>
<img src="https://images.unsplash.com/photo-1519389950473-47ba0277781c?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY4MTUxMzI5OA&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="bunch of laptops on a table" />

<figcaption>A data table...Photo by <a href="https://unsplash.com/@marvelous?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Marvin Meyer</a> on <a href="https://unsplash.com/photos/SYTO3xs06fU?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 2. Pass a DataTable to a SqlExpression

Now, to the actual OrmLite part,

```csharp
using NUnit.Framework;
using ServiceStack.DataAnnotations;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace PlayingWithOrmLiteAndDataTables;

public class DataTableAsParameterTest
{
    [Test]
    public async Task LookMaItWorks()
    {
        // 1. Register our custom converter
        OrmLiteConfig.DialectProvider = SqlServerDialect.Provider;
        OrmLiteConfig.DialectProvider.RegisterConverter<DataTable>(new SqlServerDataTableParameterConverter());
        //                                                          ^^^^^

        var connectionString = "...Any SQL Server connection string here...";
        var dbFactory = new OrmLiteConnectionFactory(connectionString);
        using var db = dbFactory.Open();

        // 2. Populate some movies
        var titanic = new Movie
        {
            Name = "Titanic",
            Director = new Director
            {
                FullName = "James Cameron"
            }
        };
        await db.SaveAsync(titanic, references: true);

        var privateRyan = new Movie
        {
            Name = "Saving Private Ryan",
            Director = new Director
            {
                FullName = "Steven Spielberg"
            }
        };
        await db.SaveAsync(privateRyan, references: true);

        var pulpFiction = new Movie
        {
            Name = "Pulp Fiction",
            Director = new Director
            {
                FullName = "Quentin Tarantino"
            }
        };
        await db.SaveAsync(pulpFiction, references: true);

        // 3. Populate datable with some Ids
        var movieIds = new DataTable();
        movieIds.Columns.Add("Id", typeof(int));
        movieIds.Rows.Add(2);
        //              ^^^^^
        // This should be Saving Private Ryan's Id

        // 4. Write the SqlExpression
        // Imagine this is a more complex query. I know!
        var query = db.From<Director>();

        var tableParam = query.ConvertToParam(movieIds);
        //                     ^^^^^
        query = query.CustomJoin(@$"INNER JOIN {tableParam} ids ON Director.MovieId = ids.Id");
        //            ^^^^^
        // We're cheating here. We know the table name! I know.

        // 5. Enjoy!
        var spielberg = await db.SelectAsync(query);
        Assert.IsNotNull(spielberg);
        Assert.AreEqual(1, spielberg.Count);
    }
}
```

Notice we first registered our `SqlServerDataTableParameterConverter`. More on that later!

After populating some records, we wrote a query using OrmLite `SqlExpression` syntax and a JOIN to our table parameter using the `CustomJoin()`. Also, we needed to convert our DataTable into a parameter with the `ConvertToParam()` method before referencing it.

We cheated a bit. Our `Director` class has the same name as our table. If that's not the case, we could use the `GetQuotedTableName()` method, for example.

## 3. Write an OrmLite custom converter for DataTable

And this is our `SqlServerDataTableParameterConverter`,

```csharp
// This converter only works when passing DataTable
// as a parameter to OrmLite methods. It doesn't work
// with OrmLite LoadSelectAsync method.
public class SqlServerDataTableParameterConverter : OrmLiteConverter
{
    public override string ColumnDefinition
        => throw new NotImplementedException("Only use to pass DataTable as parameter.");

    public override void InitDbParam(IDbDataParameter p, Type fieldType)
    {
        if (p is SqlParameter sqlParameter)
        {
            sqlParameter.SqlDbType = SqlDbType.Structured;
            sqlParameter.TypeName = "dbo.IntList";
            //                       ^^^^^ 
            // This should be our table type name
            // The same name as in the database
        }
    }
}
```

This converter only works when passing DataTable as a parameter. That's why it has a `NotImplementedException`. I tested it with the `SelectAsync()` method. It doesn't work with the `LoadSelectAsync()` method. This last method doesn't parameterize internal queries. It will bloat our database's plan cache. Take a look at OrmLite `LoadSelectAsync()` source code on GitHub [here](https://github.com/ServiceStack/ServiceStack/blob/e8e7b1e1f450506c4b2ee052fcc1904966f161d7/ServiceStack.OrmLite/src/ServiceStack.OrmLite/Async/OrmLiteReadCommandExtensionsAsync.cs#L409) and [here](https://github.com/ServiceStack/ServiceStack/blob/6298a3b84c41e9a5fe4dcba1ed7ad48cc79b69e2/ServiceStack.OrmLite/src/ServiceStack.OrmLite/Support/LoadList.cs#L48) to see what I mean.

To make this converter work with the `LoadSelectAsync()`, we would need to implement the `ToQuotedString()` and return the DataTable content as a comma-separated list of identifiers. Exercise left to the reader!

## 4. Write a convenient extension method

And, for compactness, let's put that `CustomJoin()` into a beautiful extension method that infers the table and column name to join to,

```csharp
public static class SqlExpressionExtensions
{
    public static SqlExpression<T> JoinToDataTable<T>(this SqlExpression<T> self, Expression<Func<T, int>> expression, DataTable table)
    {
        var sourceDefinition = ModelDefinition<T>.Definition;

        var property = self.Visit(expression);
        var parameter = self.ConvertToParam(table);

        // Expected SQL: INNER JOIN @0 ON "Parent"."EvaluatedExpression"= "@0".Id
        var onExpression = @$"ON ({self.SqlTable(sourceDefinition)}.{self.SqlColumn(property.ToString())} = ""{parameter}"".""Id"")";
        var customSql = $"INNER JOIN {parameter} {onExpression}";
        self.CustomJoin(customSql);

        return self;
    }
}
```

We can use it like,

```csharp
// Before:
// var query = db.From<Director>();
// var tableParam = query.ConvertToParam(movieIds);
// query = query.CustomJoin(@$"INNER JOIN {tableParam} ids ON Director.MovieId = ids.Id");

// After: 
var query = db.From<Director>();
              .JoinToDataTable<Director>(d => d.MovieId, movieIds);
```

Voilà! That is what I learned (or hacked) today. Things we only find out when reading the source code of our libraries. Another thought: the thing with ORMs is the moment we need to write complex queries, we stretch out ORM features until they break. Often, we're better off [writing dynamic SQL queries]({% post_url 2021-03-08-HowNotToWriteDynamicSQL %}). I know, I know! Nobody wants to write dynamic SQL queries by hand. Maybe ask ChatGPT?

If you want to read more about OrmLite and its features, check [how to automatically insert and update audit fields with OrmLite]({% post_url 2022-12-11-AuditFieldsWithOrmLite %}) and [some lessons I learned after working with OrmLite]({% post_url 2022-12-13-LessonsOnHangfireAndOrmLite %}).

_Happy coding!_
