#----------------------------------------------------------------------------------------------------------------------#
# Sample deployment process for OPC-UA
# https://github.com/AnyLog-co/documentation/blob/master/opcua.md
# :steps:
#   1. create OPC-UA policies
#   2. declare policies
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_path/deployment-scripts/demo-scripts/opcua_tags.al


:create-policy:
on error goto create-policy-error
<get opcua struct where
    url = !opcua_url and
    node = !opcua_node and
    dbms = !default_dbms and
    format = policy  and
    schema = true and
    class = variable and
    target = "local = true and master = !ledger_conn" and
    output = !tmp_dir/opcua_policies.al>

on error ignore
process !tmp_dir/opcua_policies.al

:opcua-client:
on error ignore
process !anylog_path/deployment-scripts/demo-scripts/opcua_client.al

:end-script:
end script

:create-policy-error:
print "Failed to create OPC-UA policies"
goto end-script
