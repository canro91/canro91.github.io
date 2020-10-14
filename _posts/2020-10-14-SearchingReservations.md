---
layout: post
title: BugOfTheDay, Searching reservations
tags: bugoftheday sql
---

This time, one of the searching features for reservations was timing out. The appropiate store procedure took 5 minutes to finish.

After opening the actual exection plan with [SentryOne Plan Explorer](https://www.sentryone.com/plan-explorer), the most-CPU expensive and slowest statement looked like this:

```sql
DELETE res
FROM #resTemp res
WHERE reservationID NOT IN (
        SELECT res1.reservationID
        FROM #resTemp res1
        JOIN dbo.reservations res
            ON res.reservationID = res1.reservationID
        JOIN dbo.accounts a
            ON (a.accountID = res.accountID
                  OR a.accountID = res.columnWithAccountID
                  OR a.accountID = res.columnWithAccountIDToo)
                AND a.clientID = @clientID
        WHERE ISNULL(a.accountNumber, '') + ISNULL(a.accountNumberAlpha, '') LIKE @accountNumber + '%'
        );

```

From the above statement, the `#resTemp` table had found reservations from previous queries. The `DELETE` statement kept only the reservations associated to a given account.

Inside SQL Server Management Studio, the store procedure did about 193 millions of logical reads to the `dbo.accounts` table.

## Solution

The subquery in the `DELETE`  joined the found reservations with the `dbo.reservations` table. And then, it joined the `dbo.accounts` table checking for any of the three columns with an `accountID`. This subquery performed an index scan on the `dbo.reservations` table. This last table had a couple of millions of records.

To remove the extra `JOIN` to the `dbo.reservations` table in the subquery, I added the three referenced columns inside the `ON` joining the `dbo.accounts` to the temp table. After this change,  the store procedure took ~8 seconds. It read about 165,000  pages for the `dbo.accounts` table.

```sql
DELETE res
FROM #resTemp res
WHERE reservationID NOT IN (
        SELECT res1.reservationID
        FROM #resTemp res1
        INNER JOIN dbo.accounts a
            ON (a.accountID = res1.accountID
                  OR a.accountID = res1.columnWithAccountID
                  OR a.accountID = res1.columnWithAccountIDToo)
                AND a.clientID = @clientID
        WHERE ISNULL(a.accountNumber, '') + ISNULL(a.accountNumberAlpha, '') LIKE @accountNumber + '%'
        );
```

Then, instead of `NOT IN`, I used `NOT EXISTS`. After this change, the store procedure finished in about 5 seconds.

```sql
DELETE res
FROM #resTemp res
WHERE NOT EXISTS (
        SELECT 1/0
        FROM dbo.accounts a
        WHERE (a.accountID = res.accountID
                OR a.accountID = res.columnWithAccountID
                OR a.accountID = res.columnWithAccountIDToo)
            AND a.clientID = @clientID
            AND ISNULL(a.accountNumber, '') + ISNULL(a.accountNumberAlpha, '') LIKE @accountNumber + '%'
        );
```

Those 4-5 seconds were good enough. But, there's still room for improvement. The `ISNULL` functions in the `WHERE` look weird. Using functions in the `WHERE` statements is a common anti-pattern. In this case, an index in a computed column concatenating the two account numbers would help.

```sql
ALTER TABLE dbo.accounts
ADD AccountNumberComplete AS ISNULL(accountNumber, '') + ISNULL(accountNumberAlpha, '')

CREATE INDEX AccountNumberComplete ON dbo.account_ref(AccountNumberComplete)
```

You could read more about indexes on computed columns on [One SQL Cheat Code For Blazing Fast JSON Queries](https://hackernoon.com/one-sql-cheat-code-for-blazing-fast-json-queries-d0cb6160d380)

_Happy coding!_
