USE Portfolio_Projects_01
GO


---Total Missions Count
SELECT COUNT(Mission) AS Total_Mission_Count, CASE WHEN MissionStatus = 'Success' THEN (SELECT DISTINCT COUNT(MissionStatus)) END AS Successful,
						CASE WHEN MissionStatus = 'Failure' THEN (SELECT DISTINCT COUNT(MissionStatus)) END AS Failed,
						CASE WHEN MissionStatus = 'Partial Failure' THEN (SELECT DISTINCT COUNT(MissionStatus)) END AS Partial_Failure,
						CASE WHEN MissionStatus = 'Prelaunch Failure' THEN (SELECT DISTINCT COUNT(MissionStatus)) END AS Prelaunch_Failure
FROM space_missions
GROUP BY MissionStatus
ORDER BY 1 DESC

SELECT COUNT(Mission) AS Total_Mission_Count, CASE WHEN MissionStatus = 'Success' THEN (SELECT DISTINCT COUNT(MissionStatus)) END AS Successful,
						CASE WHEN MissionStatus = 'Failure' THEN (SELECT DISTINCT COUNT(MissionStatus)) END AS Failed,
						CASE WHEN MissionStatus = 'Partial Failure' THEN (SELECT DISTINCT COUNT(MissionStatus)) END AS Partial_Failure,
						CASE WHEN MissionStatus = 'Prelaunch Failure' THEN (SELECT DISTINCT COUNT(MissionStatus)) END AS Prelaunch_Failure
FROM space_missions
GROUP BY MissionStatus
ORDER BY 1 DESC

----Total space missions by year

SELECT DISTINCT Launch_year, COUNT(Mission)
FROM space_missions
GROUP BY Launch_Year
ORDER BY 2 DESC

---Top 10 missions by year and country

SELECT TOP (10) Launch_Year, COUNT(Mission) as Yearly_Mission_Count
FROM space_missions
GROUP BY Launch_Year, Country
ORDER BY 2 DESC

----Total missions by month

SELECT DISTINCT  Launch_Month, COUNT(Mission)
FROM space_missions
GROUP BY Country, Launch_Year, Launch_Month
ORDER BY 2 DESC

----Total Mission count by countries

SELECT DISTINCT Country, COUNT(Mission) as Mission_Count
FROM space_missions
GROUP BY Country
ORDER BY 2 DESC


----Total mission count by company in each country

SELECT DISTINCT Company, COUNT(Mission) as Mission_Count
FROM space_missions
GROUP BY  Company
ORDER BY 2 DESC

----missions by company

SELECT DISTINCT Mission, Company, Country
FROM space_missions
GROUP BY Mission, Company, Country
ORDER BY 2,3



----Total number of company that took part in space missions by country
SELECT DISTINCT COUNT(Company)
FROM space_missions
---GROUP BY Company


----Company with heighest mission count

SELECT DISTINCT Company, COUNT(MISSION) AS Mission_Count
FROM space_missions
GROUP BY Company
ORDER BY 2 DESC

----Overall Mission status count
SELECT DISTINCT MissionStatus, COUNT(MissionStatus)
FROM space_missions
GROUP BY MissionStatus;

---Mission Status Count and rate by Country

WITH Space_CTE(MissionStatus, Status_Count)  
				AS ( 
							SELECT MissionStatus, COUNT(MissionStatus) as Status_Count
							FROM space_missions
							---WHERE Country LIKE 'USA'
							GROUP BY MissionStatus
					)
SELECT MissionStatus,  Status_Count, Status_Count*100/(select sum(cast(Status_Count as float))from Space_CTE) as Mission_Outcome_Rate
FROM Space_CTE




-----Alternative Syntax

SELECT  MissionStatus, COUNT(MissionStatus) as Mission_Outcome_Count,
       COUNT(MissionStatus)*100/(select Count(MissionStatus)from space_missions) as Mission_Outcome_Percent
FROM space_missions
--WHERE Country LIKE 'USA'
GROUP BY MissionStatus

-------No of successful Missions grouped by country and company

SELECT Country, COUNT(MissionStatus) as Outcome_Count
			,COUNT(MissionStatus)*100/(select Count(MissionStatus)from space_missions) as Mission_Outcome_Percent
FROM space_missions
WHERE MissionStatus LIKE 'Success'
GROUP BY Country, MissionStatus
ORDER BY 2 DESC

-----Launch_Site by countries
SELECT DISTINCT Launch_Site, COUNT(Launch_Site)
FROM space_missions
WHERE Country = 'USA'
GROUP BY Launch_Site

---Launch site count by countries
SELECT DISTINCT Country, COUNT(Launch_Site) AS No_of_Launch_Site
FROM  space_missions
GROUP BY Country
ORDER BY 2 DESC


select* from space_missions
where country = 'USA'



select [Amount_Spent($)]
from space_missions
where [Amount_Spent($)] is not null


WITH Space_CTE(MissionStatus, Status_Count)  
				AS ( 
							SELECT MissionStatus, COUNT(MissionStatus) as Status_Count
							FROM space_missions
							WHERE Country LIKE 'USA'
							GROUP BY MissionStatus
					)
SELECT MissionStatus,  Status_Count, Status_Count*100/(select sum(Status_Count)from Space_CTE) as Mission_Outcome_Rate
FROM Space_CTE

CREATE TABLE #Temp_Space_Missions(

MissionStatus VARCHAR (50),
Status_Count INT,
Mission_Outcome_Rate DECIMAL

)
INSERT INTO #Temp_Space_Missions 
SELECT MissionStatus, COUNT(MissionStatus) as Status_Count
							FROM space_missions
							--WHERE Country LIKE 'USA'
							GROUP BY MissionStatus

ALTER TABLE #Temp_Space_Missions
ADD  Mission_Outcome_Rate decimal

SELECT * FROM #Temp_Space_Missions 

SELECT MissionStatus, Status_Count, Status_Count *100/ ()  as Outcome_Percent
FROM #Temp_Space_Missions 
GROUP BY MissionStatus, Status_Count


INSERT INTO #Temp_Space_Missions
SELECT  MissionStatus, COUNT(MissionStatus) as Mission_Outcome_Count,
       COUNT(MissionStatus)*100/(select Count(MissionStatus)from space_missions) as Mission_Outcome_Percent
FROM space_missions
GROUP BY MissionStatus

DROP TABLE IF EXISTS #Temp_Space_Missions 
