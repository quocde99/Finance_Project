from faker  import Faker

fake = Faker()
class Transaction:
    def __init__(self, TransactionID):
        self.transactionID = TransactionID
        self.startDate = fake.date_between(start_date='-3y', end_date="-1y")
        self.endDate = self.geneRateEndDate()
        self.percent = fake.random_int(30, 100)
        self.customerID = fake.random_int(0, 999)
        self.employeeID = fake.random_int(0, 99)

    def geneRateEndDate(self):
        while(True):
            cus = fake.random_int(0,5)
            endDate =fake.date_between(start_date='-3y')
            if cus == 3:
                return 0
            if endDate > self.startDate:
                return endDate