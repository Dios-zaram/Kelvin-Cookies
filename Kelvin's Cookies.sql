--Create cookie_store Table and load it.
Create Table Cookie_2017(Order_ID INT,
						 Customer_ID Varchar,
						 Cookies_Shipped INT,
						 Revenue INT,
						 Cost INT,
						 Order_Date Date,
						 Ship_Date Date,
						 Order_Status Varchar);



COPY Cookie_2017 FROM 'C:\Program Files\PostgreSQL\15\data\data_copy\2017_Order_Data.csv'
Delimiter ',' csv header;

--Create cookie_store Table and load it.
Create Table Cookie_2018(Order_ID INT,
						 Customer_ID Varchar,
						 Cookies_Shipped INT,
						 Revenue INT,
						 Cost INT,
						 Order_Date Date,
						 Ship_Date Date,
						 Order_Status Varchar);



COPY Cookie_2018 FROM 'C:\Program Files\PostgreSQL\15\data\data_copy\2018_Order_Data.csv'
Delimiter ',' csv header;

--Create cookie_store Table and load it.
Create Table Cookie_2019(Order_ID INT,
						 Customer_ID Varchar,
						 Cookies_Shipped INT,
						 Revenue INT,
						 Cost INT,
						 Order_Date Date,
						 Ship_Date Date,
						 Order_Status Varchar);



COPY Cookie_2019 FROM 'C:\Program Files\PostgreSQL\15\data\data_copy\2019_Order_Data.csv'
Delimiter ',' csv header;

--Create cookie_store Table and load it.
Create Table Cookie_2020(Order_ID INT,
						 Customer_ID Varchar,
						 Cookies_Shipped INT,
						 Revenue INT,
						 Cost INT,
						 Order_Date Date,
						 Ship_Date Date,
						 Order_Status Varchar);



COPY Cookie_2020 FROM 'C:\Program Files\PostgreSQL\15\data\data_copy\2020_Order_Data.csv'
Delimiter ',' csv header;

--Create a temp table
Drop table if exists Both_tables;
Create temp table Both_tables as(Select * From Cookie_2017 where order_id is not null
								 UNION
								 Select * From Cookie_2018 where order_id is not null
								 UNION
								 Select * From Cookie_2019 where order_id is not null
								 UNION
								 Select * From Cookie_2020 where order_id is not null
								 and ship_date is not null);
								 
Select * From Both_tables;

--Alter table and add new columns
Alter Table Both_tables
Add Column Customer_name Varchar,
Add Column Profit Int,
Add Column Days_of_ship Varchar,
Add Column ship_year int,
Add Column order_year int;

--Update table 
Update Both_tables
Set Customer_id = split_part(customer_id, ' - ', 1),
    Customer_name = split_part(customer_id, ' - ', 2),
    Profit = Revenue - Cost,
    Days_of_ship = case when (ship_date - order_date) = 2 then 'Early' 
						when (ship_date- order_date) = 3 then 'A little Early'
						else 'Delay Bad' End,
    ship_year = Extract(Year from ship_date),
    order_year = Extract(Year from order_date);
	

--Delete column
Alter Table Both_tables Drop column order_status;

--Restructure Temp Table
Drop table if exists Re_tables;
Create temp table Re_tables as(select order_id, customer_id, customer_name,cookies_shipped,
							   revenue, cost,profit,order_date,ship_date,days_of_ship,
							   ship_year, order_year from Both_tables);
							   
Select * from Re_tables;

--Analysis 
Select customer_name, order_year, sum(profit) from Re_tables
group by customer_name, order_year
order by order_year;
/*The analysis shows that the most cookies are bought by 'Cascade Grovers'.
But in 2020 the profit of 'Cascade Grovers' dropped to 256466. 
While the least cookies purchased from 2017-2020 are by 'Acme Grocery Stores'*/

Select order_year, sum(cookies_shipped) total_cookies_shipped, sum(profit) total_profit
From Re_tables Group by cube (order_year) Order by order_year Nulls Last;
/*The most cookies and profit year is 2018, while the demand for cookies dropped in 2020
and so did the profit*/

Select customer_id, customer_name, sum(cookies_shipped) total_cookies_shipped, 
sum(profit) total_profit From Re_tables Group by customer_id,customer_name
Order by customer_id Nulls Last;
/* customer with id 325698 (Cascade Grovers) have brought the most cookies and
have generated the most profit for kelvin's cookies */

Select Customer_name, Order_year, sum(cost) sum_cost, sum(profit) sum_profit from Re_tables
group by Customer_name, Order_year
/*  */
Select order_year, sum(revenue) total_revenue
From Re_tables Group by order_year Order by order_year desc;
/*The most revenue was generated in 2018.*/
