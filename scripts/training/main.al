#----------------------------------------------------------------------------------------------------------------------#
# Main for generic scripts
#   -> set directory structure
#   -> set configs
#   -> declare policies
#   -> execute based on node type
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/training/main.al

on error ignore
set debug off
set authentication off
set echo queue on

:license-key:
on error call license-key-error
if $LICENSE_KEY then set license where activation_key = $LICENSE_KEY

:directories:
if $ANYLOG_PATH then set anylog_path = $ANYLOG_PATH
set anylog home !anylog_path
if $LOCAL_SCRIPTS then set local_scripts = $LOCAL_SCRIPTS
if $TEST_DIR then set test_dir = $TEST_DIR

on error call work-dirs-error
create work directories

:set-params:
on error ignore
process !local_scripts/training/set_params.al

:declare-policies:
process !local_scripts/training/generic_policies/generic_policy.al
process !local_scripts/training/generic_policies/generic_master_policy.al
process !local_scripts/training/generic_policies/generic_operator_policy.al
process !local_scripts/training/generic_policies/generic_query_policy.al
process !local_scripts/training/generic_policies/generic_publisher_policy.al
process !local_scripts/training/generic_policies/generic_monitoring_policy.al

:execute-policy:
policy_id = blockchain get config where node_type = !node_type bring [*][id]
on error call config-from-policy-error
if !policy_id then config from policy where id = !policy_id

:create-keys:
on error ignore
node_id = get node id
if not !public_key then
do id create keys where password = dummy and keys_file = node_id
do goto create-keys
print !public_key


:create-policy:
if !node_type == master then
<do new_policy = create policy master where
        name=!node_name and
        company=!company_name and
        ip=!external_ip and
        local_ip=!ip and
        port=!anylog_server_port and
        rest_port=!anylog_rest_port and
        id=!node_id>


:end-script:
end script

:config-from-policy-error:
print "Failed to configure from policy for node type " !node_type
return

:license-key-error:
print "Failed to enable license key"
return

:work-dirs-error;
echo "Failed to create directories"
return
