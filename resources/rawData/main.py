import os
from datetime import datetime
from distutils.dir_util import copy_tree
from faker import Faker
from Object.customer import Customer
from Object.Transaction import Transaction
from Object.jobGroup import Job
from Object.Employee import Employee
import csv
import pandas as pd
from configparser import ConfigParser
fake = Faker()

# range data
list_Data_Job = ['Marketing','Business','Education','Finance', 'Engineering', 'Human resources', 'Information technology', 'Hospitality']
dic_Job_In = [600, 600, 550, 500, 600, 450, 700, 800]
list_city =['New York','Los Angeles','Chicago','Houston','Philadelphia','Phoenix','San Antonio','San Diego']
listState = ['New York','California','Illinois','Texas','Pennsylvania','Arizona','Texas','California']
# gen csv address
def genCSVAddress():
    raw_path = os.path.dirname(__file__)+'/'+'rawdata'
    with open(f'{raw_path}\Address.csv', 'w', newline='') as csvfile:
        fieldnames = ['addressID','city','region']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = range(len(list_city))
        writer.writeheader()
        for i in RECORD_COUNT:
            cus = Customer(i)
            writer.writerow(
                {
                    'addressID': i,
                    'city':list_city[i],
                    'region':listState[i],
                })

    return
# gencsv customer
def genCSVCustomer():
    raw_path = os.path.dirname(__file__)+'/'+'rawdata'
    with open(f'{raw_path}\customer.csv', 'w', newline='') as csvfile:
        fieldnames = ['customerID', 'creditCard', 'limit', 'sex', 'firstname', 'lastname', 'date_of_birth', 'email', 'phone_Number', 'jobID',
                      'education', 'addressID']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = range(1,200)
        writer.writeheader()
        for i in RECORD_COUNT:
            cus = Customer(i)
            writer.writerow(
                {
                    'customerID': cus.customerID,
                    'creditCard': cus.creditCard,
                    'limit': cus.limit,
                    'sex': cus.sex,
                    'firstname': cus.firstname,
                    'lastname': cus.lastname,
                    'date_of_birth': cus.date_of_birth,
                    'email': cus.email,
                    'phone_Number': cus.phone_Number,
                    'jobID': cus.job,
                    'education': cus.education,
                    'addressID': cus.address
                })

    return
#gen csv jobid
def genCSVJob():
    raw_path = os.path.dirname(__file__)+'/'+'rawdata'
    with open(f'{raw_path}\job.csv', 'w', newline='') as csvfile:
        fieldnames = ['jobID', 'jobTitle', 'income_basic']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for i in range(len(list_Data_Job)):
            job = Job(i,list_Data_Job[i],dic_Job_In[i])
            writer.writerow(
                {
                    'jobID':job.jobId,
                    'jobTitle':job.jobTitle,
                    'income_basic':job.income_basic
                })
#gen data Employee
def genCSVEmployee():
    raw_path = os.path.dirname(__file__)+'/'+'rawdata'
    with open(f'{raw_path}\employee.csv', 'w', newline='') as csvfile:
        fieldnames = ['employeeID','name','date_of_birth','email','phone_Number','addressID']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = range(0,99)

        writer.writeheader()
        for i in RECORD_COUNT:
            emp = Employee(i)
            writer.writerow(
                {
                    'employeeID':emp.employee,
                    'name':emp.name,
                    'date_of_birth':emp.date_of_birth,
                    'email':emp.email,
                    'phone_Number':emp.phone_Number,
                    'addressID':emp.address
                })
# transaction
def genCSVTransation():
    raw_path = os.path.dirname(__file__)+'/'+'rawdata'
    with open(f'{raw_path}\Transaction.csv', 'w', newline='') as csvfile:
        fieldnames = ['transactionID','startDate','endDate','percents','customerID','employeeID']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = range(100,2000)
        writer.writeheader()
        for i in RECORD_COUNT:
            tran = Transaction(i)
            writer.writerow(
                {
                    'transactionID':tran.transactionID,
                    'startDate':tran.startDate,
                    'endDate':tran.endDate,
                    'percents':tran.percent,
                    'customerID':tran.customerID,
                    'employeeID':tran.employeeID
                })



if __name__ == '__main__':
    print('Creating a fake data...')
    genCSVAddress()
    genCSVCustomer()
    genCSVJob()
    genCSVEmployee()
    genCSVTransation()
    print('Copy Data to Working Folder')
    copy_tree('./rawdata', './workfolder')
    print("Loadding done")