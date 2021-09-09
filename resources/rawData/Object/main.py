"""Main run Fake Data"""
import os
from distutils.dir_util import copy_tree
import csv
from faker import Faker
from CreateData import Customer
from CreateData import Transaction
from CreateData import Job
from CreateData import Employee


fake = Faker()

# range data job
list_data_job = [
    "Marketing",
    "Business",
    "Education",
    "Finance",
    "Engineering",
    "Human resources",
    "Information technology",
    "Hospitality",
]
# range data job salary
dic_job_in = [600, 600, 550, 500, 600, 450, 700, 800]
# range data city
list_city = [
    "New York",
    "Los Angeles",
    "Chicago",
    "Houston",
    "Philadelphia",
    "Phoenix",
    "San Antonio",
    "San Diego",
]
# range data State
liststate = [
    "New York",
    "California",
    "Illinois",
    "Texas",
    "Pennsylvania",
    "Arizona",
    "Texas",
    "California",
]
# path folder has rawdata
os.chdir("..")
sourcelink = os.getcwd()
os.makedirs("rawdata", exist_ok=True)
os.makedirs("workfolder",exist_ok=True)
raw_path = os.getcwd() + "/" + "rawdata/"
# gen csv address
def sourcedata():
    """Link source to folder"""
    return sourcelink + "/"


def gencsvaddress():
    """generator data address"""
    with open(raw_path + "Address.csv", "w", newline="") as csvfile:
        fieldnames = ["addressID", "city", "region"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        recourd_count = range(len(list_city))
        writer.writeheader()
        for i in recourd_count:
            writer.writerow(
                {
                    "addressID": i,
                    "city": list_city[i],
                    "region": liststate[i],
                }
            )


# gencsv customer
def gencsvcustomer():
    """Generation data customer"""
    with open(raw_path + "Customer.csv", "w", newline="") as csvfile:
        fieldnames = [
            "customerID",
            "creditCard",
            "limit",
            "sex",
            "firstname",
            "lastname",
            "date_of_birth",
            "email",
            "phone_Number",
            "jobID",
            "education",
            "addressID",
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        recourd_count = range(1, 200)
        writer.writeheader()
        for i in recourd_count:
            cus = Customer(i)
            writer.writerow(
                {
                    "customerID": cus.customerid,
                    "creditCard": cus.creditcard,
                    "limit": cus.limit,
                    "sex": cus.sex,
                    "firstname": cus.firstname,
                    "lastname": cus.lastname,
                    "date_of_birth": cus.date_of_birth,
                    "email": cus.email,
                    "phone_Number": cus.phone_number,
                    "jobID": cus.job,
                    "education": cus.education,
                    "addressID": cus.address,
                }
            )


# gen csv jobid
def gencsvjob():
    """Generator data job"""
    with open(raw_path + "Job.csv", "w", newline="") as csvfile:
        fieldnames = ["jobID", "jobTitle", "income_basic"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for i in range(len(list_data_job)):
            job = Job(i, list_data_job[i], dic_job_in[i])
            writer.writerow(
                {
                    "jobID": job.jobid,
                    "jobTitle": job.jobtitle,
                    "income_basic": job.income_basic,
                }
            )


# gen data Employee
def gencsvemployee():
    """generator data employee"""
    with open(raw_path + "Employee.csv", "w", newline="") as csvfile:
        fieldnames = [
            "employeeID",
            "name",
            "date_of_birth",
            "email",
            "phone_Number",
            "addressID",
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        recourd_count = range(0, 99)

        writer.writeheader()
        for i in recourd_count:
            emp = Employee(i)
            writer.writerow(
                {
                    "employeeID": emp.employee,
                    "name": emp.name,
                    "date_of_birth": emp.date_of_birth,
                    "email": emp.email,
                    "phone_Number": emp.phone_number,
                    "addressID": emp.address,
                }
            )


# transaction
def gencsvtransation():
    """Generator data transaction"""
    with open(raw_path + "Transaction.csv", "w", newline="") as csvfile:
        fieldnames = [
            "transactionID",
            "startDate",
            "endDate",
            "percents",
            "customerID",
            "employeeID",
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        recourd_count = range(100, 2000)
        writer.writeheader()
        for i in recourd_count:
            tran = Transaction(i)
            writer.writerow(
                {
                    "transactionID": tran.transactionid,
                    "startDate": tran.startdate,
                    "endDate": tran.enddate,
                    "percents": tran.percent,
                    "customerID": tran.customerid,
                    "employeeID": tran.employeeid,
                }
            )


if __name__ == "__main__":
    print("Creating a fake data...")
    print("Creating a fake data for Address")
    gencsvaddress()
    print("Creating a fake data for Customer")
    gencsvcustomer()
    print("Creating a fake data for Job")
    gencsvjob()
    print("Creating a fake data for Employee")
    gencsvemployee()
    print("Creating a fake data for Transaction")
    gencsvtransation()
    print("Copy Data to Working Folder")
    #link to folder data
    link = sourcedata()
    copy_tree(link + "rawdata", link + "workfolder")
    print("Loadding done")
