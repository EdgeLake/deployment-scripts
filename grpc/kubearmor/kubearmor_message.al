#-----------------------------------------------------------------------------------------------------------------------
# Declare Policy for KubeArmor
# :sample data:
#   {"Timestamp": "1703783776", "UpdatedTime": "2023-12-28T17:16:16.571714Z", "ClusterName": "default",
#     "HostName": "minikube", "NamespaceName": "default", "PodName": "nginx-7854ff8877-k4tsj",
#     "ContainerID": "cf3e3217059a56e21ca4cf676572ffb0aac66f0182fa107d239ce4636e53c396", "ContainerName": "nginx",
#     "HostPID": 1059919, "PPID": 1014073, "PID": 1673, "Type": "ContainerLog", "Operation": "Process",
#     "Resource": "/usr/bin/bash -c apt-get -y update && apt-get -y upgrade", "Data": "syscall=SYS_EXECVE",
#     "Result": "Passed",
#     "ContainerImage": "nginx:latest@sha256:2bdc49f2f8ae8d8dc50ed00f2ee56d00385c6f8bc8a8b320d0a294d9e3b49026",
#     "ProcessName": "/usr/bin/bash", "HostPPID": 1059916, "Labels": "app=nginx",
#     "Owner": {"Ref": "Deployment", "Name": "nginx", "Namespace": "default"}}
#-----------------------------------------------------------------------------------------------------------------------
# process !anylog_path/deployment-scripts/grpc/kubearmor/kubearmor_system_policy.al

on error ignore
:set-params:
new_policy = ""


:check-policy:
is_policy = blockchain get mapping where id = !grpc_name
if !is_policy then goto end-script


:prep-policy:
<new_policy = {
    "mapping": {
        "id": !grpc_name,
        "name": !grpc_name,
        "company": !company_name,
        "dbms": !default_dbms,
        "table": !grpc_response,
        "readings": "",
        "schema": {
            "timestamp": {
                "type": "timestamp",
                "default": "now()",
                "apply" :  "epoch_to_datetime",
                "bring": "[Timestamp]"
            },
            "updated_timestamp": { 
                "type": "timestamp",
                "default": "now()",
                "bring": "[UpdatedTime]"
            },
            "cluster_name": { 
                "type": "string",
                "default": "",
                "bring": "[ClusterName]",
                "optional": "true"
            },
            "hostname": { 
                "type": "string",
                "default": "minikube",
                "bring": "[HostName]"
            },
            "host_ip": { 
                "type": "string",
                "default": "",
                "bring": "[HostIP]"
            },
            "type": {
                "type": "string",
                "default": "",
                "bring": "[Type]"
            },
            "level": { 
                "type": "string",
                "default": "",
                "bring": "[level]"
            },
            "message": {
                "type": "string",
                "default": "",
                "bring": "[Message]"
            }
        }
    }
}>

:publish-policy:
process !local_scripts/policies/publish_policy.al
if error_code == 1 then goto sign-policy-error
if error_code == 2 then goto prepare-policy-error
if error_code == 3 then declare-    policy-error

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign cluster policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member cluster policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare cluster policy on blockchain"
goto terminate-scripts



