from support import rest_request


def declare_aggregations(conn:str, db_name:str, table_name:str="*", timestamp_column:str="insert_timestamp",
                         value_column="value", aggregations_interval=10, aggregations_time="1 minute"):
    """
    Declare aggregations based on provided information
    :command:
        <set aggregation where
            dbms=!aggregations_dbms and
            table=!aggregations_table and
            intervals=!aggregations_intervals and
            time=!aggregations_time  and
            time_column=!aggregation_time_column and
            value_column=!aggregation_value_column>
    :args:
        conn:str - REST connection
        db_name:str - logical database
        table_name:str - logical table name
        timestamp_column:str - timestamp column name
        value_column:str - value column name
        aggregations_intervals:str - number of aggregation intervals to keep
        aggregations_time:str - time window for each aggregation
    :params:
        headers:dict - REST header(s)
    :response:
        raise Exception if fails
    """
    headers = {
        "command": f"set aggregation where dbms={db_name} and table={table_name} and intervals={aggregations_interval} and time={aggregations_time} and time_column={timestamp_column} and value_column={value_column}",
        "User-Agent": "AnyLog/1.23"
    }
    print(headers["command"])
    rest_request(request_type="POST", conn=conn, headers=headers)


def configure_aggregations_ingestion(conn:str, db_name:str, table_name:str="*", ingest_raw_data:bool=False,
                                     ingest_aggregation_data:bool=True):
    """
    modify the ingestion frequency of aggregation tables in the local database.
    :command:
        <set aggregation ingest where
            dbms=!aggregations_table and
            table=!aggregations_table and
            source = !ingest_raw_data and
            derived = !ingest_aggregations>
    :args:
        conn:str - REST connection
        db_name:str - logical database
        table_name:str - logical table name
        ingest_raw_data:str - Ingest raw data
        ingest_aggregation_data:str - Ingest aggregations data
    :params:
        headers:dict - REST headers:
    :response:
        raise Exception if fails
    """
    headers = {
        "command": f"set aggregation ingest where dbms={db_name} and table={table_name} and source={'true' if ingest_raw_data else 'false'} and derived={'true' if ingest_aggregation_data else 'false'}",
        "User-Agent": "AnyLog/1.23"
    }

    rest_request(request_type="POST", conn=conn, headers=headers)


def configure_encoding(conn:str, db_name:str, table_name:str="*", value_column="value", encoding_type:str="bounds",
                       encoding_tolerance:int=None):
    """
    Apply encoding on the values assigned to each time interval
    :command:
        <set aggregations encoding where
            dbms=!aggregations_dbms and
            table=!aggregations_table and
            value_column=!aggregation_value_column and
            encoding = bounds and
            tolerance = !encoding_tolerance>
    :args:
        conn:str - REST connection
        db_name:str - logical database
        table_name:str - logical table name
        timestamp_column:str - timestamp column name
        value_column:str - value column name
        encoding_type:str - Tolerance bounding
            * bounds - all entries in the time interval are replaced with a single entry representing
            * arle - Approximated Run-Length Encoding, the entries in the time interval are represented in a sequence of entries. Each entry includes
        encoding_tolerance:int - Encoding tolerance as numeric percentage
    """
    headers = {
        "command": f"set aggregations encoding where dbms={db_name} and table={table_name} and value_column={value_column} and encoding={encoding_type}",
        "User-Agent": "AnyLog/1.23"
    }

    if encoding_tolerance:
        headers["command"] += f" tolerance={encoding_tolerance}"

    rest_request(request_type="POST", conn=conn, headers=headers, payload=None)