USE Forage

SELECT * FROM Transaction_Data
SELECT * FROM Purchase_behavior


/* Market basket analysis
Products Bought Together: What two products are often bought together in the same transaction? 
Can we recommend product bundles to boost sales?
*/

---- MBA syntax
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
					p1.Prod_brand AS prod_1, 
					p2.prod_id AS id_2, 
					p2.Prod_brand AS prod_2
		FROM Transaction_Data p1
		JOIN Transaction_Data p2
		ON p1.txn_id = p2.txn_ID
		WHERE p1.Prod_brand < p2.Prod_brand
)
-----------------------------------now we run a count for the number of time identified combination purchases were made
	SELECT prod_1, prod_2, COUNT(*) AS comb_count
	FROM mba_cte
	GROUP BY prod_1, prod_2
	HAVING COUNT(*) >1
	ORDER BY comb_count DESC

-----syntax for percentage of combination transactions
WITH tot_trans 
AS
(
			SELECT COUNT(*) AS tot_trans
			FROM Transaction_Data
), comb_trans

AS 
(		SELECT t1.Prod_brand AS prod_1, 
				t2.prod_brand AS prod_2
		FROM Transaction_Data t1
		JOIN Transaction_Data t2
		ON t1.TXN_ID = t2.TXN_ID
		WHERE t1.Prod_brand < t2.Prod_brand
), com_freq

AS
(	SELECT COUNT(*) AS comb_trans_count
		FROM comb_trans
		
)
	SELECT Round(f.comb_trans_count *100.0/t.tot_trans,5) AS ratio
	FROM tot_trans t
	cross join com_freq f





---we complete our Market Basket Analysis utilizing metrics such as Frequency, Support and Confidence 

WITH mmba

AS
(
				SELECT t1.prod_name AS item_A
				,t2.prod_name AS item_B
				,COUNT(1) AS frequency
				,(SELECT COUNT(*) FROM Transaction_Data) AS tot_trans
				,(SELECT COUNT(*) FROM Transaction_Data WHERE prod_name = t1.PROD_NAME) AS item_A_RHS
				,(SELECT COUNT(*) FROM Transaction_Data WHERE prod_name = t2.PROD_NAME) AS item_B_LHS
				FROM Transaction_Data t1
				JOIN Transaction_Data t2
				ON t1.TXN_ID = t2.TXN_ID
				WHERE t1.PROD_NAME < t2.PROD_NAME
				GROUP BY t1.prod_name, t2.prod_name
)---mba there are four measures, frequency, support, confidence and lift
,mba_prod
AS
(
		SELECT item_A, item_B, frequency
		,(frequency)*100.0/(tot_trans)  AS support--we expand to calculate support
		,(frequency)*100.0/(item_A_RHS) AS confidence
		,((frequency)*100.0/(tot_trans)/(((frequency)*100.0/(item_A_RHS)) *(frequency)*100.0/(item_B_LHS))) AS lift
		FROM mmba
		WHERE frequency > 1
		---ORDER BY 3 DESC
) SELECT * 
	INTO mba_prod
	FROM mba_prod;


----mba with prod brand

WITH mmba_02

AS
(

		SELECT t1.Prod_brand AS brand_A
				,t2.prod_brand AS brand_B
				,COUNT(1) AS frequency
				,(SELECT COUNT(*) FROM Transaction_Data) AS tot_trans
				,(SELECT COUNT(*) FROM Transaction_Data WHERE prod_brand = t1.Prod_brand) AS brand_A_RHS
				,(SELECT COUNT(*) FROM Transaction_Data WHERE prod_brand = t2.Prod_brand) AS brand_B_LHS
		FROM Transaction_Data t1
		JOIN Transaction_Data t2
		ON t1.TXN_ID = t2.TXN_ID
		WHERE t1.PROD_brand < t2.Prod_brand
		GROUP BY t1.Prod_brand,t2.prod_brand
)---mba there are four measures, frequency, support, confidence and lift
,mba_brand
AS
(
		SELECT brand_A, brand_B, frequency
			   ,(frequency *100.0/tot_trans) AS support
			   ,(frequency*100.0/brand_A_RHS) AS confidence
			   ,(frequency *100.0/tot_trans)/((frequency*100.0/brand_A_RHS)* (frequency*100.0/brand_B_LHS)) AS lift
		FROM mmba_02
		----ORDER BY 3 DESC
) 
	SELECT *
	INTO mba_brand
	FROM mba_brand;
---Now we look at this metric across customer segments

WITH cus_life

