USE Sales_DB
GO

--- Showing the tables in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

SELECT * FROM Business_sales_Data

--- Data validation and cleaning
------ Checking of Null values within each column 
select 
	sum(case when State is null then 1 Else 0 END) as Null_state,
	sum(case when City is null then 1 Else 0 END) as Null_city,
	sum(case when Order_Date is null then 1 Else 0 END) as Null_date,
	sum(case when Restaurant_Name is null then 1 Else 0 END) as Null_restaurant_name,
	sum(case when Location is null then 1 Else 0 END) as Null_location,
	sum(case when Category is null then 1 Else 0 END) as Null_category,
	sum(case when Dish_Name is null then 1 Else 0 END) as Null_Dish_name,
	sum(case when Price is null then 1 Else 0 END) as Null_price,
	sum(case when Rating is null then 1 Else 0 END) as Null_rating,
	sum(case when Rating_Count is null then 1 Else 0 END) as Null_rating_count
from Business_sales_Data;


--- Detecting of Duplicates
------ Checking the data to filter out duplicates
select
	State, City, Restaurant_Name, Order_Date, bsd.Location, Category, 
	Dish_Name, Price, Rating, Rating_Count,
	Count(*) as CNT
from Business_sales_Data bsd
GROUP BY State, City, Restaurant_Name, Order_Date, Location,
	Category, Dish_Name, Price, Rating, Rating_Count
HAVING Count(*) > 1


--- Deletion of Duplicate values
----- After querying out the duplicate values, we need to delete it out of the data
with CTE as (
	select *, ROW_NUMBER() OVER(PARTITION BY State, City, Restaurant_Name, Order_Date, bsd.Location, Category, 
	Dish_Name, Price, Rating, Rating_Count ORDER BY (SELECT NULL)) as duplicate_data
	from Business_sales_Data)
DELETE FROM CTE WHERE duplicate_data > 1


--- CREATION OF SCHEMA
----- DIMENSION TABLES
----- DATE TABLE
Create Table Date_table(
	date_id int identity(1,1) primary key not null,
	Full_date Date,
	Year INT,
	Month INT,
	Month_Name varchar(50),
	Week INT,
	WeekDay varchar(50),
	Day INT,
	Quarter INT)

--- DIM LOCATION TABLE
Create Table dim_location(
	location_id int identity(1,1) primary key,
	State varchar(200),
	City varchar(200),
	Location varchar(200))

--- DIM RESTAURANT TABLE
Create Table dim_restaurant(
	restaurant_id int identity(1,1) primary key,
	Restaurant_Name varchar(200));

--- DIM CATEGORY 
Create Table dim_category(
	category_id INT IDENTITY(1,1) PRIMARY KEY,
	Category varchar(200))

--- DIM DISH NAME
Create Table dim_dish(
	dish_id INT IDENTITY(1,1) PRIMARY KEY,
	Dish_Name varchar(200));


--- CREATION OF FACT TABLE
Create Table fact_business_sales(
	orders_id INT IDENTITY(1,1) PRIMARY KEY,
	Price DECIMAL(10,2),
	Rating DECIMAL(4,2),
	Rating_Count INT,
	date_id INT,
	location_id INT,
	restaurant_id INT,
	category_id INT,
	dish_id INT,
	FOREIGN KEY (date_id) REFERENCES Date_table(date_id),
	FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
	FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
	FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id))

SELECT * FROM Business_sales_Data


--- INSERTION OF DATA INTO THE CREATED DIMENSION AND DATE TABLES

--- DATA INTO DATE TABLE USING THE ORDER_DATE FROM THE ORIGINAL DATA
INSERT INTO Date_table(Full_date, Year, Month, Month_Name, Week, WeekDay,Day, Quarter)
SELECT DISTINCT 
	Order_Date,
	YEAR(Order_Date),
	MONTH(Order_Date),
	DATENAME(MONTH, Order_Date),
	DATEPART(WEEK, Order_Date), 
	DATENAME(WEEK, Order_Date),
	DAY(Order_Date),
	DATEPART(QUARTER, Order_Date)
from Business_sales_Data;
SELECT * FROM dim_location

--- DATA INTO LOCATION TABLE FROM THE ORIGINAL DATA
INSERT INTO dim_location( State, City, Location)
select DISTINCT
	state, city, location
from Business_sales_Data

--- DATA INTO RESTAURANT TABLE FROM THE ORIGINAL TABLE
INSERT INTO dim_restaurant( Restaurant_Name)
select DISTINCT
	Restaurant_Name
from Business_sales_Data

--- DATA INTO CATEGORY TABLE FROM THE ORIGINAL TABLE
INSERT INTO dim_category(Category)
select DISTINCT
	Category
from Business_sales_Data

--- DATA INTO DISHES TABLE FROM THE ORIGINAL TABLE
INSERT INTO dim_dish(Dish_Name)
select DISTINCT
	Dish_Name
from Business_sales_Data
