CREATE DATABASE sales_db;


USE sales_db;

CREATE TABLE sales_data (
    `Row ID` INT,
    `Order ID` VARCHAR(20),
    `Order Date` DATE,
    `Ship Date` DATE,
    `Ship Mode` VARCHAR(50),
    `Customer ID` VARCHAR(20),
    `Customer Name` VARCHAR(100),
    `Segment` VARCHAR(50),
    `Country` VARCHAR(50),
    `City` VARCHAR(50),
    `State` VARCHAR(50),
    `Postal Code` VARCHAR(10),
    `Region` VARCHAR(20),
    `Product ID` VARCHAR(20),
    `Category` VARCHAR(50),
    `Sub-Category` VARCHAR(50),
    `Product Name` VARCHAR(200),
    `Sales` DECIMAL(12, 2),
    `Quantity` INT,
    `Discount` DECIMAL(4, 2),
    `Profit` DECIMAL(12, 2),
    `Profit Margin` DECIMAL(10, 4)
);

TRUNCATE TABLE sales_data;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_for_mysql.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

