USE Onyx
GO

SELECT * FROM Onyx_Data_Email_Dim_table;

SELECT * FROM Onyx_Data_Email_Fact_table

--first we look thorugh our data, explore columns and clean where necessary --

--fact_table, we start by correcting column names

EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[Email id]', 'Email_id', 'COLUMN'
EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[From Name]', 'Sender_name', 'COLUMN'
EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[From seniority]', 'Sender_Cadre', 'COLUMN'
EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[From Department]', 'Sender_Dept', 'COLUMN'
EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[To Name]', 'Rec_name', 'COLUMN'
EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[To seniority]', 'Rec_Cadre', 'COLUMN'
EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[To Department]', 'Rec_Dept', 'COLUMN'
EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[Email topic]', 'Topic', 'COLUMN'
EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[Is opened?]', 'Status', 'COLUMN'
EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[Within work hours]', 'Within_work_hrs', 'COLUMN'
EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[Within workdays]', 'Within_work_days', 'COLUMN'



--checking individual colums to identify anormalies

SELECT DISTINCT Sender_name, COUNT(Sender_name) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Sender_name
ORDER BY 2 ASC

SELECT DISTINCT Sender_Cadre, COUNT(Sender_Cadre) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Sender_Cadre
ORDER BY 2 ASC

SELECT DISTINCT Sender_Dept, COUNT(Sender_Dept) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Sender_Dept
ORDER BY 2 ASC

SELECT DISTINCT Rec_name, COUNT(Rec_name) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Rec_name
ORDER BY 2 ASC

SELECT DISTINCT Rec_Cadre, COUNT(Rec_Cadre) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Rec_Cadre
ORDER BY 2 ASC


SELECT DISTINCT Rec_dept, COUNT(Rec_dept) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Rec_dept
ORDER BY 2 ASC

SELECT DISTINCT Topic, COUNT(Topic) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Topic
ORDER BY 2 ASC

SELECT DISTINCT [Date], COUNT([Date]) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY [Date]
ORDER BY 2 ASC


SELECT DISTINCT Sentiment, COUNT(Sentiment) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Sentiment
ORDER BY 2 ASC

SELECT DISTINCT [Status], COUNT([Status]) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY [Status]
ORDER BY 2 ASC

SELECT DISTINCT Device, COUNT(Device) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Device
ORDER BY 2 ASC

SELECT DISTINCT [Within_work_hrs], COUNT([Within_work_hrs]) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Within_work_hrs
ORDER BY 2 ASC


SELECT DISTINCT [Within_work_days], COUNT([Within_work_days]) AS emp_count
FROM Onyx_Data_Email_Fact_table
GROUP BY Within_work_days
ORDER BY 2 ASC
--there are no null values in our dataset

SELECT * FROM Onyx_Data_Email_Fact_table

SELECT *
FROM (
		SELECT *, RANK() OVER(PARTITION BY Email_id, Sender_name, Sender_dept, Rec_name, Rec_Dept, Topic, [Date] ORDER BY Email_id) AS Rank_
		FROM Onyx_Data_Email_Fact_table
	) rt
WHERE rt.Rank_ >1

---correcting date column

EXEC SP_RENAME'Onyx_Data_Email_Fact_table.[Date]','Msg_date', 'COLUMN'

SELECT Msg_date, REPLACE(Msg_date, '/', '-') 
FROM Onyx_Data_Email_Fact_table

UPDATE Onyx_Data_Email_Fact_table
SET Msg_date = REPLACE(Msg_date, '/', '-') 

SELECT Msg_date, CAST(Msg_date AS DATE) 
FROM Onyx_Data_Email_Fact_table

UPDATE Onyx_Data_Email_Fact_table
SET Msg_date = CAST(Msg_date AS DATE)


SELECT * 
INTO Onyx_Fact_01
FROM Onyx_Data_Email_Fact_table

--next we expand the date columns to enable us drill down datewise

ALTER TABLE Onyx_Data_Email_Fact_table
ADD Msg_month VARCHAR (10)
	,Msg_year VARCHAR (10)

UPDATE Onyx_Data_Email_Fact_table
SET Msg_month = MONTH(Msg_date)
	,Msg_year = YEAR(Msg_date)

SELECT Msg_year 
FROM Onyx_Data_Email_Fact_table
GROUP BY Msg_year

SELECT Msg_month
FROM Onyx_Data_Email_Fact_table
GROUP BY Msg_month

ALTER TABLE Onyx_Data_Email_Fact_table
ADD Msg_day VARCHAR (10)

UPDATE Onyx_Data_Email_Fact_table
SET Msg_day = DAY(Msg_date)

SELECT Msg_day, COUNT(Msg_day)
FROM Onyx_Data_Email_Fact_table
GROUP BY Msg_day
ORDER BY 2 DESC

SELECT s.Sender_name, r.Rec_Name,  COUNT(*) AS tot_msg
FROM Onyx_Data_Email_Fact_table s
JOIN Onyx_Data_Email_Fact_table r
ON s.Sender_name = r.Sender_name
GROUP BY s.Sender_name, r.Rec_Name
ORDER BY 1, 3 DESC





