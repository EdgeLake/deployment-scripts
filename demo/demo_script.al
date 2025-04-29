
print "Starting debug demo"

set restarted = false

:report-pass:
set pass = true
if !restarted == true then do set pass = false
if !pass == true then
do print "I passed"
else print "I did not pass"

set debug on

run client 10.0.0.228:32148 print "Hello from operator 2"

set debug off

:get-status:
on error goto run-client-error
run client 10.0.0.228:32148 get status


set debug interactive

print "here"


:restart-script:
if !restarted == false then
do set restarted = true
do print "Restarting script"
do goto report-pass
else
do print "Skipping restart script"
do goto terminate-scripts

:jump-error:
print "Error with jump"
goto terminate-scripts

:run-client-error:
print "Error with run client command"
goto terminate-scripts

:terminate-scripts:
print "Exiting script"
exit scripts