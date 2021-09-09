-- you should change sql_variant when  @variable_name=N'link' with the folder of project
-- you should change sql_varian when @variable_name==N'snowserver', DNS should 64bit, and keep the account if you use out snowflake
-- You should change startdate in table intime var @StartDate
IF DB_ID('SSISDB') IS NULL
create database SSISDB;
Use [SSISDB]
--create environment
EXEC [SSISDB].[catalog].[create_environment] @environment_name=N'Project2', @environment_description=N'', @folder_name=N'Project 2'
GO
DECLARE @var sql_variant = N'C:\Users\NhatLQ3\Downloads\Finance_Project-master\Finance_Project-master'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'link', @sensitive=False, @description=N'Link to folder', @environment_name=N'Project2', @folder_name=N'Project 2', @value=@var, @data_type=N'String'
GO
DECLARE @var sql_variant = @@servername
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'Servername', @sensitive=False, @description=N'servername off sql', @environment_name=N'Project2', @folder_name=N'Project 2', @value=@var, @data_type=N'String'
GO
DECLARE @var sql_variant = N'Dsn=PROJECT1;uid=NhatLQ3;pwd=Nhat123456'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'snowserver', @sensitive=False, @description=N'snow account', @environment_name=N'Project2', @folder_name=N'Project 2', @value=@var, @data_type=N'String'
GO

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

--CREATE FINANCESTAGE
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
--Config package with enviroment
Declare @reference_id bigint
EXEC [SSISDB].[catalog].[create_environment_reference] @environment_name=N'Project2', @reference_id=@reference_id OUTPUT, @project_name=N'Finance', @folder_name=N'Project 2', @reference_type=R
GO
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=30, @parameter_name=N'Servername', @object_name=N'Finance.dtsx', @folder_name=N'Project 2', @project_name=N'Finance', @value_type=R, @parameter_value=N'Servername'
GO
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=30, @parameter_name=N'link', @object_name=N'Finance.dtsx', @folder_name=N'Project 2', @project_name=N'Finance', @value_type=R, @parameter_value=N'link'
GO
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=30, @parameter_name=N'snowserver', @object_name=N'Finance.dtsx', @folder_name=N'Project 2', @project_name=N'Finance', @value_type=R, @parameter_value=N'snowserver'
GO
--set job
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SSIS Pakage', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]'
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SSIS Pakage', @server_name = @@SERVERNAME
GO
USE [msdb]
GO
DECLARE @reference_id nvarchar(max)=(SELECT reference_id
  FROM [SSISDB].[internal].[environment_references]
  WHERE environment_name = 'Project2');
Declare @command nvarchar(max) = '/ISSERVER "\"\SSISDB\Project 2\Finance\Finance.dtsx\"" /SERVER "\"'+@@servername+'\"" /ENVREFERENCE '+ @reference_id +' /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E'
	
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SSIS Pakage', @step_name=N'SSIS run pakage', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=@command, 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'SSIS Pakage', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
--set schedule job
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'SSIS Pakage', @name=N'Daily Run Job', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=30, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210908, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
GO


-- Create a Database Mail profile
IF 'Notifications' IN (SELECT [name] FROM [msdb].[dbo].[sysmail_profile])
	EXECUTE msdb.dbo.sysmail_delete_profile_sp
    @profile_name = 'Notifications';

EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'Notifications',  
    @description = 'Profile used for sending error log using Gmail.' ;  
GO
-- Grant access to the profile to the DBMailUsers role  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'Notifications',  
    @principal_name = 'public',  
    @is_default = 1 ;
GO

IF 'Gmail' IN (SELECT [name] FROM [msdb].[dbo].[sysmail_account])
	EXECUTE msdb.dbo.sysmail_delete_account_sp
	@account_name = 'Gmail';

-- Create a Database Mail account  
EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'Gmail',  
    @description = 'Mail account for sending error log notifications.',  
    @email_address = 'nhatle281299@gmail.com',  
    @display_name = 'Automated Mailer',  
    @mailserver_name = 'smtp.gmail.com',
	@mailserver_type = 'SMTP',
    @port = 587,
    @enable_ssl = 1,
    @username = 'nhatle281299@gmail.com',
    @password = 'Nhat123456' ;  
GO

-- Add the account to the profile  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'Notifications',  
    @account_name = 'Gmail',  
    @sequence_number = 1;  
GO

-- Create a Database Mail profile
IF 'Notifications' IN (SELECT [name] FROM [msdb].[dbo].[sysmail_profile])
	EXECUTE msdb.dbo.sysmail_delete_profile_sp
    @profile_name = 'Notifications';

EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'Notifications',  
    @description = 'Profile used for sending error log using Gmail.' ;  
GO
-- Grant access to the profile to the DBMailUsers role  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'Notifications',  
    @principal_name = 'public',  
    @is_default = 1 ;
GO

IF 'Gmail' IN (SELECT [name] FROM [msdb].[dbo].[sysmail_account])
	EXECUTE msdb.dbo.sysmail_delete_account_sp
	@account_name = 'Gmail';

-- Create a Database Mail account  
EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'Gmail',  
    @description = 'Mail account for sending error log notifications.',  
    @email_address = 'nhatle281299@gmail.com',  
    @display_name = 'Automated Mailer',  
    @mailserver_name = 'smtp.gmail.com',
	@mailserver_type = 'SMTP',
    @port = 587,
    @enable_ssl = 1,
    @username = 'nhatle281299@gmail.com',
    @password = 'Nhat123456' ;  
GO

-- Add the account to the profile  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'Notifications',  
    @account_name = 'Gmail',  
    @sequence_number = 1;  
GO

