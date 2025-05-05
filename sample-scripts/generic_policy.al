#-----------------------------------------------------------------------------------------------------------------------
# Generic Policy
# :requirements:
#   -> table_name: table where data is stored
# :other params;
#   -> policy_id: name of the policy
#   -> topic_name: message client policy
#   -> readings: if JSON comes with readings value then set readings
#   -> timestamp_column: timestamp column name (in brackets "[ ]")
#   -> is_epoch
#:sample policy:
# {'mapping' : {
#    'id' : 'generic_policy',
#    'company' : 'New Company',
#    'dbms' : 'new_company',
#    'table' : 'opc_data'
#    'schema' : {
#        'timestamp' : {
#            'type' : 'timestamp',
#            'default' : 'now()',
#            'apply' : 'epoch_to_datetime'
#        },
#        '*' : {
#          'type' : '*',
#           'bring' : '*'
#       }
#    },
#    'date' : '2024-05-04T21:38:53.942580Z'
# }}
#-----------------------------------------------------------------------------------------------------------------------
# process !anylog_path/deployment-scripts/demo-scripts/generic_policy.al

on error ignore

:set-params:
policy_id = generic_policy
topic_name = new-topic

# user should specify table name
set table_name = ""
set new_policy = ""
set readings = ""
set timestamp_column = "[timestamp]"
set is_epoch = false

if not !table_name then goto table-name-error

set create_policy = false

:check-policy:
policy = blockchain get mapping where id = !policy_id
if !policy then goto msg-call
if !create_policy == true then goto declare-policy-error

:create-policy:
set policy new_policy [mapping] = {}
set policy new_policy [mapping][id] = !policy_id
set policy new_policy [mapping][company] = !company_name
set policy new_policy [mapping][dbms] = !default_dbms
set policy new_policy [mapping][table] = opc_data
if !readings then set policy new_policy [mapping][readings] = !readings

set policy new_policy [mapping][schema] = {}

set policy new_policy [mapping][schema][timestamp] = {}
set policy new_policy [mapping][schema][timestamp][type] = timestamp
set policy new_policy [mapping][schema][timestamp][default] = now()
if !timestamp_column then set policy new_policy [mapping][schema][timestamp][bring] = [Timestamp]
if !is_epoch == true then set policy new_policy [mapping][schema][timestamp][apply] = epoch_to_datetime

<set policy new_policy [mapping][schema][*] = {
    "type": "*",
    "bring": ["*"]
}>

:publish-policy:
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy

:msg-call:
on error goto msg-error
if !anylog_broker_port then
<do run msg client where broker=local and port=!anylog_broker_port and log=false and topic=(
    name=!policy_id and
    policy=!policy_id
)>
if not !anylog_broker_port and !user_name and !user_password then
<do run msg client where broker=rest and port=!anylog_rest_port and user=!user_name and password=!user_password and user-agent=anylog and log=false and topic=(
    name=!policy_id and
    policy=!policy_id
)>
if not !anylog_broker_port and not !user_name and not !user_password then then
<do run msg client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=false and topic=(
    name=opc_demo and
    policy=!policy_id
)>

:end-script:
end script

:terminate-scripts:
exit scripts

:table-name-error:
print "Missing table name - cannot create policy"
goto end-script

:sign-policy-error:
print "Failed to sign master policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member master policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare master policy on blockchain"
goto terminate-scripts

:msg-error:
echo "Failed to deploy MQTT process"
goto end-script
