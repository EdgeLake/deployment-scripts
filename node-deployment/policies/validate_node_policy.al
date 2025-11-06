#-----------------------------------------------------------------------------------------------------------------------
# Validate if policy exists
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/policies/validate_node_policy.al

on error ignore
if !debug_mode == true then set debug on


if !debug_mode == true then print "check if node policy exists"

if !tcp_bind == false and !enable_dns == true and !enable_external_dns == true then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !external_dns and
    port = !anylog_server_port bring.first>
else  if !tcp_bind == true  and !overlay_ip then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !overlay_ip and
    port = !anylog_server_port bring.first>
else if !tcp_bind == true  and ( !enable_dns == true and (!is_dns_local == false or !dns_domain) ) then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !dns and
    port = !anylog_server_port bring.first>
else if !tcp_bind == true then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !dns and
    port = !anylog_server_port bring.first>
<else is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !external_ip and
    port = !anylog_server_port bring.first>

:end-script:
end script

