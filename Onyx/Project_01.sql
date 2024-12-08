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
            WHEN yearly_income >=80001 AND yearly_income <=120000 THEN 'high_mid'
            ELSE 'high'
            END

UPDATE users_data
SET debt_cat = CASE 
            WHEN total_debt  >1 AND total_debt <=24000 THEN 'low'
            WHEN total_debt >=24001 AND total_debt <=80000 THEN 'mid'
            WHEN total_debt >=80001 AND total_debt <=120000 THEN 'high_mid'
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



UPDATE cards_data
SET credit_limit = SUBSTRING(credit_limit, 2, LEN(credit_limit)-1)

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
--ORDER BY 1 ASC

--PART B CUSTOMER SEGMENTATION ANALYSIS

--customer distribution across groups
SELECT gender, COUNT(id) AS gen_count
FROM users_data
GROUP BY gender

SELECT age_cat, COUNT(id) AS age_dist
FROM users_data
GROUP BY age_cat
ORDER BY 2 DESC

SELECT income_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY income_cat
ORDER BY 2 DESC

SELECT * FROM users_data

SELECT debt_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY debt_cat
ORDER BY 2 DESC

SELECT credit_score_cat, COUNT(id) AS cus_count
FROM users_data
GROUP BY credit_score_cat
ORDER BY 2 DESC

SELECT lifestage, COUNT(id) AS cus_count
FROM users_data
GROUP BY lifestage
ORDER BY 2 DESC