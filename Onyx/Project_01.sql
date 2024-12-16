USE Project_01;

SELECT * FROM cards_data
SELECT * FROM transactions_data
SELECT * FROM mcc_codes
SELECT * from users_data


--PART A DATA PREP AND COLUMN STANDARDIZATION

SELECT MAX(yearly_income) AS max_year, MIN(yearly_income) AS min_income,
        MAX(total_debt) AS max_debt, MIN(total_debt) AS min_debt,
        MAX(credit_score) AS max_cs, MIN(credit_score) AS min_cs
FROM users_data



ALTER TABLE users_data
ADD income_cat VARCHAR (10),
    debt_cat VARCHAR (10),
    credit_score_cat VARCHAR (10),
    dti INT,
    dti_cat VARCHAR (10)

ALTER TABLE users_data
ADD dtii FLOAT (10)

ALTER TABLE users_data
ALTER COLUMN per_capita_income INT

ALTER TABLE users_data
ALTER COLUMN yearly_income INT

ALTER TABLE users_data
ALTER COLUMN total_debt INT 

ALTER TABLE users_data
ALTER COLUMN credit_score INT

ALTER TABLE users_data
ALTER COLUMN dti FLOAT


UPDATE users_data
SET yearly_income = SUBSTRING(yearly_income, 2, LEN('yearly_income')-1); 


UPDATE users_data
SET total_debt = SUBSTRING(total_debt, 2, LEN(total_debt)-1)

UPDATE users_data
SET per_capita_income = SUBSTRING(per_capita_income, 2, LEN(per_capita_income)-1)


UPDATE users_data
SET income_cat = CASE 
            WHEN yearly_income  >1 AND yearly_income <=24000 THEN 'low'
            WHEN yearly_income >=24001 AND yearly_income <=80000 THEN 'mid'
            WHEN yearly_income >=80001 AND yearly_income <=120000 THEN 'upper_mid'
            ELSE 'high'
            END

UPDATE users_data
SET debt_cat = CASE 
            WHEN total_debt  >1 AND total_debt <=24000 THEN 'low'
            WHEN total_debt >=24001 AND total_debt <=80000 THEN 'mid'
            WHEN total_debt >=80001 AND total_debt <=120000 THEN 'upper_mid'
            ELSE 'high'
            END

UPDATE users_data
SET credit_score_cat = CASE
                WHEN  credit_score >400 AND credit_score <=580 THEN 'low'
                WHEN  credit_score >580 AND credit_score <=670 THEN 'mid'
                WHEN credit_score >670 THEN 'high'
                END
ALTER TABLE users_data
ADD age_cat VARCHAR (10)

ALTER TABLE users_data
ALTER COLUMN retirement_age INT

ALTER TABLE users_data
ADD time_to_retire INT


ALTER TABLE users_data
ADD lifestage VARCHAR (20)

ALTER TABLE users_data
ALTER COLUMN age_cat VARCHAR (20)

UPDATE users_data
SET age_cat = CASE      
                    WHEN current_age >=15 AND current_age <=24 THEN 'young_adult'
                    WHEN current_age >24 AND current_age <=34 THEN 'early_adult'
                    WHEN current_age >34 AND current_age <= 44 THEN 'mid_adult'
                    WHEN current_age >44 AND current_age <= 54 THEN 'late_adult'
                    ELSE 'elderly'
                    END
UPDATE users_data
SET dti =  CAST(CAST(total_debt AS INT) AS FLOAT)/cast(CAST(yearly_income AS INT) as FLOAT) * 100
            
UPDATE users_data
SET dti = ROUND(dti, 3)

SELECT total_debt, yearly_income, CAST(total_debt AS FLOAT)/CAST(yearly_income AS FLOAT) * 100 AS dti
FROM users_data

ALTER TABLE users_data
DROP COLUMN dtii

ALTER TABLE users_data
ALTER COLUMN current_age INT

SELECT MIN(dti), MAX(dti)
FROM users_data

UPDATE users_data 
SET time_to_retire = retirement_age - current_age

UPDATE users_data
SET lifestage = CASE      
                    WHEN time_to_retire <=0 THEN 'retired'
                    WHEN time_to_retire >0 AND time_to_retire <10 THEN 'close_to_retire'
                    WHEN time_to_retire >=10 AND time_to_retire <=20 THEN 'mid_career'
                    WHEN time_to_retire >20 THEN 'early_career'
                    END

