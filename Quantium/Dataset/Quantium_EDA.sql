USE Forage
GO


/* To analyze and identify distinct customer segments and their chip purchasing behavior.

In line with our task, we shall take a deep dive into our dataset to provide answers to the following questions:

Total Revenue and Change Over the Years: How has total revenue from chip purchases changed over the years,
and what are the key drivers of these changes?

Total Number of Transactions/Chip Purchases: What is the total number of chip purchases, 
and how does this vary by month or season? Are there any noticeable patterns or trends?

Average Order Value (AOV): What is the average order value (AOV), and how does this vary by product category? 
Are certain categories driving higher AOV?

Product Categories: What are the most popular product categories, and how do their sales volumes compare to each other? 
Are there any notable shifts in product preferences?

Total Number of Stores: How many stores are included in the analysis? 
Has this number changed over time, and what might be the reasons behind such changes?

Active Stores: How many stores are currently active, and how does this number change over time? What factors influence store activity?

Purchase Frequency: What is the purchase frequency of customers? Do some segments buy chips more frequently than others?

Repeat Customers: How many repeat customers are there, and what percentage of sales do they represent? 
What strategies can be employed to increase customer retention?

RFM (Recency, Frequency, Monetary): Can we segment customers based on RFM values? What insights can be gain from these segments?

Churned Customers: How many customers have churned, and what percentage of sales do they represent? 
What actions can be taken to reduce churn?

Top and Least Selling Products: Which products are the top sellers, and how have their sales trends changed over time? 
What about the least selling products?

Top and Least Grossing Products: Which products generate the highest and lowest gross revenue, 
and how have their sales changed over time?

Products Bought Together: What products are often bought together in the same transaction? 
Can we recommend product bundles to boost sales?

Average Spend Across Customer Segments: What is the average amount spent by customers across different customer segments? 
Are there segments that spend significantly more?


These questions will guide the analysis and help us gain valuable insights into customer purchase behavior and chip sales.

*/
SELECT * FROM Transaction_Data
/*How has total revenue from chip purchases changed over the years, and what are the key drivers of these changes?*/

----revenue analysis
SELECT Transact_year, Transact_month_desc
		,ROUND(SUM(Tot_sales),2) AS Tot_rev
		,ROUND(AVG(Tot_sales),2) AS Avg_rev
FROM Transaction_Data
GROUP BY Transact_year, Transact_month, Transact_month_desc
ORDER BY Transact_year, Transact_month

-----change in revenue over the years

SELECT Transact_year, Transact_month_desc
		,ROUND(SUM(Tot_sales),2) AS curr_rev
		,ROUND(LAG(SUM(Tot_sales),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month),2) AS prev_rev
		,ROUND(SUM(Tot_sales) - (LAG(SUM(Tot_sales),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month)),2) AS rev_diff
		,ROUND(
				SUM(Tot_sales) -(LAG(SUM(Tot_sales),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month)),2)*100
				/(LAG(SUM(Tot_sales),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month)
				) AS rev_change
FROM Transaction_Data
GROUP BY Transact_year, Transact_month, Transact_month_desc
ORDER BY Transact_year, Transact_month

----sales analysis
SELECT Transact_year, Transact_month_desc
		,ROUND(SUM(PROD_QTY),2) AS Tot_prod_sold
		,ROUND(AVG(PROD_QTY),2) AS Avg_prod_sold
FROM Transaction_Data
GROUP BY Transact_year, Transact_month, Transact_month_desc
ORDER BY Transact_year, Transact_month

-----change in sales over the years

SELECT Transact_year, Transact_month_desc
		,ROUND(SUM(PROD_QTY),2) AS curr_sales
		,ROUND(LAG(SUM(PROD_QTY),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month),2) AS prev_sales
		,ROUND(SUM(PROD_QTY) - (LAG(SUM(PROD_QTY),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month)),2) AS sales_diff
		,ROUND(
				SUM(PROD_QTY) -(LAG(SUM(PROD_QTY),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month)),2)*100
				/(LAG(SUM(PROD_QTY),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month)
				) AS sales_change
FROM Transaction_Data
GROUP BY Transact_year, Transact_month, Transact_month_desc
ORDER BY Transact_year, Transact_month

----Drivers of sales and revenue

SELECT tt.transact_year, td.Prod_brand, tt.curr_sales, tt.prev_sales, tt.sales_diff, tt.sales_change
FROM (SELECT Transact_year, Transact_month_desc
		,ROUND(SUM(PROD_QTY),2) AS curr_sales
		,ROUND(LAG(SUM(PROD_QTY),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month),2) AS prev_sales
		,ROUND(SUM(PROD_QTY) - (LAG(SUM(PROD_QTY),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month)),2) AS sales_diff
		,ROUND(
				SUM(PROD_QTY) -(LAG(SUM(PROD_QTY),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month)),2)*100
				/(LAG(SUM(PROD_QTY),1) OVER(PARTITION BY Transact_year ORDER BY Transact_month)
				) AS sales_change
				FROM Transaction_Data
				GROUP BY Transact_year, transact_month, Transact_month_desc) tt
