---
layout: post
title: "BugOfTheDay: Tune a procedure to find reservations"
tags: bugoftheday sql
---

This time, one of the searching features for reservations was timing out. The appropiate store procedure took ~5 minutes to finish. This is how I tuned it.

**To tune a store procedure, start by looking for expensive operators in its Actual Execution plan. Reduce the number of joining tables and stay away from common bad practices like putting functions around columns in WHERE clauses.**

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

This query belonged to a store procedure to search reservations. Among its filters, a hotelier can find all reservations assigned to a client's internal account number.

From the above query, the `#resTemp` table had reservations from previous queries in the same store procedure. The `DELETE` statement removes all reservations without the given account number.

Inside SQL Server Management Studio, the store procedure did about 193 millions of logical reads to the `dbo.accounts` table. That's a lot!

**For SQL Server, logical reads are the number of 8KB pages that SQL Server has to read to execute a query. Generally, the fewer logical reads, the faster a query runs.**

## Remove extra joins

The subquery in the `DELETE`  joined the found reservations with the `dbo.reservations` table. And then, it joined the `dbo.accounts` table checking for any of the three columns with an `accountID`. _Yes, a reservation could have an accountID in three columns in the same table. Don't ask me why._

This subquery performed an Index Scan on the `dbo.reservations` table. It had a couple of millions of records. That's the main table in any Reservation Management System.

To remove the extra join to the `dbo.reservations` table in the subquery, I added the three referenced columns (`accountID`, `columnWithAccountID`, `columnWithAccountIDToo`) inside the `ON` joining the `dbo.accounts` to the `#resTemp` temporary table. _By the way, those aren't the real names of those columns._

After this change,  the store procedure took ~8 seconds. It read about 165,000  pages for the `dbo.accounts` table. Wow!

```sql
DELETE res
FROM #resTemp res
WHERE reservationID NOT IN (
        SELECT res1.reservationID
        FROM #resTemp res1
        /* We don't need the extra JOIN here */
        INNER JOIN dbo.accounts a
            ON (a.accountID = res1.accountID
                  OR a.accountID = res1.columnWithAccountID
                  OR a.accountID = res1.columnWithAccountIDToo)
                AND a.clientID = @clientID
        WHERE ISNULL(a.accountNumber, '') + ISNULL(a.accountNumberAlpha, '') LIKE @accountNumber + '%'
        );
```

## Use NOT EXISTS

Then, instead of `NOT IN`, I used `NOT EXISTS`. This way, I could lead the subquery from the `dbo.accounts` table. Another JOIN gone!

After this change, the store procedure finished in about 5 seconds.

```sql
DELETE res
FROM #resTemp res
WHERE NOT EXISTS (
        SELECT 1/0
        /* Again, we got rid of another JOIN */
        FROM dbo.accounts a
        WHERE (a.accountID = res.accountID
                OR a.accountID = res.columnWithAccountID
                OR a.accountID = res.columnWithAccountIDToo)
            AND a.clientID = @clientID
            AND ISNULL(a.accountNumber, '') + ISNULL(a.accountNumberAlpha, '') LIKE @accountNumber + '%'
        );
```

Those ~4-5 seconds were good enough. But, there was still room for improvement.

<div class="message">If you're wondering about that weird SELECT 1/0, check my post on <a href="/2020/10/08/ExistsSelectSQLServer/">EXISTS SELECT in SQL Server</a></div>

## Don't use functions in WHERE's

The `ISNULL()` functions in the `WHERE` look weird. Using functions in the `WHERE` clause is a common anti-pattern.

In this case, a computed column concatenating the two parts of account numbers would help. _Yes, account numbers were stored splitted into two columns. Again, don't ask me why._

```sql
ALTER TABLE dbo.accounts
    ADD AccountNumberComplete
    AS ISNULL(accountNumber, '') + ISNULL(accountNumberAlpha, '');
```

To take things even further, an index leading on the `ClientId` followed by that computed column could make things even faster.

```sql
CREATE INDEX ClientID_AccountNumberComplete
    ON dbo.accounts(ClientID, AccountNumberComplete);
```

Voilà! That's how I tuned this query. The lesson to take home is to reduce the number of joining tables and stay away from functions in your WHERE's. Often, a computed column can help SQL Server to run queries  with functions in the WHERE clause. Even, without rewriting the query to use the new computed column.

For more content about SQL Server, check [Six SQL Server tuning tips]({% post_url 2020-09-28-SQLServerTuningTips %}) and [Two free tools to format your SQL queries]({% post_url 2020-09-30-FormatSQL %}).

_Happy coding!_
