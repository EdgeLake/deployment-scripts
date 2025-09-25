import argparse
import requests
import json


def __rest_request(request_type:str, conn:str, headers:dict, payload:str=None):
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

def create_tags(conn:str, policy_type:str, dbms:str, table:str, column_name:str, column_type:str):
    """
    Publish tags for table / columns to blockchain
    :args:
        conn:str - REST connection information
        policy_type:str - blockchain policy type
        dbms:str - logical database name
        table:str - logical table name
        column_name:str - column name
        column_type:str - column type
    :params:
        payload:dict - policy to publish on blockchain
        headers:dict - REST headers
        new_policy:str - !new_policy param
        response:requests.POST
    :return:
        success - None
        error - raise Exception
    """
    payload = {
        policy_tag_name: {
            "dbms": dbms,
            "table": table,
            "column_name": column_name,
            "column_type": column_type # <-- optional
        }
    }

    headers = {
        "command": "blockchain insert where policy=!new_policy and local=true and master=!ledger_conn",
        "User-Agent": "AnyLog/1.23",
    }
    new_policy=f"<new_policy={json.dumps(payload)}>"

    response = __rest_request(request_type='post', conn=conn, headers=headers, payload=new_policy)


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

    response = __rest_request(request_type='get', conn=conn, headers=headers)
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

    response = __rest_request(request_type='get', conn=conn, headers=headers)
    data = response.json()

    for column in data:
        if column not in ['row_id', 'insert_timestamp', 'tsd_name', 'tsd_id']:
            if data[column].strip().split(' ', 1)[0] == 'timestamp' and insert_timestamp is False:
                timestamp_column = column
            elif data[column] in ['numeric', 'double', 'decimal', 'integer', 'float', 'int']:
                columns[column] = data[column]
    columns[timestamp_column] = 'timestamp'

    return columns



def build_command(db_name:str, table_name:str, interval:int, time_frame:str, time_column:str, value_column:str):
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
        time={time_frame}  and
        time_column={time_column} and
        value_column={value_column}""".replace("\n"," ")
    while "  " in command:
        command = command.replace("  ", " ")

    return command

def post_command(conn:str, command:str):
    """
    Execute POST for command against
    """
    headers = {'command': command, 'User-Agent': 'AnyLog/1.23'}
    response = __rest_request(request_type='post', conn=conn, headers=headers)


def main():
    """
    Set aggregations based on logical database name and (optional) table name for numeric based columns
    :logic:
        0. before initiating aggregation data must flow into the AnyLog agents
        1. user either specifies database / table OR code gets a list of tables based on `get streaming`
        2. extract relevant database.table.column information for numeric type columns in a given table using `get columns`
        3. create new policies for the columns on the blockchain (if specified)
        4. declare aggregations
    :positional arguments:
        conn                  Comma-separated operator or publisher connections to get aggregations on
        dbms                  Database name
    :options:
        -h, --help            show this help message and exit
        --table TABLE         Table name (default: None)
        --interval INTERVAL
        --time-frame TIME_FRAME
        --create-policies [CREATE_POLICIES]     create policies (needed only once) for each numeric
                        column (default: False)
        --policy-type POLICY_TYPE   unique policy type (default: schema-tags)
        --insert-timestamp [INSERT_TIMESTAMP]enforce using `insert_timestamp` column (default: False)
    """
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('conn', type=str, help='Comma-separated operator or publisher connections')
    parser.add_argument('dbms', type=str, default='test', help='Database name')
    parser.add_argument('--table', type=str, default=None, help='Table name')
    parser.add_argument('--interval', type=int, default=10)
    parser.add_argument('--time-frame', type=str, default='1 minute')
    parser.add_argument('--create-policies', type=bool, nargs='?', const=True, default=False, help='create policies (needed only once) for each numeric column')
    parser.add_argument('--policy-type', type=str, default='schema-tags', help='unique policy type ')
    parser.add_argument('--insert-timestamp', type=bool, nargs='?', const=True, default=False, help='enforce using `insert_timestamp` column')
    args = parser.parse_args()

    if not args.table:
        tables = get_tables(conn=args.conn, db_name=args.dbms)
        for table in tables:
            tables[table] = get_columns(conn=args.conn, db_name=args.dbms, table=table)
    else:
        tables = {}
        for table in args.table.split(','):
            if '.' in table:  # if user specifies logical database name in table value(s), then use that otherwise use default dbms
                dbms, table_name = table.split(".")
                tables[table] = get_columns(conn=args.conn, db_name=dbms, table=table_name)
            else:
                tables[table] = get_columns(conn=args.conn, db_name=args.dbms, table=table)


    for table in tables:
        if '.' in tables:
            db_name, table_name = table.split('.')
        else:
            db_name = args.dbms
            table_name = table
        timestamp_column = next((k for k, v in tables[table].items() if v == 'timestamp'), None)
        for column in tables[table]:
            if column != timestamp_column:
                if args.create_policies: # create policy tags if exists
                    create_tags(conn=args.conn, tag_name=args.policy_type, dbms=db_name, table=table_name,
                                column_name=column, column_type=tables[table][column])

                command = build_command(db_name=db_name, table_name=table_name, interval=args.interval,
                                        time_frame=args.time_frame, time_column=timestamp_column, value_column=column)
                # print(command)
                post_command(conn=args.conn, command=command)


if __name__ == '__main__':
    main()