JOIN Transaction_Data td
ON tt.Transact_year = td.Transact_year
AND tt.Transact_month_desc = td.Transact_month_desc
ORDER BY 1 ASC,  3 DESC


-----Drivers of revenue
-----Drivers of revenue (Brands)

SELECT Prod_brand, ROUND(SUM(Tot_sales),2) as tot_rev, ROUND(AVG(Tot_sales),2) as avg_rev
FROM Transaction_Data
GROUP BY Prod_brand
HAVING ROUND(AVG(Tot_sales),2) >(
								SELECT ROUND(AVG(Tot_sales),2) as avg_rev_02
								FROM Transaction_Data) 

SELECT transact_year, Transact_Month, transact_month_desc, Prod_brand,  ROUND(SUM(Tot_sales),2) as tot_rev	
FROM Transaction_data
GROUP BY transact_year, Transact_Month,transact_month_desc, Prod_brand
HAVING ROUND(AVG(Tot_sales),2) >(
								SELECT ROUND(AVG(Tot_sales),2) as avg_rev_02
								FROM Transaction_Data)  
ORDER BY Transact_year, Transact_Month

----driving revenue
SELECT ROUND(SUM(TOT_SALES),2) FROM Transaction_Data
SELECT ROUND(AVG(Tot_sales),2) as avg_rev_02
								FROM Transaction_Data

/*
Total Number of Transactions/Chip Purchases: What is the total number of chip purchases, 
and how does this vary by month or season? Are there any noticeable patterns or trends?
*/

-----no of chip sales

SELECT SUM(prod_qty) as tot_chip_sales 
FROM Transaction_Data

----sales analysis by month

SELECT transact_year, transact_month, transact_month_desc, SUM(prod_qty) as tot_chip_sales
FROM Transaction_Data
GROUP BY transact_year, transact_month, transact_month_desc
ORDER BY transact_year, transact_month

----change in sales by month
WITH sales_chng_cte 
AS
(
		SELECT transact_year, transact_month, transact_month_desc, SUM(prod_qty) as tot_chip_sales
		FROM Transaction_Data
		GROUP BY transact_year, transact_month, transact_month_desc
)

SELECT Transact_year, transact_month, transact_month_desc, tot_chip_sales 
		,LAG(tot_chip_sales,1) OVER(PARTITION BY transact_year ORDER BY transact_month) as prev_sales
		,tot_chip_sales - LAG(tot_chip_sales,1) OVER(PARTITION BY transact_year ORDER BY transact_month) as sales_diff
		,ROUND((tot_chip_sales - LAG(tot_chip_sales,1) OVER(PARTITION BY transact_year ORDER BY transact_month)),2)*100/LAG(tot_chip_sales,1) OVER(PARTITION BY transact_year ORDER BY transact_month) as chgn_percent
		
FROM sales_chng_cte


/*Average Order Value (AOV): What is the average order value (AOV), and how does this vary by product category? 
Are certain categories driving higher AOV?
*/
-----Overall AOV
SELECT ROUND(SUM(Tot_sales)/SUM(prod_qty),2) as AOV
FROM Transaction_Data;

------AOV by product_cat/brand
WITH prod_cte
AS
(
		SELECT Prod_brand, ROUND(SUM(Tot_sales),2) AS tot_rev, SUM(PROD_QTY) AS tot_prod_sold
		FROM Transaction_Data
		GROUP BY Prod_brand
)
SELECT Prod_brand, ROUND((tot_rev)/(tot_prod_sold),2)
FROM prod_cte
ORDER BY 2 DESC


/*Product Categories: What are the most popular product categories, and how do their sales volumes compare to each other? 
Are there any notable shifts in product preferences?*/
-----Most popular brands
SELECT Prod_brand
		,Count(Prod_brand) as pur_count
		,Sum(Prod_Qty) AS sales_count
		,RANK () OVER(ORDER BY Count(Prod_brand) DESC) AS pop_rank
FROM Transaction_Data
GROUP BY Prod_brand

----most popular products across the various brands
SELECT Prod_brand, prod_name
		,Count(Prod_name) as pur_count
		,Sum(Prod_Qty)
		,RANK () OVER(PARTITION BY Prod_brand ORDER BY Count(Prod_name) DESC) AS pop_rank
FROM Transaction_Data
GROUP BY Prod_brand, Prod_name;
-------most popular products among customers across all brands
WITH pop_cte
AS
(
	SELECT Prod_brand, prod_name
		,Count(Prod_name) as pur_count
		,Sum(Prod_Qty) sales_count
		,RANK () OVER(PARTITION BY Prod_brand ORDER BY Count(Prod_name) DESC) AS pop_rank
FROM Transaction_Data
GROUP BY Prod_brand, Prod_name
)
SELECT *
FROM pop_cte
WHERE pop_rank = 1

-----top bought products among customers across all brands
WITH sales_cte
AS
(
	SELECT Prod_brand, prod_name
		,Count(Prod_name) as pur_count
		,Sum(Prod_Qty) sales_count
		,RANK () OVER(PARTITION BY Prod_brand ORDER BY SUM(Prod_qty) DESC) AS sales_rank
FROM Transaction_Data
GROUP BY Prod_brand, Prod_name
)
SELECT *
FROM sales_cte
WHERE sales_rank = 1