SELECT DISTINCT current_age
FROM users_data
ORDER BY 1 ASC

SELECT min(current_age), max(current_age)
FROM users_data

SELECT min(retirement_age), max(retirement_age)
FROM users_data

SELECT min(time_to_retire), max(time_to_retire)
FROM users_data


--CARDS TABLE

ALTER TABLE cards_data
ALTER COLUMN credit_limit INT

ALTER TABLE cards_data
ALTER COLUMN cvv INT

ALTER TABLE cards_data
ALTER COLUMN num_cards_issued INT


UPDATE cards_data
SET credit_limit = SUBSTRING(credit_limit, 2, LEN(credit_limit)-1)

SELECT * FROM  cards_data

ALTER TABLE cards_data
ADD exp_month VARCHAR (20),
    exp_year INT,
    acc_open_month VARCHAR (20),
    acc_open_year INT

    UPDATE cards_data
    SET exp_month = LEFT(expires, 3),
        exp_year = RIGHT(expires, 2),
        acc_open_month = LEFT(acct_open_date, 3),
        acc_open_year = RIGHT(acct_open_date, 2)


UPDATE cards_data 
SET exp_year = CASE 
                    WHEN exp_year <30 THEN exp_year + 2000
                    ELSE exp_year + 1900
                    END 

UPDATE cards_data 
SET acc_open_year = CASE 
                    WHEN acc_open_year<30 THEN acc_open_year + 2000
                    ELSE acc_open_year + 1900
                    END 

--Transaction data

ALTER TABLE transactions_data
ADD transact_time VARCHAR (10),
    transact_date VARCHAR (10),
    transact_month VARCHAR (20),
    transact_year INT

ALTER TABLE transactions_data
ALTER COLUMN amount FLOAT

UPDATE transactions_data
SET transact_time =TRIM(RIGHT([date], 5))

UPDATE transactions_data
SET    transact_date = LEFT([date], CHARINDEX(' ', [date])-1)

UPDATE transactions_data
SET transact_month = MONTH(transact_date),
    transact_year = YEAR(transact_date)

SELECT * FROM transactions_data


----We stasrt by exploring our columns

--PART B CUSTOMER SEGMENTATION ANALYSIS

--customer distribution across groups
SELECT gender, COUNT(id) AS gen_count
FROM users_data
GROUP BY gender

--age distribution of customers
SELECT age_cat, COUNT(id) AS age_dist
FROM users_data
GROUP BY age_cat
ORDER BY 2 DESC

--distribution across income group
SELECT income_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY income_cat
ORDER BY 2 DESC

--distribution across debt categories

SELECT debt_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY debt_cat
ORDER BY 2 DESC

--distribtuion across credit score category

SELECT credit_score_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY credit_score_cat
ORDER BY 2 DESC

--distribution across lifestage
SELECT lifestage, COUNT(id) AS cus_count
FROM users_data
GROUP BY lifestage
ORDER BY 2 DESC

--distribution across number of credit cards

SELECT num_credit_cards, COUNT(id) AS cus_count
FROM users_data
GROUP BY num_credit_cards
ORDER BY 2 DESC

--dist across number of cards and age_cat

SELECT age_cat, num_credit_cards, COUNT(id) AS cus_count
FROM users_data
GROUP BY age_cat, num_credit_cards
ORDER BY 1, 3 DESC

SELECT gender, num_credit_cards, COUNT(id) AS cus_count
FROM users_data
GROUP BY gender, num_credit_cards
ORDER BY 1, 3 DESC

SELECT age_cat, gender, COUNT(id) AS cus_count
FROM users_data
GROUP BY age_cat, gender
ORDER BY 1, 3 DESC

SELECT age_cat, credit_score_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY age_cat, credit_score_cat
ORDER BY 1, 3 DESC

SELECT gender, credit_score_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY gender, credit_score_cat
ORDER BY 1, 3 DESC


SELECT age_cat, income_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY age_cat, income_cat
ORDER BY 1, 3 DESC

SELECT gender, income_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY gender, income_cat
ORDER BY 1, 3 DESC

SELECT age_cat, debt_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY age_cat, debt_cat
ORDER BY 1, 3 DESC

SELECT gender, debt_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY gender, debt_cat
ORDER BY 1, 3 DESC


SELECT income_cat, debt_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY income_cat, debt_cat
ORDER BY 1, 3 DESC

