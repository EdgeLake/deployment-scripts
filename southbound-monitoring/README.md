# Southbound Monitoring

If any form of monitoring is enabled, the system automatically connects to a logical database called `monitoring`, and 
store associated data for 36 hours in 12 hour partition intervals. 

For convenience, the different monitoring options, and associated database, using [monitoring_policy.al](../southbound-monitoring/monitoring_policy.al)

## Node Monitoring

By default, AnyLog agents gather basic insights about the machine - such as CPU, disk and memory usage, as well as network 
insights - that's available to view via the Remote-CLI. In addition, this data can be stored on the operator nodes. 

**Command**: 
```anylog 
process deployment-scripts/southbound-monitoring/node_policy.al
```

**Generated / Used Policy**
```json
{'schedule' : {
  'id' : 'generic-schedule-policy',
  'name' : 'Generic Monitoring Schedule',
  'script' : [
    "schedule name = monitoring_ips and time=300 seconds and task monitoring_ips = blockchain get query bring.ip_port",
    "if !store_monitoring == true and !node_type == operator then process !local_scripts/connectors/monitoring_table_policy.al",
    "if !store_monitoring == true and !node_type != operator then schedule name=operator_monitoring_ips and time=300 seconds and task if not !operator_monitoring_ip then operator_monitoring_ip = blockchain get operator bring.first [*][ip] : [*][port]",
    "schedule name = get_stats and time=30 seconds and task node_insight = get stats where service = operator and topic = summary  and format = json",
    "schedule name = get_timestamp and time=30 seconds and task node_insight[timestamp] = get datetime local now()",
    "schedule name = set_node_type and time=30 seconds and task node_insight[node type]=!node_type",
    "schedule name = get_disk_space and time=30 seconds and task disk_space = get disk percentage .",
    "schedule name = get_cpu_percent and time = 30 seconds task cpu_percent = get node info cpu_percent",
    "schedule name = get_packets_recv and time = 30 seconds task packets_recv = get node info net_io_counters packets_recv",
    "schedule name = get_packets_sent and time = 30 seconds task packets_sent = get node info net_io_counters packets_sent",
    "schedule name = disk_space   and time = 30 seconds task if !disk_space   then node_insight[Free space %] = !disk_space.float",
    "schedule name = cpu_percent  and time = 30 seconds task if !cpu_percent  then node_insight[CPU %] = !cpu_percent.float",
    "schedule name = packets_recv and time = 30 seconds task if !packets_recv then node_insight[Packets Recv] = !packets_recv.int",
    "schedule name = packets_sent and time = 30 seconds task if !packets_sent then node_insight[Packets Sent] = !packets_sent.int",
    "schedule name = errin and time = 30 seconds task errin = get node info net_io_counters errin",
    "schedule name = errout and time = 30 seconds task errout = get node info net_io_counters errout",
    "schedule name = get_error_count and time = 30 seconds task if !errin and !errout then error_count = python int(!errin) + int(!errout)",
    "schedule name = error_count and time = 30 seconds task if !error_count then node_insight[Network Error] = !error_count.int",
    "schedule name = local_monitor_node and time = 30 seconds task monitor operators where info = !node_insight",
    "schedule name = monitor_node and time = 30 seconds task if !monitoring_ips then run client (!monitoring_ips) monitor operators where info = !node_insight",
    "schedule name = clean_status and time = 30 seconds task node_insight[status]='Active'",
    "if !store_monitoring == true and !node_type == operator then schedule name = operator_monitor_node and time = 30 seconds task stream !node_insight where dbms=monitoring and table=node_insight",
    "if !store_monitoring == true and !node_type != operator then schedule name = operator_monitor_node and time = 30 seconds task if !operator_monitoring_ip then run client (!operator_monitoring_ip) stream !node_insight  where dbms=monitoring and table=node_insight"
  ],
  'date' : '2024-09-18T23:55:40.154342Z',
  'ledger' : 'global'
}}
```

If configured store the data on operator node(s) - this data is stored for 36 hours in 12 hour intervals 

## Syslog
Syslog is a multistep process. A deep dive into the syslog logic can be found in the <a href="https://github.com/AnyLog-co/documentation/blob/master/using%20syslog.md" target="_blank">documentation</a>

1. When deploying AnyLog / EdgeLake that's supposed to get content from syslog - make sure to enable `ANLOG_BROKER_PORT`
2. Declare _rsyslog_ configurations for the node 
3. Through the AnyLog CLI, Set a message rule
```anylog 
set msg rule my_rule if ip = 10.0.0.78 and port = 1468 then dbms = monitoring and table = syslog and syslog = true
```

Alternatively users can deploy step 3 using [syslog_monitoring.al](../southbound-monitoring/syslog_monitoring.al). This will 
also create a special table that better stores insights from the logs

```anylog
process deployment-scripts/southbound-monitoring/syslog_monitoring.al
```

#### Multiple Syslog sources

When receiving syslog insights from multiple sources, it's a pain to update each each process / command individually. 

