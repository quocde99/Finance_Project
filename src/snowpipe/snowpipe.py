import os
import time
import datetime
from datetime import timedelta
import logging
import tempfile
from logging import getLogger
from snowflake.ingest import SimpleIngestManager
from snowflake.ingest import StagedFile
from requests import HTTPError
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.serialization import Encoding
from cryptography.hazmat.primitives.serialization import PrivateFormat
from cryptography.hazmat.primitives.serialization import NoEncryption
import snowflake.connector


# Get workfolder and src folder path
def data_path():
    src_path = os.getcwd()
    os.chdir("..")
    os.chdir("..")
    updata_path = os.getcwd() + "/resources/rawData/updata"
    downdata_path = os.getcwd() + "/resources/rawData/downdata"
    return updata_path, src_path, downdata_path


updata_path, src_path, downdata_path = data_path()


# Python API to execute snowsql command
conn = snowflake.connector.connect(
    account="lf68175.central-us.azure", user="NHATLQ3", password="Nhat123456"
)
conn.cursor().execute("USE DATABASE FINANCEDW;")
conn.cursor().execute("USE WAREHOUSE FINANCEDATAWAREHOUSE;")
conn.cursor().execute("USE SCHEMA FINANCEDW.NDS;")
conn.cursor().execute("REMOVE @PYTHON_API_STAGE;")
conn.cursor().execute(
    "PUT file:///" + updata_path + "/Finance.csv @PYTHON_API_STAGE OVERWRITE=TRUE;"
)
conn.close()


logging.basicConfig(
    filename=tempfile.gettempdir() + "\\ingest.log", level=logging.DEBUG
)
logger = getLogger(__name__)

# If you generated an encrypted private key, implement this method to return
# the passphrase for decrypting your private key.
def get_private_key_passphrase():
    return "<private_key_passphrase>"


with open(src_path + "/rsa_key.p8", "rb") as pem_in:
    pemlines = pem_in.read()
    private_key_obj = load_pem_private_key(
        pemlines, "Nhat123456".encode(), default_backend()
    )

# private key in PEM format
private_key_text = private_key_obj.private_bytes(
    Encoding.PEM, PrivateFormat.PKCS8, NoEncryption()
).decode("utf-8")


# List of files in the stage specified in the pipe definition
file_list = ["Finance.csv.gz"]
ingest_manager = SimpleIngestManager(
    account="lf68175.central-us.azure",
    host="lf68175.central-us.azure.snowflakecomputing.com",
    user="NHATLQ3",
    pipe="FINANCEDW.NDS.FINANCE_PIPE",
    private_key=private_key_text,
)

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


# Data loaded to Finance_stream table, then will be merge with Finance table (to avoid duplicating data)
conn = snowflake.connector.connect(
    account="lf68175.central-us.azure", user="NHATLQ3", password="Nhat123456"
)
conn.cursor().execute("USE ROLE SYSADMIN")
conn.cursor().execute("USE DATABASE FINANCEDW;")
conn.cursor().execute("USE WAREHOUSE FINANCEDATAWAREHOUSE;")
conn.cursor().execute('USE SCHEMA "FINANCEDW"."FinanceDatawarehouse";')
conn.cursor().execute(
    """
MERGE INTO "FINANCEDW"."FinanceDatawarehouse".FACTFINANCE USING "FINANCEDW"."NDS".FINANCE_STREAM 
    ON FACTFINANCE.TRANSACTIONID = FINANCE_STREAM.TRANSACTIONID
    WHEN NOT MATCHED THEN INSERT (TRANSACTIONID, CUSTOMERKEY, STARTDATEKEY, ENDDATEKEY, LOAN, CREDITSCORE)
    VALUES (FINANCE_STREAM.TRANSACTIONID, FINANCE_STREAM.CUSTOMERKEY,
    FINANCE_STREAM.STARTDATEKEY, FINANCE_STREAM.ENDDATEKEY,
    FINANCE_STREAM.LOAN, FINANCE_STREAM.CREDITSCORE);
"""
)

# Downdata from snowflake to local
conn.cursor().execute('USE SCHEMA "FINANCEDW"."FinanceDatawarehouse";')
list_table = ["DIMCUSTOMER", "DIMDATE", "DIMADDRESSES", "DIMJOBS", "FACTFINANCE"]
for i in list_table:
    conn.cursor().execute(
        "COPY INTO @%"
        + i
        + "/downdata/"
        + i
        + '.csv from "FINANCEDW"."FinanceDatawarehouse".'
        + i
        + ' file_format = (format_name ="CSV_FILE" compression=none)'
        + " single = True max_file_size = 4900000000 OVERWRITE=TRUE;"
    )
    conn.cursor().execute(
        "GET @%" + i + "/downdata/" + i + ".csv file://" + downdata_path + ";"
    )
conn.close()


# This means Snowflake has received file and will start loading
assert resp["responseCode"] == "SUCCESS"
# Needs to wait for a while to get result in history
while True:
    history_resp = ingest_manager.get_history()
    if len(history_resp["files"]) > 0:
        print("Ingest Report:\n")
        print(history_resp)
        break
    else:
        # wait for 20 seconds
        time.sleep(20)
    hour = timedelta(hours=1)
    date = datetime.datetime.utcnow() - hour
    history_range_resp = ingest_manager.get_history_range(date.isoformat() + "Z")

    print("\nHistory scan report: \n")
    print(history_range_resp)
