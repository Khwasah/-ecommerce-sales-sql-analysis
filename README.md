E-commerce Sales Analysis (SQL)

Overview

Analyzed the Superstore sales dataset (~10K+ order records) using MySQL to uncover revenue, profit, and customer trends, and to identify where the business is losing profitability despite strong sales.

Tools Used

MySQL, MySQL Workbench

Data Source

Superstore Dataset — sourced from Kaggle.

Business Questions Answered


What is the overall revenue and profit performance?
Which regions and categories generate the most revenue and profit?
Who are the top customers by total spend?
Which products have high sales but are actually unprofitable?


Key Findings


Overall performance: Total revenue of $2,272,449.86 against total profit of $282,857.75 — an overall profit margin of approximately 12.4%.
Regional performance: The West region is the strongest performer, generating $713,471 in revenue at a 14.9% profit margin. The Central region has the weakest margin (8.1%) despite solid revenue of $497,801, suggesting higher discounting or costs in that region.
Category breakdown: Technology leads in revenue ($835,900), followed by Furniture ($733,047) and Office Supplies ($703,503) — revenue is fairly evenly spread across categories.
Customer concentration: The top 5 customers contributed over $88,000 combined, led by Sean Miller at $25,043 — a meaningful share of revenue comes from a small group of repeat customers.
Profitability red flag: Several products sell well but actually lose money. The Cubify CubeX 3D Printer generated $11,099 in sales but a -$8,879 loss. The Lexmark MX611dhe printer and GBC DocuBind P400 show similar patterns — high revenue masking poor margins, likely driven by excessive discounting.


Sample Queries

Revenue and profit by region:

SELECT region, SUM(sales_amount) AS revenue, SUM(profit) AS profit
FROM sales
GROUP BY region
ORDER BY revenue DESC;

Products with high sales but low/negative profit:

SELECT product_name, SUM(sales_amount) AS total_sales, SUM(profit) AS total_profit
FROM sales
GROUP BY product_name
HAVING SUM(sales_amount) > 1000 AND SUM(profit) < 50
ORDER BY total_sales DESC;

Next Steps

Future iterations could include a Tableau Public or Google Looker Studio dashboard to visualize these trends, and a deeper look at discount rates driving the negative-profit products identified above.
