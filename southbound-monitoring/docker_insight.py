import ast
import argparse
import random

import requests

def blockchain_get(conn:str, policy_type:str='*', node_name:str=None, local_ip:bool=False)->list:
    """
    extract list IPs and node names from blockchain
    :args:
        conn:str - REST IP and port
        policy_type:str - tuple of policy types [ex. (master, operator)] or all "*"
        node_name:str - specific node to extract information from
        local_ip:bool - when node is configured to TCP not bound, the corresponding blockchain policy has 2 IPs - `local_ip` and `ip`. If set provide `local_ip`
    :params;
        command:str - generated `blockchain get` command
        headers:dict - REST headers
        response:requests.GET - response from GET request
    :return:
        list of values from blockchain
    """
    command = f"blockchain get * where name='{node_name}'" if node_name is not None else f'blockchain get {policy_type}'
    command += " bring.json [*][name] [*][local_ip] separator=," if local_ip is True else " bring.json [*][name] [*][ip] separator=,"
    headers = {
        'command': command,
        'User-Agent': 'AnyLog/1.23'
    }
    try:
        response = requests.get(url=f"http://{conn}", headers=headers)
        response.raise_for_status()
        return ast.literal_eval(response.text)
    except Exception as error:
        raise Exception(f"Failed to execute GET against {conn} (Error: {error})")

def post_docker_insight(conn:str, docker_frequency:int=5, continuous:bool=True, node_name:str='local', node_ip:str='localhost',
                        db_name:str='monitoring'):
    """
    Execute docker insight command
    :args:
        conn:str - REST IP and port
    :params;
        command:str - `schedule pull` command to pull docker insight
        headers:dict - REST headers
        response:requests.POST  - response from POST request
    """
    command = f"scheduled pull where name={node_name}-docker-insight and source={node_ip} type=docker and frequency={docker_frequency} and continuous={str(continuous).lower()} and dbms={db_name} asn table=docker_insight"
    headers =  {
        'command': command,
        'User-Agent': 'AnyLog/1.23'
    }
    try:
        response = requests.post(url=f'http://{url}', headers=headers)
        response.raise_for_status()
    except Exception as error:
        raise Exception(f"Failed to execute POST against {conn} (Error: {error})")


def main():
    """
    Execute docker insight against operator node for differrent nodes in the network via REST
    :positional arguments:
        operator_conn         comma separated list of operator node(s) to store ddata in
    :options:
        -h, --help            show this help message and exit
        --data-frequency    DATA_FREQUENCY      how often to pull the data
        --continuous        [CONTINUOUS]        run continuously
        --db-name           DB_NAME             logical database to store data in
        --table             TABLE               table to store data in
        --policy-type       POLICY_TYPE         comma separated list of policies to use
        --local-ip          [LOCAL_IP]          user external-ip
        --node-name         NODE_NAME           specify (policy) node name to get IP for
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('operator_conn', type=str, default=None, help='comma separated list of operator node(s) to store ddata in')
    parser.add_argument('--data-frequency', type=int, default=5, help='how often to pull the data')
    parser.add_argument('--continuous', type=bool, nargs='?', const=True, default=False, help='run continuously')
    parser.add_argument('--db-name', type=str, default='monitoring', help='logical database to store data in')
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
            policies.append(blockchain_get(conn=args.operator_conn[0], policy_type='*', node_name=node_name,
                                           local_ip=args.local_ip))
    else:
        policies = blockchain_get(conn=args.operator_conn[0], policy_type=args.policy_type, node_name=args.node_name,
                                  local_ip=args.local_ip)

    for policy in policies:
        ip = policy['local_ip'] if 'local_ip' in policy  else policy['ip']
        name = policy['name']
        post_docker_insight(conn=random.choice(args.operator_conn), docker_frequency=args.data_frequency,
                            continuous=args.continuous, node_name=name, node_ip=ip, db_name=args.db_name)


if __name__ == '__main__':
    main()