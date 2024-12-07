USE Forage
GO

SELECT  * FROM Forage..Transaction_data
SELECT * FROM Purchase_Behavior
/* Here we proceed to clean our data. In doing this we will look out for the following

	i. Missing values
	ii. Duplicates records
	iii. Data format and column name issues
	iv. Split Date and Prod_name columns to enable us drill down appropriately
*/


-----Missing Values

SELECT * FROM transaction_data
WHERE Date = '' 
OR STORE_NBR ='' 
OR LYLTY_CARD_NBR = '' 
OR TXN_ID = '' 
OR PROD_NBR = ''
OR PROD_NAME = ''
OR PROD_QTY = ''
OR TOT_SALES = '';

----Looking out for duplicates
WITH dup_cte
AS
(
SELECT *, ROW_NUMBER () OVER(PARTITION BY DATE, STORE_NBR  
										,LYLTY_CARD_NBR
										,TXN_ID 
										,PROD_NBR 
										,PROD_NAME 
										,PROD_QTY 
										,TOT_SALES ORDER BY DATE) AS Row_count
FROM Transaction_data
)
SELECT * FROM dup_cte
WHERE Row_count >1

---Removing duplicate records
WITH dup_ctee
AS
(
SELECT *, ROW_NUMBER () OVER(PARTITION BY Transact_date, STORE_ID  
										,Customer_ID
										,TXN_ID 
										,PROD_ID 
										,PROD_NAME 
										,PROD_QTY 
										,TOT_SALES ORDER BY Transact_date) AS Row_count
FROM Transaction_data
)
SELECT * FROM dup_ctee
WHERE Row_count >1;

-----Data format and addressing columns issues like value length etc


---checking the length of characters
SELECT Lylty_Card_Nbr, LEN(Lylty_Card_Nbr), TXN_ID,  LEN(TXN_ID)
FROM Transaction_Data

----Renaming columns and resolvinf data format issues

SP_RENAME 'Transaction_data.Date', 'Transact_Date', 'COLUMN'

SP_RENAME 'Transaction_data.Store_NBR', 'Store_ID', 'COLUMN'

SP_RENAME 'Transaction_data.Lylty_Card_Nbr', 'Customer_ID', 'COLUMN'

ALTER TABLE Transaction_Data
ALTER COLUMN Customer_ID INT

SP_RENAME 'Transaction_data.Prod_NBR', 'Prod_ID', 'COLUMN'


----splitting the date column

ALTER TABLE Transaction_Data
ADD Transact_Month INT
	,Transact_month_desc VARCHAR (20)
	,Transact_year INT


----Here we populate our newly created columns

UPDATE Transaction_Data
SET Transact_month = Month(Transact_date)
	,Transact_year = Year(Transact_date);

UPDATE Transaction_Data
SET Transact_month_desc = CASE WHEN Transact_month = 1 THEN 'Jan'
								WHEN Transact_month = 2 THEN 'Feb'
								WHEN Transact_month = 3 THEN 'Mar'
								WHEN Transact_month = 4 THEN 'Apr'
								WHEN Transact_month = 5 THEN 'May'
								WHEN Transact_month = 6 THEN 'Jun'
								WHEN Transact_month = 7 THEN 'Jul'
								WHEN Transact_month = 8 THEN 'Aug'
								WHEN Transact_month = 9 THEN 'Sep'
								WHEN Transact_month = 10 THEN 'Oct'
								WHEN Transact_month = 11 THEN 'Nov'
								WHEN Transact_month = 12 THEN 'Dec'
								END;

ALTER TABLE Transaction_data
ADD Transact_qtr INT

UPDATE Transaction_Data
SET Transact_qtr = CASE WHEN Transact_month IN (1,2,3) THEN 1
					WHEN Transact_month IN (4,5,6) THEN 2
					WHEN Transact_month IN (7,8,9) THEN 3
					WHEN Transact_month IN (10, 11, 12) THEN 4
					END;

ALTER TABLE Transaction_data
ALTER COLUMN Transact_Date DATE

ALTER TABLE Transaction_data
ALTER COLUMN Tot_sales FLOAT

ALTER TABLE Transaction_data
ALTER COLUMN Prod_QTY INT

---Removing unnecessary spaces in product name column

SELECT prod_name, RTRIM(Prod_name)
FROM Transaction_data
ORDER BY 1 ASC

---splitting the product name column

ALTER TABLE Transaction_data
ADD Prod_brand VARCHAR (50)

