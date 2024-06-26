---
layout: post
title: "BugOfTheDay: Object definitions, spaces, and checksums"
tags: bugoftheday sql
cover: Cover.png
cover-alt: "Object definitions, spaces, and checksums" 
---

These days I was working with a database migration tool and ended up spending almost a day figuring out why my migration didn't work. This is what I learned after debugging an issue for almost an entire day.

In one of my client's projects to create or update stored procedures, we use a custom migrator tool, a wrapper on top of [DbUp](https://github.com/DbUp/DbUp), "a set of .NET libraries that help you to deploy changes to different databases." I've already written about [Simple.Migrator]({% post_url 2020-08-15-Simple.Migrations %}), a similar tool.

To avoid updating the wrong version of a stored procedure, we rely on checksums. Before updating a stored procedure, we calculate the checksum of the existing stored procedure using a command-line tool.

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
Checksum: "A-Sha1-here-of-the-previous-stored-proc"
*/
ALTER PROC dbo.MyCoolStoredProc
BEGIN
  -- Beep, beep, boop...
END
```

To upgrade the database, the migrator compares the checksums of objects in the database with the checksums in header comments. If they're different, the migrator displays a warning message and "fails fast."

Here comes the funny part. When I ran the migrator on my local machine, it always reported a difference. Even when I was grabbing the checksum from the migrator tool itself. Arrggg!

After debugging for a while and [isolating the problem]({% post_url 2020-09-19-ThreeDebuggingTips %}) I found something. On the previous script for the same stored procedure, I started the script with `CREATE OR ALTER PROC`. There's nothing wrong with that.

But there's a difference in the object definitions of a stored procedure created with `CREATE` and with `CREATE OR ALTER`.

### CREATE PROC vs CREATE OR ALTER PROC

Let me show you an example. Let's create the same stored procedure with `CREATE` and `CREATE OR ALTER` to see its object definition.

```sql
/* With just CREATE */
CREATE PROC dbo.test
AS
SELECT 1
GO

SELECT LEN(OBJECT_DEFINITION(OBJECT_ID('dbo.Test'))) AS Length
    , OBJECT_DEFINITION(OBJECT_ID('dbo.Test')) AS Text
GO

/* What about CREATE OR ALTER? */
CREATE OR ALTER PROC dbo.test
AS
SELECT 1
GO

SELECT LEN(OBJECT_DEFINITION(OBJECT_ID('dbo.Test'))) AS Length
    , OBJECT_DEFINITION(OBJECT_ID('dbo.Test')) AS Text
GO
```

Here's the output.

{% include image.html name="CreateVsCreateOrAlter.png" alt="SQL Server object definitions" caption="Object definition of a stored procedure with CREATE and CREATE OR ALTER" width="500px" %}

Let's notice the length of the two object definitions. They're different! Some spaces were making my life harder. Arrrggg!

The migrator compared checksums of the object definition from the database and the one in the header comment. They were different in some spaces. Spaces!

I made the mistake of writing `CREATE OR ALTER` on a previous migration, and the migrator didn't take into account spaces in object names before creating checksums. I had to rewrite the previous script to use `ALTER` and recreate the checksums.

## Parting thoughts

But, what's in this story for you? **We should create processes to prevent mistakes in the first place.** For example:

* [scripts to commit SQL code formatted properly]({% post_url 2023-09-18-FormatSqlFilesOnCommit %})
* validations to avoid applying data migrations to the wrong environment
* [extensions or plugins to follow naming conventions]({% post_url 2020-09-02-TwoRecurringReviewComments %})
* scripts to install the right tools and dependencies to run a project
* up to date documentation for internal tools

I hope you got the idea. It should be hard to make stupid mistakes.

Often, [code reviews]({% post_url 2019-12-17-BetterCodeReviews %}) aren't enough to enforce conventions and prevent mistakes. We're humans and we all make mistakes. And, the more code someone reviews in a session, the more tired he will get. And, the more reviewers we add, the less effective the process gets.

Voilà! That's what I learned these days: read object definitions from SQL Server, polish my debugging skills, and build processes around our everyday development practice.

For more content on SQL Server, check my other posts on [functions and WHERE clauses]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}), [implicit conversions]({% post_url 2022-02-07-WhatAreImplicitConversions %}), and [index recommendations]({% post_url 2022-03-21-SQLServerIndexRecommendations %}).

_Happy debugging!_