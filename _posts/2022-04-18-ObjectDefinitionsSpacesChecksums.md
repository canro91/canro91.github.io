---
layout: post
title: "BugOfTheDay: Object definitions, spaces, and checksums"
tags: bugoftheday sql
cover: Cover.png
cover-alt: "Object definitions, spaces, and checksums" 
---

These days I was working with a database migration tool. This is what I learned after debugging an issue for almost an entire day.

In one of my client's projects to create or update stored procedures, we use a custom migrator tool. A wrapper on top of [DbUp](https://github.com/DbUp/DbUp). I've already written about [Simple.Migrator]({% post_url 2020-08-15-Simple.Migrations %}), a similar tool.

To avoid updating the wrong version of a stored procedure we rely on checksums. Before updating a stored procedure, we calculate the checksum of its definition at the database using a command-line tool.

## How to find object definitions in SQL Server?

By the way... **To find the text of a stored procedure in SQL Server, use the OBJECT_DEFINITION() function with the object id of the stored procedure.**

Like this,

```sql
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.MyCoolStoredProc'))
GO
```

## Checksums and CREATE statements

With the checksum of the stored procedure to update, we write a header comment in the new script file. Something like,

```sql
/*
Checksum: "A-SHA1-HERE-OF-THE-PREVIOUS-STORED-PROC"
*/
ALTER PROC dbo.MyCoolStoredProc
BEGIN
  ...
END
```

To upgrade the database, the migrator compares the checksums of objects in the database with the checksums in header comments. If they're different, the migrator displays a warning message and stops the upgrade.

Here comes the funny part. When I ran the migrator on my local machine, it always reported a difference. Even when I was grabbing the checksum from the migrator tool itself. Arrggg!

After debugging for a while and [isolating the problem]({% post_url 2020-09-19-ThreeDebuggingTips %}) I found something. On the previous script for the same stored procedure, I started the script with `CREATE OR ALTER PROC`. There's nothing wrong with that.

But, there's a difference in the object definitions of a stored procedure created with `CREATE` and with `CREATE OR ALTER`.

### CREATE PROC vs CREATE OR ALTER PROC

Let me show you an example. We're creating the same stored procedure with `CREATE` and `CREATE OR ALTER` to see its object definition.

```sql
/* With just CREATE */
CREATE PROC dbo.test
AS
SELECT 1
GO

SELECT LEN(OBJECT_DEFINITION(OBJECT_ID('dbo.Test'))) AS Length, OBJECT_DEFINITION(OBJECT_ID('dbo.Test')) AS Text
GO

/* What about CREATE OR ALTER? */
CREATE OR ALTER PROC dbo.test
AS
SELECT 1
GO

SELECT LEN(OBJECT_DEFINITION(OBJECT_ID('dbo.Test'))) AS Length, OBJECT_DEFINITION(OBJECT_ID('dbo.Test')) AS Text
GO
```

Here's the output.

{% include image.html name="CreateVsCreateOrAlter.png" alt="SQL Server object definitions" caption="Object definition of a stored procedure with CREATE and CREATE OR ALTER" width="500px" %}

Notice the length of the two object definitions. They're different! Some spaces were making my life harder.

The migrator compared checksums of the object definition from the database and the one in the header comment. They were different in some spaces.

I made the mistake of writing `CREATE OR ALTER`, and the migrator didn't take into account spaces in object names before creating checksums. I had to rewrite the previous script to use `ALTER` and recreate the checksums.

## Parting thoughts

But, what's in this story for you? We should create processes to prevent mistakes in the first place. Scripts to make sure developers commit the code formatted properly. Checks to avoid applying data migrations to the wrong environment. Extensions or plugins to follow naming conventions. Scripts to install the right tools and dependencies to run a project. Up to date documentation for internal tools.

Often, [code reviews]({% post_url 2019-12-17-BetterCodeReviews %}) aren't enough to enforce conventions. We're humans, and we all make mistakes. And, the more code someone reviews in a session, the more tired he will get. And, the more reviewers we add, the less effective the process gets.

Voilà! That's what I learned these days: read object definitions from SQL Server, polish my debugging skills and build processes around our everyday development practice.

For more content on SQL Server, check my other posts on [functions and WHERE clauses]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}), [implicit conversions]({% post_url 2022-02-07-WhatAreImplicitConversions %}) and [index recommendations]({% post_url 2022-03-21-SQLServerIndexRecommendations %}).

_Happy debugging!_