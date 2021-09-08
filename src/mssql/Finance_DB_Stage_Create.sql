IF DB_ID('FinanceStage') IS NOT NULL
DROP DATABASE FinanceStage;
go
create database FinanceStage
go
use FinanceStage
go 
-- customer stage
CREATE TABLE [Customer] (
    [customerID] int primary key,
    [creditCard] varchar(50),
    [limit] int,
    [sex] bit,
    [name] varchar(50),
    [date_of_birth] datetime,
    [email] varchar(50),
    [phone_Number] varchar(50),
    [jobID] int,
    [education] int,
    [addressID] int
)
GO
-- job stage
CREATE TABLE [JobStage] (
    [jobID] int primary key,
    [jobTitle] varchar(50),
    [income_basic] int
)
go 
-- address stage
CREATE TABLE AddressStage(
    [addressID] int primary key,
    [city] varchar(50),
    [region] varchar(50)
)
go
--fact stage
CREATE TABLE [FactStage] (
    [transactionID] int,
    [customerID] int,
    [startDateKey] int,
    [endDateKey] int,
    [loan] int,
    [scorePredict] numeric(15,1)
)
-- stage DimDate
use FinanceStage
go
Create clustered index PK_Transaction
	On [dbo].[FactStage] (transactionID)
Go

Create nonclustered index FX_Transaction 
	On [dbo].[FactStage] (customerID)
Go

/****** Object:  Table [dbo].[date]    Script Date: 8/11/2021 9:29:39 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[date]') AND type in (N'U'))
DROP TABLE [dbo].[date]
GO
/****** Object:  Table [dbo].[date]    Script Date: 8/11/2021 9:29:39 PM ******/
Create table [dbo].[date] (
[date key] [int] not  NULL primary key ,
TheDate Date not null ,
TheDay  int not null,
TheDayName  varchar(20) not null,
TheWeek  int not null ,
TheISOWeek int not null,
TheDayOfWeek  int not null,
TheMonth        int not null,
TheMonthName    varchar(20) not null,
TheQuarter      int not null,
TheYear         int not null,
TheFirstOfMonth date not null,
TheLastOfYear   date not null,
TheDayOfYear   int not null)

DECLARE @StartDate  date = '20180101'; --change start year from here--

DECLARE @CutoffDate date = GETDATE(); --change number year have use from start in DateADD (a, year should change,start year)

;WITH seq(n) AS 
(
SELECT 0 UNION ALL SELECT n + 1 FROM seq
WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
SELECT
datekey			= (DATEPART(YEAR,d)*10000+DATEPART(MONTH,d)*100+DATEPART(DAY,d)),
TheDate         = CONVERT(date, d),
TheDay          = DATEPART(DAY,       d),
TheDayName      = DATENAME(WEEKDAY,   d),
TheWeek         = DATEPART(WEEK,      d),
TheISOWeek      = DATEPART(ISO_WEEK,  d),
TheDayOfWeek    = DATEPART(WEEKDAY,   d),
TheMonth        = DATEPART(MONTH,     d),
TheMonthName    = DATENAME(MONTH,     d),
TheQuarter      = DATEPART(Quarter,   d),
TheYear         = DATEPART(YEAR,      d),
TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
TheDayOfYear    = DATEPART(DAYOFYEAR, d)
FROM d
)
Insert Into [dbo].[date]
SELECT *
From src
ORDER BY TheDate
OPTION (MAXRECURSION 0);
