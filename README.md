# Deployment Scripts 

The following provides the default deployment process and sample scripts for AnyLog & EdgeLake.
```tree
├── customers <-- Customer specific scripts
├── grpc <-- Sample process for deploying gRPC used by KubeArmor
│   └── kubearmor
├── machine-builder <-- Machine builder (factory machinary) use case example 
├── node-deployment <-- Node deployment process  
│   ├── connectors <-- Southbond connectors 
│   ├── database <-- database related calls 
│   └── policies <-- policy generator calls 
├── sample-scripts <-- sample scripts 
├── smart-city <-- smart city example (incuding Grafana) 
│   ├── grafana
│   │   ├── power_plant
│   │   ├── waste_water
│   │   └── water_plant
│   └── imgs
└── test-network-local-scripts <-- scripts used in the demo / test network 
```

## Node Deployment

By default, a pre-built AnyLog/EdgeLake deployment utilizes the [node-deployment](node-deployment) script to associate 
the node with a network and specify the node type.


### Process 
1. **Create Work Directories**: Set up directories for AnyLog/EdgeLake usage.
2. **Load Configuration**: Import environment configurations into the new node.
3. **Set Default Connections**: Establish default TCP, REST, and broker connections if specified.
4. **Blockchain Sync**: For non-master nodes, sync with the blockchain.

Once step 5 is executed, the generated policy triggers steps 6-11:

5. **Create Configuration Policy**: Generate a [configuration policy](node-deployment/policies/config_policy.al).
6. **Create Node Policy**: Generate a [node policy](node-deployment/policies/create_node_policy.al).
7. **Deploy Databases**: Initialize and deploy the necessary databases.
8. **Start Scheduling Processes**: Activate any scheduling processes.
9. **Enable Node Processes**: For publisher and operator nodes, enable the relevant processes.
10. **Run Additional Services**: Start services such as MQTT, node monitoring, and custom scripts.
11. **Enable License Key**: For AnyLog, enable the [license key](https://anylog.co/download-anylog/).


## Other Deployments
* [sample-scripts](sample-scripts) - sample commands that can be used by users
  * manual connection of network configurations
  * Examples for receiving data into AnyLog via a message client (_MQTT_ & _REST-POST_) or via _Kafka_   
  * how to connect postgres and mongo to databases
  * basic monitoring commends
  * how to deploy syslog
  * Setting a message client to accept data from [_FLEDGE_](https://lfedge.org/projects/fledge/)
* [grpc](grpc) - connecting and running gRPC client against KubeArmor and accept data associated with _alerts_, _logs_ and _messages_
* [Smart City](customers/smart-city) - provides a sample deployment of AnyLog / EdgeLake as a data manager for a smart city using 
_Dynics Fusion_. 
* [Machine Builder](customers/machine-builder) - provides a sample deployment for a machine builder 
