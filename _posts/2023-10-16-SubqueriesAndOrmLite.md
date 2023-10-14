---
layout: post
title: "TIL: How to join to subqueries with OrmLite"
tags: todayilearned csharp showdev
cover: Cover.png
cover-alt: "Phone booths" 
---

Another day working with OrmLite. This time, I needed to support a report page with a list of dynamic filters and sorting fields. Instead of writing a plain SQL query, I needed to write a `SqlExpression` that joins to a subquery. OrmLite doesn't support that. This is what I learned (or hacked) today.

Let's imagine we need to write an SQL query for a report to show all directors based on filters like name, birthdate, and other conditions. Next to each director, we need to show their movie count and other counts. For me, it was reservations and rooms. But the idea is still the same.

## 1. Using a SQL query with a CTE

Since we needed to support filters based on the user's input, the best solution would be to write a [dynamic SQL query]({% post_url 2021-03-08-HowNotToWriteDynamicSQL %}). I know, I know! That's tedious.

If we have the `Director` and `Movie` tables, we could write a query like this,

```sql
WITH MovieCount AS (
	SELECT DirectorId
	   , COUNT(*) Count
	   /* More aggregations here */
	FROM Movie
	/* Some filters here */
	GROUP BY DirectorId
	)
SELECT d.*, m.Count
FROM Director d
LEFT JOIN MovieCount m
	ON d.Id = m.DirectorId
WHERE d.Country = 'USA' /* More filters here */
/* Sorting by other filters here */
ORDER BY m.Count DESC
```

I'm using a common table expression, CTE. I have already used them to [optimize queries with ORDER BY]({% post_url 2022-03-07-OptimizeGroupBySQLServer %}).

For this example, a simple JOIN without any CTE would work. But let me prove a point and finish this post.

## 2. Using OrmLite SqlExpression

Let's use these `Director` and `Movie` classes to represent the one-to-many relationship between directors and their movies,

```csharp
public class Director
{
    [AutoIncrement]
    public int Id { get; set; }

    [Reference]
    public List<Movie> Movies { get; set; }

    [StringLength(255)]
    public string FullName { get; set; }

    [StringLength(255)]
    public string Country { get; set; }
}

public class Movie
{
    [AutoIncrement]
    public int Id { get; set; }

    [StringLength(256)]
    public string Name { get; set; }

    [References(typeof(Director))]
    public int DirectorId { get; set; }
}
```

While trying to translate that query to OrmLite expressions, I realized OrmLite doesn't support joining to subqueries. Arrrggg!

I rolled up my sleeves and started to take a deeper look.

I ended up hacking this,

```csharp
using ServiceStack.DataAnnotations;
using ServiceStack.OrmLite;

namespace JoiningToSubqueries;

public class JoinTetsts
{
    [Fact]
    public async Task ItWorksItWorks()
    {
        var connectionString = "...Any SQL Server connection string here...";
        var dbFactory = new OrmLiteConnectionFactory(connectionString);
        using var db = dbFactory.Open();

        // 0. Create Movie and Director tables
        db.CreateTable<Director>();
        db.CreateTable<Movie>();

        // 1. Populate some data
        var jamesCameron = new Director
        {
            FullName = "James Cameron",
            Country = "Canada",
            Movies = new List<Movie>
            {
                new Movie
                {
                    Name = "Titanic"
                }
            }
        };
        await db.SaveAsync(jamesCameron, references: true);

        var stevenSpielberg = new Director
        {
            FullName = "Steven Spielberg",
            Country = "USA",
            Movies = new List<Movie>
            {
                new Movie
                {
                    Name = "Raiders of the Lost Ark"
                },
                new Movie
                {
                    Name = "Jurassic Park",
                }
            }
        };
        await db.SaveAsync(stevenSpielberg, references: true);

        var georgeLucas = new Director
        {
            FullName = "George Lucas",
            Country = "USA",
            Movies = new List<Movie>
            {
                new Movie
                {
                    Name = "Star Wars: A New Hope"
                }
            }
        };
        await db.SaveAsync(georgeLucas, references: true);

        // 2. Write a subquery to do the counting
        var movieCountPerDirector = db.From<Movie>()
                // We could add some filters here...
                .GroupBy(x => x.DirectorId)
                .Select(x => new
                {
                    x.DirectorId,
                    Count = Sql.Custom("COUNT(*)")
                });

        // 2. Write the parent query to filter and sort
        var query = db.From<Director>()
            .LeftJoin(movieCountPerDirector, (d, m) => d.Id == m.DirectorId, subQueryAlias: "mc")
            // ^^^^^
            // It receives a subquery, join expression
            // and alias
            //
            // We could add some filters here...
            .Where(d => d.Country == "USA")
            .Select(d => new
            {
                d,
                MovieCount = Sql.Custom("mc.Count")
                //                      ^^^^
                // Same alias as subQueryAlias parameter
            })
            // We could change the sorting column here too...
            .OrderBy(Sql.Desc("mc.Count"));

        var directors = await db.SelectAsync<DirectorAndMovieCount>(query);

        Assert.Equal(2, directors.Count);
        Assert.Contains(directors, d => d.FullName == "Steven Spielberg");
        Assert.Contains(directors, d => d.FullName == "George Lucas");
    }
}

public class DirectorAndMovieCount
{
    public int Id { get; set; }

    public string FullName { get; set; }

    public string Country { get; set; }

    public int MovieCount { get; set; }
}
```

After creating the two tables and adding some movies, we wrote the aggregation part inside the CTE with a normal `SqlExpression`. That's the `movieCountPerDirector` variable.

