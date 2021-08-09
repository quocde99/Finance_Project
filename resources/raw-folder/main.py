import csv
import os
from datetime import datetime
from faker import Faker
from customer import Customer
from Transaction import Transaction
from jobGroup import Job
from Employee import Employee
import pyodbc
import csv
import pandas as pd
from configparser import ConfigParser
fake = Faker()


def create_csv_file_Order_Line():
    time_stampe = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")
    raw_path = os.path.dirname(__file__)
    with open(f'{raw_path}\hitData-{time_stampe}.csv', 'w', newline='') as csvfile:
        fieldnames = ['Line_Item_ID', 'Order_ID', 'Product_ID', 'Quantity', 'Is_Returned', 'Return_Reason_ID']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = 10
        writer.writeheader()
        for i in range(RECORD_COUNT):
            writer.writerow(
                {
                    'Line_Item_ID': i,
                    'Order_ID': fake.random_int(0,56892),
                    'Product_ID': fake.random_int(0,8323),
                    'Quantity': fake.random_int(1,100),
                    'Is_Returned': fake.boolean(chance_of_getting_true=25),
                    'Return_Reason_ID': fake.random_int(1,6)
                }
            )
#gen by oject
# def genCSV(object,record):
#     raw_path = os.path.dirname(__file__)
#     print(raw_path)
#     ex1 = object(1)
#     fieldList = []
#     for i in vars(ex1):
#         fieldList.append(i)
#     with open(f'{raw_path}\hitData-{object.__name__}.csv', 'w', newline='')as csvfile:
#         writer = csv.DictWriter(csvfile, fieldnames=fieldList)
#         arr = []
#         writer.writeheader()
#         for i in range(record):
#             new = object(i)
#             arr.append(new)
#         for i in arr:
#             writer.writerow(i)

# range data
list_Data_Job = ['Marketing','Business','Education','Finance', 'Engineering', 'Human resources', 'Information technology', 'Hospitality']
dic_Job_In = [600, 600, 550, 500, 600, 450, 700, 800]
def load_address():
    raw_path = os.path.dirname(__file__)
    path = raw_path +'/'+"raw_path/city.csv"
    data = pd.read_csv(path)
    df = pd.DataFrame(data, columns=['id', 'city', 'state'])
    return df
def configData(filename = 'config.ini', section='mssql'):
    parser = ConfigParser()
    parser.read(filename)
    db = {}
    if parser.has_section(section):
        items = parser.items(section)
        for item in items:
            db[item[0]] = item[1]
    else:
        raise Exception('{0} not found in the {1} file'.format(section, filename))
    return db

# connect SQL
def connect_SQL():
    dbConfig = configData()
    conn = pyodbc.connect(**dbConfig)
    return conn

if __name__ == '__main__':
    print('Creating a fake data...')
    # connect_SQL()
    conn = connect_SQL()
    cursor = conn.cursor()
    # fake data address
    df = load_address()
    for row in df.itertuples():
        storedProc = "Exec [InsertAddresses]  @addressID = ?, @city = ?, @region=?"
        params = (row.id, row.city, row.state)
        # Execute Stored Procedure With Parameters
        cursor.execute(storedProc, params)
    conn.commit()
    # # gen job
    for i in range(len(list_Data_Job)):
        job = Job(i, list_Data_Job[i], dic_Job_In[i])
        storedProc = "Exec [InsertJobs]  @jobID = ?, @jobTitle = ?, @income_basic=?"
        params = (job.jobId, job.jobTitle, job.income_basic)
        # Execute Stored Procedure With Parameters
        cursor.execute(storedProc, params)
    conn.commit()
    # gen customer
    for i in range(1000):
        customer = Customer(i)
        storedProc = "Exec [InsertCustomer]  @customerID=?, @creditCard=?, @limit=?, @sex=?, @name=?, @date_of_birth=?, @email=?, @phone_Number=?, @jobID=?, @education=?, @addressID=?"
        params = (customer.customerID, customer.creditCard,customer.limit,customer.sex,customer.name,customer.date_of_birth,customer.email,customer.phone_Number,customer.job,customer.education,customer.address)
        # Execute Stored Procedure With Parameters
        cursor.execute(storedProc, params)
    conn.commit()
    #gen employee
    for i in range(100):
        employee = Employee(i)
        storedProc = "Exec [InsertEmployees]  @employeeID=? , @name=?, @date_of_birth=?, @email=?, @phone_Number=?, @addressID=?"
        params = (employee.employee,employee.name,employee.date_of_birth,employee.email,employee.phone_Number,employee.address)
        # Execute Stored Procedure With Parameters
        cursor.execute(storedProc, params)
    conn.commit()
    #gen transaction
    for i in range(10000):
        tran = Transaction(i)
        storedProc = "Exec [InsertTransactions] @transactionID=?, @startDate=?, @endDate=?, @percents=?, @customerID=?,@employeeID=?"
        params = (tran.transactionID,tran.startDate,tran.endDate,tran.percent,tran.customerID,tran.employeeID)
        # Execute Stored Procedure With Parameters
        cursor.execute(storedProc, params)
    conn.commit()
    print("Loadding done")