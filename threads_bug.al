anylog_broker_port = 32550
<new_policy = {
    "config": {
        "name": "network-configs",
        "ip": '!external_ip',
        "local_ip": '!ip',
        "port": '!anylog_server_port.int',
        "rest_port": '!anylog_rest_port.int',
        "broker_port": '!anylog_broker_port.int',
        "tcp_bind": '!tcp_bind.bool',
        "rest_bind": '!rest_bind.bool',
        "broker_bind": '!broker_bind.bool',
        "tcp_threads": '!tcp_threads.int',
        "rest_threads": '!rest_threads.int',
        "broker_threads": '!broker_threads.int'
    }
}>
json !new_policy