# Aggregation Script

Aggregation functions summarize streaming data over a time interval. Users define (per table) the time interval and the 
number of intervals per each table to allow continuous aggregations. The aggregated values can be queried or used to 
impact the database updates and monitoring.

Aggregation functions are used to summarize streaming data over a specified time interval. These functions process 
incoming data continuously, computing key statistics such as counts, sums, averages, or max/min values over defined 
periods.

Users define, per table, the length of time interval and the number of intervals to maintain.

For a detailed description, please refer to the <a href="https://github.com/AnyLog-co/documentation/blob/master/aggregations.md" target="_blank">documentation</a>.

## Running Aggregations

Aggregations are pretty straightforward to implement, 4 key things: 
* Database and table name 
* Timestamp column 
* Aggregation column(s) 
* Frequency of aggregation. 

Since time-series tables often have multiple columns, or there are multiple tables that require aggregation, we developed 
a python3 script that automates the process. The script also allows you to automatically. Alternatively, if the tables
have a simple timestamp/value column naming logic, aggregations can be done automatically via docker configurations. 

The process by then aggregations is done is broken into 3 simple parts: 
1. actual aggregations 
2. Whether to store the raw data or only summary of the aggregations
3. If you'd like to only store aggregations, a logic to for push data if value(s) are suddenly out of bounds 

## Docker Initiated Aggregations

A Docker-based configuration of aggregation ensures that aggregations is ready to go **before** data begins to ingest, 
and is done **automatically**, as it is integrated into the automated process. 

**Steps**: In the advanced configurations file, simply enable aggregations and specify the relevant configurations. Everything
else will be done automatically. 

The script being used for configuration based can be found [here](../sample-scripts/aggregation.al) 

## Python Initiated Aggregations 
A python initiated aggregation process is done manually, but also for great granulation of aggregation as it allows the user
to better drill-down with the configuration. The catch with this is because it's a REST based process aggregations 
aren't initiated automatically. 

**Steps**:
1. Attach into the executable of the node
```shell
cd docker-compose 
make exec ANYLOG_TYPE=[node-name]
```

2. Under `/app/deployment-scripts/aggregations` run [aggregations.py](aggregations.py). 
```shell
python3 /app/deployment-scripts/aggregations/aggregations.py --help 
<<COMMENT
:positional arguments:
    conn                  REST connection
    db_name               logical database
:options:
    -h, --help                                              show this help message and exit
    --table-name                TABLE_NAME                  logical table name
    --timestamp-column          TIMESTAMP_COLUMN            timestamp column name
    --value-column              VALUE_COLUMN                value column name (can be comma separated)
    --aggregations-intervals    AGGREGATIONS_INTERVALS      number of aggregation intervals to keep
    --aggregations-time         AGGREGATIONS_TIME           time window for each aggregation
    --enable-ingest             [ENABLE_INGEST]             Whether to enable ingestion for aggregation tables
    --ingest-raw-data           [INGEST_RAW_DATA]           Ingest raw data
    --ingest-aggregation-data   [INGEST_AGGREGATION_DATA]   Ingest aggregations data
    --enable-encoding           [ENABLE_ENCODING]           Enable value encoding
    --encoding-tolerance        ENCODING_TOLERANCE          Encoding tolerance as numeric percentage
    --encoding-type             ENCODING_TYPE               Tolerance bounding
        * bounds - all entries in the time interval are replaced with a single entry representing
        * arle - Approximated Run-Length Encoding, the entries in the time interval are represented in a sequence of entries. Each entry includes
    <<
```

**Sample Call**: 
```shell
python3 /app/deployment-scripts/aggregations/aggregations.py 10.0.0.172:32149 lcdb \
  --table-name helios_dlb \
  --timestamp-column timestamp 
  --value-column current,power_limit,max_dc_current,max_ac_current \
  --aggregations-intervals 10 \
  --aggregations-time "1 minute" \
  --enable-ingest \
  --ingest-aggregation-data \
  --enable-encoding \
  --encoding-tolerance 10 \
  --encoding-type bounds
```


