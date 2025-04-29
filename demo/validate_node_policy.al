#-----------------------------------------------------------------------------------------------------------------------
# Validate if policy exists
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/policies/validate_node_policy.al

on error ignore
if !debug_mode.int == 1 then set debug on
else if !debug_mode.int == 2 then debug interactive

if !debug_mode.int > 0 then print "check if node policy exists"
if !tcp_bind == false then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !external_ip and
    port = !anylog_server_port bring.first>
if !tcp_bind == true and !overlay_ip then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !overlay_ip and
    port = !anylog_server_port bring.first>
if !tcp_bind == true and not !overlay_ip then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !ip and
    port = !anylog_server_port bring.first>

:end-script:
end script

