from logging import getLogger
from snowflake.ingest import SimpleIngestManager
from snowflake.ingest import StagedFile
from snowflake.ingest.utils.uris import DEFAULT_SCHEME
from datetime import timedelta
from requests import HTTPError
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.serialization import Encoding
from cryptography.hazmat.primitives.serialization import PrivateFormat
from cryptography.hazmat.primitives.serialization import NoEncryption
import time
import datetime
import os
import logging
import snowflake.connector


## Flow: Python API to put file to external stage on snowflake (snowpipe take data in external stage to load into table)


conn = snowflake.connector.connect(
    account='lf68175.central-us.azure',
    user='NHATLQ3',
    password='Nhat123456')
    # private_key=private_key_text

conn.cursor().execute("USE DATABASE FINANCEDW;")
conn.cursor().execute("USE WAREHOUSE FINANCEDATAWAREHOUSE;")
conn.cursor().execute("USE SCHEMA FINANCEDW.TEST;")           # Nhớ fix test
conn.cursor().execute("PUT file:///C:/Users/thuchh/Downloads/Finance_Project-master/Finance_Project-master/resources/rawData/workfolder/customer.csv @PYTHON_API_STAGE OVERWRITE=TRUE;")                               
conn.close()
#PUT file:///C://Users//thuchh//Downloads//Finance_Project-master//Finance_Project-master//resources//rawData//workfolder//customer.csv @PYTHON_API_STAGE OVERWRITE=TRUE;
#COPY INTO FINANCEDW.TEST.CUSTOMER purge = true file_format = CSV_FILE pattern = 'customer.csv.gz';

#PUT file:///C:\Users\thuchh\Downloads\Finance_Project-master\Finance_Project-master\resources\rawData\workfolder\customer.csv @PYTHON_API_STAGE
# snowsql -a lf68175.central-us.azure -u nhatlq3

"""
# Putting Data
con.cursor().execute("PUT file:///tmp/data/file* @%testtable OVERWRITE=TRUE")    # @ là quăng vào stage trên snowflake; @% là quăng vào external stage của snowflake mà không cần tạo bảng
con.cursor().execute("COPY INTO testtable")
"""







logging.basicConfig(
        filename= r"C:/Users/thuchh/AppData/Local/Temp/ingest.log",                      # /tmp/ingest.log
        level=logging.DEBUG)
logger = getLogger(__name__)

# If you generated an encrypted private key, implement this method to return
# the passphrase for decrypting your private key.
def get_private_key_passphrase():
  return '<private_key_passphrase>'

with open("rsa_key.p8", 'rb') as pem_in:
  pemlines = pem_in.read()
  private_key_obj = load_pem_private_key(pemlines,
  'Nhat123456'.encode(),
  default_backend())

private_key_text = private_key_obj.private_bytes(
  Encoding.PEM, PrivateFormat.PKCS8, NoEncryption()).decode('utf-8')
# Assume the public key has been registered in Snowflake:
# private key in PEM format


# List of files in the stage specified in the pipe definition
file_list=['customer.csv.gz']                                                                     # 'employee.csv.gz'                                              
ingest_manager = SimpleIngestManager(account='lf68175.central-us.azure',
                                     host='lf68175.central-us.azure.snowflakecomputing.com',      # if error: <account_identifier>.snowflakecomputing.com
                                     user='NHATLQ3',
                                     pipe='FINANCEDW.test.mypipe',       #nhớ fix test            # lưu ý là load vào pipe => cẩn thận sai schema
                                     private_key=private_key_text)
# List of files, but wrapped into a class
staged_file_list = []                                                           
for file_name in file_list:
    staged_file_list.append(StagedFile(file_name, None))

try:
    resp = ingest_manager.ingest_files(staged_file_list)
except HTTPError as e:
    # HTTP error, may need to retry
    logger.error(e)
    exit(1)

# This means Snowflake has received file and will start loading
assert(resp['responseCode'] == 'SUCCESS')

# Needs to wait for a while to get result in history
while True:
    history_resp = ingest_manager.get_history()

    if len(history_resp['files']) > 0:
        print('Ingest Report:\n')
        print(history_resp)
        break
    else:
        # wait for 20 seconds
        time.sleep(20)

    hour = timedelta(hours=1)
    date = datetime.datetime.utcnow() - hour
    history_range_resp = ingest_manager.get_history_range(date.isoformat() + 'Z')

    print('\nHistory scan report: \n')
    print(history_range_resp)