import argparse
import requests
import json










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