AS
(
		SELECT pb.lifestage AS lifestage
				,t1.Prod_brand AS brand_A
				,t2.prod_brand AS brand_B
				,COUNT(1) AS frequency
				,(SELECT COUNT(*) FROM Transaction_Data) AS tot_trans
				,(SELECT COUNT(*) FROM Transaction_Data WHERE Prod_brand = t1.Prod_brand) AS Brand_A_LHS
				,(SELECT COUNT(*) FROM Transaction_Data WHERE Prod_brand = t2.Prod_brand) AS Brand_B_RHS
		FROM Transaction_Data t1
		JOIN Transaction_Data t2
		ON t1.TXN_ID = t2.TXN_ID
		JOIN Purchase_Behavior pb
		ON t1.Customer_ID = pb.Customer_ID
		WHERE t1.prod_brand < t2.Prod_brand
		GROUP BY pb.LIFESTAGE, t1.Prod_brand, t2.Prod_brand
		---HAVING COUNT(1) > 1
), mba_life
AS
(
		SELECT lifestage, brand_A
				,brand_B
				,frequency
				,(frequency*100.0/tot_trans) AS support
				,(frequency*100.0/Brand_A_LHS) AS confidence
				,(frequency*100.0/tot_trans)/((frequency*100.0/Brand_A_LHS)*(frequency*100.0/Brand_B_RHS)) AS lift
		FROM cus_life
		---ORDER BY 4 DESC
)
		SELECT * INTO mba_life
		FROM mba_life;


---Now we do same for cus segment

WITH cus_cat

AS
(			SELECT pb.PREMIUM_CUSTOMER AS cus_cat, 
					t1.Prod_brand AS brand_A
					,t2.Prod_brand AS brand_B
					,COUNT(1) AS frequency
					,(SELECT COUNT(Prod_brand) FROM Transaction_Data) AS tot_trans
					,(SELECT COUNT(Prod_brand) FROM Transaction_Data WHERE Prod_brand = t1.Prod_brand) AS brand_A_LHS
					,(SELECT COUNT(Prod_brand) FROM Transaction_Data WHERE Prod_brand = t2.Prod_brand) AS brand_B_RHS
			FROM Transaction_Data t1
			JOIN Transaction_Data t2
			ON t1.TXN_ID = t2.TXN_ID
			JOIN Purchase_Behavior pb
			ON t1.Customer_ID = pb.Customer_ID
			WHERE t1.prod_brand < t2.Prod_brand
			GROUP BY pb.PREMIUM_CUSTOMER, t1.Prod_brand, T2.Prod_brand
			---ORDER BY 4 DESC
			
						
), mba_cus_seg
AS
(
			SELECT cus_cat, brand_A
					,brand_B
					,frequency
					,(frequency*100.0/tot_trans) AS support
					,(frequency*100.0/brand_A_LHS) AS confidence
					,(frequency*100.0/tot_trans)/((frequency*100.0/brand_A_LHS)*(frequency*100.0/brand_B_RHS)) AS lift
			FROM cus_cat
)
			SELECT * INTO mba_cus_seg
			FROM mba_cus_seg 
DROP TABLE	mba_cus_seg


SELECT DISTINCT Prod_Brand
INTO brand_tbl
FROM Transaction_Data

SELECT DISTINCT Prod_name
INTO prod_tbl
FROM Transaction_Data

SELECT DISTINCT lifestage
INTO life_tbl
FROM Purchase_Behavior

SELECT DISTINCT PREMIUM_CUSTOMER
INTO prem_tbl
FROM Purchase_Behavior;



WITH cus_cat_comb

AS
(			SELECT pb.PREMIUM_CUSTOMER AS cus_cat, pb.LIFESTAGE AS lifestage_cat 
					,t1.Prod_brand AS brand_A
					,t2.Prod_brand AS brand_B
					,COUNT(1) AS frequency
					,(SELECT COUNT(Prod_brand) FROM Transaction_Data) AS tot_trans
					,(SELECT COUNT(Prod_brand) FROM Transaction_Data WHERE Prod_brand = t1.Prod_brand) AS brand_A_LHS
					,(SELECT COUNT(Prod_brand) FROM Transaction_Data WHERE Prod_brand = t2.Prod_brand) AS brand_B_RHS
			FROM Transaction_Data t1
			JOIN Transaction_Data t2
			ON t1.TXN_ID = t2.TXN_ID
			JOIN Purchase_Behavior pb
			ON t1.Customer_ID = pb.Customer_ID
			WHERE t1.prod_brand < t2.Prod_brand
			GROUP BY pb.PREMIUM_CUSTOMER, pb.LIFESTAGE, t1.Prod_brand, T2.Prod_brand
			---ORDER BY 4 DESC
			
						
), mba_cus_comb
AS
(
			SELECT cus_cat, lifestage_cat 
					,brand_A
					,brand_B
					,frequency
					,(frequency*100.0/tot_trans) AS support
					,(frequency*100.0/brand_A_LHS) AS confidence
					,(frequency*100.0/tot_trans)/((frequency*100.0/brand_A_LHS)*(frequency*100.0/brand_B_RHS)) AS lift
			FROM cus_cat_comb
)
			SELECT * INTO mba_cus_comb
			FROM mba_cus_comb 



