#-----------------------------------------------------------------------------------------------------------------------
# Sample commands to connect to PostgresSQL and MongoDB
#   - Postgres is used for storing SQL / time-series data. The default configuration is using SQLite
#   - Mongo is used for storing blobs such as videos and images. The default configuration is storing blobs to file
#-----------------------------------------------------------------------------------------------------------------------
# process !anylog_path/deployment-scripts/demo-scripts/connect_dbms.al

# Configurations

default_dbms = new_company
db_user = admin
db_passwd = demo
db_ip = 127.0.0.1

# connect to Postgres
<connect dbms !default_dbms where
    type=psql and
    user = !db_user and
    password = !db_passwd and
    ip = !db_ip and
    port = 5432 and
    autocommit = true
>

# Connect to MongoDB - note when executing `get connections` you'll see a database called new_company_blobs
<do connect dbms !default_dbms where
    type=mongo and
    ip = !db_ip and
    port = 27017 and
    user = !db_user and
    password = !db_passwd
>