SELECT lifestage, debt_cat, COUNT(id)
FROM users_data
GROUP BY lifestage, debt_cat
ORDER BY 1


--Transaction tbl

--total transactions

SELECT COUNT(id) AS tot_transact, ROUND(SUM(amount), 2) AS tot_rev
FROM transactions_data

--tot_transaction by clients

SELECT client_id, COUNT(id) AS tot_transact
FROM transactions_data
GROUP BY client_id
ORDER BY tot_transact DESC

--tot amount spent by clients 
SELECT client_id, ROUND(SUM(amount), 2) AS tot_spent
FROM transactions_data
GROUP BY client_id
ORDER BY 2 DESC

--tot_transactions by channel

SELECT use_chip, COUNT(id) AS tot_transact, ROUND(SUM(amount), 2) AS rev_gen_channel
FROM transactions_data
GROUP BY use_chip
ORDER BY 2 DESC

--channel use by clients
SELECT use_chip, COUNT(DISTINCT client_id) AS cus_count
FROM transactions_data
GROUP BY use_chip
ORDER BY 2 DESC

---merchant

SELECT merchant_id, COUNT(id) AS tot_transact
FROM transactions_data
GROUP BY merchant_id
ORDER BY 2 DESC

SELECT merchant_id, COUNT(DISTINCT client_id) AS tot_cus
FROM transactions_data
GROUP BY merchant_id
ORDER BY 2 DESC

SELECT merchant_id, ROUND(SUM(amount), 2) AS rev_gen
FROM transactions_data
GROUP BY merchant_id
ORDER BY 2 DESC

SELECT COUNT(DISTINCT merchant_id) AS tot_mer
FROM transactions_data
---we shall come back to thie (merchants without city and state values )

SELECT * 
FROM transactions_data
WHERE merchant_id IN (
        SELECT DISTINCT merchant_id 
        FROM transactions_data
        WHERE merchant_city = '' OR merchant_state = ''
        ) 

--transactions and rev by city
SELECT merchant_city, COUNT(id), ROUND(SUM(amount), 2) AS rev_gen
FROM transactions_data
GROUP BY merchant_city
ORDER BY 2 DESC

--transactions and rev by state
SELECT merchant_state, COUNT(id), ROUND(SUM(amount), 2) AS rev_gen
FROM transactions_data
GROUP BY merchant_state
ORDER BY 2 DESC

--transactions by purchases/spendings

SELECT mcc, COUNT(id) AS tot_tsact, ROUND(SUM(amount), 2) AS tot_spent
FROM transactions_data
GROUP BY mcc
ORDER BY 2 DESC

--errors

SELECT COUNT(id) AS tot_err
FROM transactions_data
WHERE   errors != ''

--lets tak a quick look at error transactions
SELECT *
FROM transactions_data
WHERE   errors != ''


--error categories

SELECT errors, COUNT(id) AS err_count
FROM transactions_data
WHERE errors !=''
GROUP BY errors
ORDER BY 2 DESC

---testing to figure out fraud...nothing concrete yet
SELECT id, errors, COUNT(id) AS err_count
FROM transactions_data
WHERE errors !=''
GROUP BY id, errors
ORDER BY id DESC

---transactions by month and year

SELECT transact_month, COUNT(id) AS tot_tsact, ROUND(SUM(amount), 2) AS tot_rev
FROM transactions_data
GROUP BY transact_month 
ORDER BY 1 ASC

SELECT transact_year, COUNT(id) AS tot_tsact, ROUND(SUM(amount), 2) AS tot_rev
FROM transactions_data
GROUP BY transact_year
ORDER BY 1 ASC


----- cards_data

SELECT card_brand, COUNT(id) AS card_count, COUNT(DISTINCT client_id) AS cus_count
FROM cards_data
GROUP BY card_brand

SELECT card_type, COUNT(id) AS card_count, COUNT(DISTINCT client_id) AS cus_count
FROM cards_data
GROUP BY card_type

SELECT has_chip, COUNT(id) AS card_count, COUNT(DISTINCT client_id) AS cus_count
FROM cards_data
GROUP BY has_chip

----card issue across month and years
SELECT acc_open_month, COUNT(DISTINCT id) AS acc_open_cnt, COUNT(DISTINCT client_id) AS cus_count
FROM cards_data
GROUP BY acc_open_month


SELECT acc_open_year, COUNT(DISTINCT id) AS acc_open_cnt, COUNT(DISTINCT client_id) AS cus_count, 
        SUM(num_cards_issued)