------change in popularity of brands among customers

WITH sales_cte
AS
(
	SELECT Transact_year, Transact_Month, Transact_month_desc, Prod_brand, prod_name
		,Count(Prod_name) as pur_count
		,Sum(Prod_Qty) sales_count
		,RANK () OVER(PARTITION BY Transact_year ORDER BY COUNT(Prod_name) DESC) AS pur_rank
FROM Transaction_Data
GROUP BY Transact_year, Transact_Month, Transact_month_desc, Prod_brand, Prod_name
)
SELECT Transact_year, Transact_Month, Transact_month_desc, Prod_brand, pur_count
		,LAG(pur_count,1,0) OVER(PARTITION BY Transact_year, prod_brand ORDER BY transact_month) AS prev_pur_vol
		,pur_count - LAG(pur_count,1,0) OVER(PARTITION BY Transact_year, prod_brand ORDER BY transact_month) AS pur_diff
FROM sales_cte;


/*Total Number of Stores: How many stores are included in the analysis? 
Has this number changed over time, and what might be the reasons behind such changes?*/

SELECT COUNT(DISTINCT Store_ID) as Store_count
FROM Transaction_Data

SELECT Transact_year 
		,Transact_month 
		,Transact_month_desc
		,Store_Count
		,LAG(Store_count) OVER(PARTITION BY Transact_year ORDER BY Transact_month) AS Store_cnt_change
FROM	(
			SELECT Transact_year, Transact_month, Transact_month_desc
					,COUNT(DISTINCT Store_ID) AS Store_Count
			FROM Transaction_Data
			GROUP BY Transact_year, Transact_Month, Transact_month_desc
		) AS Subquery

-----Tracking reasons for the changes

SELECT Transact_year 
		,Transact_month 
		,Transact_month_desc
		,Store_Count
		,LAG(Store_count) OVER(PARTITION BY Transact_year ORDER BY Transact_month) AS Store_cnt_change
FROM	(
			SELECT Transact_year, Transact_month, Transact_month_desc
					,COUNT(DISTINCT Store_ID) AS Store_Count
			FROM Transaction_Data
			GROUP BY Transact_year, Transact_Month, Transact_month_desc
		) AS Subquery


-- Active Stores: How many stores are currently active, and how does this number change over time? What factors influence store activity?

---most recent sales date across all stores
SELECT store_ID, MAX(transact_date) AS most_recent_sales_date
FROM Transaction_Data
GROUP BY Store_ID

---difference between most recent sales date and the last transaction date

SELECT store_ID, MAX(transact_date) AS most_recent_sales_date
		,DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM transaction_data)) AS days_of_last_activity
FROM Transaction_Data
GROUP BY Store_ID
ORDER BY 3 DESC

---here we define inactive stores as those whose last sales activity is >=30 days

SELECT store_ID, MAX(transact_date) AS most_recent_sales_date
		,DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM transaction_data)) AS days_of_last_activity
FROM Transaction_Data
GROUP BY Store_ID
HAVING DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM transaction_data)) <=30
ORDER BY 3

---here we utilize a cte and case statement to enable us categorize our stores into active and inactive
WITH act_str_cte
AS
(
SELECT store_ID, MAX(transact_date) AS most_recent_sales_date
		,DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM transaction_data)) AS days_of_last_activity
		,CASE 
				WHEN 
					DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM transaction_data)) <=30 THEN 'Active'
					ELSE 'Inactive'
					END AS Store_status
FROM Transaction_Data
GROUP BY Store_ID
)
	SELECT COUNT(Store_status) AS active_stores_count
	FROM act_str_cte
	WHERE Store_status = 'Active'

---and how does this number change over time? What factors influence store activity?
CREATE VIEW active_store_change
AS
WITH act_chng
AS
(
SELECT tt.Transact_year AS T_year, tt.Transact_month_desc AS T_month_desc, tt.transact_month AS T_month, 
						CAST(tt.store_ID AS INT) AS Store_ID, 
						MAX(tt.transact_date) AS most_recent_sales_date
						,DATEDIFF(day, MAX(tt.Transact_Date), (SELECT MAX(transact_date) 
													FROM transaction_data t 
													WHERE t.transact_year = tt.transact_year
													AND t.transact_month = tt.transact_month
													GROUP BY t.Transact_year, t.Transact_Month)) last_sales_date
						,CASE  
							WHEN
								DATEDIFF(day, MAX(tt.Transact_Date), (SELECT MAX(transact_date) 
													FROM transaction_data t
													WHERE t.transact_year = tt.transact_year
													AND t.transact_month = tt.transact_month
													GROUP BY t.Transact_year, t.Transact_Month)) <=7
													THEN 'Active'
													ELSE 'Inactive'
													END AS Store_status
FROM Transaction_Data tt
GROUP BY tt.Transact_year, CAST(tt.store_ID AS INT), tt.Transact_month_desc, tt.Transact_month
---ORDER BY tt.Transact_year, tt.Transact_month
)
SELECT T_year, T_month_desc, COUNT(Store_status) AS act_store_Count
		,LAG(COUNT(store_status),1) OVER(PARTITION BY T_year ORDER BY T_month) AS act_str_change
		,COUNT(Store_status)-LAG(COUNT(store_status),1) OVER(PARTITION BY T_year ORDER BY T_month) AS act_str_change_diff 
