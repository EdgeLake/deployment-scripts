import requests


def validate_encoding_tolerance(value):
    if value:
        try:
            isinstance(value, int) and value >= 0
        except AssertionError:
            raise AssertionError(f"Invalid encoding_tolerance - must be int and greater than 0")
    return value


def rest_request(request_type:str, conn:str, headers:dict, payload=None):
    """
    Generic REST request method
    :args:
        conn:str - REST connection information
        headers:dict - REST headers
        payload:str  - request payload
    :params:
        response:requests.${request_type} - response for cURL request
    :return:
        response
    """
    response = None
    try:
        if request_type.lower() == 'get':
            response = requests.get(url=f'http://{conn}', headers=headers, data=payload)
        elif request_type.lower() == 'post':
            response = requests.post(url=f'http://{conn}', headers=headers, data=payload)
        response.raise_for_status()
    except Exception as error:
        raise Exception(f"Failed to execute {request_type.upper()} against {conn} (Error: {error})")
    return  response