FROM cards_data
GROUP BY acc_open_year

--total_cards issued
SELECT SUM(num_cards_issued)
FROM cards_data

---card expiration

SELECT exp_year, COUNT(DISTINCT id) AS acc_open_cnt, COUNT(DISTINCT client_id) AS cus_count, 
        SUM(num_cards_issued)
FROM cards_data
GROUP BY exp_year

SELECT exp_month, COUNT(DISTINCT id) AS acc_open_cnt, COUNT(DISTINCT client_id) AS cus_count, 
        SUM(num_cards_issued)
FROM cards_data
GROUP BY exp_month


/*
PART B 2
Now we proceed to analyzing our data looking into the following:

Revenue analysis

total revenue and change over the years (we left out
monthly breadown, because we will utilize the time intelligence 
capabilities of power BI during visualization)


Customer Retention and Churn analysis

Customer Liifetime Value (AOV etc)

Spending Analysis

Top spenders and location

The above will be carried out and measured across the folowing
age-group, income_cat, location, lifestage

predictive analysis to identify early warnings of churn


PART B 3 
Transaction analysis RFM across all customer groups

Channel analysis

mom transact and rev generation

error analysis

merchant analysis (top earners, )

PART B 4

Risk analysis (identify customers with high financial risk, utilize debt, card limit, income-cat, credit score,
total debt across all customer segments)
predict risk of default

Fraud detection (indicators for fraudulent transactions etc)
identify high value transactions for potential fraud

Indepth spending patterns. regions prone to failed transactions and fraud



*/
--Customer segmentation analysis 

SELECT client_id, COUNT(card_id) AS card_use_count, COUNT(client_id) AS transact_count
FROM transactions_data
GROUP BY client_id
ORDER  BY 2


---total transactions
---average order value

--average spending
--RFM
---spending analytics
---Channel used
--customer churn and retention analytics

---errors analytic, and transaction risks

----merchant analytics
---top earning merchants, location etc


---REVENUE ANALYSIS
---total revenue and change over the years

SELECT * FROM transactions_data

SELECT transact_year, ROUND(SUM(amount),2) AS tot_rev
FROM transactions_data
GROUP BY transact_year
ORDER BY 1 ASC

---change in revenue generated
SELECT transact_year, ROUND(SUM(amount),2) AS tot_rev, 
        LAG(ROUND(SUM(amount),2), 1) OVER (ORDER BY transact_year) AS prev_year_rev,
       ROUND(SUM(amount) - LAG(SUM(amount), 1) OVER (ORDER BY transact_year),2) AS yoy_diff,
       ROUND(((SUM(amount) - LAG(SUM(amount), 1) OVER (ORDER BY transact_year))/LAG(SUM(amount), 1) OVER (ORDER BY transact_year)
       )*100,2) AS yoy_percent_diff
FROM transactions_data
GROUP BY transact_year
ORDER BY 1 ASC

--now we look at revenue across customer segments
--revenue across gender
SELECT t.transact_year, u.gender, ROUND(SUM(t.amount),2) AS tot_rev,
        LAG(ROUND(SUM(t.amount),2), 1) OVER (PARTITION BY u.gender ORDER BY t.transact_year) AS prev_year_rev,
       ROUND(SUM(t.amount) - LAG(SUM(t.amount), 1) OVER (PARTITION BY u.gender ORDER BY t.transact_year),2) AS yoy_diff,
       ROUND(((SUM(t.amount) - LAG(SUM(t.amount), 1) OVER (PARTITION BY u.gender ORDER BY t.transact_year))/LAG(SUM(t.amount), 1) 
       OVER (PARTITION BY u.gender ORDER BY transact_year)
       )*100,2) AS yoy_percent_diff
FROM transactions_data t
JOIN users_data u
ON t.client_id = u.id
GROUP BY t.transact_year, u.gender
ORDER BY 2, 1 ASC

---revenue across age groups
SELECT t.transact_year, u.age_cat, ROUND(SUM(t.amount),2) AS tot_rev,
        LAG(ROUND(SUM(t.amount),2), 1) OVER (PARTITION BY u.age_cat ORDER BY t.transact_year) AS prev_year_rev,
       ROUND(SUM(t.amount) - LAG(SUM(t.amount), 1) OVER (PARTITION BY u.age_cat ORDER BY t.transact_year),2) AS yoy_diff,
       ROUND(((SUM(t.amount) - LAG(SUM(t.amount), 1) OVER (PARTITION BY u.age_cat ORDER BY t.transact_year))/LAG(SUM(t.amount), 1) 
       OVER (PARTITION BY u.age_cat ORDER BY transact_year)
       )*100,2) AS yoy_percent_diff