FROM act_chng
WHERE Store_status = 'Active'
GROUP BY T_year, T_month, T_month_desc
ORDER BY T_year, T_month;


/* Purchase Frequency: What is the purchase frequency of customers? Do some segments buy chips more frequently than others?
To figure this out we look at the count of purchase for each customer, then the count of purchase across customer segments
*/
---overall frequency of purchase
SELECT COUNT(DISTINCT customer_id) AS cus_count, COUNT(txn_id) AS pur_count 
			,COUNT(txn_id)/COUNT(DISTINCT customer_id) AS pur_freq
FROM Transaction_Data

---frequency of purchase across customer segments
SELECT p.premium_customer, p.lifestage,  COUNT(t.txn_id) AS pur_count 
			,COUNT(txn_id) /COUNT(DISTINCT t.customer_id) AS pur_freq
FROM Transaction_Data t
JOIN Purchase_Behavior p
ON t.Customer_ID = p.Customer_ID
GROUP BY p.lifestage, p.premium_customer
ORDER BY p.premium_customer;

----purchase frequency at customer level

SELECT Customer_ID,  COUNT(txn_id) AS pur_count 
			,COUNT(txn_id) /COUNT(DISTINCT customer_id) AS pur_freq
FROM Transaction_Data
GROUP BY Customer_ID;

----- Do some segments buy chips more frequently than others?

SELECT p.premium_customer, p.lifestage,  COUNT(t.prod_name) AS chip_pur_count
		,COUNT(txn_id) /COUNT(DISTINCT t.Customer_ID) AS pur_freq			
FROM Transaction_Data t
JOIN Purchase_Behavior p
ON p.Customer_ID = t.Customer_ID
GROUP BY p.premium_customer, p.lifestage
ORDER BY p.premium_customer, 3 DESC


/*Repeat Customers: How many repeat customers are there, and what percentage of sales do they represent? 
What strategies can be employed to increase customer retention?
*/

		SELECT DISTINCT p.customer_id, t.transact_year, t.transact_month, t.transact_month_desc 
				,COUNT(t.txn_id) as pur_count
		FROM Transaction_Data t
		JOIN Purchase_Behavior p
		ON p.Customer_ID = t.Customer_ID
		GROUP BY p.customer_id, t.transact_year, t.transact_month, t.transact_month_desc 
		HAVING COUNT(t.txn_id) >1
		ORDER BY COUNT(t.txn_id) DESC

---customers who made repeat purchases during the entire period of interest
WITH rep_pur
AS
(
		SELECT DISTINCT p.customer_id ,COUNT(t.txn_id) as pur_count
		FROM Transaction_Data t
		JOIN Purchase_Behavior p
		ON p.Customer_ID = t.Customer_ID
		GROUP BY p.customer_id, Transact_Date
		HAVING COUNT(t.txn_id) >1 AND t.Transact_Date BETWEEN MIN(t.Transact_Date)  AND MAX(t.transact_date)
		--HAVING 
		--ORDER BY COUNT(t.txn_id) DESC
)
SELECT COUNT(*) AS rep_cus
FROM rep_pur;

---number of customers who make repeat purchases on monthly basis

-----percentage of sales they represent
WITH sales_rep_cte 
AS
(
		SELECT DISTINCT p.customer_id AS cus_id,COUNT(t.txn_id) as pur_count
						,SUM(prod_qty) AS tot_sales
						,SUM(tot_sales) AS tot_rev
		FROM Transaction_Data t
		JOIN Purchase_Behavior p
		ON p.Customer_ID = t.Customer_ID
		GROUP BY p.customer_id, Transact_Date
		HAVING COUNT(t.txn_id) >1 AND t.Transact_Date BETWEEN MIN(t.Transact_Date)  AND MAX(t.transact_date)
),
tot_salles 
AS 
(
		SELECT SUM(prod_qty) AS sales_tot, SUM(tot_sales) AS rev_tot
		FROM Transaction_Data
)
SELECT COUNT(cus_id) AS rep_cus
		,SUM(tot_sales) AS sales
		,ROUND(SUM(tot_sales)*100.0/(SELECT sales_tot FROM tot_salles),3) AS sales_percent
		,SUM(tot_rev) AS rev_gen
		,SUM(tot_rev)*100/(SELECT rev_tot FROM tot_salles) AS rev_percent
FROM sales_rep_cte;


