# FIRST PROJECT FA (FINANCE PROJECT)

## I. Decsription of this project

**Define the business needs:** 
Finance- We is trying to evaluate the a *consumer's creditworthiness* (based on historical financial and personal information)

**Solution:**
*We will need to aggregate data based on *transition*, *customer*, *jobs*, *addresses* and *date*. It will be evaluated based on *credit score* (historical financial and personal information)*

## II. Working data

Data is generated based on Python sript. The database (.csv flat files) will include:

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
5. Ingest data from flat file csv
    -  Design SSIS package to ETL the data
    -  Using SSIS pipe line load data
    -  Using SSIS stage data in SQL Server
6. Load data onto SNOWFLAKE
    - Using SSIS load data from SQL Server to Snowflake
7. Visualize data using PowerBI
   - Connect Snowflake source
   - Visualize data

## IV. Set up
1. Login into MSSQL and run [t-sql-finance.sql](./src/mssql/t-sql-finance.sql)

