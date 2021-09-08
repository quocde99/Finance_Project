""" Create Customer Data"""
from faker import Faker  # fake data module for customer

arr_Limit = [1000, 1500, 2000, 3000, 4000, 5000]  # random values

class Customer:
    """ Create Customer Data"""
    def __init__(self, CustomerID):
        """Create init Customer"""
        fake = Faker()  # start obj
        self.customerid = CustomerID
        self.creditcard = fake.credit_card_number()
        self.limit = arr_Limit[fake.random_int(0, 5)]
        # 0 male 1 female
        self.sex = fake.boolean()
        self.firstname = self.genname()
        self.lastname = fake.first_name()
        self.date_of_birth = fake.date_between(start_date="-60y", end_date="-18y")
        self.email = fake.email()
        self.phone_number = fake.phone_number()
        self.job = fake.random_int(0, 7)
        # (1=graduate school, 2=university, 3=high school, 4=others, 5=unknown)
        self.education = fake.random_int(1, 5)
        self.address = fake.random_int(0, 7)

    def genname(self):
        """Create name Customer"""
        fake = Faker()  # start obj
        # create name of customer
        if self.sex:
            return fake.first_name_female()
            # name depend sex
        return fake.first_name_male()


class Employee:
    """ Create Customer Data"""
    def __init__(self, employeeID):
        # init data
        fake = Faker()  # start obj
        self.employee = employeeID
        # 0 male 1 female
        self.sex = fake.boolean()
        self.name = fake.name()
        self.date_of_birth = fake.date_between(start_date="-60y", end_date="-18y")
        self.email = fake.email()
        self.phone_number = fake.phone_number()
        self.address = fake.random_int(0, 7)


class Job:
    """Create class job"""

    def __init__(self, job, jobTitle, income_basic):
        """intnit job"""
        self.jobid = job
        self.jobtitle = jobTitle
        # giá trị lương cơ bản
        self.income_basic = income_basic



class Transaction:
    """Create class Transaction"""

    def __init__(self, TransactionID):
        """intnit transaction"""
        fake = Faker()
        self.transactionid = TransactionID
        self.startdate = fake.date_between(start_date="-3y", end_date="-1y")
        self.enddate = self.genrateenddate()
        self.percent = fake.random_int(30, 100)
        self.customerid = fake.random_int(1, 100)
        self.employeeid = fake.random_int(0, 98)

    def genrateenddate(self):
        """Create class Transaction"""
        while True:
            # cus = fake.random_int(0,5)
            fake = Faker()

            enddate = fake.date_between(start_date="-3y")
            # if cus == 3:
            #     return 0
            if enddate > self.startdate:
                return enddate