---to look into the breakdown of repeat customers across the various months
WITH sales_rep_cte 
AS (
SELECT DISTINCT t.Transact_year AS t_year, t.Transact_Month AS t_month, 
				t.Transact_month_desc AS t_month_desc
				,p.customer_id AS cus_id,COUNT(t.txn_id) as pur_count
				,SUM(prod_qty) AS tot_pur
				,SUM(tot_sales) AS tot_rev
FROM Transaction_Data t
JOIN Purchase_Behavior p
ON p.Customer_ID = t.Customer_ID
GROUP BY t.Transact_year,t.Transact_Month, t.Transact_month_desc, p.customer_id, Transact_Date
HAVING COUNT(t.txn_id) >1 AND t.Transact_Date BETWEEN MIN(t.Transact_Date)  AND MAX(t.transact_date)
),
tot_salles 
AS (
SELECT Transact_year,Transact_Month
				,Transact_month_desc,
				prod_qty AS sales_tot, tot_sales AS rev_tot
FROM Transaction_Data
)
SELECT t_year, t_month, t_month_desc
		,COUNT(cus_id) AS rep_cus
		,SUM(tot_pur) AS sales_gen
		,ROUND(SUM(tot_pur)*100.0/(SELECT SUM(ts.sales_tot) 
									FROM tot_salles ts
									WHERE ts.Transact_year = t_year
									AND ts.Transact_Month = t_month
									AND ts.Transact_month_desc = t_month_desc
									GROUP BY ts.Transact_year
									,ts.Transact_Month
									,ts.Transact_month_desc),2) AS sales_percent
		,SUM(tot_rev) AS rev_gen
		,ROUND(SUM(tot_rev)*100/(SELECT SUM(ts.rev_tot) 
									FROM tot_salles ts
									WHERE ts.Transact_year = t_year
									AND ts.Transact_Month = t_month
									AND ts.Transact_month_desc = t_month_desc
									GROUP BY ts.Transact_year
									,ts.Transact_Month
									,ts.Transact_month_desc),2) AS rev_percent
FROM sales_rep_cte
GROUP BY t_year, t_month, t_month_desc;


/*the code below generated this error
Msg 8120, Level 16, State 1, Line 494
Column 'tot_salles.sales_tot' is invalid in the select list because it is not contained in either an aggregate function or 
the GROUP BY clause. this was s because we did not specify what aggregate function was to be performed on ts.sales_tot and
ts.rev_tot
*/

WITH sales_rep_cte 
AS
(
SELECT DISTINCT t.Transact_year AS t_year, t.Transact_Month AS t_month, 
				t.Transact_month_desc AS t_month_desc
				,p.customer_id AS cus_id,COUNT(t.txn_id) as pur_count
				,SUM(prod_qty) AS tot_pur
				,SUM(tot_sales) AS tot_rev
FROM Transaction_Data t
JOIN Purchase_Behavior p
ON p.Customer_ID = t.Customer_ID
GROUP BY t.Transact_year,t.Transact_Month, t.Transact_month_desc, p.customer_id, Transact_Date
HAVING COUNT(t.txn_id) >1 AND t.Transact_Date BETWEEN MIN(t.Transact_Date)  AND MAX(t.transact_date)
),
tot_salles 
AS 
(
SELECT Transact_year,Transact_Month
				,Transact_month_desc,
				SUM(prod_qty) AS sales_tot, tot_sales AS rev_tot
FROM Transaction_Data
GROUP BY Transact_year,Transact_Month, Transact_month_desc
)
SELECT t_year, t_month, t_month_desc
		,COUNT(cus_id) AS rep_cus
		,SUM(tot_pur) AS sales
		,ROUND(SUM(tot_pur)*100.0/(SELECT ts.sales_tot 
									FROM tot_salles ts
									WHERE ts.Transact_year = t_year
									AND ts.Transact_Month = t_month
									AND ts.Transact_month_desc = t_month_desc
									GROUP BY ts.Transact_year
									,ts.Transact_Month
									,ts.Transact_month_desc),3) AS sales_percent
		,SUM(tot_rev) AS rev_gen
		,SUM(tot_rev)*100/(SELECT SUM(rev_tot) 
									FROM tot_salles ts
									WHERE ts.Transact_year = t_year
									AND ts.Transact_Month = t_month
									AND ts.Transact_month_desc = t_month_desc
									GROUP BY ts.Transact_year
									,ts.Transact_Month
									,ts.Transact_month_desc) AS rev_percent
FROM sales_rep_cte
GROUP BY t_year, t_month, t_month_desc;


---RFM (Recency, Frequency, Monetary): Can we segment customers based on RFM values? What insights can be gain from these segments?
SELECT DISTINCT customer_id, MAX(transact_date) AS last_pur_date, COUNT(txn_id) AS pur_count 
				,COUNT(txn_id) /COUNT(DISTINCT customer_id) AS pur_freq
				,DATEDIFF(day, MAX(transact_date), (SELECT MAX(Transact_date) FROM Transaction_Data)) AS recency, 
				SUM(tot_sales) AS rev_gen

FROM transaction_data
GROUP BY customer_id;

----now we look at RFM analysis by customer segments
WITH rfm_cte
AS
(
SELECT p.premium_customer AS prem_cus, p.LIFESTAGE AS lifestage 
				,t.customer_id AS cus_count, MAX(t.transact_date) AS last_pur_date, COUNT(t.txn_id) AS pur_count 
				,COUNT(DISTINCT t.customer_id) AS cuss_cnt
				,COUNT(t.txn_id) /COUNT(DISTINCT t.customer_id) AS pur_freq
				,DATEDIFF(day, MAX(t.transact_date), (SELECT MAX(Transact_date) FROM Transaction_Data)) AS recency 
				,SUM(t.tot_sales) AS rev_gen

FROM transaction_data t
JOIN Purchase_Behavior p
ON t.customer_id = p.customer_id
GROUP BY p.premium_customer, p.LIFESTAGE, t.Customer_ID

)