FROM transactions_data t
JOIN users_data u
ON t.client_id = u.id
GROUP BY t.transact_year, u.age_cat
ORDER BY 2, 1 ASC

---revenue across income category
SELECT t.transact_year, u.income_cat, ROUND(SUM(t.amount),2) AS tot_rev,
        LAG(ROUND(SUM(t.amount),2), 1) OVER (PARTITION BY u.income_cat ORDER BY t.transact_year) AS prev_year_rev,
       ROUND(SUM(t.amount) - LAG(SUM(t.amount), 1) OVER (PARTITION BY u.income_cat ORDER BY t.transact_year),2) AS yoy_diff,
       ROUND(((SUM(t.amount) - LAG(SUM(t.amount), 1) OVER (PARTITION BY u.income_cat ORDER BY t.transact_year))/LAG(SUM(t.amount), 1) 
       OVER (PARTITION BY u.income_cat ORDER BY transact_year)
       )*100,2) AS yoy_percent_diff
FROM transactions_data t
JOIN users_data u
ON t.client_id = u.id
GROUP BY t.transact_year, u.income_cat
ORDER BY 2, 1 ASC


--revenue across lifestage

SELECT t.transact_year, u.lifestage, ROUND(SUM(t.amount),2) AS tot_rev,
        LAG(ROUND(SUM(t.amount),2), 1) OVER (PARTITION BY u.lifestage ORDER BY t.transact_year) AS prev_year_rev,
       ROUND(SUM(t.amount) - LAG(SUM(t.amount), 1) OVER (PARTITION BY u.lifestage ORDER BY t.transact_year),2) AS yoy_diff,
       ROUND(((SUM(t.amount) - LAG(SUM(t.amount), 1) OVER (PARTITION BY u.lifestage ORDER BY t.transact_year))/LAG(SUM(t.amount), 1) 
       OVER (PARTITION BY u.lifestage ORDER BY transact_year)
       )*100,2) AS yoy_percent_diff
FROM transactions_data t
JOIN users_data u
ON t.client_id = u.id
GROUP BY t.transact_year, u.lifestage
ORDER BY 2, 1 ASC


---Customer Retention and Churn analysis

---total number of active customers

SELECT COUNT(*) AS act_cus
FROM (
        SELECT u.id, MIN(t.transact_date) AS first_transact, MAX(t.transact_date) AS last_tsact, COUNT(t.id) AS pur_count
        FROM transactions_data t
        JOIN users_data u
        ON u.id = t.client_id
        GROUP BY u.id
        HAVING COUNT(t.id) >0) AS sub;

--total active and inactive customers
with act_cus_cte 
AS
(
        SELECT COUNT(*) AS act_cus
        FROM(
                SELECT u.id, MIN(t.transact_date) AS first_transact, MAX(t.transact_date) AS last_tsact, COUNT(t.id) AS pur_count
                FROM transactions_data t
                JOIN users_data u
                ON u.id = t.client_id
                GROUP BY u.id
                HAVING COUNT(t.id) >0
        )AS sub
), inact_cus
AS
(
        SELECT COUNT(*) AS inact_cus
        FROM(
                SELECT u.id, MIN(t.transact_date) AS first_transact, MAX(t.transact_date) AS last_tsact, COUNT(t.id) AS pur_count
                FROM transactions_data t
                RIGHT JOIN users_data u
                ON u.id = t.client_id
                WHERE t.client_id IS NULL
                GROUP BY u.id
        ) AS sub2
), tot_cus
AS
                (
                        SELECT COUNT(*) AS tot_cus
                        FROM users_data
                )
        SELECT ac.act_cus, ia.inact_cus, tc.tot_cus
        FROM act_cus_cte ac
        CROSS JOIN inact_cus ia
        CROSS JOIN tot_cus tc;


---percentage of spendings and debt they represent

---total spendings of active customers

