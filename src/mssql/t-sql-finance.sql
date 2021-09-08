--CREATE FINANCE DB
IF DB_ID('FinanceDB') IS NOT NULL
DROP DATABASE FinanceDB;
go
create database FinanceDB
go
use FinanceDB
-- set up Schema
--CREATE TABLE Jobs
CREATE TABLE Jobs
(
			 jobID int not null,
			 jobTitle varchar(50) not null,
			 income_basic int not null,
			  -- key
			 CONSTRAINT PKjobID  PRIMARY KEY (jobID) 
);
--CREATE TABLE Address
CREATE TABLE Addresses
(
			 addressID int not null,
			 city varchar(50) not null,
			 region varchar(50) not null,
			  -- key
			 CONSTRAINT PKaddressID  PRIMARY KEY (addressID) 
);
-- CREATE TABLE Customer
CREATE TABLE Customer
(
			 customerID int not null,
			 creditCard varchar(50) not null,
			 limit int not null,
			 sex bit not null,
             name varchar(50) not null,
			 date_of_birth datetime not null,
			 email varchar(50) not null,
			 phone_Number varchar(50) not null,
			 jobID int not null,
			 education int not null,
			 addressID int not null,
			  -- key
			 CONSTRAINT PKcustomerID  PRIMARY KEY (customerID) ,
			 CONSTRAINT FKjobID foreign key (jobID) references Jobs(jobID),
			 CONSTRAINT FKaddressID foreign key (addressID) references Addresses(addressID)
);
--CREATE TABLE Employees
CREATE TABLE Employees
(
			 employeeID int not null,
			 name varchar(50) not null,
			 date_of_birth datetime not null,
			 email varchar(50) not null,
			 phone_Number varchar(50) not null,
			 addressID int not null,
			  -- key
			 CONSTRAINT PKemployeeID  PRIMARY KEY (employeeID),
			 CONSTRAINT FKaddressID_E foreign key (addressID) references Addresses(addressID)
);
--CREATE TABLE Transactions

CREATE TABLE Transactions
(
			 transactionID int not null,
			 startDate datetime not null,
			 endDate datetime not null,
			 percents int not null,
             customerID int not null,
			 employeeID int not null,
			  -- key
			 CONSTRAINT PKtransactionID  PRIMARY KEY (transactionID),
			 CONSTRAINT FKcustomerID foreign key (customerID) references Customer(customerID),
			 CONSTRAINT FKemployeeID foreign key (employeeID) references Employees(employeeID)
);

CREATE TABLE Transactions_Errors
(
			 error_code int,
			 error_Column int,
			 transactionID int,
			 startDate datetime ,
			 endDate datetime ,
			 percents int ,
             customerID int, 
			 employeeID int,

);
-- handle info event
create table SSIS_handling_table(
EIGUID uniqueidentifier not null,
PakageName varchar(50) not null,
SourceName varchar(50) not null,
EventInfo varchar(200) not null,
Timelogged datetime not null default getdate()
);
CREATE TABLE [Error Load] (
    [date_of_birth] varchar(50),
    [email] varchar(50),
    [phone_Number] varchar(50),
    [jobID] varchar(50),
    [education] varchar(50),
    [fullname] varchar(50),
    [customerIDnew] int,
    [limitnew] int,
    [jobIDnew] int,
    [addressIDnew] int,
    [educationnew] int,
    [sexnew] bit,
    [customerID] int,
    [creditCard] varchar(50),
    [ErrorCode] int,
    [ErrorColumn] int
);
Go
-- Create View
CREATE VIEW View_Transaction_Detail AS (
select t.transactionID,c.customerID,cast(YEAR(GETDATE())-YEAR(c.date_of_birth) as float) as age,(year(startDate)*10000+month(startDate)*100+day(startDate))as startDateKey,(year(endDate)*10000+month(endDate)*100+day(endDate))as endDateKey,percents*limit/100 as loan,education,abs(DATEDIFF(month,endDate,startDate)) as MonthReturn,(percents*limit)/(income_basic*12)as percentincome,j.income_basic
from customer c, Transactions t,Jobs j
where c.customerID = t.customerID and c.jobID = j.jobID
)
go