SELECT prem_cus, lifestage, COUNT(cus_count) as cus_count 
		,SUM(pur_count)/ SUM(cuss_cnt) AS pur_freq
		,SUM(rev_gen) AS rev_gen
FROM rfm_cte
WHERE recency <=30
GROUP BY prem_cus, lifestage
ORDER BY prem_cus

/*Churned Customers: How many customers have churned, and what percentage of sales do they represent? 
What actions can be taken to reduce churn?
*/

SELECT * FROM Transaction_Data
---identifying customers who made only one purchase
SELECT Customer_ID, MIN(transact_date) AS min_date, MAX(transact_date) AS max_date, COUNT(txn_id) AS pur_count
				,COUNT(prod_name) AS prod_pur
				,SUM(prod_qty) AS tot_pur
				---,DATEDIFF(day, MIN(transact_date), MAX(transact_date)) AS pur_date_diff
				,DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM Transaction_Data)) AS pur_date_diff
FROM Transaction_Data
GROUP BY Customer_ID
HAVING COUNT(txn_id) <=1 OR DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM Transaction_Data)) >=30

/* the syntax above doesn't give us an output as accurate as we would want it to hence the need to twick it in the following syntax
In the next syntax we look at the difference between the date of last purchase of our customers and the last transaction date/sales cycle.
we look at customers whose last purchase date is above 60 days
*/

SELECT Customer_ID, MIN(transact_date) AS min_date, MAX(transact_date) AS max_date, COUNT(txn_id) AS pur_count
				,COUNT(prod_name) AS prod_pur
				,SUM(prod_qty) AS tot_pur
				,SUM(tot_sales) AS tot_rev
				---,DATEDIFF(day, MIN(transact_date), MAX(transact_date)) AS pur_date_diff
				,DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM Transaction_Data)) AS pur_date_diff
FROM Transaction_Data
GROUP BY Customer_ID
HAVING DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM Transaction_Data)) >=60

---to find out the percentage of sales and revenue they represent
WITH churn_cte
AS
(
SELECT Customer_ID, MIN(transact_date) AS min_date, MAX(transact_date) AS max_date, COUNT(txn_id) AS pur_count
				,COUNT(prod_name) AS prod_pur
				,SUM(prod_qty) AS tot_pur
				,SUM(tot_sales) AS tot_rev
				---,DATEDIFF(day, MIN(transact_date), MAX(transact_date)) AS pur_date_diff
				,DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM Transaction_Data)) AS pur_date_diff
FROM Transaction_Data
GROUP BY Customer_ID
HAVING DATEDIFF(day, MAX(transact_date), (SELECT MAX(transact_date) FROM Transaction_Data)) >=60
)
SELECT COUNT(customer_ID) AS cus_count
		,SUM(tot_pur) AS tot_pur
		,ROUND(SUM(tot_pur) *100 / (SELECT SUM(prod_qty) FROM  Transaction_Data),2) AS sales_percent
		,ROUND(SUM(tot_rev),2) AS tot_rev
		,ROUND(SUM(tot_rev)*100 / (SELECT SUM(tot_sales) FROM Transaction_Data),2) AS rev_percent
FROM churn_cte

/*
Top and Least Selling Products: Which products are the top sellers, and how have their sales trends changed over time? 
What about the least selling products?*/

SELECT (Prod_ID), COUNT(prod_id) --Prod_brand, Prod_ID
FROM Transaction_Data
GROUP BY prod_id
----top selling brands
--first we look at sales across all products
SELECT prod_brand, prod_name, (prod_qty) tot_sales
FROM transaction_data
GROUP BY prod_brand, prod_name
ORDER BY SUM(prod_qty) DESC

---- lease selling brands across the duration and change in sales

WITH sales_rank_change
AS
(
SELECT transact_year, transact_month, Transact_month_desc
		,prod_name
		,SUM(prod_qty) AS tot_sales
FROM Transaction_Data
GROUP BY transact_year, transact_month, Transact_month_desc, prod_brand ,prod_name
---ORDER BY Transact_year, Transact_Month
), rank_sal
AS
(
	SELECT *, RANK () OVER(PARTITION BY transact_year, transact_month ORDER BY tot_sales ASC) AS prod_rank
	FROM sales_rank_change
)

	SELECT s.transact_year, s.transact_month, s.Transact_month_desc
		,s.prod_name
		,s.tot_sales
		,r.prod_rank
	FROM sales_rank_change s
	JOIN rank_sal r
	ON s.Transact_year = r.Transact_year
	AND s.Transact_Month = r.Transact_Month
	AND s.PROD_NAME = r.PROD_NAME
	WHERE r.prod_rank <=5
	ORDER BY Transact_year, Transact_Month, prod_rank

