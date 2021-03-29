---
layout: post
title: "TIL: How to compare DateTime without the date part in SQL Server"
tags: todayilearned sql
---

With `InsertedOn` as `DATETIME`, do

```sql
SELECT *
  FROM dbo.YourTable
 WHERE InsertedOn >= CAST(GETDATE() AS DATE)
   AND InsertedOn < DATEADD(day, 1, CAST(GETDATE() AS DATE))
```

Don't do `WHERE CAST(InsertedOn AS DATE) = CAST(GETDATE() AS DATE)`


_Source_: [Optimized date compare in WHERE clause](https://dba.stackexchange.com/questions/128235/optimized-date-compare-in-where-clause-convert-or-datediff-0)
