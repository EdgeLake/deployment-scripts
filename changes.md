# Deployment Script Changes

```tree
deployment-scripts
|- node-deployment <-- default node deployment
   |- database
      |- deploy_database.al             <-- main for deploying different databases
      |- configure_dbms_almgm.al        <-- creates almgm database and tsd_info table (runs on both operator + publisher)
      |- configure_dbms_blockchain.al   <-- creates blockchain database and ledger table
      |- configure_dbms_operator.al     <-- default database used by operator to store data structured data
      |- configure_dbms_nosql.al        <-- create NoSQL (MongoDB) logical database if configured. If not, the code still preps the node to accept blobs to file
      |- configure_system_query.al      <-- system query logical database
   |- policies
      |- config_policy.al             <-- configuration policy
      |- config_policy_network_dns.al <-- configuration policy that informs the system to use dns rather than IP address
      |- cluster_policy.al            <-- for Operator node, create the associated cluster policy if DNE
      |- node_policy.al               <-- node specific policy
      |- license_policy.al            <-- AnyLog license policy
      |- validate_node_policy.al      <-- for nodes, validate policy DNE
      |- publish_policy.al            <-- publish node policy
   |- main.al       <-- main script
   |- set_params.al <-- convert env params to AnyLog Params
|- southbound-industrial <-- southbound connectors associated with industrial devices
   |- industrial_policy.al <-- Policy for accepting data from industrial devices
   |- etherip_tags.al         <-- EtherIP declare tags
   |- etherip_Client.al       <-- EtherIP accept data
   |- opcua_tags.al           <-- OPC-UA declare tags
   |- opcua_Client.al         <-- OPC-UA accept data
|- southbound-monitoring <-- southbound node monitoring processes
   |- monitoring_policy.al       <-- configurationpolicy for node monitoring
   |- node_monitoring.al         <-- schedule policy for monitoring the node (cpu, disk, etc.)
   |- node_monitoring_table.al   <-- table used for monitoring data 
   |- syslog_monitoring.al       <-- message broker to accept data from syslog(s)
   |- syslog_monitoring_table.al <-- table used for syslog data 
   |- syslog_insight.py          <-- python3 script to accept data from syslog  
   |- docker_monitoring.al       <-- schedule policy for monitoring docker state
   |- docker_insight.py          <-- python3 script to accept data regarding docker
|- customers <-- "archive" with customer use cases 
   |- machine-builder <-- Orics machine builder use case 
   |- smart-city <-- Sabetha smart city example
|- data-generator <-- scripts associated with Sample-Data-Generator
|- sample-scripts <-- accept data from third-party applications
   |- basic_kafka_client.al <-- basic kafka client 
   |- basic_msg_client.al        <-- basic MQTT client
   |- basic_msg_client_policy.al <-- basic MQTT client, but uses mapping policy
   |- edgex.al                   <-- sample connection to EdgeX (Foundry) 
   |- fledge.al                  <-- sample connection to FogLAMP / Fledge (by Dianomic) 
   |- telegraf.al                <-- sample connection to InfuxDB's Telegraf application 
|- grpc                         <-- accept data from a gGRPC data source. The code is built on the idea of KubeArmor to monitor Kubernetes instances
|- test-network-local-scripts   <-- scripts for test network
|- tests                        <-- altest scripts
```

## Change log
1. simply node config policy
2. Added `SYSTEM_QUERY_DB` value to select psql or sqlite. For PSQL the connection information is set as part of the DEFAULT database configs
3. create policies for different monitoring options

## Todo
1. update paths based on changes
2. integrate industrial and monitoring policies 
3. validate env params
4. integrate config_threshold.al
5. README.md