with act_cus_cte 
AS
(       SELECT ROUND(SUM(tot_spending),2) AS tot_ac_spend
        FROM(
                SELECT u.id, MIN(t.transact_date) AS first_transact, MAX(t.transact_date) AS last_tsact, COUNT(t.id) AS pur_count
                        ,SUM(t.amount) AS tot_spending
                FROM transactions_data t
                JOIN users_data u
                ON u.id = t.client_id
                GROUP BY u.id
                HAVING COUNT(t.id) >0
        ) AS sub
), inact_cus
AS
(
        SELECT ROUND(SUM(tot_spending),2) AS tot_inac_spend
        FROM(
                SELECT u.id, MIN(t.transact_date) AS first_transact, MAX(t.transact_date) AS last_tsact, COUNT(t.id) AS pur_count
                        ,SUM(t.amount) AS tot_spending
                FROM transactions_data t
                RIGHT JOIN users_data u
                ON u.id = t.client_id
                WHERE t.client_id IS NULL
                GROUP BY u.id
        ) AS subb
        
), tot_cus
AS
                (
                        SELECT ROUND(SUM(amount),2) AS tot_spent
                        FROM transactions_data
                )
        SELECT ac.tot_ac_spend, ia.tot_inac_spend, tc.tot_spent
        FROM act_cus_cte ac
        CROSS JOIN inact_cus ia
        CROSS JOIN tot_cus tc;


---total debt of active and inactive customers

with act_cus_debt 
AS
(       SELECT SUM(total_debt) AS tot_ac_debt
        FROM users_data
        WHERE id IN (
                        SELECT u.id
                        FROM transactions_data t
                        JOIN users_data u
                        ON u.id = t.client_id
	                GROUP BY u.id
	                HAVING COUNT(t.id) > 0
) 
), inact_cus_debt
AS
(
        SELECT SUM(total_debt) AS tot_inac_debt
        FROM users_data
        WHERE id IN (
                        SELECT u.id
                        FROM transactions_data t
                        RIGHT JOIN users_data u
                        ON u.id = t.client_id
	                WHERE t.client_id IS NULL
                        GROUP BY u.id
)
        
), tot_cus
AS
                (
                        SELECT ROUND(SUM(total_debt),2) AS tot_debt
                        FROM users_data
                )
        SELECT ac.tot_ac_debt, ia.tot_inac_debt, tc.tot_debt, 
                ROUND(CAST(ac.tot_ac_debt AS FLOAT) / CAST(tc.tot_debt AS FLOAT) *100,2) AS act_debt_per,
                ROUND(CAST(ia.tot_inac_debt AS FLOAT) / CAST(tc.tot_debt AS FLOAT) *100,2) AS inact_debt_per
        FROM act_cus_debt ac
        CROSS JOIN inact_cus_debt ia
        CROSS JOIN tot_cus tc;


/*Churn Rate: Calculate the overall churn rate over a specific period.

*/
---in the instance of our analysis, churned customers are those who had no transaction during the transaction cycle in question
---- overall churn rate over the years

SELECT c.client_id, MAX(t.transact_date) 
FROM transactions_data t
RIGHT JOIN cards_data c
ON c.client_ID = t.client_id
GROUP BY c.client_id
HAVING  MAX(t.transact_date) IS NULL


----customer acquisition across years
SELECT acc_open_year, COUNT(client_id) AS tot_cus_acq
FROM cards_data
GROUP BY acc_open_year
ORDER BY 1


WITH churned_cus
AS
        (
        SELECT c.client_id, 
        MAX(t.transact_date) AS last_pur_date
        FROM transactions_data t
        LEFT JOIN cards_data c
        ON c.client_ID = t.client_id
        GROUP BY c.client_id
        HAVING MAX(t.transact_date) IS NULL OR MAX(t.transact_date) < DATEADD(DAY, 730, CONVERT(DATE, GETDATE()))
        ORDER BY 1 


        ), 
cus_acq
AS
        (
        SELECT acc_open_year AS cohort_year, 
        COUNT(client_id) AS tot_cus_acq
        FROM cards_data
        GROUP BY acc_open_year
       -- ORDER BY 1
        )
                SELECT
                ca.cohort_year,
                ca.tot_cus_acq,
                COALESCE(cc.churned_cus, 0) AS churned_cus,
                ROUND((COALESCE(cc.churned_cus, 0) * 1.0/ca.tot_cus_acq)*100, 2) AS churn_rate
                FROM cus_acq ca
                LEFT JOIN (
                        SELECT
                        c.acc_open_year AS cohort_year,
                        COUNT(cc.client_id) AS churned_cus
                        FROM churned_cus cc
                        JOIN cards_data c
                        ON cc.client_id = c.client_id
                        GROUP BY c.acc_open_year

                )cc ON ca.cohort_year = cc.cohort_year
                ORDER BY ca.cohort_year

