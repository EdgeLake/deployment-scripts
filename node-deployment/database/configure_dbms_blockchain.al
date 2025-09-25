#-----------------------------------------------------------------------------------------------------------------------
# Based on node_type create relevant databases / tables for master node
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/configure_dbms_blockchain.al

on error ignore
if !debug_mode == true then set debug on

:ledger-dbms:
on error goto ledger-db-error
if !debug_mode == true then print "Connect to blockchain database"
<if !db_type == psql then connect dbms blockchain where
    type=!db_type and
    user = !db_user and
    password = !db_passwd and
    ip = !db_ip and
    port = !db_port and
    autocommit = !autocommit and
    unlog = !unlog>
else if !db_type == sqlite then connect dbms blockchain where type=!db_type

on error goto ledger-table-error
if !debug_mode == true then print "Create table ledger in blockchain database"
is_table = info table blockchain ledger exists
if !is_table == false then create table ledger where dbms=blockchain

:end-script:
end script

:terminate-scripts:
exit scripts

:ledger-db-error:
echo "Error: Unable to connect to almgm database with db type: " !db_type ". Cannot continue"
goto terminate-scripts

:ledger-table-error:
echo "Error: Failed to create table blockchain.ledger. Cannot continue"
goto terminate-scripts

