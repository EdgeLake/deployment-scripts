#-----------------------------------------------------------------------------------------------------------------------
# Based on node_type create relevant databases / tables for monitoring logical database
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/configure_dbms_monitoring.al

on error ignore
if !debug_mode == true then set debug on

:monitoring-dbms:
if !debug_mode == true then print "deploy `monitoring` logical database - used for HA"

on error goto monitoring-dbms-error
<if !db_type == psql then connect dbms monitoring where
    type=!db_type and
    user = !db_user and
    password = !db_passwd and
    ip = !db_ip and
    port = !db_port>
else connect dbms monitoring where type=!db_type


:end-script:
end script

:monitoring-dbms-error:
echo "Error: Unable to connect to monitoring database with db type: " !db_type ". Cannot continue"
goto end-script

:monitoring-table-error:
echo "Error: Failed to create table monitoring.tsd_info. Cannot continue"
goto end-script
