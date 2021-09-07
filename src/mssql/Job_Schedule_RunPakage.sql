--CREATE MSBD
IF DB_ID('msdb') IS NOT NULL
DROP DATABASE msdb;
go
create database msdb
USE [msdb]
GO
--set environment deploy pakage
EXEC [SSISDB].[catalog].[create_environment] @environment_name=N'Project2', @environment_description=N'', @folder_name=N'project 2'
GO
DECLARE @var sql_variant = N'C:\Users\NhatLQ3\Downloads\Finance_Project-master\Finance_Project-master' --You should change link to folder.
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'Link', @sensitive=False, @description=N'Link to folder', @environment_name=N'Project2', @folder_name=N'project 2', @value=@var, @data_type=N'String'
GO
DECLARE @var sql_variant = N'CVP00204895A\NHATKQ3FSOFT'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'Servername', @sensitive=False, @description=N'Name Server', @environment_name=N'Project2', @folder_name=N'project 2', @value=@var, @data_type=N'String'
GO
DECLARE @var sql_variant = N'Dsn=PROJECT1;uid=NhatLQ3;pwd=Nhat123456' --account,pwd of snow account
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'snowserver', @sensitive=False, @description=N'Snowfile', @environment_name=N'Project2', @folder_name=N'project 2', @value=@var, @data_type=N'String'
GO
--Set Environment config pakage
USE [msdb]
Declare @reference_id bigint
EXEC [SSISDB].[catalog].[create_environment_reference] @environment_name=N'Project2', @reference_id=@reference_id OUTPUT, @project_name=N'Project2', @folder_name=N'project 2', @reference_type=R
Select @reference_id
GO
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=30, @parameter_name=N'Servername', @object_name=N'Finance.dtsx', @folder_name=N'project 2', @project_name=N'Project2', @value_type=R, @parameter_value=N'Servername'
GO
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=30, @parameter_name=N'link', @object_name=N'Finance.dtsx', @folder_name=N'project 2', @project_name=N'Project2', @value_type=R, @parameter_value=N'Link'
GO
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=30, @parameter_name=N'snowserver', @object_name=N'Finance.dtsx', @folder_name=N'project 2', @project_name=N'Project2', @value_type=R, @parameter_value=N'snowserver'
GO
--SET Environment for execute
USE [msdb]
-- EXECUTE parameter_pakages Pakages
Declare @execution_id bigint
EXEC [SSISDB].[catalog].[create_execution] @package_name=N'Finance.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'project 2', @project_name=N'Project2', @use32bitruntime=False, @reference_id=5, @runinscaleout=False
Select @execution_id
DECLARE @var0 smallint = 1
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var0
GO

--Create job
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SSIS Deploy', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]'
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SSIS Deploy', @server_name = @@SERVERNAME
GO
USE [msdb]
GO
Declare @reference_id nvarchar(max) = (SELECT reference_id
  FROM [SSISDB].[internal].[environment_references]
  WHERE environment_name = 'Project2');
Declare @command nvarchar(max) = '/ISSERVER "\"\SSISDB\project 2\Project2\Finance.dtsx\"" /SERVER "\".\"" /ENVREFERENCE '+ @reference_id +' /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E'
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SSIS Deploy', @step_name=N'SSIS pakage', 
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
EXEC msdb.dbo.sp_update_job @job_name=N'SSIS Deploy', 
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
--SET SCHEDULE JOB
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'SSIS Deploy', @name=N'Run SSIS Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210906, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
GO


EXEC [SSISDB].[catalog].[start_execution] @execution_id
GO
