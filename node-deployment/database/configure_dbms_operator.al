#-----------------------------------------------------------------------------------------------------------------------
# Based on node_type create relevant databases / tables for operator node
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/configure_dbms_operator.al

on error ignore
if !debug_mode == true then set debug on

if !debug_mode == true then print "Deploy local database " !default_dbms

:operator-dbms:
on error goto operator-db-error
if !db_type == psql then
<do connect dbms !default_dbms where
    type=!db_type and
    user = !db_user and
    password = !db_passwd and
    ip = !db_ip and
    port = !db_port and
    autocommit = !autocommit and
    unlog = !unlog
>
else connect dbms !default_dbms where type=!db_type

:data-partitioning:
if !debug_mode == true then print "Set Partitioning"
if !enable_partitions == true then
do partition !default_dbms !table_name using !partition_column by !partition_interval
<do schedule time=!partition_sync and name="Drop Partitions"
    task drop partition where dbms=!default_dbms and table =!table_name and keep=!partition_keep>
schedule name=remove_archive and time=1 day and task delete archive where days = !archive_delete

:end-script:
end script

:terminate-scripts:
exit scripts

:operator-db-error:
echo "Error: Unable to connect to almgm database with db type: " !db_type ". Cannot continue"
goto terminate-scripts

