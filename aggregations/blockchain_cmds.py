import json
from aggregations.support import rest_request


def check_tag(conn:str, policy_type:str, dbms:str, table:str, column_name:str):
    is_policy = False
    headers = {
        "command": f"blockchain get {policy_type} where dbms={dbms} and table={table} and column_name={column_name}",
        "User-Agent": "AnyLog/1.23"
    }

    response = rest_request(request_type="GET", conn=conn, headers=headers)
    if 200 <= response.status_code < 300:
        try:
            is_policy = True if response.json() else False
        except Exception as error:
            raise  Exception(f"Failed to extract results from `blockchain get` against {conn} (Error; {error})")
    return is_policy



def create_tags(conn:str, policy_type:str, dbms:str, table:str, column_name:str, column_type:str=None):
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
        policy_type: {
            "dbms": dbms,
            "table": table,
            "column_name": column_name
        }
    }
    if column_type:
        payload[policy_type]["column_type"] = column_type  # <-- optional

    headers = {
        "command": "blockchain insert where policy=!new_policy and local=true and master=!ledger_conn",
        "User-Agent": "AnyLog/1.23",
    }
    new_policy=f"<new_policy={json.dumps(payload)}>"

    rest_request(request_type='POST', conn=conn, headers=headers, payload=new_policy)

