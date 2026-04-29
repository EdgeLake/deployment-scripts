#--------------------------------------------------------------------------------------------------------------------
# The following was used in a demo by AnyLog / IoTech System - EdgeXpert to demonstrate demo data being sent into
# AnyLog. The data used was retail-device1 and lightout. The example expects EdgeX to send data directly into the
# AnyLog broker or REST (POST) port.
# :sample-data:
# {
#  "apiVersion": "v2",
#  "id": "707564c4-6818-4746-9c54-219a0fd110c6",
#  "deviceName": "ba-virtual",
#  "profileName": "BuildingAutomationVirtualDevice",
#  "sourceName": "AvgTemp",
#  "origin": 1686087247849269800,
#  "readings": [
#    {
#      "id": "42700bdd-4525-443f-88dd-22c488011b65",
#      "origin": 1686087247849269800,
#      "deviceName": "ba-virtual",
#      "resourceName": "AvgTemp",
#      "profileName": "BuildingAutomationVirtualDevice",
#      "valueType": "Float32",
#      "units": "°F",
#      "value": "7.934139e+01"
#    }
#  ]
# :documentation:
#   - https://github.com/AnyLog-co/documentation/blob/master/using%20edgex.md
#--------------------------------------------------------------------------------------------------------------------
# process !local_scripts/demo-scripts/edgex.al

on error ignore

set create_policy = false

:prepare-policy:
policy_id = basic-mqtt
policy = blockchain get mapping where id = !policy_id
if !policy then goto msg-call
if !create_policy == true then goto declare-policy-error

:declare-policy:
mapping_policy = []
<mapping_policy = {
    "mapping": {
        "id": !topic_name,
        "dbms": !default_dbms,
        "table": "bring [sourceName]",
        "readings": "readings",
        "schema": {
            "timestamp" : {
                "bring": "[origin]",
                "default" : "now()",
                "type" : "timestamp",
                "apply" :  "epoch_to_datetime"
            },
            "reading_id": {
                "type": "string",
                "value": "bring [id]"
            },
            "units": {
                "type": "string",
                "value": "bring [units]",
                "default": ""
            },
            "value": [
                {
                    "table": "PeopleCount",
                    "type": "int",
                    "value": "bring [value]"
                },
                {
                    "table": "CO2",
                    "type": "float",
                    "value": "bring [value]"
                },
                {
                    "table": "AvgTemp",
                    "type": "float",
                    "value": "bring [value]"
                },
                {
                    "table": "FreezerTemp1",
                    "type": "float",
                    "value": "bring [value]"
                },
                {
                    "table": "FreezerTemp2",
                    "type": "float",
                    "value": "bring [value]"
                },
                {
                    "table": "lightout1",
                    "type": "int",
                    "value": "bring [value]"
                },
                {
                    "table": "lightout2",
                    "type": "int",
                    "value": "bring [value]"
                },
                {
                    "table": "lightout3",
                    "type": "int",
                    "value": "bring [value]"
                },
                {
                    "table": "lightout4",
                    "type": "int",
                    "value": "bring [value]"
                },
                {
                    "table": "fanstatus",
                    "type": "int",
                    "value": "bring [value]"
                },
                {
                    "table": "zonetemp",
                    "type": "float",
                    "value": "bring [value]"
                },
                {
                    "type": "float",
                    "value": "bring [value]"
                }
            ]
        }
    }
}>

:publish-policy:
process !local_scripts/node-deployment/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy


:msg-call:
on error goto msg-error
if not !anylog_broker_port and !user_name and !user_password then
<do run msg client where broker=rest and port=!anylog_rest_port and user=!user_name and password=!user_password and user-agent=anylog and log=false and topic=(
    name=!policy_id and
    policy=!policy_id
)>
else if !anylog_broker_port then
<do run msg client where broker=local and port=!anylog_broker_port and log=false and topic=(
    name=!policy_id and
    policy=!policy_id
)>
else if not !anylog_broker_port then
<do run msg client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=false and topic=(
    name=!policy_id and
    policy=!policy_id
)>

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign master policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member master policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare master policy on blockchain"
goto terminate-scripts

:msg-error:
echo "Failed to deploy MQTT process"
goto end-script