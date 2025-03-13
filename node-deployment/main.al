#-----------------------------------------------------------------------------------------------------------------------
# The following is intended to deploy an AnyLog instance based on user configurations
# If !policy_based_networking == true, the deployment is executed in the following way
# Script: !local_scripts/start_node_policy_based.al
#   1. set params
#   2. run tcp server
#   3. blockchain seed
#   4. config node based on node type - if node type is generic then "stop"
#-----------------------------------------------------------------------------------------------------------------------
# python3.10 AnyLog-Network/anylog_enterprise/anylog.py process $ANYLOG_PATH/deployment-scripts/node-deployment/main.al

:set-configs:
on error ignore
set debug off
set echo queue on

:is-edgelake:
# check whether we're running EdgeLake or AnyLog
set is_edgelake = false
version = get version
deployment_type = python !version.split(" ")[0]
if !deployment_type != AnyLog then set is_edgelake = true
if !is_edgelake == true and $NODE_TYPE == publisher then edgelake-error

if !is_edgelake == false then set authentication off

:directories:
# directory where deployment-scripts is stored
set anylog_path = /app
if $ANYLOG_PATH then set anylog_path = $ANYLOG_PATH
else if $EDGELAKE_PATH then set anylog_path = $EDGELAKE_PATH
set anylog home !anylog_path

create work directories

set local_scripts = !anylog_path/deployment-scripts/node-deployment
if $LOCAL_SCRIPTS then set local_scripts = $LOCAL_SCRIPTS
set test_dir = /app/deployment-scripts/test
if $TEST_DIR then set test_dir = $TEST_DIR


:set-params:
process !local_scripts/set_params.al
process !local_scripts/connect_networking.al

:is-generic:
if !node_type == generic then goto set-license

:blockchain-seed:
on error call blockchain-seed-error
if !node_type != master then blockchain seed from !ledger_conn

:declare-policy:
process !local_scripts/policies/config_policy.al

:set-license:
on error ignore
if !is_edgelake == true then goto end-script
if not !license_key and noddee

master_license = blockchain get master bring [*][license]
on error goto license-error
if !license_key then set license where activation_key = !license_key
if not !license_key and !master_license then set license where activation_key = !master_license
if not !license_key and not !master_license then goto license-error

:end-script:
get processes
if !enable_mqtt == true then get msg client
reset error log
end script

:edgelake-error:
print "Node type `publisher` not supported with EdgeLake deployment"
goto terminate-scripts

:blockchain-seed-error:
print "Failed to run blockchain seed"
return

:license-error:
print "Failed set license"
goto end-script

