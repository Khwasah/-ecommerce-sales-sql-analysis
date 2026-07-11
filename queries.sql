# E-commerce Sales Analysis (MySQL Workbench)

---

## STEP 1: Create a Database

Open MySQL Workbench, connect to your local server, and in a query tab run:

```sql
CREATE DATABASE superstore_project;
USE superstore_project;
```

## STEP 2: Import Your CSV

1. In the left sidebar, right-click **Schemas** → your new `superstore_project` database
2. Right-click it → **Table Data Import Wizard**
3. Browse to your CSV file (the one you extracted)
4. Let it create a new table — name it `sales`
5. Workbench will guess column types automatically. 
6. When done, refresh the schema (right-click → Refresh All) and you should see `sales` under Tables

**Check it worked:**
```sql
SELECT * FROM sales LIMIT 10;
```
This shows the first 10 rows. If you see your data, you're set.
---
## STEP 3: Understand What You're Working With

Before writing analysis queries, always look at the shape of the data first.

```sql
-- How many rows total?
SELECT COUNT(*) FROM sales;

-- What columns exist and what type are they?
DESCRIBE sales;

-- Any obviously broken/null values in key columns?
SELECT COUNT(*) FROM sales WHERE Sales IS NULL;
```

Take a minute to actually read the column names (Order Date, Sales, Profit, Category, Region, Customer Name, etc.) — you'll need to reference them exactly, including capitalization, in every query.

---

## STEP 4: Basic Queries (Foundation)

These are the building blocks

```sql
-- Look at specific columns only
SELECT Customer_Name, Sales, Profit FROM sales;

-- Filter rows
SELECT * FROM sales WHERE Region = 'West';

-- Sort results
SELECT * FROM sales ORDER BY Sales DESC LIMIT 10;

-- Combine filter + sort
SELECT * FROM sales WHERE Category = 'Furniture' ORDER BY Profit ASC LIMIT 5;
```
---

## STEP 5: Aggregate Queries (This Is Where Real Analysis Starts)

```sql
-- Total revenue
SELECT SUM(Sales) AS total_revenue FROM sales;

-- Total profit
SELECT SUM(Profit) AS total_profit FROM sales;

-- Revenue by category
SELECT Category, SUM(Sales) AS total_sales
FROM sales
GROUP BY Category
ORDER BY total_sales DESC;

-- Revenue AND profit by region
SELECT Region, SUM(Sales) AS revenue, SUM(Profit) AS profit
FROM sales
GROUP BY Region
ORDER BY revenue DESC;

-- Average order value by segment
SELECT Segment, AVG(Sales) AS avg_order_value
FROM sales
GROUP BY Segment;
```

**Key concept:** `GROUP BY` collapses rows into groups (e.g. one row per Region), and the aggregate function (`SUM`, `AVG`, `COUNT`) tells SQL what to calculate for each group. This is the single most important idea in SQL analysis .

---

## STEP 6: Filtering Aggregated Results (HAVING)

```sql
-- Categories with total sales over 50,000
SELECT Category, SUM(Sales) AS total_sales
FROM sales
GROUP BY Category
HAVING SUM(Sales) > 50000;
```

**Important distinction:** `WHERE` filters rows *before* grouping. `HAVING` filters groups *after* aggregation. This trips up most beginners — it's normal to mix it up a few times.

---

## STEP 7: Date-Based Analysis (Trends Over Time)

```sql
-- Revenue by year
SELECT YEAR(Order_Date) AS year, SUM(Sales) AS total_sales
FROM sales
GROUP BY YEAR(Order_Date)
ORDER BY year;

-- Revenue by year and month
SELECT YEAR(Order_Date) AS year, MONTH(Order_Date) AS month, SUM(Sales) AS total_sales
FROM sales
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY year, month;
```

If this errors, your `Order Date` column may be imported as text, not a date. Fix it with:
```sql
ALTER TABLE sales MODIFY Order_Date DATE;
```

**If you get "Incorrect date value" error:** this means your dates are stored as text in `M/D/YYYY` format (like `11/9/2016`), which is how the Superstore CSV stores them — but MySQL's DATE type only understands `YYYY-MM-DD`. You need to convert the format first, then change the column type. Run these in order:

```sql
-- Step A: add a temporary new column
ALTER TABLE sales ADD COLUMN order_date_fixed DATE;

-- Step B: convert the text dates into proper DATE format and fill the new column
UPDATE sales
SET order_date_fixed = STR_TO_DATE(order_date, '%m/%d/%Y');

-- Step C: drop the old broken column
ALTER TABLE sales DROP COLUMN order_date;

-- Step D: rename the fixed column to the original name
ALTER TABLE sales RENAME COLUMN order_date_fixed TO order_date;
```

**Check it worked:**
```sql
SELECT order_date FROM sales LIMIT 5;
```
You should now see dates in `YYYY-MM-DD` format (e.g. `2016-11-09`). Now your `YEAR(order_date)` and `MONTH(order_date)` queries from Step 7 will run correctly.

**Note:** if `STR_TO_DATE` returns all `NULL` values instead of erroring, your dates might actually be `D/M/YYYY` or another format — run `SELECT order_date FROM sales LIMIT 5;` *before* Step B to check the raw format, and swap `%m/%d/%Y` for `%d/%m/%Y` if needed.

---

## STEP 8: The "Impressive" Queries (Subqueries & Window Functions)

```sql
-- Top 5 customers by total spend
SELECT Customer_Name, SUM(Sales) AS total_spent
FROM sales
GROUP BY Customer_Name
ORDER BY total_spent DESC
LIMIT 5;

-- Products with high sales but low profit (the "interesting insight" query)
SELECT Product_Name, SUM(Sales) AS total_sales, SUM(Profit) AS total_profit
FROM sales
GROUP BY Product_Name
HAVING SUM(Sales) > 1000 AND SUM(Profit) < 50
ORDER BY total_sales DESC;
-- Running monthly total using a window function
SELECT
  YEAR(Order_Date) AS year,
  MONTH(Order_Date) AS month,
  SUM(Sales) AS monthly_sales,
  SUM(SUM(Sales)) OVER (ORDER BY YEAR(Order_Date), MONTH(Order_Date)) AS running_total
FROM sales
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY year, month;
```
