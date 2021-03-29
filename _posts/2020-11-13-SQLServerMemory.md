---
layout: post
title: "TIL: SQL Server uses all available memory"
tags: todayilearned sql
---

SQL Server tries to use all available memory. SQL Server allocates memory during its activity. And, it only releases it when Windows asks for it.

This is normal behavior. SQL Server caches data into memory to reduce access to disk. _Remember, SQL Server caches data pages, not query results_.

But, you can limit the amount of memory available by setting the option "Maximum Server Memory". By default, it is a ridiculous huge number.

{% include image.html name="SQLServerEatingMyRAM.png" caption="SQL Server eating my RAM" alt="SQL Server uses all available memory" width="600px" %}

This is specially true, if you're running SQL Server on your development machine.

_True story! SQL Server was eating my memory. We needed some limits._

_Sources_: [Setting a fixed amount of memory for SQL Server](https://www.mssqltips.com/sqlservertip/4182/setting-a-fixed-amount-of-memory-for-sql-server/), 
[Limit SQL Server Memory Use on Dev Machine
](https://ardalis.com/limit-sql-server-memory-use-on-dev-machine/)

