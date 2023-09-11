#-----------------------------------------------------------------------------------------------------------------------
# Declare a generic monitoring policy
#   -> free disk space
#   -> cpu percentage
#   -> networking IO
#   -> networking error count
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/training/generic_policies/generic_monitoring_policy.al
on error ignore

:is-policy:
is_policy = blockchain get schedule where id = generic-schedule-policy
if !is_policy then goto end-script

:declare-policy:
<new_policy = {
    "schedule": {
        "id": "generic-schedule-policy",
        "name": "Generic Schedule",
        "script": [
            'if !node_type == operator then schedule name = get_operator_stat and time = !schedule_time task node_insight = get operator stat format = json',
            'schedule name = disk_space and time = !schedule_time task node_insight[Free space %] = get disk percentage .',
            'schedule name = cpu_percent and time = !schedule_time task node_insight[CPU %] = get node info cpu_percent',
            'schedule name = packets_recv and time = !schedule_time task node_insight[Packets Recv] = get node info net_io_counters packets_recv',
            'schedule name = packets_sent and time = !schedule_time task node_insight[Packets Sent] = get node info net_io_counters packets_sent',
            'schedule name = errin and time = !schedule_time task errin = get node info net_io_counters errin',
            'schedule name = errout and time = !schedule_time task errout = get node info net_io_counters errout',
            'schedule name = error_count and time = !schedule_time task node_insight[Network Error] = python int(!errin) + int(!errout)',
            'schedule name = monitor_node and time = !schedule_time task run client (blockchain get !monitor_node where company=!monitor_node_company bring.ip_port) monitor operators where info = !node_insight'
        ]
}}>

process !local_scripts/training/publish_policy.al
if error_code == 1 then goto sign-policy-error
if error_code == 2 then goto prepare-policy-error
if error_code == 3 then declare-policy-error

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
echo "Failed to sign generic schedule policy"
goto terminate-scripts

:prepare-policy-error:
echo "Failed to prepare sign policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
echo "Failed to declare generic schedule policy on blockchain"
goto terminate-scripts