#-----------------------------------------------------------------------------------------------------------------------
# Based on node_type create relevant databases / tables for almgm logical database
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/configure_dbms_almgm.al

on error ignore
if !debug_mode == true then set debug on

:almgm-dbms:
if !debug_mode == true then print "deploy `almgm` logical database - used for HA"

on error goto almgm-dbms-error
<if !db_type == psql then connect dbms almgm where
    type=!db_type and
    user = !db_user and
    password = !db_passwd and
    ip = !db_ip and
    port = !db_port>
else connect dbms almgm where type=!db_type

if !debug_mode == true then print "create tsd_info table in almgm"
on error goto almgm-table-error
is_table = info table almgm tsd_info exists
if !is_table == false then create table tsd_info where dbms=almgm


:end-script:
end script

:terminate-scripts:
exit scripts


:almgm-dbms-error:
echo "Error: Unable to connect to almgm database with db type: " !db_type ". Cannot continue"
goto terminate-scripts

:almgm-table-error:
echo "Error: Failed to create table almgm.tsd_info. Cannot continue"
goto terminate-scripts
