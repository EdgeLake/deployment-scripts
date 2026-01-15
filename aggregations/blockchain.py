from support import rest_request


def get_tables(conn:str, db_name:str, table_name:str="*"):
    """
    Get list of tables for a given database
    :args:
        conn:str - REST connection
        db_name:str - logical database
        table_name:str - logical table name
    :params:
        headers:dict - REST headers
        response:requests.Response - response from request
    :return:
        list of tables
    """
    headers = {
        "command": f"blockchain get table where dbms={db_name}",
        "User-Agent": "AnyLog/1.23"
    }
    if table_name and table_name != "*":
        headers["command"] += f" and name={table_name}"
    headers["command"] += " bring [*][name] separator=,"

    response = rest_request(request_type="GET", conn=conn, headers=headers)
    return response.text.split(',')


def get_columns(conn:str, db_name:str, table_name:str):
    """
    Get columns based on db and table names
    :args:
        conn:str - REST connection
        db_name:str - logical database
        table_name:str - logical table name
    :params:
        timestamp:str - timestamp column
        columns:list - list of columns
        headers:dict - REST headers
        response:requests.Response - response from request
    :return:
        timestamp, columns
    """
    timestamp = "insert_timestamp"
    columns = []

    headers = {
        "command": f"get columns where dbms={db_name} and table={table_name} and format=json",
        "User-Agent": "AnyLog/1.23"
    }

    response = rest_request(request_type="GET", conn=conn, headers=headers, payload=None)
    raw_columns = response.json()
    for column, column_type in raw_columns.items():
        if column in ["row_id", "insert_timestamp", "tsd_name", "tsd_id"]:
            pass
        elif "timestamp" in column_type and timestamp == "insert_timestamp":
            timestamp = column
        elif not "timestamp" in column_type:
            columns.append(column)

    return timestamp, columns