Then, we needed the JOIN between `movieCountPerDirector` and the parent query to apply all the filters and sorting. We wrote,

```csharp
var query = db.From<Director>()
    .LeftJoin(movieCountPerDirector,
                (d, m) => d.Id == m.DirectorId,
                subQueryAlias: "mc")
    // ...    
```

We wrote a `LeftJoin()` that received a subquery, a joining expression, and an alias.
 
We might use aliases on the tables to avoid name clashes on the JOIN expression.

## 3. LeftJoin with another SqlExpression

And this is the `LeftJoin()` method,

```csharp
public static partial class SqlExpressionExtensions
{
    public static SqlExpression<T> LeftJoin<T, TSubquery>(
        this SqlExpression<T> expression,
        SqlExpression<TSubquery> subquery,
        Expression<Func<T, TSubquery, bool>> joinExpr,
        string subqueryAlias)
    {
        // This is to "move" parameters from the subquery
        // to the parent query while keeping the right
        // parameter count and order.
        // Otherwise, we could have a parameter named '@0'
        // on the parent and subquery that refer to
        // different columns and values.
        var subqueryParams = subquery.Params.Select(t => t.Value!).ToArray();
        var subquerySql = FormatFilter(expression, subquery.ToSelectStatement(), filterParams: subqueryParams);

        // This is a hacky way of replacing the original
        // table name from the join condition with the
        // subquery alias
        // From:
        //      "table1"."Id" = "table2"."Table1Id"
        // To:
        //      "table1"."Id" = "mySubqueryAlias"."Table1Id"
        var originalCondition = expression.Visit(joinExpr).ToString();

        var definition = ModelDefinition<TSubquery>.Definition;
        var aliasCondition = definition.Alias == null
                                ? originalCondition
                                : originalCondition!.Replace(definition.Alias, subqueryAlias);

        // For example,
        // LEFT JOIN (SELECT Column1 FROM ...) cte ON parent.Id = cte.parentId
        expression = expression.CustomJoin<TSubquery>($"LEFT JOIN ({subquerySql}) {subqueryAlias} ON {aliasCondition}");

        return expression;
    }

    private static string FormatFilter<T>(SqlExpression<T> query, string sqlFilter, params object[] filterParams)
    {
        if (string.IsNullOrEmpty(sqlFilter))
        {
            return string.Empty;
        }

        for (var i = 0; i < filterParams.Length; i++)
        {
            var pLiteral = "{" + i + "}";
            var filterParam = filterParams[i];

            if (filterParam is SqlInValues sqlParams)
            {
                if (sqlParams.Count > 0)
                {
                    var sqlIn = CreateInParamSql(query, sqlParams.GetValues());
                    sqlFilter = sqlFilter.Replace(pLiteral, sqlIn);
                }
                else
                {
                    sqlFilter = sqlFilter.Replace(pLiteral, SqlInValues.EmptyIn);
                }
            }
            else
            {
                var p = query.AddParam(filterParam);
                sqlFilter = sqlFilter.Replace(pLiteral, p.ParameterName);
            }
        }
        return sqlFilter;
    }

    private static string CreateInParamSql<T>(SqlExpression<T> query, IEnumerable values)
    {
        var sbParams = StringBuilderCache.Allocate();
        foreach (var item in values)
        {
            var p = query.AddParam(item);

            if (sbParams.Length > 0)
                sbParams.Append(",");

            sbParams.Append(p.ParameterName);
        }
        var sqlIn = StringBuilderCache.ReturnAndFree(sbParams);
        return sqlIn;
    }
}
```

Let's go through it!

It starts by copying the parameters from the subquery into the parent query. Otherwise, we could end up with parameters with the same name that refer to different values.

OrmLite names parameters using numbers, like `@0`. On the subquery, `@0` could refer to another column as the `@0` on the parent query.

Then, it converts the joining expression into a SQL string. We used the `Visit()` method for that. Then, if the subquery has an alias, it replaces the table name with that alias on the generated SQL fragment for the join expression. And it builds the final raw SQL and calls `CustomJoin()`.

I brought the [FormatFilter()](https://github.com/ServiceStack/ServiceStack/blob/main/ServiceStack.OrmLite/src/ServiceStack.OrmLite/Expressions/SqlExpression.cs#L557) and [CreateInParamSql()](https://github.com/ServiceStack/ServiceStack/blob/main/ServiceStack.OrmLite/src/ServiceStack.OrmLite/Expressions/SqlExpression.cs#L588) methods from OrmLite source code. They're private on the OrmLite source code.

Voilà! That is what I learned (or hacked) today. Again, things we learn when we read the source code of our libraries. We used the `Visit()`, `CustomJoin()`, and two helper methods we brought from the OrmLite source code to make this work.

We only used LEFT JOIN, but we can extend this idea to support INNER JOIN.

As an alternative to this ~~hacky~~ solution, we could write a dynamic SQL query. Next idea! Or we could create an indexed view to replace that counting subquery with a normal join. We could roll a custom method `JoinToView()` to append a `WITH NO_EXPAND` to the actual JOIN. I know everybody can't afford a SQL Server Enterprise edition.

For more OrmLite content, check [how to automatically insert and update audit fields with OrmLite]({% post_url 2022-12-11-AuditFieldsWithOrmLite %}), [how to pass a DataTable as a parameter to a SqlExpression]({% post_url 2023-06-26-PassDataTableOrmLite %}) and [some lessons I learned after working with OrmLite]({% post_url 2022-12-13-LessonsOnHangfireAndOrmLite %}).

_Happy coding!_

