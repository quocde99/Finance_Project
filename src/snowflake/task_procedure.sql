USE ROLE SYSADMIN;
USE FINANCEDW;
--NDS_ADDRESS TO MODEL--
CREATE OR REPLACE PROCEDURE NDS_ADDRESS()
RETURNS string
LANGUAGE javascript
AS
$$
var result;
var sql_command =
`MERGE INTO "FINANCEDW"."FinanceDatawarehouse"."DIMADDRESSES" t
USING "FINANCEDW"."NDS"."ADDRESS" s
ON t.ADDRESSID = s.ADDRESSID
WHEN matched THEN
UPDATE SET t.CITY = s.CITY, t.REGION = s.REGION;`;
try {
snowflake.execute ({sqlText: sql_command});
result = "Succeeded";
}
catch (err) {
result = "Failed"+err;
}
return result;
$$;

--NDS_JOB_to_model
CREATE OR REPLACE PROCEDURE NDS_JOB()
RETURNS string
LANGUAGE javascript
AS
$$
var result;
var sql_command =
`MERGE INTO "FINANCEDW"."FinanceDatawarehouse"."DIMJOBS" t
USING "FINANCEDW"."NDS"."JOB" s 
ON t.JOBID = s.JOBID
WHEN matched THEN
UPDATE SET t.JOBTITLE = s.JOBTITLE, t.INCOME_BASIC = s.INCOME_BASIC;`;
try {
snowflake.execute ({sqlText: sql_command});
result = "Succeeded";
}
catch (err) {
result = "Failed"+err;
}
return result;
$$;

--NDS_Customer_to_Model--
CREATE OR REPLACE PROCEDURE NDS_Customer()
RETURNS string
LANGUAGE javascript
AS
$$
var result;
var sql_command =
`MERGE INTO "FINANCEDW"."FinanceDatawarehouse"."DIMCUSTOMER" t
USING "FINANCEDW"."NDS"."CUSTOMER" s
ON t.CUSTOMERID = s.CUSTOMERID
WHEN matched THEN
UPDATE SET t.CREDITCARD = s.CREDITCARD, t.LIMIT = s.LIMIT,T.SEX=S.SEX,T.NAME=S.NAME,T.DATE_OF_BIRTH=S.DATE_OF_BIRTH,
            T.EMAIL=S.EMAIL, T.PHONE_NUMBER=S.PHONE_NUMBER,t.JOBSKEY=S.JOBSKEY,T.EDUCATION=S.EDUCATION,T.ADDRESSESKEY=S.ADDRESSESKEY;`;
try {
snowflake.execute ({sqlText: sql_command});
result = "Succeeded";
}
catch (err) {
result = "Failed"+err;
}
return result;
$$;

--pro_NDS_FINANCE_to_Model--
CREATE OR REPLACE PROCEDURE NDS_FINANCE()
RETURNS string
LANGUAGE javascript
AS
$$
var result;
var sql_command =
`MERGE INTO "FINANCEDW"."FinanceDatawarehouse"."FACTFINANCE" t
USING "FINANCEDW"."NDS"."FINANCE" s
ON t.TRANSACTIONID = s.TRANSACTIONID
WHEN matched THEN
UPDATE SET t.CUSTOMERKEY = s.CUSTOMERKEY, t.STARTDATEKEY = s.STARTDATEKEY, T.ENDDATEKEY=S.ENDDATEKEY,
            T.LOAN=S.LOAN, T.CREDITSCORE=S.CREDITSCORE;`;
try {
snowflake.execute ({sqlText: sql_command});
result = "Succeeded";
}
catch (err) {
result = "Failed"+err;
}
return result;
$$;
--TRUNCATE DATA IN DNS--
CREATE OR REPLACE PROCEDURE TRUNCATE_NDS()
RETURNS string
LANGUAGE javascript
AS
$$
var result;
var sql_command1 =`TRUNCATE TABLE "FINANCEDW"."NDS"."ADDRESS";`;
var sql_command2 =`TRUNCATE TABLE "FINANCEDW"."NDS"."JOB";`;
var sql_command3 =`TRUNCATE TABLE "FINANCEDW"."NDS"."CUSTOMER";`;
var sql_command4 =`TRUNCATE TABLE "FINANCEDW"."NDS"."FINANCE";`;
try {
snowflake.execute ({sqlText: sql_command1});
snowflake.execute ({sqlText: sql_command2});
snowflake.execute ({sqlText: sql_command3});
snowflake.execute ({sqlText: sql_command4});
result = "Succeeded";
}
catch (err) {
result = "Failed"+err;
}
return result;
$$;
-- Create Taskadmin
use role securityadmin;
create or replace role taskadmin;
-- set the active role to ACCOUNTADMIN before granting the EXECUTE TASK privilege to the new role
use role accountadmin;
grant execute task on account to role taskadmin;
-- set the active role to SECURITYADMIN to show that this role can grant a role to another role
use role securityadmin;
grant role taskadmin to role sysadmin;

USE ROLE SYSADMIN;
CREATE OR REPLACE SCHEMA TASK_RUN;
USE SCHEMA TASK_RUN;
CREATE OR REPLACE TASK task_master
  warehouse = FINANCEDATAWAREHOUSE
  --  TIMESTAMP_INPUT_FORMAT = 'YYYY-MM-DD HH24'
  schedule = '6 MINUTE'
  WHEN
    SYSTEM$STREAM_HAS_DATA('export_stream') OR SYSTEM$STREAM_HAS_DATA('import_stream')
  as  
    ALTER TASK TASK_MASTER SUSPEND;
    
ALTER TASK task_master SUSPEND;
create or replace task  task_address
  WAREHOUSE = FINANCEDATAWAREHOUSE
  After task_master
  AS Call NDS_ADDRESS();
create or replace task task_job
  WAREHOUSE = FINANCEDATAWAREHOUSE
  AFTER task_address
  AS Call NDS_JOB();
create or replace task task_customer
  WAREHOUSE = FINANCEDATAWAREHOUSE
  AFTER task_job
  AS Call NDS_Customer();
create or replace task task_fact
  WAREHOUSE = FINANCEDATAWAREHOUSE
  AFTER task_customer
  AS Call NDS_FINANCE();
create or replace task task_TRUNCATE_NDS
  WAREHOUSE = FINANCEDATAWAREHOUSE
  AFTER task_fact
  AS Call TRUNCATE_NDS();
USE ROLE ACCOUNTADMIN ;
ALTER TASK task_TRUNCATE_NDS RESUME;
ALTER TASK task_fact RESUME;
ALTER TASK task_customer RESUME;
ALTER TASK task_job RESUME;
ALTER TASK task_address RESUME;
ALTER TASK task_master RESUME;
show tasks;
