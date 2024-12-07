USE Project_01;

SELECT * FROM cards_data
SELECT * FROM transactions_data
SELECT * FROM mcc_codes
SELECT * from users_data


--PART A CUSTOMER SEGMENTATION ANALYSIS

--customer distribution across groups

SELECT MAX(yearly_income) AS max_year, MIN(yearly_income) AS min_income,
        MAX(total_debt) AS max_debt, MIN(total_debt) AS min_debt,
        MAX(credit_score) AS max_cs, MIN(credit_score) AS min_cs
FROM users_data


ALTER TABLE users_data
ADD income_cat VARCHAR (10)

ALTER TABLE users_data
ADD debt_cat VARCHAR (10),
    credit_score_cat VARCHAR (10)

UPDATE users_data
SET yearly_income = SUBSTRING(yearly_income, 2, LEN('yearly_income')-1); 


UPDATE users_data
SET total_debt = SUBSTRING(total_debt, 2, LEN(total_debt)-1)

UPDATE users_data
SET income_cat = CASE 
            WHEN yearly_income  >1 AND yearly_income <=24000 THEN 'low'
            WHEN yearly_income >=24001 AND yearly_income <=80000 THEN 'mid'
            WHEN yearly_income >=80001 AND yearly_income <=120000 THEN 'high_mid'
            ELSE 'high'
            END






