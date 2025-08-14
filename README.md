# Deployment Scripts 

This repository contains the default deployment process and sample scripts for AnyLog and EdgeLake.

These scripts streamline the setup, configuration, and management of nodes, and are downloaded automatically when 
running through Docker, Podman, or Kubernetes.

If you want to use these deployment scripts locally when running AnyLog / EdgeLake from source or as a service, follow the steps described in
<a href="https://github.com/AnyLog-co/documentation/blob/master/deployments/AnyLog_as_Service.md" target="_blank">AnyLog as a Service</a>. 

- [Node Deployment](#node-deployment)
  - [Process for Node Deployment](#process-for-node-deployment)
- [Southbound Industrial](#southbound-industrial)
- [Southbound Monitoring](#southbound-monitoring)
  - [Node Monitoring](#node-monitoring)
  - [Syslog](#syslog)
- [gRPC](#grpc)
- [Enable Aggregations](#enable-aggregations)
  - [Python Call](#python-call)



### Repository Structure 
```tree
├───node-deployment             <-- Node deployment process scripts
│   ├───database                <-- Database setup and initialization
│   └───policies                <-- Policy configuration scripts
├───data-generator              <-- Scripts for ingesting sample data from the Sample Data Generator
├───grpc                        <-- gRPC connection scripts, protocol definitions, and compilation utilities
│   └───kubearmor               <-- gRPC scripts specific to KubeArmor integration
├───sample-scripts              <-- Scripts to receive data from third-party applications
├───southbound-industrial       <-- Scripts to accept data from OPC-UA, Modbus, EtherIP, and other industrial protocols
├───southbound-monitoring       <-- Scripts for collecting and ingesting monitoring data from nodes
├───test-network-local-scripts  <-- Scripts used by the test network in local environments
└──customers                    <-- Customer-specific deployment scripts and configurations
    ├───machine-builder
    └───smart-city
        ├───grafana
        │   ├───power_plant
        │   ├───waste_water
        │   └───water_plant
        └───imgs
```

## Node Deployment

The process of deploying a node is entirely configuration-based and is initiated via the [main.al](node-deployment/main.al) script. 

```
# AnyLog
python3 anylog.py process deployment-scripts/node-deployment/main.al

# EdgeLake
python3 edgelake.py process deployment-scripts/node-deployment/main.al
``` 

**Note**: `process` is an AnyLog/EdgeLake built-in function for executing `.al` scripts.


### Process for node deployment

0. **Set environment variables** - This is handled automatically when running via Docker or Kubernetes.


1. **Set file paths in the agent**

```anylog
set anylog_path = /app
set anylog home !anylog_path 
create work directories
```


2. **Convert environment variables** - Environment variables are mapped to AnyLog/EdgeLake variables via [set_params.al](node-deployment/set_params.al)


3. **Declare configuration policy** - The configuration policy defines:
   * Which services to enable
   * Which additional scripts to run 
   * The operational role of the node

Below is an example policy for an operator node. When applied, it enables:
* TCP 
* REST 
* Blockchain sync 
* Cluster + operator policies (if DNE)
* associated logical databases 
* data processing processes 
* (optional) node monitoring  
* (optional) industrial device(s)
* enable license if not EdgeLake

```json
 {'config' : {
    'name' : 'operator-configs',
    'company' : 'My Company',
    'node_type' : 'operator',
    'ip' : '!external_ip',
    'local_ip' : '!ip',
    'port' : '!anylog_server_port.int',
    'rest_port' : '!anylog_rest_port.int',
    'threads' : '!tcp_threads.int',
    'tcp_bind' : '!tcp_bind',
    'rest_threads' : '!rest_threads.int',
    'rest_timeout' : '!rest_timeout.int',
    'rest_bind' : '!rest_bind',
    'script' : [
      'process !local_scripts/connect_blockchain.al',
      'process !local_scripts/policies/cluster_policy.al',
      'process !local_scripts/policies/node_policy.al',
      'process !local_scripts/database/deploy_database.al',      
      'run scheduler 1',
      'set buffer threshold where time=!threshold_time and volume=!thre',
      'shold_volume and write_immediate=!write_immediate',
      'run streamer',
      'if !enable_ha == true then run data distributor',
      'if !enable_ha == true then run data consumer where start_date=!start_data',
      'if !operator_id and !blockchain_source != master then run operator where create_table=!create_table and update_tsd_info=!update_tsd_info and compress_json=!compress_file and compress_sql=!compress_sql and archive_json=!archive and archive_sql=!archive_sql and blockchain=!blockchain_source and policy=!operator_id and threads=!operator_threads',
      'if !operator_id and !blockchain_source == master then run operator where create_table=!create_table and update_tsd_info=!update_tsd_info and compress_json=!compress_file and compress_sql=!compress_sql and archive_json=!archive and archive_sql=!archive_sql and master_node=!ledger_conn and policy=!operator_id and threads=!operator_threads',
      'process !anylog_path/deployment-scripts/southbound-monitoring/monitoring_policy.al',
      'process !anylog_path/deployment-scripts/southbound-industrial/industrial_policy.al',
      'if !deploy_local_script == true then process !local_scripts/local_script.al',
      'if !is_edgelake == false then process !local_scripts/policies/license_policy.al'
    ],
    'id' : '2e54c04ce4e1241d41e68cbbd31a2469',
    'date' : '2025-08-04T17:07:16.505677Z',
    'ledger' : 'global'
  }
}
```

## Southbound Industrial 

When ingesting data from industrial devices such as OPC-UA, Modbus, or EtherIP, the process involves two main steps.

AnyLog/EdgeLake stores incoming industrial data per-table, per data point, ensuring each data point is uniquely tracked 
and managed.

1. **Create a Policy for Each Data Point** - A policy defines how a specific industrial data point should be stored and 
processed. This is created once for each data point via the AnyLog CLI, generating a unique blockchain policy.


**Command**:
```anylog
proces deployment-scripts/southbound-industrial/etherip_tags.al 
```

**Sample Policy**:
```json
{'tag' : {
    'dbms' : 'opcua_demo',
    'table' : 't1',
    'protocol' : 'opcua',
    'class' : 'variable',
    'ns' : 2,
    'node_sid' : 'D1001VFDStop',
    'datatype' : 'Double',
    'parent' : 'VFD_CNTRL_TAGS',
    'path' : 'Root/Objects/DeviceSet/WAGO 750-8210 PFC200 G2 4ETH XTR/Resources/Application/GlobalVars/VFD_CNTRL_TAGS/D1001VFDStop',
    'id' : 'b48e075ce41e0333619b95366aac5e5a',
    'date' : '2025-07-15T01:08:31.457608Z',
    'ledger' : 'global'
  }
}
```

2. **Begin Data Ingestion** - Once the policies are created, data ingestion can begin.

**Command**:
```anylog
proces deployment-scripts/southbound-industrial/etherip_client.al 
```

For convenience, this entire two-step process can be automated using: [industrial_policy.al](southbound-industrial/industrial_policy.al). 

## Southbound Monitoring

If any form of monitoring is enabled, the system automatically connects to a logical database called `monitoring`, and 
store associated data for 36 hours in 12 hour partition intervals. 

For convenience, the different monitoring options, and associated database, using [monitoring_policy.al](southbound-monitoring/monitoring_policy.al)

### Node Monitoring

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

2. If configured store the data on operator node(s) - this data is stored for 36 hours in 12 hour intervals 

### Syslog
Syslog is a multistep process. A deep dive into the syslog logic can be found in the <a href="https://github.com/AnyLog-co/documentation/blob/master/using%20syslog.md" target="_blank">documentation</a>

1. When deploying AnyLog / EdgeLake that's supposed to get content from syslog - make sure to enable `ANLOG_BROKER_PORT`
2. Declare _rsyslog_ configurations for the node 
3. Through the AnyLog CLI, Set a message rule
```anylog 
set msg rule my_rule if ip = 10.0.0.78 and port = 1468 then dbms = monitoring and table = syslog and syslog = true
```

Alternatively users can deploy step 3 using [syslog_monitoring.al](southbound-monitoring/syslog_monitoring.al). This will 
also create a special table that better stores insights from the logs

```anylog
process deployment-scripts/southbound-monitoring/syslog_monitoring.al
```

#### Multiple Syslog sources

When receiving syslog insights from multiple sources, it's a pain to update each each process / command individually. 

1. Locate [syslog_insight.py](southbound-monitoring/syslog_insight.py)
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
python3 /var/lib/docker/volumes/    "docker-makefiles_my-operator-local-scripts/_data/southbound-monitoring/syslog_insight.py --help
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
3. Execute aggregation
```shell
python3 /var/lib/docker/volumes/    "docker-makefiles_my-operator-local-scripts/_data/sample-scripts\set_aggregations.py 127.0.0.1:32149 --db-name monitoring --table syslog
```



## gRPC

The gRPC deployment process involves multiple steps, including compiling the .proto file. For detailed instructions, 
refer to the [gRPC README](gRPC/README.md).

## Enable Aggregations

The <a href="https://github.com/AnyLog-co/documentation/blob/master/aggregations.md" target="_blank">Aggregation function</a>
allows you to summarize streaming data over a time interval. While it can be run via the AnyLog CLI, it is often simpler 
to deploy it using a Python or REST script.

This process should run on either a **Publisher** or **Operator** node — whichever is initially receiving the data.

**Base CLI Command**: 
```anylog 
<set aggregations where 
   dbms=opcua_demo and 
   table=t1 and 
   intervals=1 minute and 
   time=10 minutes  and
   time_column=timestamp and
   value_column=value>
```

### Python Call
1. Locate [set_aggregations.py](sample-scripts/set_aggregations.py) script
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
python3 /var/lib/docker/volumes/    "docker-makefiles_my-operator-local-scripts/_data/sample-scripts\set_aggregations.py --help
```

**Output**
```output
usage: set_aggregations.py [-h] [--table TABLE] [--interval INTERVAL] [--time-frame TIME_FRAME] conn dbms
positional arguments:
  conn                  Comma-separated operator or publisher connections
  dbms                  Database name

options:
  -h, --help            show this help message and exit
  --table TABLE         Table name (default: None)
  --interval INTERVAL
  --time-frame TIME_FRAME
```
**Note**: If `--table` is not provided, the script will execute aggregation for all numeric columns in all tables of the specified database.

3. Execute aggregation
```shell
python3 /var/lib/docker/volumes/    "docker-makefiles_my-operator-local-scripts/_data/sample-scripts\set_aggregations.py 127.0.0.1:32149 opcua_demo
```
