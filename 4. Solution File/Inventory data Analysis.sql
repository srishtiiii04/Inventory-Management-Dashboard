-- Creating a new database
create Database Inventory_Management_Project;

-- using the database
Use Inventory_Management_Project;

-- Creating Tables and Loading the data in the table
create table Inventory1 (
Product_ID varchar(30),
In_Stock_Quantity Decimal(15,5),
Avg_Lead_Time_in_Days int,
Max_Lead_Time_in_Days Decimal(10,5),
Price_Per_Unit Decimal(15,5)
);

Load Data infile
"D:/github_workspace/Inventory_Dashboard/2. Dataset/Inventory.csv"
into table Inventory1
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table Orders (
Order_Date varchar(30), -- we will upload the orderdate as varchar and then change it to date later
Product_ID1 varchar(30),
Order_Quantity Decimal(15,5)
);

Load Data infile
"D:/github_workspace/Inventory_Dashboard/2. Dataset/Orders.csv"
into table Orders
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- Checking the data
select * from orders;
select * from inventory1;

-- Setting correct data type for date column

Set SQL_Safe_Updates = 0; -- to disable Safe update mode

UPDATE orders
SET order_date = str_to_date(order_date, '%d-%m-%Y');

ALTER TABLE orders
MODIFY order_date date;

describe orders; -- Date datatype changed

-- -------------------------------------------------------------ABC Analysis -----------------------------------------------------------------------------------------
-- calculating Annual Sales Quantity and annual revenue for each Product Id
create table I1 as(
Select inventory1.Product_ID,sum(order_quantity) as annual_sales_quantity,sum(price_per_unit*order_quantity) as annual_Revenue from inventory1, Orders 
where inventory1.product_ID = Orders.product_ID1 and order_date >= '2022-12-02' - INTERVAL 365 day -- this sql file was created on 2nd December 2022 use interval accordingly!
group by Product_ID order by product_ID);

Create table I2 as
Select a.*, b.annual_sales_quantity, b.annual_Revenue from Inventory1 a
Left Outer join I1 b on a.product_ID = b.product_ID
group by Product_ID order by product_ID;

-- setting Null values to 0
UPDATE I2 SET annual_sales_quantity=0 WHERE annual_sales_quantity IS NULL;
UPDATE I2 SET annual_Revenue=0 WHERE annual_Revenue IS NULL;

select * from I2;

-- Calculating Revenue share percentage 
create table I3 as
select *, 100*annual_revenue/(select sum(annual_Revenue) from I2) as Revenue_Percent from I2 order by Revenue_Percent desc;

select * from I3;

-- Calculating the Cumulative Sum for Revenue Percent Share
set @csum := 0;
create table I4 as
select *, (@csum := @csum + Revenue_Percent) as cumulative_sum from I3;

-- Classifiying each product into A, B and C based on the cumulative Revenue
Create table I5 as
SELECT *,
CASE
    WHEN cumulative_sum <= 70 THEN "A [High Value]"
    WHEN cumulative_sum <= 90 THEN "B[Medium Value]"
    ELSE "C[Low Value]" 
END as ABC_Analysis
FROM I4;

select * from I5;

-- Calculating Rank for Cumulative Sum
create table I6 as(
select *, In_Stock_Quantity*Price_Per_Unit as value_in_Inventory, RANK() over (
ORDER BY cumulative_sum ASC) ABC_rank
from I5 order by product_ID);

Select * from I6;

-- ------------------------------------------------------------- Weekly Demand -----------------------------------------------------------------------------------------
-- Creating Date Table
Create table `date` (`date` date);

DROP PROCEDURE IF EXISTS filldates;
DELIMITER |
CREATE PROCEDURE filldates(dateStart DATE, dateEnd DATE)
BEGIN
  WHILE dateStart <= dateEnd DO
    INSERT INTO `date` VALUES (dateStart);
    SET dateStart = date_add(dateStart, INTERVAL 7 DAY);
  END WHILE;
END;
|
DELIMITER ;
-- CALL filldates(CURRENT_DATE - INTERVAL 365 DAY, CURDATE()); -- this sql file was created on 2nd December 2022 use interval accordingly!
CALL filldates('2022-12-02' - INTERVAL 365 DAY, '2022-12-01');
select * from `date`;

-- Creating Product table
create table Products as
select Product_ID from inventory1;

select * from Products;

