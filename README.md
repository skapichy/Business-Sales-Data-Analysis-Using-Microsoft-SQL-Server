# Business-Sales-Data-Analysis-Using-Microsoft-SQL-Server
A complete end-to-end SQL project covering data quality checks, cleaning, dimensional modelling, ETL, and analytical querying to generate actionable business insights for restaurants, food delivery platforms, and retail operators.

# Project Overview
This project showcases my ability to use Microsoft SQL Server (MSSQL) to transform raw business sales data into a properly structured, analysis-ready Star Schema Data Warehouse.
The project demonstrates capabilities across:
* Data Cleaning
* Data Validation
* Duplicate Detection & Removal
* Dimensional Modelling (Star Schema)
* ETL: Loading Dimension & Fact Tables
* Building a scalable structure for BI dashboards
The original dataset contains restaurant-level transaction data including: State, City, Location, Restaurant Name, Order Date, Dish Name & Category, Price, Ratings & Rating Count
This project converts the unstructured raw dataset into a data warehouse model suitable for business analytics.

# Database Used
USE Sales_DB;
GO
* I created and used the database Sales_DB, where all tables, schemas, and models were built.

## Inspecting and Understanding the Data
* Viewing all tables in the database
```TSQL
SELECT * FROM INFORMATION_SCHEMA.TABLES;
```
### Purpose:
* Shows available tables and ensures the raw table (Business_sales_Data) exists before transformation.

✔ Preview the raw data
SELECT * FROM Business_sales_Data;
### Purpose:
Quick scan to understand structure, columns, values, and potential issues.

🧹 2. Data Validation & Cleaning
✔ Checking for NULL values
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


Business Importance:
Data completeness affects revenue calculations, category performance, and dashboards.
This helps decide if missing values should be dropped, filled, or flagged.

✔ Detecting Duplicate Records
select
	State, City, Restaurant_Name, Order_Date, bsd.Location, Category, 
	Dish_Name, Price, Rating, Rating_Count,
	Count(*) as CNT
from Business_sales_Data bsd
GROUP BY State, City, Restaurant_Name, Order_Date, Location,
	Category, Dish_Name, Price, Rating, Rating_Count
HAVING Count(*) > 1


Importance:
Duplicates cause over-reporting of revenue, purchases, and ratings.

✔ Deleting Duplicates with CTE + ROW_NUMBER()
with CTE as (
	select *, ROW_NUMBER() OVER(
	    PARTITION BY State, City, Restaurant_Name, Order_Date, bsd.Location, Category, 
		Dish_Name, Price, Rating, Rating_Count 
	    ORDER BY (SELECT NULL)
	) as duplicate_data
	from Business_sales_Data
)
DELETE FROM CTE WHERE duplicate_data > 1;


Business Impact:
Removes inflated revenue and duplicate restaurant activities.

🧱 3. Building a STAR SCHEMA (Dimensional Model)

Dimensional modeling makes analytics fast and Power BI-ready.

⭐ Fact Table

Contains measurable values: price, rating, etc.

⭐ Dimension Tables

Contain descriptive attributes used for slicing and dicing data.

🗓 Dimension 1 — Date Table
Create Table Date_table(
	date_id int identity(1,1) primary key not null,
	Full_date Date,
	Year INT,
	Month INT,
	Month_Name varchar(50),
	Week INT,
	WeekDay varchar(50),
	Day INT,
	Quarter INT
);


✔ Enables calendar-based reporting:

Revenue by month

Top restaurants by quarter

Seasonality insights

📍 Dimension 2 — Location
Create Table dim_location(
	location_id int identity(1,1) primary key,
	State varchar(200),
	City varchar(200),
	Location varchar(200)
);


✔ Helps compare performance across States, Cities & Locations.

🍽 Dimension 3 — Restaurant
Create Table dim_restaurant(
	restaurant_id int identity(1,1) primary key,
	Restaurant_Name varchar(200)
);


✔ Supports ranking top restaurants, profitability analysis & comparing branches.

🏷 Dimension 4 — Category
Create Table dim_category(
	category_id INT IDENTITY(1,1) PRIMARY KEY,
	Category varchar(200)
);


✔ Useful for product mix analysis.

🍲 Dimension 5 — Dish
Create Table dim_dish(
	dish_id INT IDENTITY(1,1) PRIMARY KEY,
	Dish_Name varchar(200)
);


✔ Enables top-selling dish analysis and customer preference insights.

📦 4. Fact Table
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
	FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);


Why this is important:
This is the core table for analytics:

Revenue calculations

Ratings analysis

Category performance

Restaurant comparisons

Time-series reporting

🔄 5. ETL: Inserting Data into Dimensions
✔ Load Date Table
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

✔ Load Location Table
INSERT INTO dim_location(State, City, Location)
SELECT DISTINCT State, City, Location
FROM Business_sales_Data;

✔ Load Restaurant Table
INSERT INTO dim_restaurant(Restaurant_Name)
SELECT DISTINCT Restaurant_Name
FROM Business_sales_Data;

✔ Load Category Table
INSERT INTO dim_category(Category)
SELECT DISTINCT Category
FROM Business_sales_Data;

✔ Load Dish Table
INSERT INTO dim_dish(Dish_Name)
SELECT DISTINCT Dish_Name
FROM Business_sales_Data;

🎯 Business Value of This Project

This entire pipeline supports important real-world business outcomes:

✔ Better Decision Making

Managers can quickly assess category performance, dish popularity, and revenue trends.

✔ Improved Restaurant Performance Analysis

Identifies:

Top performing restaurants

Low-performing branches

Locations with best/worst ratings

✔ Pricing & Menu Optimization

Insights from:

Dish sales

Category trends

Price sensitivity

✔ Customer Experience Improvement

Ratings and rating count help measure satisfaction and identify quality issues.

✔ Analytics-Ready Data Structure

The star schema allows:

Fast Power BI reports

Clean dashboards

Easy time-based analysis

Efficient data querying

📈 What This Project Demonstrates About My Skills
✔ Strong SQL Server Querying
✔ Data Cleaning & Quality Assurance
✔ Duplicate Handling Using CTE
✔ Dimensional Modelling (Star Schema)
✔ ETL Process Execution
✔ Understanding of Business Metrics
✔ Ability to Build Analysis-Ready Databases