---- overall top selling products with the duration of interest
WITH sales_rank_change
AS
(
SELECT transact_year, transact_month, Transact_month_desc
		,prod_brand
		,prod_name
		,SUM(prod_qty) AS tot_sales
FROM Transaction_Data
GROUP BY transact_year, transact_month, Transact_month_desc, prod_brand ,prod_name
---ORDER BY Transact_year, Transact_Month
), rank_sal
AS
(
	SELECT *, RANK () OVER(PARTITION BY transact_year, transact_month ORDER BY tot_sales DESC) AS prod_rank
	FROM sales_rank_change
)

	SELECT s.transact_year, s.transact_month, s.Transact_month_desc
		,s.prod_brand
		,s.prod_name
		,s.tot_sales
		,r.prod_rank
	FROM sales_rank_change s
	JOIN rank_sal r
	ON s.Transact_year = r.Transact_year
	AND s.Transact_Month = r.Transact_Month
	AND s.Prod_brand = r.Prod_brand
	AND s.PROD_NAME = r.PROD_NAME
	WHERE r.prod_rank <=5
	ORDER BY Transact_year, Transact_Month, prod_rank


---here we rank top selling products for each product_brand
WITH sales_rank
AS
(
		SELECT prod_brand, prod_name, SUM(prod_qty) AS tot_sales
		FROM transaction_data
		GROUP BY prod_brand, prod_name
		---ORDER BY Prod_brand
)
	SELECT prod_brand, prod_name, tot_sales
			,RANK () OVER(PARTITION BY prod_brand ORDER BY tot_sales DESC) as sale_rank
	FROM sales_rank;

/*Top and Least Grossing Products: Which products generate the highest and lowest gross revenue, 
and how have their sales changed over time?
*/

---top revenue grossing products

WITH rev_rank_change
AS
(
SELECT transact_year, transact_month, Transact_month_desc
		,prod_brand
		,prod_name
		,ROUND(SUM(tot_sales),2) AS tot_rev
FROM Transaction_Data
GROUP BY transact_year, transact_month, Transact_month_desc, prod_brand ,prod_name
---ORDER BY Transact_year, Transact_Month
), rev_rank
AS
(
	SELECT *, RANK () OVER(PARTITION BY transact_year, transact_month ORDER BY tot_rev DESC) AS rev_rank
	FROM rev_rank_change
)

	SELECT rc.transact_year, rc.transact_month, rc.Transact_month_desc
		,rc.prod_brand
		,rc.prod_name
		,rc.tot_rev
		,rr.rev_rank
	FROM rev_rank_change rc
	JOIN rev_rank rr
	ON rc.Transact_year = rr.Transact_year
	AND rc.Transact_Month = rr.Transact_Month
	AND rc.Prod_brand = rr.Prod_brand
	AND rc.PROD_NAME = rr.PROD_NAME
	WHERE rr.rev_rank <=5
	ORDER BY Transact_year, Transact_Month, rev_rank

----Least grossing products
WITH rev_rank_change
AS
(
SELECT transact_year, transact_month, Transact_month_desc
		,prod_brand
		,prod_name
		,ROUND(SUM(tot_sales),2) AS tot_rev
FROM Transaction_Data
GROUP BY transact_year, transact_month, Transact_month_desc, prod_brand ,prod_name
---ORDER BY Transact_year, Transact_Month
), rev_rank
AS
(
	SELECT *, RANK () OVER(PARTITION BY transact_year, transact_month ORDER BY tot_rev ASC) AS rev_rank
	FROM rev_rank_change
)

	SELECT rc.transact_year, rc.transact_month, rc.Transact_month_desc
		,rc.prod_brand
		,rc.prod_name
		,rc.tot_rev
		,rr.rev_rank
	FROM rev_rank_change rc
	JOIN rev_rank rr
	ON rc.Transact_year = rr.Transact_year
	AND rc.Transact_Month = rr.Transact_Month
	AND rc.Prod_brand = rr.Prod_brand
	AND rc.PROD_NAME = rr.PROD_NAME
	WHERE rr.rev_rank <=5
	ORDER BY Transact_year, Transact_Month, rev_rank

/* Market basket analysis
Products Bought Together: What products are often bought together in the same transaction? 
Can we recommend product bundles to boost sales?
*/
---the query below would return values but with a slight error, in that some values will be repeated further explanation later
SELECT p1.prod_ID, p1.prod_name, p2.prod_id, p2.prod_name
FROM Transaction_Data p1
JOIN Transaction_Data p2
ON p1.txn_id = p2.txn_ID
WHERE p1.prod_name != p2.prod_name

---actual MBA syntax
SELECT p1.prod_ID, p1.prod_name, p2.prod_id, p2.prod_name
FROM Transaction_Data p1
JOIN Transaction_Data p2
ON p1.txn_id = p2.txn_ID
WHERE p1.prod_name < p2.prod_name;

-----we drill further to find out the number of times the identified products were bought together
WITH mba_cte ---we start with our market basket analysis, which gives an insight into what products customers purchase together
AS				----we do this with the aid of the cte
(
		SELECT p1.prod_ID AS id_1, 
					p1.prod_name AS prod_1, 
					p2.prod_id AS id_2, 
					p2.prod_name AS prod_2
		FROM Transaction_Data p1
		JOIN Transaction_Data p2
		ON p1.txn_id = p2.txn_ID
		WHERE p1.prod_name < p2.prod_name
)
-----------------------------------now we run a count for the number of time identified combination purchases were made
	SELECT prod_1, prod_2, COUNT(*) AS comb_count
	FROM mba_cte
	GROUP BY prod_1, prod_2
	HAVING COUNT(*) >1
	ORDER BY comb_count DESC