UPDATE Transaction_Data
SET Prod_brand = 'Burger Rings'
WHERE Prod_name LIKE '%Burger Rings%'

UPDATE Transaction_Data
SET Prod_brand = 'Cheezels'
WHERE Prod_name LIKE '%Cheezels%'

UPDATE Transaction_Data
SET Prod_brand = 'Copbs_Popd'
WHERE Prod_name LIKE '%Cobs Popd%'

UPDATE Transaction_Data
SET Prod_brand = 'Doritos'
WHERE Prod_name LIKE '%Dorito%'

UPDATE Transaction_Data
SET Prod_brand = 'French_Fries'
WHERE Prod_name LIKE '%French Fries%'

UPDATE Transaction_Data
SET Prod_brand = 'Grain_waves'
WHERE Prod_name LIKE '%GrnWves%'


UPDATE Transaction_Data
SET Prod_brand = 'Infuzions'
WHERE Prod_name LIKE '%Infuzions%'

UPDATE Transaction_Data
SET Prod_brand = 'Natural Chips'
WHERE Prod_name LIKE '%Natural Chip%'

UPDATE Transaction_Data
SET Prod_brand = 'Smiths_Crinkle'
WHERE Prod_name LIKE '%Smiths Crinkle%' 

UPDATE Transaction_Data
SET Prod_brand = 'Tostitos'
WHERE Prod_name LIKE '%Tostitos%'

UPDATE Transaction_Data
SET Prod_brand = 'Twisties_Cheese'
WHERE Prod_name LIKE '%Twisties cheese%'

UPDATE Transaction_Data
SET Prod_brand = 'WW'
WHERE Prod_name LIKE '%WW%'

----here we can observe that some records have null in their product brand and we nee to populate them

SELECT Prod_name
FROM Transaction_Data                
WHERE Prod_brand IS NULL
ORDER BY 1 ASC

UPDATE Transaction_Data
SET Prod_brand = 'Infuzions'
WHERE Prod_name = 'Infzns Crn Crnchers Tangy Gcamole 110g'


UPDATE Transaction_Data
SET Prod_brand = 'Grain_waves'
WHERE Prod_name = 'GrnWves Plus Btroot & Chilli Jam 180g'

UPDATE Transaction_Data
SET Prod_brand = 'NCC'
WHERE Prod_name = 'NCC Sour Cream &    Garden Chives 175g'


UPDATE Transaction_Data
SET Prod_brand = 'Smiths_Crinkle'
WHERE Prod_name = 'Smiths Crinkle'

UPDATE Transaction_Data
SET Prod_brand = 'Thins_Potato'
WHERE Prod_name = 'Thins Potato Chips  Hot & Spicy 175g'

UPDATE Transaction_Data
SET Prod_brand = 'Twisties_Chicken'
WHERE Prod_name = 'Twisties Chicken270g'

SELECT Prod_brand, Prod_name
FROM Transaction_Data
WHERE Prod_name = 'Twisties Chicken270g'
ORDER BY 1 DESC


/* At this junction, we shall commence the cleaning of our second table (purchase_data) 

Just like we did with the transaction table, we shall look out for the following 
	i. Missing values
	ii. Duplicates records
	iii. Data format and column name issues
	iv. Split Date and Prod_name columns to enable us drill down appropriately
*/


SELECT *
FROM Purchase_Behavior

----Looking out for missing values

SELECT * FROM Purchase_Behavior
WHERE LYLTY_CARD_NBR = '' 
		OR LIFESTAGE = '' 
		OR PREMIUM_CUSTOMER = ''
---our output here shows we have no duplicate records
		
----Looking out for duplicates
WITH pur_dup_cte
AS
(
SELECT *, ROW_NUMBER () OVER(PARTITION BY LYLTY_CARD_NBR
										,LIFESTAGE 
										,PREMIUM_CUSTOMER ORDER BY LYLTY_CARD_NBR) AS Row_count
FROM Purchase_Behavior
)
SELECT * FROM pur_dup_cte
WHERE Row_count >1

---the output of the above syntax shows we have no duplicate records in the purchase behavior table

-----renaming columns and resolving data format issues

SP_RENAME 'Purchase_behavior.LYLTY_CARD_NBR', 'Customer_ID', 'COLUMN';

ALTER TABLE Purchase_Behavior
ALTER COLUMN Customer_ID INT


----At this juction our data is free of anormalies and ready to be used for our analysis 