---
layout: post
title: "TIL: Five lessons while working with OrmLite"
tags: todayilearned csharp showdev
cover: Cover.png
cover-alt: "Car engine" 
---

Back in the day, for my [Advent of Posts]({% post_url 2022-12-01-AdventOfCode2022 %}) I shared some [lessons on Hangfire and OrmLite]({% post_url 2022-12-13-LessonsOnHangfireAndOrmLite %}). In this year, for one of my client's project I've been working with OrmLite a lot. Let me expand on those initial lessons and share some others.

## 1. IgnoreOnUpdate attribute

When using `SaveAsync()` or any update method, OrmLite omits properties marked with the `[IgnoreOnUpdate]` attribute in the generated SQL statement. [Source](https://github.com/ServiceStack/ServiceStack/blob/main/ServiceStack.OrmLite/src/ServiceStack.OrmLite/OrmLiteDialectProviderBase.cs#L1013)

For example,

```csharp
public class Movie
{
    public string Name { get; set; }
    
    [IgnoreOnUpdate]
    // ^^^^^
    public string OrmLiteDoesNotUpdateThisOne { get; set; }
}
```

I used this attribute when [inserting and updating audit fields]({% post_url 2022-12-11-AuditFieldsWithOrmLite %}) to avoid messing with creation dates when updating records.

Also OrmLite has similar attributes for insertions and queries: `[IgnoreOnInsertAttribute]` and `[IgnoreOnSelectAttribute]`.

## 2. QueryFirst vs SqlScalar

OrmLite `QueryFirst()` method requires an explicit transaction as a parameter. [Source](https://github.com/ServiceStack/ServiceStack/blob/main/ServiceStack.OrmLite/src/ServiceStack.OrmLite/Dapper/SqlMapper.cs#L738) Unlike `QueryFirst()`, `SqlScalar()` uses the same transaction from the input database connection. [Source](https://github.com/ServiceStack/ServiceStack/blob/main/ServiceStack.OrmLite/src/ServiceStack.OrmLite/OrmLiteReadApi.cs#L524)

I learned this because I had a `DoesIndexExist()` method inside a [database migration]({% post_url 2020-08-15-Simple.Migrations %}) and it failed with the message _"ExecuteReader requires the command to have a transaction..."_

This is what I had to change,

```csharp
private static bool DoesIndexExist<T>(IDbConnection connection, string tableName, string indexName)
{
    var doesIndexExistSql = @$"
      SELECT CASE WHEN EXISTS (
        SELECT * FROM sys.indexes
        WHERE name = '{indexName}'
        AND object_id = OBJECT_ID('{tableName}')
      ) THEN 1 ELSE 0 END";
    
    // Before
    //
    // return connection.QueryFirst<bool>(isIndexExistsSql);
    //                   ^^^^^
    // Exception: ExecuteReader requires the command to have a transaction...

    // After
    var result = connection.SqlScalar<int>(doesIndexExistSql);
    //                      ^^^^^
    return result > 0;
}
```

## 3. Create Indexes

Apart from reading and writing records, OrmLite can modify the database schema, for example to create tables and indexes.

To create an index for a table, we could either annotate fields or classes. For example,

```csharp
[CompositeIndex(unique: false, fieldsNames: "ReleaseYear", "Name", Name = "AnOptionalIndexName")]
// ^^^^^
public class Movie
{
    public int ReleaseYear { get; set; }

    [Index]
    // ^^^^^
    public string Name { get; set; }
}
```

Also, OrmLite has a `CreateIndex()` method that receives an expression, like this,

```csharp
_connection.CreateIndex<Movie>(m => m.Name);
// or
_connection.CreateIndex<Movie>(m => new { m.ReleaseYear, m.Name });
```

By default, `CreateIndex()` creates indexes with names like: `idx_TableName_FieldName`. [Source](https://github.com/ServiceStack/ServiceStack/blob/main/ServiceStack.OrmLite/src/ServiceStack.OrmLite/OrmLiteDialectProviderBase.cs#L1701) We can omit the index name if we're fine with this naming convention.

## 4. Tag queries to easy troubleshooting

To identify the source of queries, OrmLite has two methods: `TagWith()` and `TagWithCallSite()`.

For example,

```csharp
var movies =  _connection.From<Movie>()
                    // Some filters here...
                    .Take(10)
                    .TagWith("AnAwesomeQuery")
                    // Or
                    //.TagWithCallSite();
```

With `TagWith()`, OrmLite includes a comment at the top of the generated SQL query with the identifier we pass.

For the previous tagged query, this is the generated SQL statement,

```sql
-- AnAwesomeQuery

SELECT TOP 10 "Id", "Name", "ReleaseYear" 
FROM "Movie"
```

With `TagWithCallSite()`, Ormlite uses the path and line number of the file that made that database call instead.

This is a similar trick to the one we use to [debug dynamic SQL queries]({% post_url 2020-12-03-DebugDynamicSQL %}). It helps up to traceback queries once we found them in our database plan cache.

## 5. LoadSelectAsync and unparameterized queries

OrmLite has two convenient methods: `LoadSelect()` and `LoadSelectAsync()`. They find some records and load their child references.

Let's write the `Movie` and `Director` classes,

```csharp
public class Movie
{
    public string Name { get; set; }

    [Reference]
    // ^^^^^
    public Director Director { get; set; }
}

public class Director
{
    [References(typeof(Movie))]
    // ^^^^^^
    public int MovieId { get; set; }

    public string FullName { get; set; }
}
```

Now let's use `LoadSelectAsync()`,

```csharp
var query = _connection.From<Movie>()
                        // Some filters here
                        .Take(10);
var movies = await _connection.LoadSelectAsync(query);
//                             ^^^^^
// It loads movies and their child directors
```

When using `LoadSelect()` and `LoadSelectAsync()`, OrmLite doesn't parameterize the internal query used to load the child entities. Arrrggg!

I'm not sure if it's a bug or a feature. But, to load child entities, OrmLite "inlines" the parameters used to run the parent query. We will see in the plan cache of our database lots of unparameterized queries.

See it by yourself in OrmLite source code, [here](https://github.com/ServiceStack/ServiceStack/blob/main/ServiceStack.OrmLite/src/ServiceStack.OrmLite/Async/OrmLiteReadCommandExtensionsAsync.cs#L409) and [here](https://github.com/ServiceStack/ServiceStack/blob/main/ServiceStack.OrmLite/src/ServiceStack.OrmLite/Support/LoadList.cs#L48).

After finding out about this behavior, I ended up ditching `LoadSelectAsync()` and using `SelectAsync()` instead, like this,

```csharp
var moviesQuery = _connection.From<Movie>()
                        // Some filters here
                        .Take(10);
var movies = await _connection.SelectAsync(moivesQuery);
if (!movies.Any())
{
    return Enumerable.Empty<Movie>();
}

var directorsQuery = _connection.From<Director>()
                        .Where(d => Sql.In(d.MovieId, moviesQuery.Select<Movie>(d => d.Id)));
var directors = await _connection.SelectAsync(directorsQuery);

foreach (var m in movies)
{
    m.Director = directors.Where(r => r.MovieId == m.Id);
}
```

Probably there's a better solution, but that was my workaround to avoid a flooded plan cache. I could afford an extra roundtrip to the database and I didn't want to write SQL queries by hand. C'mon!

Voilà! These are some of the lessons I've learned while working with OrmLite. Again, things we only find out when we adventure to read our libraries source code.

To read more content on OrmLite, check [how to pass a DataTable as parameter to an OrmLite query]({% post_url 2023-06-26-PassDataTableOrmLite %}) and [how to join to a subquery with OrmLite]({% post_url 2023-10-16-SubqueriesAndOrmLite %}).

_Happy coding!_