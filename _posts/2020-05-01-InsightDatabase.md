---
layout: post
title: How to create a CRUD API with ASP.NET Core and Insight.Database
tags: tutorial showdev asp.net
---

A common task when working with web applications is querying the database. You want to store and retrieve any information from your database. If you choose to use [ADO.NET](https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/), you end up writing boilerplate code. But, you could use an ORM instead.

## Why to use an ORM?

**An ORM, Object-relational mapping, is a library that translates between your program and your database.** It converts objects to database records and vice-versa.

ORMs vary in size and features. You can find ORMs that create and maintain your database objects and generate SQL statements. Also, you can find micro-ORMs that make you write SQL queries.

You can roll your own database access layer. But, an ORM helps you to:

* Open and close connections, commands and readers
* Parse query results into C# objects
* Prepare input values to avoid [SQL injection](https://en.wikipedia.org/wiki/SQL_injection) attacks
* Write less code. _Less code, less bugs_

## Insight.Database

[Insight.Database](https://github.com/jonwagner/Insight.Database) is a _"fast, lightweight .NET micro-ORM"_. It allows you to query your database with almost no mapping code. It maps fields/properties to query parameters and columns to fields/properties. Also, you can make extra changes to records as they're being read. For example, [you can trim whitespace-padded string columns]({% post_url 2018-09-21-INeedSomeSpace %}) from a legacy database.

> _Insight.Database is the .NET micro-ORM that nobody knows about because it's so easy, automatic, and fast, (and well-documented) that nobody asks questions about it on StackOverflow._

Insight.Database recommends you to call your database through [store procedures](https://www.essentialsql.com/what-is-a-stored-procedure/). It doesn't generate any SQL statements for you. You have to write your own SQL queries.

## Roll-up your sleeves

Let's create a simple CRUD application for a catalog of products. You should have installed the latest version of [ASP.NET Core SDK](https://dotnet.microsoft.com/download) and one database engine. Let's use [SQL Server Express LocalDB](https://docs.microsoft.com/en-us/aspnet/core/tutorials/razor-pages/sql?view=aspnetcore-3.1&tabs=visual-studio#sql-server-express-localdb) shipped with Visual Studio.

Of course, you can use another database. Insight.Database has providers to work with MySql, SQLite or PostgreSQL. For a list of all providers, see [Database providers](https://github.com/jonwagner/Insight.Database/wiki#database-providers).

### Create the skeleton

Let's create an ASP.NET Core Web application from Visual Studio for our catalog of products. Choose API as the project type. Let's call it `ProductCatalog`. You will have a file structure like this one:

```
|____appsettings.Development.json
|____appsettings.json
|____Controllers
| |____WeatherForecastController.cs
|____ProductCatalog.csproj
|____Program.cs
|____Properties
| |____launchSettings.json
|____Startup.cs
|____WeatherForecast.cs
```

> _You can delete the files `WeatherForecast.cs` and `WeatherForecastController.cs`._

Now, let's create a `ProductController` insde the `Controllers` folder. You can choose the template with read/write actions. You will get a class like this:

```csharp
[Route("api/[controller]")]
[ApiController]
public class ProductController : ControllerBase
{
    // GET: api/Product
    [HttpGet]
    public IEnumerable<string> Get()
    {
        return new string[] { "value1", "value2" };
    }

    // GET: api/Product/5
    [HttpGet("{id}", Name = "Get")]
    public string Get(int id)
    {
        return "value";
    }

    // POST: api/Product
    [HttpPost]
    public void Post([FromBody] string value)
    {
    }

    // PUT: api/Product/5
    [HttpPut("{id}")]
    public void Put(int id, [FromBody] string value)
    {
    }

    // DELETE: api/Product/5
    [HttpDelete("{id}")]
    public void Delete(int id)
    {
    }
}
```

Now, if you run the project and make a GET request to `https://localhost:44343/api/Product`. You will get the two result values. _The port number may be different for you._

```json
[
    "value1",
    "value2"
]
```

_You're ready to start!_

### Get all products

#### Create the database

Let's create a database `ProductCatalog` and a `Products` table. Feel free to use a table designer or write the SQL statement. A product will have an id, name, price and description.

```sql
CREATE TABLE [dbo].[Table]
(
    [Id] INT NOT NULL PRIMARY KEY IDENTITY,
    [Name] VARCHAR(50) NOT NULL,
    [Price] DECIMAL NOT NULL,
    [Description] VARCHAR(255) NULL
)
```

> _It's a good idea to version control the table definitions and the store procedures. But, let's keep it simple for now._

#### Modify GET

Let's create a `Product` class inside a new folder `Models`. Modify the first Get method to return a `IEnumerable<Product>` instead of `IEnumerable<string>`. Don't forget to add `using ProductCatalog.Models;` at the top of your file.

```csharp
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public string Description { get; set; }
}
```

Now, install Insight.Database nuget package. After that, update the body of the `Get` method to query the database with a store procedure called `GetAllProducts`. You will need the `Query` extension method from Insight.Database.

```csharp
using ProductCatalog.Models;
using System.Data.SqlClient;

[HttpGet]
public IEnumerable<Product> Get()
{
    var connection = new SqlConnection(@"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ProductCatalog;Integrated Security=True");
    return connection.Query("GetAllProducts");
}
```

> _I know, I know...We will refactor this in the next steps...By the way, don't version control passwords or any sensitive information, please._

#### Create GetAllProducts store procedure

Now, you need the `GetAllProducts` store procedure. Depending on your workplace, you will have to follow a naming convention. For example, `sp_Products_GetAll`.

```sql
CREATE PROCEDURE [dbo].[GetAllProducts]
AS
BEGIN
    SELECT Id, Name, Price, Description
    FROM dbo.Products
END
GO
```

To try things out, add a product with an `INSERT` statement on your database.

```sql
INSERT INTO Products(Name, Price, Description)
VALUES ('iPhone SE', 399, 'Lots to love. Less to spend.')
```

And, if you make another GET request, you will find the new product. _Yay!_
 
```json
[
    {
        "id": 1,
        "name": "iPhone SE",
        "price": 399,
        "description": "Lots to love. Less to spend."
    }
]
```

> _It's a good idea not to return model or business objects from your API methods. It's recommended to create view models or DTO's with only the properties a consumer of your API will need. But, let's keep it simple._

#### Refactor

Let's clean what we have. First, move the connection string to the `appsettings.json` file.

```json
"ConnectionStrings": {
    "ProductCatalog": "Data Source=(localdb)\\MSSQLLocalDB;Initial Catalog=ProductCatalog;Integrated Security=True;"
}
```

Next, register a `SqlConnection` in the `ConfigureServices` method of the `Startup` class. This will create a new connection on every request.

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddScoped((provider) => new SqlConnection(Configuration.GetConnectionString("ProductCatalog")));
    services.AddControllers();
}
```

Now, update `ProductController` to add a field and a constructor.

```csharp
private readonly SqlConnection _connection;

public ProductController(SqlConnection connection)
{
    _connection = connection;
}

// GET: api/Product
[HttpGet]
public IEnumerable<Product> Get()
{
    return _connection.Query("GetAllProducts");
}

```

Notice, properties in the `Product` class matches column names in `Products` table. After this refactor, this `Get` method should continue to work.

#### Pagination

If your table grows, you don't want to retrieve all products in a single database call. Let's query a page of results each time. For this, you will need two parameters in the `Get` method and in the `GetAllProducts` store procedure.

```csharp
[HttpGet]
public IEnumerable Get(int pageIndex = 1, int pageSize = 10)
{
    var parameters = new { PageIndex = pageIndex - 1, PageSize = pageSize };
    return _connection.Query("GetAllProducts", parameters);
}
```

We have used an anonymous object for the parameters. These names should match the names in the store procedure definition. Notice, the store procedure expects a zero-based page index, so we have used `pageIndex - 1`.

Next, modify the `GetAllProducts` to add two new parameters: `PageIndex` and `PageSize`. And, update the `SELECT` statement to use the [OFFSET-FETCH](https://www.sqlservertutorial.net/sql-server-basics/sql-server-offset-fetch/) clauses.

```sql
ALTER PROCEDURE [dbo].[GetAllProducts]
    @PageIndex INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SELECT Id, Name, Price, Description
    FROM dbo.Products
    ORDER BY Name
    OFFSET @PageIndex ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO
```

If you add more products to the table, you will see how you retrieve a subset of products on GET requests.

> _If you want to practice more, create an endpoint to search a product by id. You should change the appropriate Get method and a create a new store procedure: `GetProductById`._

### Insert a new product

First, inside a new `ViewModels` folder, create an `AddProduct` class. It should have with three properties: name, price and description.

```csharp
public class AddProduct
{
    public string Name { get; set; }
    public decimal Price { get; set; }
    public string Description { get; set; }
}
```

Next, update the `Post` method in the `ProductController` to use as parameter `AddProduct`. This time, since you will insert a new product, you need the `Execute` method instead of `Query`.

```csharp
[HttpPost]
public void Post([FromBody] AddProduct request)
{
    var product = new Product
    {
        Name = request.Name,
        Price = request.Price,
        Description = request.Description
    };
    _connection.Execute("AddProduct", product);
}
```

Next, create the `AddProduct` store procedure. It will have a single `INSERT` statement.

```sql
CREATE PROCEDURE AddProduct
    @Name varchar(50),
    @Price decimal(18, 0),
    @Description varchar(255) = NULL
AS
BEGIN
    INSERT INTO Products(Name, Price, Description)
    VALUES (@Name, @Price, @Description)
END
GO
```

> _You need to validate input data, of course. For example, name and price are required. You can use annotations and a [model validator](https://docs.microsoft.com/en-us/aspnet/core/mvc/models/validation?view=aspnetcore-3.1) or a library like [FluentValidation](https://fluentvalidation.net/)_.

Finally, to add a new product, make a POST request with a json body. It should include the name, price and description for the new product. You will see your product if you make another GET request.

```json
POST https://localhost:44343/api/Product
{
    "name": "iPhone 11 Pro",
    "price": 999,
    "description": "Pro cameras. Pro display. Pro performance."
}
```

## Conclusion

_Voilà!_ You know how to use Insight.Database to retrieve results and execute actions with store procedures using `Query` and `Execute` methods. If you stick to naming conventions, you won't need any mapping code. Insight.Database helped you to keep your data access to a few lines of code. 

> _Your mission, Jim, should you decide to accept it, is to change the `Update` and `Delete` methods to comple all CRUD operations. This post will self-destruct in five seconds. Good luck, Jim._

_Happy coding!_
