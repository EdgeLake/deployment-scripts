#-----------------------------------------------------------------------------------------------------------------#
# Configuration policy related to node monitoring
#-----------------------------------------------------------------------------------------------------------------#
# process !local_scripts/policies/southbound_monitoring_policy.al

on error ignore
set create_config = false

:get-monitoring-config:
on error ignore
is_policy = blockchain get config where id = monitoring-config
if !is_policy then goto config-policy
if not !is_policy and !create_config == true then goto declare-policy-error

:monitoring-config:
<new_policy = {
    "config": {
        "name": "monitoring policy",
        "id": "monitoring-config",
        "script": [
            "if !monitor_nodes == true or !syslog_monitoring == true or !docker_monitoring == true then process !local_scripts/database/configure_dbms_monitoring.al"
            "if !monitor_nodes == true then process !anylog_path/deployment-scripts/node-deployment/connectors/monitoring_policy.al",
            "if !syslog_monitoring == true then process !anylog_path/deployment-scripts/node-deployment/connectors/syslog.al",
            "if !docker_monitoring == true then process !anylog_path/deployment-scripts/node-deployment/docker_insight.al"
        ]
    }
}>

:publish-policy:
set is_config = true
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_config = true
wait 5
blockchain reload metadata
set is_config = false
goto get-monitoring-config

:publish-policy:
set is_config = true
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_config = true
wait 5
blockchain reload metadata
set is_config = false
goto check-policy

:config-policy:
on error goto config-policy-error
config from policy where id = !config_id

:end-script:
end script

:sign-policy-error:
print "Failed to sign config policy"
goto end-script

:prepare-policy-error:
print "Failed to prepare member config policy for publishing on blockchain"
goto end-script

:declare-policy-error:
print "Failed to declare config policy on blockchain"
goto end-script

:config-policy-error:
print "Failed to execute config policy"
goto end-script
