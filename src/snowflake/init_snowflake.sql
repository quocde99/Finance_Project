-- Set up Warehouse
-- Set up Database
create database FINANCEDW;
use FINANCEDW;
CREATE SCHEMA "FINANCEDW"."FinanceDatawarehouse";
Use SCHEMA "FINANCEDW"."FinanceDatawarehouse";
-- set up table
--DimJobs

CREATE TABLE DimJobs (
	JobsKey  int identity not null
	-- attributes
, 	jobID int not null
,  	jobTitle varchar(50) not null
,  	income_basic int not null
, CONSTRAINT PK_DimJobs  PRIMARY KEY (JobsKey)
);

--dimAddress
CREATE TABLE DimAddresses (
	AddressesKey  int identity not null
	-- attributes
, 	addressID int not null
,  	city varchar(50) not null
,  	region varchar(50) not null
, CONSTRAINT PK_DimAddresses  PRIMARY KEY (AddressesKey)
);
-- DimDate
--Date Dimension
CREATE TABLE DimDate(
	DateKey int NOT NULL,
	Date datetime NULL,
	DayOfWeek int NOT NULL,
	DayName nchar(10) NOT NULL,
	DayOfMonth int NOT NULL,
	DayOfYear int NOT NULL,
	WeekOfYear int NOT NULL,
	MonthName nchar(10) NOT NULL,
	MonthOfYear int NOT NULL,
	Quarter int NOT NULL,
	Year int NOT NULL,
	IsAWeekday varchar(1) NOT NULL DEFAULT (('N')),
	CONSTRAINT PK_DimDate PRIMARY KEY (DateKey)
);

--dim Customer
CREATE TABLE DimCustomer (
	CustomerKey  int identity not null
	-- attributes
, 	customerID int not null
,  	creditCard varchar(50) not null
,  	limit int not null
,  	sex boolean not null
,  	name nvarchar(50) not null
,  	date_of_birth datetime not null
,  	email varchar(50) not null
,  	phone_Number varchar(50) not null
,  	JobsKey int not null
,  	education int not null
,  	AddressesKey int not null
	-- constraints
,	CONSTRAINT PK_DimCustomer  PRIMARY KEY (CustomerKey)
,	CONSTRAINT FK_JobsKey FOREIGN KEY (JobsKey) REFERENCES DimJobs(JobsKey)
,	CONSTRAINT FK_AddressesKey FOREIGN KEY (AddressesKey) REFERENCES DimAddresses(AddressesKey)
);

-- FactFinace
CREATE TABLE FactFinance (
	transactionID int not null
,	CustomerKey  int not null
,	startDateKey int not null
,	endDateKey int not null
	-- measure
, 	loan int not null
,	creditscore int not null
	-- constraints
, 	CONSTRAINT PK_FactFinance PRIMARY KEY (transactionID)
,	CONSTRAINT FK_CustomerKey FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey)
,	CONSTRAINT FK_startDateKey FOREIGN KEY (startDateKey) REFERENCES DimDate (DateKey)
,	CONSTRAINT FK_endDateKey FOREIGN KEY (endDateKey) REFERENCES DimDate (DateKey)
);
create view Avg_Score
as
select C.CUSTOMERID, ROUND(avg(F.CREDITSCORE), 0) as Avg_Score
from "FINANCEDW"."FinanceDatawarehouse"."FACTFINANCE" as F, "FINANCEDW"."FinanceDatawarehouse"."DIMCUSTOMER" as C
where F.CUSTOMERKEY=C.CUSTOMERKEY
group by C.CUSTOMERID
-- Create Trigger

-- Set up Snowpipe

-- Task
