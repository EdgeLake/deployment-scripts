#----------------------------------------------------------------------------------------------------------------------
# The following provides an example for data coming in from Topic - Enterprise_C/#
# unlike the other examples, "Enterprise C" is dynamic which means it automatically creates a UNS structure
# based on the data flowing in and then inserts it into AnyLog.
#
# Data is stored in timestamp / value logic with the sensor/device acting as the table name
#
# The following example uses dynamic against topic =
#----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/data-generator/mqtt_enterprise_c_tff.al

:msg-client:
on error goto msg-client-error
<run msg client where
    broker=172.104.228.251 and port=1883 and
    user=anyloguser and password=mqtt4AnyLog! and
    log=false and topic=(
        name="Enterprise C/sub/#" and
        dbms = !default_dbms and
        dynamic = true
    )>

:end-script:
end script

:msg-client-error:
echo "Failed to declare msg client"
goto end-script
