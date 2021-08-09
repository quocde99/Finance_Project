from faker import Faker
from decimal import Decimal


fake = Faker()
arr_Limit = [1000,1500,2000,3000,4000,5000]
class Customer:
    def __init__(self, CustomerID):
        self.customerID = CustomerID
        self.creditCard = fake.credit_card_number()
        self.limit = arr_Limit[fake.random_int(0, 5)]
        # 0 male 1 female
        self.sex = fake.boolean()
        self.name = self.genName()
        self.date_of_birth = fake.date_between(start_date='-60y', end_date='-18y')
        self.email = fake.email()
        self.phone_Number = fake.phone_number()
        self.job = fake.random_int(0, 7)
        # (1=graduate school, 2=university, 3=high school, 4=others, 5=unknown)
        self.education = fake.random_int(1, 5)
        self.address = fake.random_int(1, 1000)
    def genName(self):
        if(self.sex):
            return fake.first_name_female()
        return fake.first_name_male()
