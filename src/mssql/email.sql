USE [msdb]
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



-- Create Proxy
USE [msdb]
IF 'runcmd' IN (SELECT [name] FROM [msdb].[dbo].[sysproxies])
	EXEC msdb.dbo.sp_delete_proxy @proxy_name=N'runcmd';

GO
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'runcmd', @credential_name=N'runcmd', 
		@enabled=1;

USE msdb
EXEC msdb.dbo.sp_grant_proxy_to_subsystem
@proxy_name=N'runcmd',
@subsystem_name='CmdExec' 
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem
@proxy_name=N'runcmd',
@subsystem_name='ANALYSISQUERY'
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem
@proxy_name=N'runcmd',
@subsystem_name='ANALYSISCOMMAND'
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem
@proxy_name=N'runcmd',
@subsystem_name='Dts'
GO