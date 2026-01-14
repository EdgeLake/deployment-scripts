import requests


def rest_request(request_type:str, conn:str, headers:dict, payload:str=None):
    """
    Generic REST request method
    :args:
        conn:str - REST connection information
        headers:dict - REST headers
        payload:str  - request payload
    :params:
        response:requests.${request_type} - response for cURL request
    :return:
        response
    """
    response = None
    try:
        if request_type.lower() == 'get':
            response = requests.get(url=f'http://{conn}', headers=headers, data=payload)
        elif request_type.lower() == 'post':
            response = requests.post(url=f'http://{conn}', headers=headers, data=payload)
        response.raise_for_status()
    except Exception as error:
        raise Exception(f"Failed to execute {request_type.upper()} against {conn} (Error: {error})")
    return  response


def get_tables(conn:str, db_name:str)->dict:
    """
    get list of tables getting data
    :args:
        conn:str - REST connection
        db_name:str - logical database name
    :params:
        tables:dict - list of tables
    :return:
        tables
    """
    tables = {}

    headers = {
        'command': 'get streaming where format=json',
        "User-Agent": "AnyLog/1.23"
    }

    response = rest_request(request_type='get', conn=conn, headers=headers)
    for row in response.json():
        if 'table' in row and db_name in row['table']:
            tables[row['table'].split('.')[-1]] = {}
    return tables


def get_columns(conn:str, db_name:str, table:str, insert_timestamp:bool=False):
    """
    Get list of columns and their corresponding data types
    :args:
        conn:str - REST connection
        db_name:str - logical database name
        table:str - logical table name
        insert_timestamp:bool - use `insert_timestamp` (True) instead of user-defined timestamp column if exists
    :params:
        columns:dict - columns and types
        timestamp_column:str - timestamp column
        headers:dict - REST header information
    :return:
        columns
    """
    columns = {}
    timestamp_column = 'insert_timestamp'
    headers = {
        'command': f'get columns where dbms={db_name} and table={table} and format=json',
        'User-Agent': 'AnyLog/1.23'
    }

    response = rest_request(request_type='get', conn=conn, headers=headers)
    data = response.json()

    for column in data:
        if column not in ['row_id', 'insert_timestamp', 'tsd_name', 'tsd_id']:
            if data[column].strip().split(' ', 1)[0] == 'timestamp' and insert_timestamp is False:
                timestamp_column = column
            else:
                columns[column] = data[column]
            # elif data[column] in ['numeric', 'double', 'decimal', 'integer', 'float', 'int']:
            #     columns[column] = data[column]
    columns[timestamp_column] = 'timestamp'

    return columns


def declare_aggregation(conn:str, db_name:str, table_name:str, interval:int, time_frame:str, time_column:str,
                        value_column:str, store_aggregations:bool=False, target_dbms:str=None, target_table:str=None):
    """
    Build an AnyLog request to set aggregations
    :args:
        db_name:str - logical database name
        table_name:str - logical table name
        interval:int - number of intervals
        time_frame:str - length of each interval
        time_column:str - timestamp column
        value_column:str - value column name
    :params:
        command:str - generated command
    :return:
        command
    """
    command = f"""set aggregations where 
        dbms={db_name} and 
        table={table_name} and
        intervals={interval} and 
        time={time_frame} and
        time_column={time_column} and
        value_column={value_column}
    """.replace("\n", "")
    while "  " in command:
        command = command.replace("  ", " ")
    if store_aggregations and target_dbms:
        command += f" and target_dbms={target_dbms}"
    if store_aggregations and target_table:
        command += f" and target_table={target_table}"

    rest_request(request_type="POST", conn=conn, headers={"command": command, "User-Agent": "AnyLog/1.23"})

def set_ingestion(conn:str, db_name:str, frequency:str, interval:str=None, table_name:str=None)
    command = f"""set ingestion in aggregations where 
        dbms={db_name} and 
        frequency={frequency}
    """.replace("\n", "")
    while "  " in command:
        command = command.replace("  ", " ")

    if frequency == "time" and interval:
        command += f" and interval={interval}"
    elif frequency == "time" and not interval:
        raise ValueError("Interval required for time frequency")
    if table_name:
        command += f" and table={table_name}"

    rest_request(request_type="POST", conn=conn, headers={"command": command, "User-Agent": "AnyLog/1.23"})