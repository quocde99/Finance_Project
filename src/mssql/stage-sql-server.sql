go
create database FinanceStage
go
use FinanceStage
go 
-- customer stage
CREATE TABLE [Customer] (
    [customerID] int,
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
    [jobID] int,
    [jobTitle] varchar(50),
    [income_basic] int
)
go 
-- address stage
CREATE TABLE AddressStage(
    [addressID] int,
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
go
/****** Object:  Table [dbo].[date]    Script Date: 8/11/2021 9:29:39 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[date]') AND type in (N'U'))
DROP TABLE [dbo].[date]
GO
/****** Object:  Table [dbo].[date]    Script Date: 8/11/2021 9:29:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[date](
	[date key] [int] NULL,
	[full date] [datetime] NULL,
	[day of week] [int] NULL,
	[day num in month] [int] NULL,
	[day num overall] [int] NULL,
	[day name] [nvarchar](9) NULL,
	[day abbrev] [nvarchar](3) NULL,
	[weekday flag] [nvarchar](1) NULL,
	[week num in year] [int] NULL,
	[week num overall] [int] NULL,
	[week begin date] [datetime] NULL,
	[week begin date key] [int] NULL,
	[month] [int] NULL,
	[month num overall] [int] NULL,
	[month name] [nvarchar](9) NULL,
	[month abbrev] [nvarchar](3) NULL,
	[quarter] [int] NULL,
	[year] [int] NULL,
	[yearmo] [int] NULL,
	[fiscal month] [int] NULL,
	[fiscal quarter] [int] NULL,
	[fiscal year] [int] NULL,
	[month end flag] [nvarchar](1) NULL
) ON [PRIMARY]