--run the above against the various customer segments
SELECT * FROM cards_data
WHERE acc_open_year = 1991

SELECT * FROM transactions_data
WHERE client_id IN (285, 1362, 1692)




---------------------------------------

WITH churned_cus
AS
        (
        SELECT c.client_id, 
        MAX(t.transact_date) AS last_pur_date
        FROM transactions_data t
        LEFT JOIN cards_data c
        ON c.client_ID = t.client_id
        GROUP BY c.client_id
        HAVING MAX(t.transact_date) IS NULL OR MAX(t.transact_date) > DATEADD(DAY, -730, CONVERT(DATE, GETDATE()))
       --- ORDER BY 1 


        ), 
cus_acq
AS
        (
        SELECT acc_open_year AS cohort_year, 
        COUNT(client_id) AS tot_cus_acq
        FROM cards_data
        GROUP BY acc_open_year
       -- ORDER BY 1
        )
                SELECT
                ca.cohort_year,
                ca.tot_cus_acq,
                COALESCE(cc.churned_cus, 0) AS churned_cus,
                ROUND((COALESCE(cc.churned_cus, 0) * 1.0/ca.tot_cus_acq)*100, 2) AS churn_rate
                FROM cus_acq ca
                LEFT JOIN (
                        SELECT
                        c.acc_open_year AS cohort_year,
                        COUNT(cc.client_id) AS churned_cus
                        FROM churned_cus cc
                        JOIN cards_data c
                        ON cc.client_id = c.client_id
                        GROUP BY c.acc_open_year

                )cc ON ca.cohort_year = cc.cohort_year
                ORDER BY ca.cohort_year

--run the above against the various customer segments
SELECT * FROM cards_data
WHERE acc_open_year = 1991

SELECT * FROM transactions_data
WHERE client_id IN (285, 1362, 1692)

---total transactions
---average transact value
with atv
AS
(
        SELECT COUNT(id) AS transact_count, SUM(amount) AS tot_rev
        FROM transactions_data
)
        SELECT ROUND(tot_rev/transact_count *100,2) AS aov
        FROM atv;

---atv over years
with atv_yr
AS
(
        SELECT transact_year,  COUNT(id) AS transact_count, SUM(amount) AS tot_rev
        FROM transactions_data
        GROUP BY transact_year
)
        SELECT transact_year, ROUND(tot_rev/transact_count  *100,2) AS aov
        FROM atv_yr
        ORDER BY 1

---atv across customer groups
--age

WITH atv_age
AS
(
        SELECT u.age_cat AS age_cat, COUNT(t.id) AS transact_count, SUM(t.amount) AS tot_rev
        FROM transactions_data t
        JOIN users_data u
        ON t.client_id = u.id
        GROUP BY u.age_cat
)
        SELECT age_cat, ROUND(tot_rev/transact_count  *100,2) AS aov
        FROM atv_age
        ORDER BY 1

---lifestage

WITH atv_lifestage
AS
(
        SELECT u.lifestage AS lifestage, COUNT(t.id) AS transact_count, SUM(t.amount) AS tot_rev
        FROM transactions_data t
        JOIN users_data u
        ON t.client_id = u.id
        GROUP BY u.lifestage
)
        SELECT lifestage, ROUND(tot_rev/transact_count  *100,2) AS aov
        FROM atv_lifestage
        ORDER BY 1



--average spending
--Recency Frequency Monetary value
SELECT client_id, DATEDIFF(DAY, MIN(transact_date), MAX(transact_date)) AS recency
        ,COUNT(id) AS freq, ROUND(SUM(amount),2) m_val
FROM transactions_data
GROUP BY client_id
ORDER BY client_id

----RFM across customer segments
SELECT u.age_cat, t.client_id, DATEDIFF(DAY, MIN(t.transact_date), MAX(t.transact_date)) AS recency
        ,COUNT(t.id) AS freq, ROUND(SUM(t.amount),2) m_val
FROM transactions_data t
JOIN  users_data u
ON t.client_id = u.id
GROUP BY u.age_cat, t.client_id
ORDER BY u.age_cat, t.client_id

SELECT 
---spending analytics
---Channel used