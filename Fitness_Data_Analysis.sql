
use Portfolio_Projects_01
go


select * from fitness_data


-----4 key questions

----1.... top 5 brands average rating and average price
----2.... is there significant demand for fitness trackers in india
----3.... correlation between prices and product specifications, ratings
----4.... different types of fitness trackers, the price segment for different users




----Total revenue, average revenue and discount on all fitness tracker in india

 
with count_CTE (total_revenue, average_revenue, total_launch_Price, overall_discount)
as
(
select sum(cast(Current_Price as float)) as total_revenue, avg(cast(current_price as float)) as average_revenue, sum(cast(Original_Price as float)) as total_launch_Price, 
				sum(cast(Original_Price as float))-sum(cast(Current_Price as float)) as overall_discount
	from Fitness_Data
)

	select total_revenue, average_revenue, total_launch_Price, overall_discount, (overall_discount/total_launch_price)*100 as discount_percent
	from count_CTE


----total count of device brands and models of fitness trackers

with model_count_CTE(brand_count) 

as 
(
	select distinct (brand) as brand_count
	from Fitness_Data
	group by brand

	)

	select count(brand_count) as Total_brand
	from model_count_CTE;

	
---models
with model_count_CTE(device_model_count)

as 
(
	select distinct count(device_model) as device_model_count
	from Fitness_Data
	group by Device_Model

	)

	select sum(device_model_count) as total_device_model
	from model_count_CTE


----Total number of fitness tracker brands and count of sales

select distinct (Brand), count(brand) as models_count
from  fitness_data
group by brand
order by 2 desc

----1.... top 5 brands average rating and average price
---Top selling Brands (Total and average revenue)
select distinct top 5  brand, sum(cast(Current_Price as float)) as total_revenue, avg(Cast(Current_Price as float)) as Avg_Revenue
from fitness_data
group by brand
order by 3 desc

----Top 5 rated Brands
select distinct top 5 brand, avg(Cast(Rating as float)) as Avg_rating
from fitness_data
group by brand
order by 2 desc

----Top 5 most expensive devices and price
select distinct top 5  brand, device_model, count(device_model) as sales_count, cast(current_price as float), sum(cast(current_price as float)) as price
from fitness_data
where device_model like '% %'
group by brand, device_model, current_price
order by 4 desc


-----Least expensive devices and price
select distinct top 5 brand, device_model, count(device_model) as sales_count, cast(current_price as float), sum(cast(current_price as float)) as price
from fitness_data
where device_model like '% %'
group by brand, device_model, current_price
order by 1 asc


----4.... different types of fitness trackers, the price segment for different users
------creating a price category to which each product and brand falls into


select brand, device_model, current_price, case when current_price >=1000 and [Current_Price]<20000 then '1000-19999'
				when current_price >=20000 and [Current_Price]<40000 then '20000-39999'
				when current_price >=40000 and [Current_Price]<60000 then '40000-59999'
				when current_price >=60000 and [Current_Price]<80000 then '60000-79999'
				when current_price >=80000 and [Current_Price]<100000 then '80000-99999'
				when current_price >=100000 and [Current_Price]<120000 then '100000-119999'
				when current_price >=120000 and [Current_Price]<140000 then '120000-139999'
				end as price_category
from fitness_data

alter table fitness_data
add price_category varchar (50)

update fitness_data
set price_category = case when current_price >=1000 and [Current_Price]<20000 then '1000-19999'
				when current_price >=20000 and [Current_Price]<40000 then '20000-39999'
				when current_price >=40000 and [Current_Price]<60000 then '40000-59999'
				when current_price >=60000 and [Current_Price]<80000 then '60000-79999'
				when current_price >=80000 and [Current_Price]<100000 then '80000-99999'
				when current_price >=100000 and [Current_Price]<120000 then '100000-119999'
				when current_price >=120000 and [Current_Price]<140000 then '120000-139999'
				end 

---- distribution of fitness tracker brand across price range

select brand, current_price
from fitness_data
where current_price is not null---like '% %'
group by price_category, brand, current_price
order by 1,2 asc


----distribution of fitness tracker models across price range
select brand, device_model, current_price
from fitness_data
where current_price is not null and price_category = '1000-19999'---like '% %'
group by brand, device_model, current_price
order by 1,2,3 asc


----3.... correlation between prices and product specifications, ratings

select p.current_price, d.brand, d.device_Shape, d.Strap_color, d.Strap_Material, d.touchscreen, d.bluetooth
						,d.[Battery_Life[Days]]], d.[Weight[kg]]], d.[Display_Size["]]], d.Rating
from Fitness_Data p
join Fitness_Data d
on p.[device_model] = d.[device_model]
where p.Current_Price not like '% %' and p.brand = 'samsung'
order by p.Current_Price desc, d.Rating desc


-----fitness tracker buying pattern by price in india


with price_catCTE(price_category, price_cat_count)

as
(
		select price_category, count(price_category) as price_cat_count
		from Fitness_Data
		where price_category is not null
		group by price_category

	)

	select price_category, price_cat_count, (cast(price_cat_count as float)*100/(select sum(price_cat_count) from price_catCTE)) as Price_cat_percent
	from price_catCTE 
	order by 3 desc
	
-----Top rating count per brands
	
select top 5 brand, sum(ratings_count) as rating_count
from Fitness_Data
group by brand
order by 2 desc

-----least rating count per brand

select top 5 brand, sum(ratings_count) as rating_count
from Fitness_Data
group by brand
order by 2 asc

----breakdown by deveice specifications
---bluetooth
select distinct bluetooth, count(bluetooth) as bluetooth_feature_count
from Fitness_Data
where bluetooth not like '%  %'
group by Bluetooth
order by 2 desc

----touchscreen
select distinct Touchscreen, count(Touchscreen) as touchscreen_feature_count
from Fitness_Data
where Touchscreen not like '%  %'
group by Touchscreen
order by 2 desc


-----display size

select distinct [Display_Size["]]], count([Display_Size["]]]) as display_size_count
from Fitness_Data
where [Display_Size["]]] not like '%  %'
group by [Display_Size["]]]
order by 2 desc


-----weight
select distinct [Weight[kg]]], count([Weight[kg]]]) as weight_count
from Fitness_Data
where [Weight[kg]]] not like '%  %'
group by [Weight[kg]]]
order by 2 desc

---battery life

select distinct [Battery_Life[Days]]], count([Battery_Life[Days]]]) as battery_life_count
from Fitness_Data
where [Battery_Life[Days]]] not like '%  %'
group by [Battery_Life[Days]]]
order by 2 desc

----strap color

select distinct Strap_Color, count(Strap_Color) as Strap_Color_count
from Fitness_Data
where Strap_Color not like '%  %'
group by Strap_Color
order by 2 desc

-----strap material
select distinct Strap_Material, count(Strap_Material) as Strap_material_count
from Fitness_Data
where Strap_Material not like '%  %'
group by Strap_Material
order by 2 desc

----device shape

select distinct Device_Shape, count(Device_Shape) as device_shape_count
from Fitness_Data
where Device_Shape not like '%  %'
group by Device_Shape
order by 2 desc


----devices model by brand
select distinct Device_Model, count(Device_Model) as device_model_count
from Fitness_Data
where brand = 'fitbit' and  Device_Model not like '%  %'
group by brand, Device_Model
order by 2 desc


select * from fitness_data
order by device_model desc