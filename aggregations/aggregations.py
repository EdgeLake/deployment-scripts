import argparse
from aggregation_functions import declare_aggregations, configure_aggregations_ingestion, configure_encoding
from support import validate_encoding_tolerance
from blockchain import get_tables, get_columns


def main():
    """
    Main for configuring aggregations process(es) against AnyLog / EdgeLake via python3
    :positional arguments:
        conn                  REST connection
        db_name               logical database
    :options:
        -h, --help            show this help message and exit
        --table-name                TABLE_NAME              logical table name
        --timestamp-column          TIMESTAMP_COLUMN        timestamp column name
        --value-column              VALUE_COLUMN            value column name (can be comma separated)
        --aggregations-intervals    AGGREGATIONS_INTERVALS  number of aggregation intervals to keep
        --aggregations-time         AGGREGATIONS_TIME       time window for each aggregation
        --enable-ingest             [ENABLE_INGEST]         Whether to enable ingestion for aggregation tables
        --ingest-raw-data           [INGEST_RAW_DATA]       Ingest raw data
        --ingest-aggregation-data   [INGEST_AGGREGATION_DATA]   Ingest aggregations data
        --enable-encoding           [ENABLE_ENCODING]           Enable value encoding
        --encoding-tolerance        ENCODING_TOLERANCE          Encoding tolerance as numeric percentage
        --encoding-type             ENCODING_TYPE               Tolerance bounding
            * bounds - all entries in the time interval are replaced with a single entry representing
            * arle - Approximated Run-Length Encoding, the entries in the time interval are represented in a sequence of entries. Each entry includes
    """
    parse = argparse.ArgumentParser()
    parse.add_argument("conn", type=str, default=None, help="REST connection")
    parse.add_argument("db_name", type=str, default=None, help="logical database")
    parse.add_argument("--table-name", type=str, default="*", help="logical table name")
    parse.add_argument("--timestamp-column", type=str, default="insert_timestamp", help="timestamp column name")
    parse.add_argument("--value-column", type=str, default="value", help="value column name (can be comma separated)")
    parse.add_argument("--aggregations-intervals", type=int, default=10, help="number of aggregation intervals to keep")
    parse.add_argument("--aggregations-time", type=str, default="1 minute", help="time window for each aggregation")
    parse.add_argument("--automate-process", type=bool, nargs='?', const=True, default=False, help="Automatically get get table name(s) and columns from blockchain")
    parse.add_argument("--enable-ingest", type=bool, nargs='?', const=True, default=False, help="Whether to enable ingestion for aggregation tables")
    parse.add_argument("--ingest-raw-data", type=bool, nargs='?', const=False, default=True, help="Ingest raw data")
    parse.add_argument("--ingest-aggregation-data", type=bool, nargs='?', const=True, default=False, help="Ingest aggregations data")
    parse.add_argument("--enable-encoding", type=bool, nargs='?', const=True, default=False, help="Enable value encoding")
    parse.add_argument("--encoding-tolerance", type=validate_encoding_tolerance, default=None, help="Encoding tolerance as numeric percentage")
    parse.add_argument("--encoding-type", type=str, choices=["bounds", "arle"], default="bounds",
                       help="Tolerance bounding - \n\tbounds - all entries in the time interval are replaced with a single entry representing\n\tarle - Approximated Run-Length Encoding, the entries in the time interval are represented in a sequence of entries. Each entry includes")
    args = parse.parse_args()

    tables_info = {args.table_name: {"timestamp": args.timestamp_column, "columns": args.value_column.split(",")}}
    if args.automate_process:
        tables_info = {}
        tables = get_tables(conn=args.conn, db_name=args.db_name, table_name=args.table_name)
        for table in tables:
            if table not in tables_info:
                tables_info[table] = {}
            tables_info[table]["timestamp"], tables_info[table]["columns"] = get_columns(conn=args.conn, db_name=args.db_name, table_name=table)

    for table in tables_info:
        time_column = tables_info[table]["timestamp"]
        for column in tables_info[table]["columns"]:
            declare_aggregations(conn=args.conn, db_name=args.db_name, table_name=table,
                                 timestamp_column=time_column, value_column=column,
                                 aggregations_interval=args.aggregations_interval,
                                 aggregations_time=args.aggregations_time)
        if args.enable_ingest:
            configure_aggregations_ingestion(conn=args.conn, db_name=args.db_name, table_name=table,
                                             ingest_aggregation_data=args.ingest_aggregation_data,
                                             ingest_raw_data=args.ingest_raw_data)
        if args.enable_encoding:
            for column in tables_info[table]["columns"]:
                configure_encoding(conn=args.conn, db_name=args.db_name, table_name=table, value_column=column,
                                   encoding_type=args.encoding_type, encoding_tolerance=args.encoding_tolerance)


if __name__ == '__main__':
    main()