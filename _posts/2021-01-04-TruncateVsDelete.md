---
layout: post
title: "TIL: Three differences between TRUNCATE and DELETE"
tags: todayilearned sql
---

These days I learned three differences between TRUNCATE and DELETE statements in SQL Server. Let me share them with you.

**Both DELETE and TRUNCATE remove records from a table.** But, DELETE accepts a WHERE condition to only remove some records, TRUNCATE doesn't. Also, DELETE doesn't reset identity columns to its initial value, but TRUNCATE does. And, DELETE fire triggers, TRUNCATE doesn't.

To see these three differences in action, let's create a sample database with a `Movies` table. It only contains an auto-incremented id, a movie title and an score.

```sql
CREATE DATABASE DeleteVsTruncate
GO

USE DeleteVsTruncate
GO

CREATE TABLE dbo.Movies(
    Id INT PRIMARY KEY IDENTITY,
    Name VARCHAR(255) NOT NULL,
    Score INT
)
GO

INSERT INTO dbo.Movies
VALUES
    ('Titanic', 5),
    ('The Fifth Element', 5),
    ('Terminator 2', 5)
GO
```

## WHERE clause

The first difference is about the WHERE clause. **One one hand, DELETE accept a WHERE clause to only delete some records from a table. But, TRUNCATE doesn't.** It deletes all records from a table. If you try to add a WHERE clause with TRUNCATE, you get _"Incorrect syntax near the keyword 'WHERE'"_.

```sql
SELECT * FROM dbo.Movies
GO

DELETE FROM dbo.Movies WHERE Name = 'Armageddon'
GO
TRUNCATE TABLE dbo.Movies WHERE Name = 'Armageddon'
                          ~~~~~ Incorrect syntax near the keyword 'WHERE'
```

## Identity columns

An identity column is a column with automatic incremented values. It's used to create key values in tables.

Values for identity columns start from a "seed" value and increase by an "increment" value. You can use any number as seed and any positive or negative number as increment. By default, if you don't use any seed or increment, it starts from 1 and increments by 1. `IDENTITY = IDENTITY(1, 1)`

**DELETE statements don't reset identity columns.** It means new rows will have the next value in the identity columns. But, TRUNCATE does reset identity columns. The next new row will have the seed in the identity column.

Let's delete all movies from our sample table and see the Id columns for the new movies.

```sql
SELECT * FROM dbo.Movies
GO
DELETE FROM dbo.Movies
GO
INSERT INTO dbo.Movies
VALUES
    ('Avatar', 5)
GO
SELECT * FROM dbo.Movies
GO
```

{% include image.html name="DeleteDoesNotReset.png" caption="DELETE doesn't reset identity columns" %}

Notice how 'Avatar' still has the `Id = 4` after deleting all movies.

Now, let's see how TRUNCATE resets the identity column. This time, let's use TRUNCATE instead of DELETE.

```sql
SELECT * FROM dbo.Movies
GO
TRUNCATE TABLE dbo.Movies
GO
INSERT INTO dbo.Movies
VALUES
    ('Platoon', 4)
GO
SELECT * FROM dbo.Movies
GO
```

{% include image.html name="TruncateResets.png" caption="TRUNCATE resets identity columns" %}

Notice the Id of 'Platoon'. It's 1 again. When we created our `Movies` table, we used the default seed and increment.

## Triggers

A trigger is an special type of store procedure that runs when a given action has happened at the database or table level. For example, you can run a custom action inside a trigger after INSERT, DELETE or UPDATE to a table.

When you work with triggers, you have two virtual tables: `INSERTED` and `DELETED`. These tables hold the values inserted or deleted in the statement that started the trigger in the first place.

Now, back to the differences between TRUNCATE and DELETE. **DELETE fires triggers, TRUNCATE doesn't.**

Let's create a trigger that shows the deleted values. It uses the `DELETED` table.

```sql
CREATE OR ALTER TRIGGER dbo.PrintDeletedMovies
ON dbo.Movies
AFTER DELETE
AS
BEGIN
    SELECT Id 'Deleted Id', Name 'Deleted Name', Score 'Deleted Score'
    FROM DELETED;
END
```

Now, let's delete our movies with DELETE and TRUNCATE to see what happens. First, let's add some new movies and let's use the DELETE.

```sql
INSERT INTO dbo.Movies
VALUES
    ('Titanic', 5),
    ('The Fifth Element', 5),
    ('Terminator 2', 5)
GO
DELETE FROM dbo.Movies
GO
```

{% include image.html name="DeleteFiresTriggers.png" caption="DELETE fires triggers" %}

Notice the results tab with our three sample movies. Now, let's use TRUNCATE.

```sql
INSERT INTO dbo.Movies
VALUES
    ('Titanic', 5),
    ('The Fifth Element', 5),
    ('Terminator 2', 5)
GO
TRUNCATE TABLE dbo.Movies
GO
```

{% include image.html name="TruncateDoesNotFireTriggers.png" caption="TRUNCATE doesn't fire triggers" %}

Now, after truncating the table, we only see in the messages tab the number of rows affected. No movies shown.

## Bonus: Rollback a TRUNCATE

We can rollback a TRUNCATE operation. To see this, let's add our three movies and use a ROLLBACK with some SELECT's in between. 

```sql
INSERT INTO dbo.Movies
VALUES
    ('Titanic', 5),
    ('The Fifth Element', 5),
    ('Terminator 2', 5)
GO

BEGIN TRAN
    TRUNCATE TABLE dbo.Movies;

    SELECT * FROM dbo.Movies;
ROLLBACK
GO

SELECT * FROM dbo.Movies;
GO
```

{% include image.html name="RollbackTruncates.png" caption="You can rollback a TRUNCATE" %}

Notice, the two results. The one inside the transaction, before the rollback, is empty. And the last one, after the rollback, with our three movies.

Voilà! Those are three differences between DELETE and TRUNCATE.
