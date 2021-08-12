from faker import Faker
fake = Faker()
class Job:
    def __init__(self, Job, jobTitle, income_basic):
        self.jobId = Job
        self.jobTitle = jobTitle
        # giá trị lương cơ bản
        self.income_basic = income_basic