---we complete our Market Basket Analysis utilizing metrics such as Frequency, Support and Confidence 
WITH mba_cte 
AS				
(		SELECT p1.txn_id,  
					p1.prod_name AS prod_1,	p2.prod_name AS prod_2
					,(SELECT COUNT(prod_name) FROM Transaction_Data) AS tot_trans
					,(SELECT COUNT(prod_name) FROM Transaction_Data WHERE prod_name = p1.prod_name) AS LHS
					,(SELECT COUNT(prod_name) FROM Transaction_Data WHERE prod_name = p2.prod_name) AS RHS
		FROM Transaction_Data p1
		JOIN Transaction_Data p2
		ON p1.txn_id = p2.txn_ID
		WHERE p1.prod_name < p2.prod_name
)
-----------------------------------now we look for frequency, support and confidence 
		SELECT prod_1, prod_2, COUNT(*) AS freq
				,ROUND((COUNT(*)*100.0/MAX(tot_trans)),5) AS support
				,ROUND((COUNT(*) *100.0/MAX(LHS)),2) AS confidence
				,LHS
		FROM mba_cte
		GROUP BY prod_1, prod_2, LHS
		HAVING COUNT(*) >1
		ORDER BY freq DESC


---we further drill down to look at the spread of this combination across customer segments
WITH mba_cte 
AS				
(
		SELECT p1.txn_id,  
					p1.prod_name AS prod_1
					,p2.prod_name AS prod_2
					,pb.lifestage AS lifestage
					,pb.premium_customer AS prem_cus
					,(SELECT COUNT(prod_name) FROM Transaction_Data) AS tot_trans
		FROM Transaction_Data p1
		JOIN Transaction_Data p2
		ON p1.txn_id = p2.txn_ID
		JOIN Purchase_Behavior pb
		ON pb.Customer_ID = p1.Customer_ID
		WHERE p1.prod_name < p2.prod_name
)
-----------------------------------now we look how combination purchases are made across customer segments
	SELECT lifestage, prem_cus
			,prod_1, prod_2, COUNT(*) AS freq
			,ROUND((COUNT(*)*100.0/MAX(tot_trans)),5) AS support	
	FROM mba_cte
	GROUP BY lifestage, prem_cus, prod_1, prod_2
	---HAVING COUNT(*) >1
	ORDER BY freq DESC

/*
Average Spend Across Customer Segments: What is the average amount spent by customers across different customer segments? 
Are there segments that spend significantly more?
*/
WITH avg_spend
AS
(
		SELECT p.lifestage AS lifestage, p.premium_customer AS prem_cus
				,ROUND(SUM(t.tot_sales),2) AS tot_spending
				,ROUND(AVG(t.tot_sales),2) AS avg_spending
		FROM Transaction_Data t
		JOIN Purchase_Behavior p
		ON t.customer_id = p.Customer_ID
		GROUP BY p.lifestage, p.premium_customer
		--ORDER BY p.lifestage, AVG(t.tot_sales)
),
	spend_rank ----here we rank the average spending of customer categories 
	AS
	(
		SELECT lifestage, prem_cus
			,tot_spending
			,avg_spending
			,RANK() OVER(ORDER BY avg_spending DESC) AS spe_rank
		FROM avg_spend
	) ----here we select the top five customer segments with the highest average spending
		SELECT *
		FROM spend_rank
		WHERE spe_rank <=5

/*
Part 2

After successfully looking into customer purchase behavior, our task has taken a new turn in line with our clients directive
Now we have to carry out an experiment. the aim here is to analyse the effect of product layout in purchase behavior and sales
To achieve this, we have two categories of stores 
		i trials ctores
		11 control stores

Here we have to look into similarities in their performance

To select our control stores, we utilize the following metrics
		overall monthly sales
		revenue
		number of customers as well as number of purchases made by customers in each store
*/

SELECT * FROM T_data_02

ALTER TABLE transaction_data
ADD prod_size VARCHAR (10)

UPDATE Transaction_Data
SET prod_size = RIGHT(prod_name, 4)

UPDATE Transaction_Data
SET prod_size = SUBSTRING(prod_name, len(prod_name)-20, 4)
WHERE prod_size = 'salt'


SELECT prod_name, prod_size ----, SUBSTRING(prod_name, len(prod_name)-20, 4)
FROM Transaction_Data
WHERE prod_size = 'salt'


SELECT store_id, SUM(prod_qty) AS sales, ROUND(SUM(tot_sales),2) AS tot_rev 
FROM Transaction_data
WHERE Store_ID IN (77, 86, 88)
GROUP BY Store_ID
ORDER BY STORE_ID

/* we start by analysing monthly sales for our trial stores
*/

SELECT store_id, SUM(prod_qty) AS sales, ROUND(SUM(tot_sales),2) AS tot_rev 
FROM Transaction_data
WHERE Store_ID NOT IN (77, 86, 88)
GROUP BY Store_ID
ORDER BY 3 DESC

SELECT * FROM  Transaction_Data

DROP TABLE T_data_02


