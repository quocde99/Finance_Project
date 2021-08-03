import csv
import os
import random
from datetime import datetime
from decimal import Decimal
from faker import Faker


fake = Faker()


def create_csv_file_Order_Line():
    time_stampe = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")
    raw_path = os.path.dirname(__file__)
    with open(f'{raw_path}\hitData-{time_stampe}.csv', 'w', newline='') as csvfile:
        fieldnames = ['Line_Item_ID','Order_ID', 'Product_ID','Quantity','Is_Returned', 'Return_Reason_ID']
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

if __name__ == '__main__':
    print('Creating a fake data...')
    create_csv_file_Order_Line()