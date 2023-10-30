---
layout: post
title: How to create a CRUD API with ASP.NET Core and Insight.Database
tags: tutorial showdev asp.net
---

Almost all web applications we write talk to a database. We could write our own database access layer, but we might end up with a lot of boilerplate code. Let's use Insight.Database to create a CRUD API for a catalog of products with ASP.NET Core.

## 1. Why to use an ORM?

**An object-relational mapping (ORM) is a library that converts objects to database records and vice-versa.**

ORMs vary in size and features. We can find ORMs that manipulate database objects and generate SQL statements. Also, we can find micro-ORMs that make us write SQL queries.

We can roll our own database access layer. But, an ORM helps us to:

* Open and close connections, commands, and readers
* Parse query results into C# objects
* Prepare input values to avoid [SQL injection](https://en.wikipedia.org/wiki/SQL_injection) attacks
* Write less code. And less code means fewer bugs.

## 2. What is Insight.Database?

[Insight.Database](https://github.com/jonwagner/Insight.Database) is a "fast, lightweight .NET micro-ORM."

> _Insight.Database is the .NET micro-ORM that nobody knows about because it's so easy, automatic, and fast (and well-documented) that nobody asks questions about it on StackOverflow._

Insight.Database maps properties from C# classes to query parameters and query results back to C# classes with almost no mapping code.

Insight.Database supports record post-processing, too. We can manipulate records while read. For example, I used this feature to trim whitespace-padded strings from a legacy database without using `Trim()` in every mapping class.

Unlike other ORMs like [OrmLite]({% post_url 2022-12-11-AuditFieldsWithOrmLite %}), Insight.Database doesn't generate SQL statements for us. We have to write our own SQL queries or store procedures. In fact, Insight.Database documentation recommends calling our database through store procedures.

<figure>
<img src="https://images.unsplash.com/photo-1441986300917-64674bd600d8?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Trendy apparel store" />

<figcaption>Let's create our catalog of products. Photo by <a href="https://unsplash.com/@mercantile?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Clark Street Mercantile</a> on <a href="https://unsplash.com/s/photos/store?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 3. A CRUD application with Insight.Database and ASP.NET Core

Let's create a simple CRUD application for a catalog of products using Insight.Database.

Before we begin, we should have a SQL Server instance up and running. For example, we could use SQL Server Express LocalDB, shipped with Visual Studio.

Of course, Insight.Database has providers to work with other databases like MySQL, SQLite, or PostgreSQL.

### Create the skeleton

First, let's create an "ASP.NET Core Web API" application with Visual Studio or [dotnet cli]({% post_url 2022-12-15-CreateProjectStructureWithDotNetCli %}) for our catalog of products. Let's call our solution: `ProductCatalog`.

After creating our API project, we will have a file structure like this one:

```
|____appsettings.Development.json
|____appsettings.json
|____Controllers
| |____WeatherForecastController.cs
|____ProductCatalog.csproj
|____Program.cs
|____Properties
| |____launchSettings.json
|____WeatherForecast.cs
```

Let's delete the files `WeatherForecast.cs` and `WeatherForecastController.cs`. Those are sample files. We won't need them for our catalog of products.

Now, let's create a `ProductController` inside the `Controllers` folder. In Visual Studio, let's choose the template: "API Controller with read/write actions." We will get a controller like this:

```csharp
using Microsoft.AspNetCore.Mvc;

namespace ProductCatalog.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IEnumerable<string> Get()
    {
        return new string[] { "value1", "value2" };
    }

    [HttpGet("{id}")]
    public string Get(int id)
    {
        return "value";
    }

    [HttpPost]
    public void Post([FromBody] string value)
    {
    }

    [HttpPut("{id}")]
    public void Put(int id, [FromBody] string value)
    {
    }

    [HttpDelete("{id}")]
    public void Delete(int id)
    {
    }
}
```

We're using implicit usings and file-scoped namespaces. Those are [some recent C# features]({% post_url 2021-09-13-TopNewCSharpFeatures %}).

If we run the project and make a GET request, we see two results.

{% include image.html name="FirstGet.png" alt="GET request" caption="A request to our GET endpoint using curl" %}

We're ready to start!

### Get all products

#### Create the database

Let's create a database `ProductCatalog` and a `Products` table inside our SQL Server instance. We could use a table designer or write the SQL statement in SQL Server Management Studio.

A product will have an ID, name, price, and description.

```sql
CREATE TABLE [dbo].[Products]
(
    [Id] INT NOT NULL PRIMARY KEY IDENTITY,
    [Name] VARCHAR(50) NOT NULL,
    [Price] DECIMAL NOT NULL,
    [Description] VARCHAR(255) NULL
)
```

It's a good idea to [version control]({% post_url 2020-05-29-HowToVersionControl %}) our database schema and, even better, use [database migrations]({% post_url 2020-08-15-Simple.Migrations %}). Let's keep it simple for now.

#### Modify GET

Let's create a `Product` class in a new `Models` folder. And let's name the properties of the `Product` class after the columns of the `Products` table. Insight.Database will map the two for us.

```csharp
namespace ProductCatalog.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public string Description { get; set; }
}
```

Next, let's modify the first `Get` method in the `ProductController` class to return an `IEnumerable<Product>` instead of `IEnumerable<string>`.

We need to add `using ProductCatalog.Models;` at the top of our file.

```csharp
using Microsoft.AspNetCore.Mvc;
using ProductCatalog.Models;
//    ^^^^^

namespace ProductCatalog.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IEnumerable<Product> Get()
    //                 ^^^^^
    {
    }
    
    // ...
}
```

Now, let's install the `Insight.Database` NuGet package. After that, let's update the `Get()` method to query the database with a store procedure called `GetAllProducts`. We need the `QueryAsync()` extension method from Insight.Database.

```csharp
using Insight.Database;
//    ^^^^^
using Microsoft.AspNetCore.Mvc;
//    ^^^^^
using ProductCatalog.Models;

namespace ProductCatalog.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public async Task<IEnumerable<Product>> Get()
    {
        var connection = new SqlConnection(@"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ProductCatalog;Integrated Security=True");
        return connection.QueryAsync<Product>("GetAllProducts");
        //                ^^^^^
    }
    
    // ...
}
```

I know, I know...We will refactor this shortly...By the way, let's not version control passwords or any sensitive information, please.

#### Create GetAllProducts stored procedure

Now, let's write the `GetAllProducts` stored procedure.

Depending on our workplace, we should follow a naming convention for stored procedures. For example, `sp_<TableName>_<Action>`.

```sql
CREATE PROCEDURE [dbo].[GetAllProducts]
AS
BEGIN
    SELECT Id, Name, Price, Description
    FROM dbo.Products;
END
GO
```

To try things out, let's insert a product,

```sql
INSERT INTO Products(Name, Price, Description)
VALUES ('iPhone SE', 399, 'Lots to love. Less to spend.')
```

And, if we make another GET request, we should find the new product,

{% include image.html name="GetWithAProduct.png" alt="GET request showing one new product" caption="A GET with curl showing one product" width="600px" %}

It's a good idea not to return models or business objects from our API methods. Instead, we should create view models or DTOs with only the properties a consumer of our API will need. But let's keep it simple.

#### Use appsettings.json file

Let's clean what we have. First, let's move the connection string to the `appsettings.json` file. That's how we should use [configuration values with ASP.NET Core]({% post_url 2020-08-21-HowToConfigureValues %}).

```json
"ConnectionStrings": {
    "ProductCatalog": "Data Source=(localdb)\\MSSQLLocalDB;Initial Catalog=ProductCatalog;Integrated Security=True;"
}
```

Next, let's register a `SqlConnection` into the dependencies container using `AddScoped()`. This will create a new connection on every request. Insight.Database opens and closes database connections for us.

```csharp
using Microsoft.Data.SqlClient;
//    ^^^^^

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

var connectionString = builder.Configuration.GetConnectionString("ProductCatalog");
//  ^^^^^
builder.Services.AddScoped(provider => new SqlConnection(connectionString));
//               ^^^^^

var app = builder.Build();
app.MapControllers();
app.Run();
```

Now, let's update our `ProductController` to add a field and a constructor with a `SqlConnection` parameter.

```csharp
using Insight.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using ProductCatalog.Models;

namespace ProductCatalog.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    private readonly SqlConnection _connection;
    //               ^^^^^

    public ProductsController(SqlConnection connection)
    //     ^^^^^
    {
        _connection = connection;
    }

    [HttpGet]
    public async Task<IEnumerable<Product>> Get()
    {
        return await _connection.QueryAsync<Product>("GetAllProducts");
        //     ^^^^^
    }

    // ...
}
```

After this refactoring, our `Get()` should continue to work. Hopefully!

#### Pagination with OFFSET-FETCH

If our table grows, we don't want to retrieve all products in a single database call. That would be slow!

Let's query a page of results each time instead. Let's add two parameters to the `Get()` method and the `GetAllProducts` store procedure: `pageIndex` and `pageSize`.

```csharp
using Insight.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using ProductCatalog.Models;

namespace ProductCatalog.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    private readonly SqlConnection _connection;

    public ProductsController(SqlConnection connection)
    {
        _connection = connection;
    }

    [HttpGet]
    public async Task<IEnumerable<Product>> Get(
        int pageIndex = 1,
        int pageSize = 10)
    {
        var parameters = new
        //  ^^^^^
        {
            PageIndex = pageIndex - 1,
            PageSize = pageSize
        };
        return await _connection.QueryAsync<Product>(
            "GetAllProducts",
            parameters);
            // ^^^^^
    }

    // ...
}
```

We used an anonymous object with the query parameters. These property names should match the store procedure parameters.

Next, let's modify the `GetAllProducts` store procedure to add two new parameters and update the `SELECT` statement to use the OFFSET/FETCH clauses.

```sql
ALTER PROCEDURE [dbo].[GetAllProducts]
    @PageIndex INT = 1,
    // ^^^^^
    @PageSize INT = 10
    // ^^^^^
AS
BEGIN
    SELECT Id, Name, Price, Description
    FROM dbo.Products
    ORDER BY Name
    // ^^^^^
    OFFSET (@PageIndex*@PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
    // ^^^^^
END
GO
```

Our store procedure uses a zero-based page index. That's why we passed `pageIndex - 1` from our C# code.

If we add more products to our table, we should get a subset of products on `GET` requests.

If you want to practice more, create an endpoint to search a product by id. You should change the appropriate `Get()` method and create a new store procedure: `GetProductById`.

### Insert a new product

#### Modify POST

To insert a new product, let's create an `AddProduct` class inside the `Models` folder. It should have three properties: name, price, and description. That's what we want to store for our products.

```csharp
namespace ProductCatalog.Models;

public class AddProduct
{
    public string Name { get; set; }
    public decimal Price { get; set; }
    public string Description { get; set; }
}
```

Next, let's update the `Post()` method in the `ProductController` to use `AddProduct` as a parameter. This time, we need the `ExecuteAsync()` method instead.

```csharp
using Insight.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using ProductCatalog.Models;

namespace ProductCatalog.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    private readonly SqlConnection _connection;

    public ProductsController(SqlConnection connection)
    {
        _connection = connection;
    }

    // ...

    [HttpPost]
    public async Task Post([FromBody] AddProduct request)
    {
        var product = new
        {
            Name = request.Name,
            Price = request.Price,
            Description = request.Description
        };
        await _connection.ExecuteAsync("AddProduct", product);
        //                ^^^^^
    }

    // ...
}
```

#### Create AddProduct stored procedure

Next, let's create the `AddProduct` stored procedure. It will have a single `INSERT` statement.

```sql
CREATE PROCEDURE AddProduct
    @Name VARCHAR(50),
    @Price DECIMAL(18, 0),
    @Description VARCHAR(255) = NULL
AS
BEGIN
    INSERT INTO Products(Name, Price, Description)
    VALUES (@Name, @Price, @Description)
END
GO
```

We should validate input data, of course. For example, a name and price should be required. We could use a library like [FluentValidation](https://fluentvalidation.net/) for that.

Finally, to add a new product, let's make a POST request with a JSON body. It should include a name, price, and description. We will see our new product, if we make another GET request.

{% include image.html name="PostAndGet.png" alt="POST followed by a GET request" caption="A POST request followed by a GET request using curl" %}

Did you notice we didn't need any mapping code? We named our classes to match the stored procedure parameters and results. Great!

## 4. Conclusion

Voilà! That's how to use Insight.Database to retrieve results and execute actions with store procedures using the `QueryAsync()` and `ExecuteAsync()` methods. If we follow naming conventions, we won't need any mapping code. With Insight.Database, we keep our data access to a few lines of code. 

Your mission, Jim, should you decide to accept it, is to change the `Update()` and `Delete()` methods to complete all CRUD operations. This post will self-destruct in five seconds. Good luck, Jim.

For more ASP.NET Core content, check [how to write a caching layer with Redit]({% post_url 2020-06-29-HowToAddACacheLayer %}) and [how to compress responses]({% post_url 2020-10-01-CompressResponses %}). If you're coming from the old ASP.NET Framework, check my [ASP.NET Core Guide for ASP.NET Framework Developers]({% post_url 2020-03-23-GuideToNetCore %}).

_Happy coding!_