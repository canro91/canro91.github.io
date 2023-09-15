---
layout: post
title: "TIL: EXISTS SELECT 1 vs EXISTS SELECT * in SQL Server"
tags: todayilearned sql
---

EXISTS is a logical operator that checks if a subquery returns any rows. EXISTS works only with SELECT statements inside the subquery. Let's see if there are any differences between EXISTS with SELECT * and SELECT 1.

**There is no difference between EXISTS with SELECT * and SELECT 1. SQL Server generates similar execution plans in both scenarios. EXISTS returns true if the subquery returns one or more records, even if it returns NULL or 1/0**.

Let's use a local copy of the [StackOverflow database](https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/) to find users from Antartica who have left any comments. Yes, the same StackOverflow we use everyday to copy and paste code.

Let's check how the execution plans look like when using `SELECT *` and `SELECT 1` in the subquery with the EXISTS operator.

## 1. EXISTS with "SELECT *"

This is the query to find all users from Antartica who have commented anything. This query uses EXISTS with `SELECT *`.

```sql
SELECT *
FROM dbo.Users u
WHERE u.Location = 'Antartica'
AND EXISTS(SELECT * FROM dbo.Comments c WHERE u.Id = c.UserId);
--         ^^^^^^^^
```

To make things faster, let's add one index on `Location` and another one on `UserId` on the `dbo.Users` and `dbo.Comments` tables, respectively.

```sql
CREATE INDEX UserId ON dbo.Comments(UserId);
CREATE INDEX Location ON dbo.Users(Location);
GO
```

Let's check the execution plan. Notice the "Left Semi Join" operator and the other operators.

{% include image.html name="Exists_Start.png" alt="Execution plan using EXISTS with 'SELECT *'" caption="Execution plan using EXISTS with 'SELECT *'" %}

## 2. EXISTS with "SELECT 1"

Now, let's change the subquery inside the EXISTS to use `SELECT 1`.

```sql
SELECT *
FROM dbo.Users u
WHERE u.Location = 'Antartica'
AND EXISTS(SELECT 1 FROM dbo.Comments c WHERE u.Id = c.UserId)
--         ^^^^^^^^
```

Again, let's see the execution plan.

{% include image.html name="Exists1.png" alt="Execution plan using EXISTS with 'SELECT 1'" caption="Execution plan using EXISTS with 'SELECT 1'" %}

Voilà! Notice, there is no difference between the two execution plans when using EXISTS with `SELECT *` and `SELECT 1`. We don't need to write `SELECT TOP 1 1` inside our EXISTS subqueries. We can even rewrite our queries to use `SELECT NULL` or `SELECT 1/0` without any division-by-zero error.

If you want to read more SQL and SQL Server content, check [how to write Dynamic SQL]({% post_url 2021-03-08-HowNotToWriteDynamicSQL %}) and [three differences between TRUNCATE and DELETE]({% post_url 2021-01-04-TruncateVsDelete %}).

_Happy SQL time!_
