import argparse
from __support__ import get_blockchain_info, publish_command


def main():
    """
    Python3 script to enable docker and/or syslog insights to be sent to Anylog/EdgeLake node. Based on
    user inputs, rather than manually configuring per node.
    :positional arguments:
        dest                  destination to run command against
    :options:
      -h, --help            show this help message and exit
      --node-type NODE_TYPE
                            comma separated list of node types to get blockchain
                            info from
      --node-name NODE_NAME
                            comma separated list of node names to get information
                            from
      --local-ip [LOCAL_IP]
                            force use `local_ip`, otherwise will use `ip` address
      --db-name DB_NAME     database to store monitoring in
      --docker-table DOCKER_TABLE
                            table to store docker insight
      --syslog-table SYSLOG_TABLE
                            table to store syslog insight
      --docker-insight [DOCKER_INSIGHT]
                            get docker container insights for node(s)
      --syslog-insight [SYSLOG_INSIGHT]
                            get syslog insights for node(s)

    """
    parse = argparse.ArgumentParser()
    parse.add_argument('dest', type=str, default=None, help='destination to run command against')
    parse.add_argument('--node-type', type=str, default='master, operator, query, publisher', help='comma separated list of node types to get blockchain info from')
    parse.add_argument('--node-name', type=str, default=None, required=False, help='comma separated list of node names to get information from')
    parse.add_argument('--local-ip', type=bool, nargs='?', const=True, default=False, required=False, help='force use `local_ip`, otherwise will use `ip` address')
    parse.add_argument('--db-name', type=str, default='monitoring', required=False, help='database to store monitoring in')
    parse.add_argument('--docker-table', type=str, default='docker', required=False, help='table to store docker insight')
    parse.add_argument('--syslog-table', type=str, default='syslog', required=False, help='table to store syslog insight')
    parse.add_argument('--docker-insight', type=bool, nargs='?', const=True , default=False, required=False, help='get docker container insights for node(s)')
    parse.add_argument('--syslog-insight', type=bool, nargs='?', const=True, default=False, required=False, help='get syslog insights for node(s)')
    args = parse.parse_args()

    if args.node_name:
        args.node_name = args.node_name.split(",")

    policy_info = get_blockchain_info(conn=args.dest, policy_type=args.node_type, node_name=args.node_name, local_ip=args.local_ip)
    for policy in policy_info:
        node_name = policy['name']
        node_ip = policy['ip']

        if args.syslog_insight:
            command = f"set msg rule {node_name}-syslog if ip={node_ip} then dbms={args.db_name} and table={args.syslog_table} and extend=ip and syslog=true"
            publish_command(conn=args.dest, command=command)
        if args.docker_insight:
            command = f"run scheduled pull where name={node_name}-docker-insight and source={node_ip} and type=docker and frequency=5 and continuous=true and dbms={args.db_name} and table={args.docker_table}"
            publish_command(conn=args.dest, command=command)


if __name__ == '__main__':
    main()