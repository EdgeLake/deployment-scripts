#----------------------------------------------------------------------------------------------------------------------#
# Declare a policy specific for different types of node monitoring
#   -> generic: cpu, disk, file i/o, event count, etc.
#   -> store syslog into Operator database(s)
#   -> docker insights
#:params:
#   operator_monitoring_ip - IP and Port (TCP) for sending data from non-Operator node(s) into Operator node(s)
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/monitoring_policy.al


on error ignore

if !debug_mode == true then set debug on

if !store_monitoring == true and !node_type == operator then process !local_scripts/connectors/monitoring_table_policy.al

:set-params:
if !debug_mode == true then print "Setting env params"
schedule_id = config-monitoring
set create_policy = false

on error ignore
if !debug_mode == true then set debug on

:declare-policy:
if !store_monitoring == true and !node_type == operator then process !local_scripts/connectors/monitoring_table_policy.al

:check-policy:
if !debug_mode == true then print "check if policy exists"
is_policy = blockchain get schedule where id=!schedule_id

# just created the policy + exists
if !is_policy then goto config-policy

# failure show created policy
if not !is_policy and !create_policy == true then goto declare-policy-error

:schedule-policy:
if !debug_mode == true then print "create policy"
new_policy=""
<new_policy = {
    "schedule": {
        "id": !schedule_id,
        "name": "Node Monitoring Schedule",
        "script": [
            "if !node_type != operator and (!monitor_nodes == true or !syslog_monitoring == true or !docker_monitoring == true) then schedule name=operator_monitoring_ips and time=300 seconds and task if not !operator_monitoring_ip then operator_monitoring_ip = blockchain get operator bring.first [*][ip] : [*][port]",
            "if !node_type == operator and (!monitor_nodes == true or !syslog_monitoring == true or !docker_monitoring == true) then process !anylog_path/deployment-scripts/southbound-monitoring/configure_dbms_monitoring.al",
            "if !monitor_nodes == true then process !anylog_path/deployment-scripts/southbound-monitoring/node_monitoring.al",
            "if !syslog_monitoring == true then process !anylog_path/deployment-scripts/southbound-monitoring/syslog_monitoring_table.al"
        ]
    }
}>

:publish-policy:
on error ignore
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy

:config-policy:
if !debug_mode == true then print "Config from policy"
on error goto config-policy-error
config from policy where id=!schedule_id

:end-script:
end script

:terminate-scripts:
exit scripts

:store-monitoring-error:
print "Failed to store "
:config-policy-error:
print "Failed to configure node based on Schedule ID"
goto terminate-scripts

:sign-policy-error:
print "Failed to sign schedule policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member schedule policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare schedule policy on blockchain"
goto terminate-scripts

