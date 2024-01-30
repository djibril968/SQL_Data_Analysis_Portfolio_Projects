USE WOLT


ALTER TABLE orders_autumn_2020
ADD delivery_hour INT


UPDATE orders_autumn_2020
SET delivery_hour = LEFT(delivery_time, 2)

---KPIs

/*The aim of our task is to develop a predictive model to help accurately predict product delivery under different weather conditions. Firstly we have to explore
and visualize our data
*/
--total and average number of deliveries
WITH tot_del_cte
AS
(
	SELECT delivery_date, Delivery_hour, COUNT(*) AS tot_delivery
	FROM orders_autumn_2020
	GROUP BY delivery_date, Delivery_hour
)
	SELECT delivery_date, delivery_hour,	
			SUM(tot_delivery) OVER (ORDER BY delivery_date) AS tot_delivery
			,AVG(tot_delivery) OVER (ORDER BY delivery_date) AS avg_daily_delivery			
	FROM tot_del_cte
	GROUP BY delivery_date, delivery_hour, tot_delivery
	ORDER BY Delivery_date, delivery_hour 
	

---total and average number of items delivered

SELECT delivery_date, delivery_hour
		,SUM(item_count) AS tot_item_delivered
		,AVG(item_count) AS avg_item_delivered
FROM orders_autumn_2020
GROUP BY delivery_date, delivery_hour
ORDER BY delivery_date, delivery_hour

---total and average esimated delivery time vs actual_delivery_time

SELECT delivery_date, delivery_hour
		,SUM(estimated_delivery_minutes) AS tot_est_del
		,AVG(estimated_delivery_minutes) AS avg_est_del
		,SUM(actual_delivery_minutes) AS tot_act_del
		,AVG(actual_delivery_minutes) AS avg_act_del
		,SUM(del_time_diff) AS tot_time_diff
		,AVG(del_time_diff) AS avg_time_diff
FROM orders_autumn_2020
GROUP BY delivery_date, delivery_hour
ORDER BY delivery_date, delivery_hour


---ontime delivery rate

SELECT delivery_date, delivery_hour
		,COUNT(*) AS ontime_count
		,COUNT(*)*100.0/(SELECT COUNT(*) FROM orders_autumn_2020 o
							WHERE o.Delivery_date = oo.Delivery_date
							GROUP BY delivery_date) AS ontime_rate 
FROM orders_autumn_2020 oo
WHERE del_time_diff <= 0
GROUP BY delivery_date, delivery_hour
ORDER BY delivery_date, delivery_hour


----delayed delivery rate

SELECT delivery_date, delivery_hour
		,COUNT(*) AS delayed_count
		,COUNT(*)*100.0/(SELECT COUNT(*) FROM orders_autumn_2020 o
							WHERE o.Delivery_date = oo.Delivery_date
							GROUP BY delivery_date) AS delay_rate 
FROM orders_autumn_2020 oo
WHERE del_time_diff > 0
GROUP BY delivery_date, delivery_hour
ORDER BY delivery_date, delivery_hour


----metrics (weather) analytics

SELECT delivery_date, delivery_hour
		,AVG(temperature) AS avg_daily_temp
		,AVG(cloud_coverage) AS avg_daily_cloud_cov
		,AVG(wind_speed) AS avg_daily_wind_speed
		,AVG(precipitation) AS avg_daily_precipitation
FROM orders_autumn_2020
GROUP BY delivery_date, delivery_hour
ORDER BY delivery_date, delivery_hour

----delivery analytics across regions
SELECT Delivery_date, delivery_hour, 
		user_lat,
		user_long,
		venue_lat
		,venue_long
		,COUNT(*) AS delivery_count
FROM orders_autumn_2020
GROUP BY Delivery_date, delivery_hour, user_lat, user_long,
		venue_lat ,venue_long;
---next we take a deep dive into how our KPIs are influenced and changes over time

---how does weather conditions influence deliveries

---how does weather conditions influence number of daily/weekly deliveries
WITH del_wea_con_cte
AS
(
SELECT delivery_date, delivery_hour, cloud_coverage
		,AVG(temperature) OVER (PARTITION BY delivery_date ORDER BY delivery_hour) AS avg_temp
		,AVG(cloud_coverage) OVER (PARTITION BY delivery_date ORDER BY delivery_hour) AS avg_cloud_cov
		,AVG(wind_speed) OVER (PARTITION BY delivery_date ORDER BY delivery_hour) AS avg_wind_speed
		,AVG(precipitation) OVER (PARTITION BY delivery_date ORDER BY delivery_hour) AS avg_precip
		,COUNT(*) OVER (PARTITION BY delivery_date ORDER BY delivery_hour) AS tot_delivery
		,SUM(item_count) OVER (PARTITION BY delivery_date ORDER BY delivery_hour) AS tot_item
		,AVG(del_time_diff) OVER (PARTITION BY delivery_date ORDER BY delivery_hour) AS avg_del_time_diff
		,AVG(estimated_delivery_minutes) OVER (PARTITION BY delivery_date ORDER BY delivery_hour) AS avg_est_del
		,AVG(actual_delivery_minutes) OVER (PARTITION BY delivery_date ORDER BY delivery_hour) AS avg_act_del
FROM orders_autumn_2020
)
		SELECT delivery_date, delivery_hour
				,AVG(avg_temp) AS temp
				,AVG(avg_cloud_cov) AS cloud_cov
				,AVG(avg_wind_speed) AS wind_speed
				,AVG(avg_precip) AS precip
				,AVG(tot_delivery) AS tot_deliveries
				,AVG(tot_item) AS tot_items
				,AVG(avg_est_del) AS est_del_time
				,AVG(avg_act_del) AS act_del_time
				,AVG(avg_act_del - avg_est_del) AS del_time_diff
		FROM del_wea_con_cte
		----WHERE delivery_hour = 20
		GROUP BY delivery_date, delivery_hour
		ORDER BY delivery_date, delivery_hour

----delivery accuracy rate across days and weather conditions

SELECT delivery_date
FROM 







