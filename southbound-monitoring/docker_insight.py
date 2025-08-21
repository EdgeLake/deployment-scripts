import ast
import argparse
import random

import requests
from syslog_insight import  blockchain_get


def post_docker_insight(conn:str, docker_frequency:int=5, continuous:bool=True, node_name:str='local', node_ip:str='localhost',
                        db_name:str='monitoring', table:str='docker_insight'):
    command = f"run scheduled pull where name={node_name}-docker-insight and source={node_ip} and type=docker and frequency={docker_frequency} and continuous={str(continuous).lower()} and dbms={db_name} and table={table}"
    headers =  {
        'command': command,
        'User-Agent': 'AnyLog/1.23'
    }
    try:
        response = requests.post(url=f'http://{conn}', headers=headers)
        response.raise_for_status()
    except Exception as error:
        raise Exception(f"Failed to execute POST against {conn} (Error: {error})")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('operator_conn', type=str, default=None,
                        help='comma separated list of operator node(s) to store ddata in')
    parser.add_argument('--data-frequency', type=int, default=5, help='how often to pull the data')
    parser.add_argument('--continuous', type=bool, nargs='?', const=True, default=False, help='run continuously')
    parser.add_argument('--db-name', type=str, default='monitoring', help='logical database to store data in')
    parser.add_argument('--table', type=str, default='docker_insight', help='table to store data in')
    parser.add_argument('--policy-type', type=str, default='*', help='comma separated list of policies to use')
    parser.add_argument('--local-ip', type=bool, nargs='?', const=True, default=False, help='user external-ip')
    parser.add_argument('--node-name', type=str, default=None, help='specify (policy) node name to get IP for')
    args = parser.parse_args()

    args.operator_conn = args.operator_conn.split(',')
    if args.policy_type != '*' and '*' in args.policy_type:
        args.policy_type = '*'
    elif args.policy_type != '*':
        tmp_policy = ""
        for policy in args.policy_type.split(","):
            tmp_policy += policy + ","
        args.policy_type = f"({tmp_policy.rsplit(',', 1)[0]})"

    if args.node_name:
        policies = []
        for node_name in args.node_name.split(','):
            policies.extend(blockchain_get(conn=args.operator_conn[0], policy_type=args.policy_type, node_name=node_name,
                               local_ip=args.local_ip))
    else:
        policies =  blockchain_get(conn=args.operator_conn[0], policy_type=args.policy_type, local_ip=args.local_ip)

    for policy in policies:
        ip = policy['local_ip'] if 'local_ip' in policy  else policy['ip']
        name = policy['name']
        post_docker_insight(conn=random.choice(args.operator_conn), docker_frequency=args.data_frequency,
                            continuous=args.continuous, node_name=name, node_ip=ip, db_name=args.db_name,
                            table=args.table)


if __name__ == '__main__':
    main()