-- Preparing Weekly Demand for each product
create table WD1 as
Select * from `date`
cross join Products order by `date`, Product_ID;

-- Calculating Weekly Demand for each Product
create table WD2 as (
select sum(Order_Quantity) as WD, `date`as date1, Product_ID as P1 from orders, WD1 
where orders.Product_ID1 = WD1.product_ID and orders.order_date>=WD1.`date`-INTERVAL 6 DAY
and orders.order_date<=WD1.`date`
group by date,product_ID1 order by date,product_ID);

select * from WD2;

Create table WD3 as(
Select date, product_ID, WD as weeks_demand from WD1 Left outer join WD2 on WD1.`date` = WD2.date1 and WD1.Product_ID=WD2.P1 group by date,Product_ID order by date,Product_ID);

-- setting Null values to 0
UPDATE WD3 SET weeks_demand=0 WHERE weeks_demand IS NULL;

-- Calculating Sales per Week for each product
create table Weekly_demand as(
select WD3.*, (weeks_demand*Price_Per_Unit) as sales_Amount from WD3 left outer join I6 on WD3.product_ID = I6.product_ID);

select * from Weekly_Demand;

-- -------------------------------------------------------------XYZ Analysis -----------------------------------------------------------------------------------------
-- Calculating Average, standard deviation and Coeffecient of variation for weekly demand
Create table I7 as (
Select I6.*, 
avg(weeks_demand) as average_weekly_demand,
(STDDEV(weeks_demand)) as SD_Weekly_Demand,
(STDDEV(weeks_demand)/IF(avg(weeks_demand)=0,10000,avg(weeks_demand))) as Coff_Var from I6, Weekly_Demand
where Weekly_Demand.product_ID = I6.product_ID group by I6.product_ID order by cumulative_sum);
select * from I7;

-- setting Null values to 0
UPDATE I7 SET Coff_Var=10000 WHERE Coff_Var= 0;

-- Calculating rank for Coefficient
Create table I8 as (
SELECT *,
RANK() over (
ORDER BY Coff_Var ASC ) Coff_rank
from I7);

select * from I8 order by product_ID;

-- Catagorizing demand based on the coefficient
Create table I9 as
SELECT *,
CASE
    WHEN Coff_rank <= 0.2*max(Coff_rank) Over w  THEN "X [Uniform Demand]"
    WHEN Coff_rank <= 0.5*max(Coff_rank) Over w THEN  "Y [Variable Demand]"
    ELSE "Z [Uncertain Demand]" 
END as XYZ_Analysis
FROM I8
Window w as ()
Order by Coff_rank asc;

select * from I9;

-- ------------------------------------------- Other Inventory Variables ------------------------------------------------------------------------------
-- Calculating Peak Weekly demand, Safety Stock, Reorder point
Create Table I10 as(
Select I9.*, max(weeks_demand) as peak_weekly_demand,
(max(weeks_demand)*(Max_Lead_Time_in_Days/7)-average_weekly_demand*(Avg_Lead_Time_in_Days)/7) as Safety_Stock,
((max(weeks_demand)*(Max_Lead_Time_in_Days/7)-average_weekly_demand*(Avg_Lead_Time_in_Days)/7)*(Max_Lead_Time_in_Days/7)-average_weekly_demand*(Avg_Lead_Time_in_Days)/7)+(average_weekly_demand*(Avg_Lead_Time_in_Days)/7)as Reorder_Point
from I9, Weekly_Demand
where I9.product_ID = Weekly_Demand.product_ID Group by product_ID Order by product_ID);

Select * from I10;

-- Categorizing the stock based on the reorder point
Create Table I11 as ( 
SELECT *,
CASE
    WHEN Reorder_Point > In_Stock_Quantity THEN "Yes [Reorder]"
    ELSE "No [There is Time]" 
END as Reorder_Time
FROM I10);

Select * from I11;

-- Categorizing the inventory based on the reorder time
Create Table Inventory as ( 
SELECT *,
CASE
    WHEN (In_Stock_Quantity = 0) THEN "Out Of Stock"
    WHEN (Reorder_Time = "Yes [Reorder]") Then "Below Reorder point"
    Else "In Stock"
END as Inventory_Status
FROM I11);

Select * from Inventory;

-- Dropping off the extra tables

Show Tables;

drop tables i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,inventory1,wd1,wd2,wd3;

-- Checking the final data and tables
select * from inventory;
select * from orders;
select * from products;
select * from weekly_demand;
select * from date;
