---
layout: post
title: "TIL: SQL Server uses all available memory"
tags: todayilearned sql
---

SQL Server tries to use all available memory. SQL Server allocates memory during its activity. And, it only releases it when Windows asks for it.

This is normal behavior. SQL Server caches data into memory to reduce access to disk. Remember, SQL Server caches data pages, not query results.

You can limit the amount of memory available by setting the option "Maximum Server Memory". By default, it is a ridiculous huge number: 2,147,483,647 MB. 

{% include image.html name="SQLServerEatingMyRAM.png" caption="SQL Server eating my RAM" alt="SQL Server uses all available memory" width="600px" %}

This is specially true, if you're running SQL Server on your development machine.

For your Production instances, check BornSQL's [Max Server Memory Matrix](https://bornsql.ca/s/memory/) to set the right amount of RAM your SQL Server needs.

Voilà! This is a true story of how SQL Server was eating my memory. We needed some limits to keep things running smoothly on my laptop.

For more SQL Server content, check [Six SQL Server performance tuning tips]({% post_url 2020-09-28-SQLServerTuningTips %}) and [How to write dynamic SQL queries]({% post_url 2021-03-08-HowNotToWriteDynamicSQL %}).

_Source_: [Setting a fixed amount of memory for SQL Server](https://www.mssqltips.com/sqlservertip/4182/setting-a-fixed-amount-of-memory-for-sql-server/)
