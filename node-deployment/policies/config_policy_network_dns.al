#----------------------------------------------------------------------------------------------------------------------#
# Create configuration policy based on variables
# :sample-master-policy:
# [{'config' : {'name' : 'master-anylog_co.-configs',
#              'company' : 'AnyLog Co.',
#              'ip' : '!external_dns',
#              'local_ip' : '!dns',
#              'port' : '!anylog_server_port.int',
#              'rest_port' : '!anylog_rest_port.int',
#              'threads' : '!tcp_threads.int',
#              'rest_threads' : '!rest_threads.int',
#              'rest_timeout' : '!rest_timeout.int',
#              'script' : [
#                   'process !local_scripts/policies/master_policy.al',
#                   'process !local_scripts/database/deploy_database.al',
#                   'run scheduler 1',
#                   'run blockchain sync where source=!blockchain_source and time=!blockchain_sync and dest=!blockchain_source != master and connection=!ledger_conn',
#                   'process !local_scripts/policies/monitoring_policy.al',
#                   'if !deploy_local_script == true then process !local_scripts/loca'l_script.al'
#               ],
#              'id' : 'fd547a557d63e18d10335d8df59c2cfb',
#              'date' : '2024-02-05T01:14:22.204991Z',
#              'ledger' : 'global'}}]
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/policies/config_policy_network_dns.al

reset error log
reset echo queue
reset event log

on error ignore
if !debug_mode == true then set debug on

:check-policy:
if !debug_mode == true then print "Check whether config policy exists - if exists then goes to declare policy"

:prepare-new-policy:
if !debug_mode == true then print "Create base for new config policy"

new_policy = ""
set policy new_policy [config] = {}
set policy new_policy [config][name] = !config_name
set policy new_policy [config][company] = !company_name
set policy new_policy [config][node_type] = !node_type

:network-configs:
if !debug_mode.int == 2 then
do set debug interactive
do print "Add networking configurations for policy"
do set debug on

set policy new_policy [config][ip] = '!external_dns'
set policy new_policy [config][local_ip] = '!dns'
if !overlay_ip then set policy new_policy [config][local_ip] = '!overlay_ip'

set policy new_policy [config][port] = '!anylog_server_port.int'
set policy new_policy [config][rest_port] = '!anylog_rest_port.int'
if !anylog_broker_port then set policy new_policy [config][broker_port] = '!anylog_broker_port.int'

set policy new_policy [config][threads] = '!tcp_threads.int'
set policy new_policy [config][tcp_bind] = '!tcp_bind'

set policy new_policy [config][rest_threads] = '!rest_threads.int'
set policy new_policy [config][rest_timeout] = '!rest_timeout.int'
set policy new_policy [config][rest_bind] = '!rest_bind'
if !rest_bind == true and  not !overlay_ip then set new_policy [config][rest_ip] == '!dns'
if !rest_bind == true and !overlay_ip      then set policy new_policy [config][rest_ip] = '!overlay_ip'

if !anylog_broker_port then
do set policy new_policy [config][broker_threads] = '!broker_threads.int'
do set policy new_policy [config][broker_bind] = '!broker_bind'

if !broker_bind == true and  not !overlay_ip then set new_policy [config][broker_ip] == '!dns'
if !broker_bind == true and !overlay_ip      then set policy new_policy [config][broker_ip] = '!overlay_ip'

:end-script:
end script