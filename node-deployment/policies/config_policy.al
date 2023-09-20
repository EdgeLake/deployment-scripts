:check-policy:
config_id = blockchain get config where company=!company_name and config=!config_name bring [*][id]
if !config_id then goto config-policy
if not !config_id and !create_config == true then goto declare-policy-error

:preapare-new-policy:
new_policy = ""
set policy new_policy [config] = {}
set policy new_policy [config][name] = !config_name
set policy new_policy [config][company] = !company_name

:network-configs:
if !overlay_ip and !tcp_bind == true then set policy new_policy [config][ip] = '!overlay_ip'
if not !overlay_ip and !tcp_bind == true then set policy new_policy [config][ip] = '!ip'
if !overlay_ip and !tcp_bind == false then
do set policy new_policy [config][ip] = '!external_ip'
do set policy new_policy [config][internal_ip] = '!overlay_ip'
if not !overlay_ip and !tcp_bind == false then
do set policy new_policy [config][ip] = '!external_ip'
do set policy new_policy [config][internal_ip] = '!ip'

if !overlay_ip and !rest_bind == true then set policy new_policy [config][rest_ip] = '!overlay_ip'
if not !overlay_ip and !rest_bind == true then set policy new_policy [config][rest_ip] = '!ip'

if !anylog_broker_port and (!node_type == operator or !node_type == publisher) then
do if !overlay_ip and !bind_bind == true then set policy new_policy [config][bind_ip] = '!overlay_ip'
do if not !overlay_ip and !bind_bind == true then set policy new_policy [config][bind_ip] = '!ip'


set policy new_policy [config][port] = '!anylog_server_port.int'
set policy new_policy [config][rest_port] = '!anylog_rest_port.int'
if !anylog_broker_port and (!node_type == operator or !node_type == publisher) then set policy new_policy [config][broker_port] = '!anylog_broker_port.int'

set policy new_policy [config][threads] = '!tcp_threads.int'
set policy new_policy [config][rest_threads] = '!rest_threads.int'
if !anylog_broker_port and (!node_type == operator or !node_type == publisher) then set policy new_policy [config][broker_threads] = '!broker_threads.int'
set policy new_policy [config][rest_timeout] = '!rest_timeout.int'

:scripts:
<set policy new_policy [config][script] = [
    "if !node_type == master then process !local_scripts/policies/master_policy.al",
    "run scheduler 1",
    "run blockchain sync where source=!blockchain_source and time=!blockchain_sync and dest=!blockchain_destination and connection=!ledger_conn"
]>

:publish-policy:
process !local_scripts/policies/publish_policy.al
if error_code == 1 then goto sign-policy-error
if error_code == 2 then goto prepare-policy-error
if error_code == 3 then declare-policy-error
set create_policy = true
goto check-policy

:config-policy:
on error goto config-policy-error
config from policy where id=!cofig_id

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign config policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member config policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare config policy on blockchain"
goto terminate-scripts

:config-policy-error: 
print "Failed to execute config policy"
goto terminate-scripts
