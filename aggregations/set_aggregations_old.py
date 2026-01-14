import argparse
import aggregations.support as support

NUMERIC_TYPES = {"numeric", "double", "decimal", "integer", "float", "int"}


def get_numeric_columns_and_timestamp(columns, force_insert_ts):
    numeric = []
    timestamp = "insert_timestamp"

    for name, col_type in columns.items():
        if col_type in NUMERIC_TYPES:
            numeric.append(name)
        elif col_type == "timestamp" and not force_insert_ts:
            timestamp = name

    return numeric, timestamp


def resolve_tables(all_tables, requested):
    if not requested:
        return list(all_tables.keys())
    return [t for t in requested.split(",") if t in all_tables]


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("conn", help="REST connection for setting aggregations")
    parser.add_argument("db_name", help="logical database")

    # --- aggregation ---
    parser.add_argument("--set-aggregations", action="store_true")
    parser.add_argument("--store-aggregations", action="store_true")
    parser.add_argument("--agg-interval", type=int, default=10)
    parser.add_argument("--time-frame", default="1 minute")
    parser.add_argument("--aggregation-db", dest="target_dbms")
    parser.add_argument("--insert-timestamp", action="store_true")
    parser.add_argument("--aggregation-tables", help="comma separated list")

    # --- ingestion ---
    parser.add_argument("--set-ingestion", action="store_true")
    parser.add_argument("--frequency", choices=["continuous", "time", "none"], default="none")
    parser.add_argument("--ingestion-interval")
    parser.add_argument("--ingestion-table", help="comma separated list")

    # --- policies ---
    parser.add_argument("--create-policies", action="store_true")
    parser.add_argument("--policy-type", default="schema-tags")

    args = parser.parse_args()

    # --- discover tables and columns ---
    tables = {}
    for table in support.get_tables(args.conn, args.db_name):
        tables[table] = support.get_columns(args.conn, args.db_name, table)

    # --- set aggregations ---
    if args.set_aggregations:
        target_tables = resolve_tables(tables, args.aggregation_tables)

        for table in target_tables:
            numeric_cols, timestamp_col = get_numeric_columns_and_timestamp(
                tables[table], args.insert_timestamp
            )

            agg_table = f"aggregation_{table}" if args.store_aggregations else table

            for column in numeric_cols:
                support.declare_aggregation(
                    conn=args.conn,
                    db_name=args.db_name,
                    table_name=agg_table,
                    interval=args.agg_interval,
                    time_frame=args.time_frame,
                    time_column=timestamp_col,
                    value_column=column,
                    store_aggregations=args.store_aggregations,
                    target_dbms=args.target_dbms,
                    target_table=agg_table,
                )

    # --- set ingestion ---
    if args.set_ingestion:
        target_tables = (
            resolve_tables(tables, args.ingestion_table)
            if args.ingestion_table
            else [None]
        )

        for table in target_tables:
            if table and args.store_aggregations:
                table = f"aggregation_{table}"

            support.set_ingestion(
                conn=args.conn,
                db_name=args.db_name,
                frequency=args.frequency,
                interval=args.ingestion_interval,
                table_name=table,
            )


if __name__ == "__main__":
    main()
