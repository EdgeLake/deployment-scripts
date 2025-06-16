:store-monitoring:
if !debug_mode == true then print "Monitoring database and table configurations for docker_insight"
on error goto store-monitoring-error
connect dbms monitoring where type=sqlite
create table syslog where dbms=monitoring

on error goto partition-data-err
partition monitoring docker_insight using timestamp by 12 hours
schedule time=12 hours and name="drop docker_insight partitions" task drop partition where dbms=monitoring and table=docker_insight and keep=3


:pull-data:
on error
<run scheduled pull
  where name = docker_client
  and type = docker
  and frequency = 5
  and continuous = false
  and dbms = monitoring
  and table = docker_insight>



:end-script:
end script

:terminate-scripts:
exit scripts

:store-monitoring-error:
print "Failed to store"

:partition-data-err:
print "Error: Failed to set partitioning for default database"
goto terminate-scripts
