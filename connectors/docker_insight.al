on error ignore
if !node_type != operator then goto pull-data
:store-monitoring:
process !local_scripts/database/configure_dbms_monitoring.al

on error goto partition-data-err
partition monitoring docker_insight using timestamp by 12 hours
schedule time=12 hours and name="drop docker_insight partitions" task drop partition where dbms=monitoring and table=docker_insight and keep=3




:pull-data:
on error pull-data-error
<run scheduled pull
  where name = docker_client
  and type = docker
  and frequency = 5
  and continuous = false
  and dbms = monitoring
  and table = docker_insight>

if !node_type == operator or !node_type == publisher then goto end-script


# if not !docker_operator then docker_operator = blockchain get operator bring.first [*][ip] : [*][port]
# run client (!docker_operator) file copy !watch_dir/* !!watch_dir
# system mv !watch_dir/* !bkup_dir/

:end-script:
end script

:partition-data-err:
print "Error: Failed to set partitioning for default database"
goto end-script

:pull-data-error:
print "Error occurred during pull-data"
goto end-script

