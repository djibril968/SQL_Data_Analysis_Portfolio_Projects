

USE Onyx_Portfolio

SELECT * FROM Onyx_Christmas_Sales_02


----RFM Analysis

SELECT MAX(age), MIN(age), MAX(age) - MIN(age)
FROM Onyx_Christmas_Sales_02

UPDATE Onyx_Christmas_Sales_02
SET Age_cat = CASE 
				WHEN Age >=18 and Age <= 24 THEN 'Young_Adult'
				WHEN Age >=25 and Age <= 39 THEN 'Adult'
				WHEN Age >=40 and Age <= 54 THEN 'Middle_aged_Adult'
				ELSE 'Elderly'
				END

SELECT CustomerID, MAX(Purchase_date) AS last_pur, DATEDIFF(day, MAX(Purchase_date), (SELECT MAX(Purchase_date) FROM Onyx_Christmas_Sales_02)) AS recency
					,COUNT(TransactionID) AS Frequency, ROUND(SUM(TotalPrice),2) AS MV
FROM Onyx_Christmas_Sales_02
GROUP BY CustomerID
ORDER BY 3


----breakdown across age group

SELECT Age_cat, CustomerID, MAX(Purchase_date) AS last_pur, 
					DATEDIFF(day, MAX(Purchase_date), (SELECT MAX(Purchase_date) FROM Onyx_Christmas_Sales_02)) AS recency
					,COUNT(TransactionID) AS Frequency, ROUND(SUM(TotalPrice),2) AS MV
FROM Onyx_Christmas_Sales_02
GROUP BY CustomerID, Age_cat
ORDER BY 1, 4

-----RFM breakdown across Gender
SELECT Gender, CustomerID, MAX(Purchase_date) AS last_pur, 
					DATEDIFF(day, MAX(Purchase_date), (SELECT MAX(Purchase_date) FROM Onyx_Christmas_Sales_02)) AS recency
					,COUNT(TransactionID) AS Frequency, ROUND(SUM(TotalPrice),2) AS MV
FROM Onyx_Christmas_Sales_02
GROUP BY CustomerID, Gender
ORDER BY 1, 4

----Market basket Analysis


SELECT p.ProductID AS prodID_1, p.Productname AS prod_1, pp.ProductID AS prodID_2, pp.Productname AS prod_2
FROM Onyx_Christmas_Sales_02 p
JOIN Onyx_Christmas_Sales_02 pp
ON p.TransactionID = pp.TransactionID
WHERE p.ProductID < pp.ProductID





