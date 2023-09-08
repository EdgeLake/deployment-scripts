#-----------------------------------------------------------------------------------------------------------------------
# Declare a generic operator node policy
#   -> connect to TCP and REST (both not binded)
#   -> run blockchain sync
#   -> create default dbms
#   -> create almgm + tsd_info
#   -> prepare for deployment
#   -> execute `run operator`
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/generic_scripts/generic_operator_policy.al
on error ignore

:is-policy:
is_policy = blockchain get config where id = generic-operator-policy
if !is_policy then goto end-script

:declare-policy:
<new_policy = {
    "config": {
        "id": "generic-operator-policy",
        "node_type": "operator",
        "ip": '!external_ip',
        "local_ip": '!ip',
        "port": '!anylog_server_port.int',
        "rest_port": '!anylog_rest_port.int',
        "script": [
            "set node name !node_name",
            "run scheduler 1",
            "run blockchain sync where source=master and time=30 seconds and dest=file and connection=!ledger_conn",
            "connect dbms !default_dbms where type=sqlite",
            "connect dbms almgm where type=sqlite",
            "create table tsd_info where dbms=sqlite",
            "partition !default_dbms * using insert_timestamp by day",
            "schedule time=1 day and name="Drop Partitions" task drop partition where dbms=!default_dbms and table=* and keep=3",
            "set buffer threshold where time=60 seconds and volume=10KB and write_immediate=true",
            "run streamer",
            "run blobs archiver where dbms=false and folder=true and compress=true and reuse_blobs=true",
            "run operator where create_table=true and update_tsd_info=true and compress_json=true and compress_sql=true and archive=true and master_node=!ledger_conn and policy=!operator_id and threads=3"
        ]
}}>

process !local_scripts/generic_scripts/publish_policy.al
if error_code == 1 then goto sign-policy-error
if error_code == 2 then goto prepare-policy-error
if error_code == 3 then declare-policy-error

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
echo "Failed to sign cluster policy"
goto terminate-scripts

:prepare-policy-error:
echo "Failed to prepare member cluster policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
echo "Failed to declare cluster policy on blockchain"
goto terminate-scripts