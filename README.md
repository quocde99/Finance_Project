## FIRST PROJECT FA (FINANCE PROJECT)

## I. Decsription of this project

**Define the business needs:** 
Finance- We is trying to evaluate the a *consumer's creditworthiness* (based on historical financial and personal information)

**Solution:**
*We will need to aggregate data based on *transition*, *customer*, *jobs*, *addresses* and *date*. It will be evaluated based on *credit score* (historical financial and personal information)*

## II. Working data

Data is generated based on Python script. The database (.csv flat files) will include:
1. Address.csv
	This file includes basics data for an address such as addressID, city, region.
2. Job.csv
	This file includes basics data for a job such as jobID, jobTitle, income_basic.
3. Customer.csv
	This file includes basics data for a job such as customerID, creditCard, limit, sex, firstname, lastname, date_of_birth, email, phone_Number, jobID, education, addressID.
4. Employee.csv
	This file includes basics data for an employee such as employeeID, name, date_of_birth, email, phone_Number, addressID.
5. Transaction.csv
	This file includes basics data for an transaction such as transactionID, startDate, endDate, percents, customerID, employeeID.

## III. Detail of work

1. Generate Data
    - Generate rawdata and copy to workfolder
2. Design data pipeline ![data_pipeline](./docs/data_pipeline.png)
3. Design finance database ![finance_database](./docs/finance_database.png)
4. Design the dimensional model schema ![Finance_DW](./docs/Finance_DW.png)
    - Defined Dimensiona tables and Facts tables
    - Design logical data map: [here]()
5. Ingest data from flat file csv
    -  Design SSIS package to ETL the data
    -  Using SSIS pipe line load data to SQL Server (Fiance Database)
    -  Using SSIS stage data in SQL Server (stage)
6. Upload and download data on Snowflake
    -  Using SSIS: upload data and dimDate (auto generated) from SQL Server to Snowflake (schema: NDS)
    -  Using Snowpipe: Python API put file to external stage, then create a pipeline to upload data continuously to Snowflake (to stage: Python_API_Stage)
    -  Using python API to download dim fact tables in warehouse schema to local machine
7. Visualize data using PowerBI
   - Connect Snowflake source
   - Visualize data
   -  Connect Power BI Desktop with Power BI Service

## IV. Set up
1. Install Python package generates fake data: `pip install Faker`
2. Login into MSSQL and run [t-sql-finance.sql](./src/mssql/t-sql-finance.sql)
3. In MSSQL, run [stage-sql-server.sql](./src/mssql/stage-sql-server.sql)
4. Download and install ODBC Driver [here](https://sfc-repo.snowflakecomputing.com/odbc/win64/latest/index.html)
5. Download and install Snowflake SSIS Component [here](https://www.cdata.com/drivers/snowflake/ssis)
6. Open SSIS solution:
   - Change variable logForder with your path that you want to log rows in ETL staging process
   - Deploy environment on SSIS Solution link to SQL server
   - Run SSIS Solution
7. Install packages for python snowpipe
   Install requirement:
  ```bash  
  pip install -r requirements.txt 
  ```
   - Installing the Python SDK `pip install snowflake-ingest`
   - Installing Python connector:
     + Check for Python version: `python --version`
     + Install Python connector: `pip install snowflake-connector-python==<version>`
     + Example: `pip install snowflake-connector-python==3.9.6`
8. Run snowpipe.py [snowpipe.py](./src/snowpipe/snowpipe.py)

## V. Dashboard
1. Overview : [here](https://app.powerbi.com/view?r=eyJrIjoiZmE0YTE4N2QtMTc3OC00MzJiLWJiZDQtYWE3NzE4YzE0ZTkzIiwidCI6ImYwMWU5MzBhLWI1MmUtNDJiMS1iNzBmLWE4ODgyYjVkMDQzYiIsImMiOjEwfQ%3D%3D&pageName=ReportSection)
![DASHBOARD](./docs/DASHBOARD.png)

2. Detail for rank of customer: [here](https://app.powerbi.com/view?r=eyJrIjoiZmE0YTE4N2QtMTc3OC00MzJiLWJiZDQtYWE3NzE4YzE0ZTkzIiwidCI6ImYwMWU5MzBhLWI1MmUtNDJiMS1iNzBmLWE4ODgyYjVkMDQzYiIsImMiOjEwfQ%3D%3D&pageName=ReportSection3cf65f523be593a0e166)
![DASHBOARD1](./docs/DASHBOARD1.png)

Note account trainer (snowflake):

1. Account: longbv1, pass:123456

2. Account: mainq2, pass:123456
