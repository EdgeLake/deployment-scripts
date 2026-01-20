def create_policy(db_name:str, table_name:str, timestamp_column:str, value_columns:list, interval:int,
                  interval_time:str, per_column:bool=False):
    """
    Create base for aggregation policy
    :args:
        db_name:str - logical database name
        table_name:str - logical table name
        timestamp_column:str - timestamp column
        value_columns:list - list of value column(s)
        interval:int - Number of intervals to keep in aggregation
        interval_time:int - how long each interval is for aggregating data
        per_column:bool - if per column is set to true include `value_column` info in new_policy
    :params:
        new_policy:dict - new policy
        command:str - `set aggregation where ...` command
    :return:
        new_policy
    """
    new_policy = {
        "aggregation": {
            "dbms": db_name,
            "table": table_name,
            **({"value_column": value_columns[0]} if per_column else {}),
            "script": [],
        }
    }

    command = f'set aggregation where dbms={db_name} and table={table_name} and intervals={interval} and time="{interval_time}" and time_column={timestamp_column} and value_column=%s'

    if isinstance(value_columns, str):
        new_policy["aggregation"]["script"].append(command % value_columns)
    else:
        for value_column in value_columns:
            new_policy["aggregation"]["script"].append(command % value_column)

    return new_policy


def define_ingestion(new_policy:dict, db_name:str, table_name:str, keep_source:bool=True, keep_aggregation:bool=False):
    """
    define data ingestion
    :args:
        new_policy:dict - aggregation policy
        db_name:str - logical database name
        table_name:str - logical table name
        keep_source:bool - store raw data into operator node(s)
        keep_aggregation:bool - store aggregation results / derived data into operator node(s)
    :params:
        new_policy:dict - new policy
        command:str - `set aggregation ingest where ...` command
    :return:
        new_policy
    """
    command = f"set aggregation ingest where dbms={db_name} and table={table_name} and source=%s and derived=%s"

    new_policy["aggregation"]["script"].append(command % ("true" if keep_source else "false",
                                                          "true" if keep_aggregation else "false"))

    return new_policy


def define_encoding(new_policy:dict, db_name:str, table_name:str, value_columns:list, encoding_type:str=None,
                    tolerance_level:int=None):
    """
    define data encoding
    :args:
        new_policy:dict - aggregation policy
        db_name:str - logical database name
        table_name:str - logical table name
        value_column:str - value column name
        encoding_type:str - encoding type
            * None
            * bounds
            * arel
        tolerance_level:int - percentage difference - Approximated Run-Length Encoding, allowable difference between
                              consecutive values while treating them as part of the same group or segment.
    :params:
        new_policy:dict - new policy
        command:str - `set aggregation ingest where ...` command
    :return:
        new_policy
    """
    command = f"set aggregation encoding where dbms={db_name} and table={table_name} and value_column=%s"
    if encoding_type:
        command += f" and encoding={encoding_type}"
    if tolerance_level:
        command += f" and tolerance={tolerance_level}"

    if isinstance(value_columns, str):
        new_policy["aggregation"]["script"].append(command % value_columns)
    else:
        for value_column in value_columns:
            new_policy["aggregation"]["script"].append(command % value_column)

    return new_policy

