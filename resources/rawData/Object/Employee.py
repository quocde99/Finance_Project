from faker import Faker
fake = Faker()
class Employee:
    def __init__(self, empoyeeID):
        self.employee = empoyeeID
        # 0 male 1 female
        self.sex = fake.boolean()
        self.name = fake.name()
        self.date_of_birth = fake.date_between(start_date='-60y', end_date='-18y')
        self.email = fake.email()
        self.phone_Number = fake.phone_number()
        self.address = fake.random_int(0,7)