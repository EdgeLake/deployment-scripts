import argparse
from blockchain import get_policy_id, declare_policy, config_policy
from policy_generator import create_policy, define_ingestion, define_encoding


def sub_main(args, value_columns:(list or str)=None):
    policy_id = get_policy_id(conn=args.conn, db_name=args.db_name, table_name=args.table_name,
                              value_column=value_columns)

    # create policy if DNE
    if not policy_id:
        new_policy = create_policy(db_name=args.db_name, table_name=args.table_name,
                                   timestamp_column=args.timestamp_column, value_columns=value_columns,
                                   interval=args.intervals, interval_time=args.interval_time,
                                   per_column=args.per_column)
        new_policy = define_ingestion(new_policy=new_policy, db_name=args.db_name, table_name=args.table_name,
                                      keep_source=args.keep_source, keep_aggregation=args.keep_aggregation)

        if not args.keep_source and args.keep_aggregation:
            new_policy = define_encoding(new_policy=new_policy, db_name=args.db_name, table_name=args.table_name,
                                         value_columns=value_columns, encoding_type=args.encoding_type,
                                         tolerance_level=args.tolerance_level)

        declare_policy(conn=args.conn, new_policy=new_policy)
        policy_id = get_policy_id(conn=args.conn, db_name=args.db_name, table_name=args.table_name,
                                  value_column=value_columns)

    # configure from policy
    if args.declare_policy_only:
        config_policy(conn=args.conn, policy_id=policy_id)
    # provide policy ID
    print(f"Policy for Aggregation: {policy_id}")


def main():
    """
    The following generates a configuration policy for a aggregating data
    :sample-policy:
    {"aggregation": {
        "dbms": [db name],
        "table": [table name],
        # this configuration is set using  `--per-column` and should only be used if/when aggregation configuration is unique per column
        "value_column": [value column],
        "script": [
            "set aggregation where dbms=[db_name] and table=[table_name] and intervals=[interval] and time=[interval_time] and time_column=[time_column] and value_column=[value_column]",
            "set aggregation ingest where dbms=[db_name] and table=[table_name] and source=[true||false] and derived=[true||false]",
            # if `derived` is set to True then code includes `encoding`,
            "set aggregation encoding where dbms=[db_name] and table=[table_name] and value_column=[value_column] and encoding=[bounds||arle]"
        ]
    }
    :positional arguments:
        conn                  REST IP:Port information for operator / publisher node to run aggregation against
    :options:
        -h, --help                                      show this help message and exit
        --db-name               DB_NAME                 Logical database to aggregate against
        --table-name            TABLE_NAME              logical table name to execute aggregation against
        --timestamp-column      TIMESTAMP_COLUMN        timestamp column to aggregate against
        --value-columns         VALUE_COLUMNS           comma separated value column(s)
        --intervals             INTERVALS               Number of intervals to keep in aggregation
        --interval-time         INTERVAL_TIME           time period per interval
        --keep-source           [KEEP_SOURCE]           Store raw data into table(s)
        --keep-aggregation      [KEEP_AGGREGATION]      Store aggregation insights into table(s)
        --encoding-type
            * None
            * bounds: all entries in the time interval are replaced with a single entry representing
            * arle: Approximated Run-Length Encoding, the entries in the time interval are represented in a sequence of
                    entries. Each entry includes
        --tolerance-level       TOLERANCE_LEVEL         percentage difference - Approximated Run-Length Encoding, allowable
                                                        difference between consecutive values while treating them as part of
                                                        the same group or segment.
        --per-column            [PER_COLUMN]            Create aggregation for a specific value column
         --declare-policy-only  [DECLARE_POLICY_ONLY]   do not configure from policy

    :params:
        policy_id:str - blockchain policy ID for aggregation
        new_policy:dict - generated policy for aggregation(s)
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("conn", type=str, default=None, help="REST IP:Port information for operator / publisher node to run aggregation against")
    parser.add_argument("--db-name", required=True, type=str, default=None, help="Logical database to aggregate against")
    parser.add_argument("--table-name", required=True, type=str, default=None, help="logical table name to execute aggregation against")
    parser.add_argument("--timestamp-column", type=str, default="insert_timestamp", help="timestamp column to aggregate against")
    parser.add_argument("--value-columns", type=str, default="value", help="comma separated value column(s)")
    parser.add_argument("--intervals", type=int, default=10, help="Number of intervals to keep in aggregation")
    parser.add_argument("--interval-time", type=str, default="1 minute", help="time period per interval")
    parser.add_argument("--keep-source", type=bool, nargs='?', default=False, const=True, help="Store raw data into table(s)")
    parser.add_argument("--keep-aggregation", type=bool, nargs='?', default=False, const=True, help="Store aggregation insights into table(s)")
    parser.add_argument("--encoding-type", type=str, default=None, choices=[None, "bounds", "arle"],
                        help="bounds: all entries in the time interval are replaced with a single entry representing\narle: Approximated Run-Length Encoding, the entries in the time interval are represented in a sequence of entries. Each entry includes")
    parser.add_argument("--tolerance-level", type=int, default=None, help="percentage difference - Approximated Run-Length Encoding, allowable difference between consecutive values while treating them as part of the same group or segment.")
    parser.add_argument("--per-column", type=bool, nargs='?', const=True, default=False, help="Create aggregation for a specific value column")
    parser.add_argument("--declare-policy-only", type=bool, nargs='?', const=True, default=False, help="do not configure from policy")
    args = parser.parse_args()

    args.value_columns = args.value_columns.split(",")
    if args.per_column:
        for value_column in args.value_columns:
            sub_main(args=args, value_columns=value_column)
    else:
        sub_main(args=args, value_columns=args.value_columns)


if __name__ == "__main__":
    main()