1. Locate [syslog_insight.py](../southbound-monitoring/syslog_insight.py)
```shell
docker volume inspect docker-makefiles_my-operator-local-scripts
```

**Output**
```output
[
    {
        "CreatedAt": "2025-07-14T00:52:11Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "docker-makefiles",
            "com.docker.compose.version": "2.29.1",
            "com.docker.compose.volume": "smart-city-operator3-local-scripts"
        },
        "Mountpoint": "/var/lib/docker/volumes/    "docker-makefiles_my-operator-local-scripts/_data",
        "Name": "    "docker-makefiles_my-operator-local-scripts",
        "Options": null,
        "Scope": "local"
    }
]
```

2.View script `help` options
```shell
python3 /var/lib/docker/volumes/docker-makefiles_my-operator-local-scripts/_data/southbound-monitoring/syslog_insight.py --help
```

**Output**
```output 
usage: syslog_insight.py [-h] [--db-name DB_NAME] [--table TABLE] [--policy-type POLICY_TYPE] [--local-ip [LOCAL_IP]] [--node-name NODE_NAME] operator_conn

positional arguments:
  operator_conn         comma separated list of operator node(s) to store ddata in

options:
  -h, --help            show this help message and exit
  --db-name DB_NAME     logical database to store data in
  --table TABLE         table to store data in
  --policy-type POLICY_TYPE
                        comma separated list of policies to use
  --local-ip [LOCAL_IP]
                        user external-ip
  --node-name NODE_NAME
                        specify (policy) node name to get IP for
```
**Note**: If no `--node-name` is set, then simply declare `msg rule` for local syslog.

3. Execute `msg rule` based on the provided params
```shell
python3 /var/lib/docker/volumes/docker-makefiles_my-operator-local-scripts/_data/sample-scripts/set_aggregations.py 127.0.0.1:32149 --db-name monitoring --table syslog
```


## Docker

AnyLog / EdgeLake can autonomously gather insight  regarding docker containers on the node, using the command 
```anylog 
<run scheduled pull
  where name = docker_insights
  and type = docker
  and frequency = 5
  and continuous = true
  and dbms = monitoring
  and table = docker_insight>
```

### Requirements 
When deploying the docker container for AnyLog/EdgeLake, users associate the socket connection for the docker service as 
a volume for the node receiving the data.

**Example**: Generic docker-compose.yaml
```yaml
version: '3.8'

services:
  my-service:
    image: your-image
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

```

This is done automatically when deploying AnyLog/EdgeLake via Docker. 

### python-based process 

The process for getting insights for docker is done via a `scheduled pull`, the operator node can get insights from multiple 
machines running docker container(s). As such, a python3 script can be used to execute the `scheduled pull` request for the
different nodes, rather than manually executing `scheduled pull` via AnyLog/EdgeLake CLI.

1. Locate [docker_insight.py](../southbound-monitoring/docker_insight.py)
```shell
docker volume inspect docker-makefiles_my-operator-local-scripts
```

**Output**
```output
[
    {
        "CreatedAt": "2025-07-14T00:52:11Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "docker-makefiles",
            "com.docker.compose.version": "2.29.1",
            "com.docker.compose.volume": "smart-city-operator3-local-scripts"
        },
        "Mountpoint": "/var/lib/docker/volumes/    "docker-makefiles_my-operator-local-scripts/_data",
        "Name": "    "docker-makefiles_my-operator-local-scripts",
        "Options": null,
        "Scope": "local"
    }
]
```

2.View script `help` options
```shell
python3 /var/lib/docker/volumes/docker-makefiles_my-operator-local-scripts/_data/southbound-monitoring/docker_insight.py --help
```

**Output**
```output 
usage: docker_insight.py [-h] [--data-frequency DATA_FREQUENCY] [--continuous [CONTINUOUS]] [--db-name DB_NAME] [--table TABLE] [--policy-type POLICY_TYPE] [--local-ip [LOCAL_IP]] [--node-name NODE_NAME] operator_conn

positional arguments:
  operator_conn         comma separated list of operator node(s) to store data in

options:
  -h, --help            show this help message and exit
  --data-frequency DATA_FREQUENCY
                        how often to pull the data
  --continuous [CONTINUOUS]
                        run continuously
  --db-name DB_NAME     logical database to store data in
  --table TABLE         table to store data in
  --policy-type POLICY_TYPE
                        comma separated list of policies to use
  --local-ip [LOCAL_IP]
                        user external-ip
  --node-name NODE_NAME
                        specify (policy) node name to get IP for
```
**Note**: If no `--node-name` is set, then simply declare `msg rule` for local syslog.

3. Execute `scheduled pull` based on the provided params
```shell
python3 /var/lib/docker/volumes/docker-makefiles_my-operator-local-scripts/_data/sample-scripts/docker_insight.py 127.0.0.1:32149 --node-name smart-city1,smart-city2,smart-city3 --db-name monitoring --table docker
```
