---
layout: post
title: TIL&colon; EXISTS SELECT 1 vs EXISTS SELECT * in SQL Server
tags: todayilearned sql
---

There is no difference between the two. SQL Server will generate similar execution plans. You can even write `EXISTS SELECT 1/0` without any division-by-zero error.

_Source_: [EXISTS (SELECT 1) vs EXISTS (SELECT *)](https://dba.stackexchange.com/questions/159413/exists-select-1-vs-exists-select-one-or-the-other), [EXISTS Subqueries: SELECT 1 vs. SELECT](https://www.sqlskills.com/blogs/conor/exists-subqueries-select-1-vs-select/)
