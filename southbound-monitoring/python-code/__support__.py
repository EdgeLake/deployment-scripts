import ast
import requests

def blockchain_get(conn:str, command:str)->list:
    """
    based on policy type - extract connection information
    :args:
        conn:str - REST connection
        policy_type:str - policy to get insight from
        node_name:str - node name(s)
        local_ip:str
    """
    headers = {
        'command': command,
        'User-Agent': 'AnyLog/1.23'
    }

    try:
        response = requests.get(url=f"http://{conn}", headers=headers)
        response.raise_for_status()
        return response.json()
    except Exception as error:
        raise Exception(f"Failed to execute GET against {conn} (Error: {error})")


def publish_command(conn:str, command:str):
    headers = {
        'command': command,
        'User-Agent': 'AnyLog/1.23'
    }

    try:
        response = requests.post(url=f"http://{conn}", headers=headers)
        response.raise_for_status()
    except Exception as error:
        raise Exception(f"Failed to execute POST against {conn} (Error: {error})")


def get_blockchain_info(conn:str, policy_type:(str or tuple)='*', node_name:(str or list)=None, local_ip:bool=False):
    node_info = []
    if node_name and isinstance(node_name, str):
        command = f'blockchain get ({policy_type}) where name="{node_name}"'
        blockchain_info = blockchain_get(conn=conn, command=command)
        for policy in blockchain_info:
            node_type = list(policy.keys())[0]
            node_info.append({
                'name': policy[node_type]['name'],
                'ip': policy[node_type]['local_ip'] if 'local_ip' in policy[node_type] and local_ip is True else
                policy[node_type]['ip']
            })
    elif node_name and isinstance(node_name, list):
        for node in node_name:
            command = f'blockchain get ({policy_type}) where name="{node}"'
            blockchain_info = blockchain_get(conn=conn, command=command)
            for policy in blockchain_info:
                node_type = list(policy.keys())[0]
                node_info.append({
                    'name': policy[node_type]['name'],
                    'ip': policy[node_type]['local_ip'] if 'local_ip' in policy[node_type] and local_ip is True else
                    policy[node_type]['ip']
                })
    else:
        command = f'blockchain get ({policy_type})'
        blockchain_info = blockchain_get(conn=conn, command=command)
        for policy in blockchain_info:
            node_type = list(policy.keys())[0]
            node_info.append({
                'name': policy[node_type]['name'],
                'ip': policy[node_type]['local_ip'] if 'local_ip' in policy[node_type] and local_ip is True else
                policy[node_type]['ip']
            })

    return node_info
