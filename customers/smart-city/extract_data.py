import argparse
import psycopg2

def get_tables(cur):
    cur.execute("""
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
        AND table_schema NOT IN ('pg_catalog', 'information_schema')
        ORDER BY table_schema, table_name;
    """)

    print(cur.fetchall())

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('conn', type=str, default=None,  help="Access for database {user}:{password}@{host}:{port}")
    parser.add_argument('dbms', type=str, default='cos', help="logical database name")
    args = parser.parse_args()

    user, password = args.conn.split('@')[0].split(":")
    host, port = args.conn.split('@')[-1].split(":")

    try:
        conn = psycopg2.connect(host=host, port=port, user=user, password=password, dbname=args.dbms)
        cur = conn.cursor()
    excetp:

    get_tables(cur=cur)

if __name__ == '__main__':
    main()
