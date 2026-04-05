#--------------------------------------------------------------------------------------------------------------------#
# Mapping policy for vessel data
#--------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/data-generator/mapping/vessel_POSITION-LOGS.al
on error ignore

set create_policy = false

:check-policy:
is_policy = blockchain get (mapping, transform) where id = POSITION-LOGS
if !is_policy then goto end-script
else if not !is_policy and !create_table == true then goto declare-policy-error


:declare-policy:
<new_policy = [{
    "mapping" : {
        "id" : "POSITION-LOGS",
        "dbms" : "bring [dbms]",
        "table" : "position_logs",
        "readings" : "",
        "schema" : {
            "timestamp" : {
                "type" : "timestamp",
                "default" : "now()",
                "bring" : "[timestamp]"
            },
            "boat_name" : {
                "type" : "string",
                "bring" : "[boat_name]",
                "default" : ""
            },
            "side" : {
                "type" : "string",
                "bring" : "[side]",
                "default" : ""
            },
            "ip_index" : {
                "type" : "int",
                "bring" : "[ip_index]",
                "default" : None
            },
            "motor_id" : {
                "type" : "int",
                "bring" : "[motor_id]",
                "default" : None
            },
            "__start__" : {"script" : ["set POSITION-LOGS_counter = 0"]
            },
            "hmiYear" : {
                "type" : "int",
                "bring" : "[hmiYear]",
                "default" : None,
                "optional" : True,
                "script" : ["if [hmiYear] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "hmiMonth" : {
                "type" : "int",
                "bring" : "[hmiMonth]",
                "default" : None,
                "optional" : True,
                "script" : ["if [hmiMonth] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "hmiDay" : {
                "type" : "int",
                "bring" : "[hmiDay]",
                "default" : None,
                "optional" : True,
                "script" : ["if [hmiDay] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "hmiHour" : {
                "type" : "int",
                "bring" : "[hmiHour]",
                "default" : None,
                "optional" : True,
                "script" : ["if [hmiHour] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "hmiMinute" : {
                "type" : "int",
                "bring" : "[hmiMinute]",
                "default" : None,
                "optional" : True,
                "script" : ["if [hmiMinute] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "hmiSecond" : {
                "type" : "int",
                "bring" : "[hmiSecond]",
                "default" : None,
                "optional" : True,
                "script" : ["if [hmiSecond] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "currentPositionLatitude" : {
                "type" : "float",
                "bring" : "[currentPositionLatitude]",
                "default" : None,
                "optional" : True,
                "script" : ["if [currentPositionLatitude] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "currentPositionLongitude" : {
                "type" : "float",
                "bring" : "[currentPositionLongitude]",
                "default" : None,
                "optional" : True,
                "script" : ["if [currentPositionLongitude] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "currentPositionToggle" : {
                "type" : "int",
                "bring" : "[currentPositionToggle]",
                "default" : None,
                "optional" : True,
                "script" : ["if [currentPositionToggle] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "currentHeading" : {
                "type" : "int",
                "bring" : "[currentHeading]",
                "default" : None,
                "optional" : True,
                "script" : ["if [currentHeading] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "headingDestination" : {
                "type" : "float",
                "bring" : "[headingDestination]",
                "default" : None,
                "optional" : True,
                "script" : ["if [headingDestination] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "headingHome" : {
                "type" : "float",
                "bring" : "[headingHome]",
                "default" : None,
                "optional" : True,
                "script" : ["if [headingHome] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "speedOverGround" : {
                "type" : "float",
                "bring" : "[speedOverGround]",
                "default" : None,
                "optional" : True,
                "script" : ["if [speedOverGround] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "speedOverGroundFixed" : {
                "type" : "float",
                "bring" : "[speedOverGroundFixed]",
                "default" : None,
                "optional" : True,
                "script" : ["if [speedOverGroundFixed] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "speedThroughWater" : {
                "type" : "int",
                "bring" : "[speedThroughWater]",
                "default" : None,
                "optional" : True,
                "script" : ["if [speedThroughWater] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "sogValid" : {
                "type" : "int",
                "bring" : "[sogValid]",
                "default" : None,
                "optional" : True,
                "script" : ["if [sogValid] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "trip" : {
                "type" : "float",
                "bring" : "[trip]",
                "default" : None,
                "optional" : True,
                "script" : ["if [trip] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "distanceHome" : {
                "type" : "float",
                "bring" : "[distanceHome]",
                "default" : None,
                "optional" : True,
                "script" : ["if [distanceHome] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "distanceDestination" : {
                "type" : "float",
                "bring" : "[distanceDestination]",
                "default" : None,
                "optional" : True,
                "script" : ["if [distanceDestination] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "socDestination" : {
                "type" : "int",
                "bring" : "[socDestination]",
                "default" : None,
                "optional" : True,
                "script" : ["if [socDestination] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "socHome" : {
                "type" : "int",
                "bring" : "[socHome]",
                "default" : None,
                "optional" : True,
                "script" : ["if [socHome] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "timeDestHour" : {
                "type" : "int",
                "bring" : "[timeDestHour]",
                "default" : None,
                "optional" : True,
                "script" : ["if [timeDestHour] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "timeDestMinute" : {
                "type" : "int",
                "bring" : "[timeDestMinute]",
                "default" : None,
                "optional" : True,
                "script" : ["if [timeDestMinute] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "timeHomeHour" : {
                "type" : "int",
                "bring" : "[timeHomeHour]",
                "default" : None,
                "optional" : True,
                "script" : ["if [timeHomeHour] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "timeHomeMinute" : {
                "type" : "int",
                "bring" : "[timeHomeMinute]",
                "default" : None,
                "optional" : True,
                "script" : ["if [timeHomeMinute] then POSITION-LOGS_counter = incr !POSITION-LOGS_counter"]
            },
            "__end__" : {"script" : ["if !POSITION-LOGS_counter == 0 then streaming data ignore event"]}
        }
   }
}>

:publish-policy:
process !local_scripts/node-deployment/policies/publish_policy.al
if not !error_code.int then
do set create_policy = true
goto check-table-policy

if !error_code == 1 then goto sign-policy-error
else if !error_code == 2 then goto prepare-policy-error
else if !error_code == 3 then goto declare-policy-error

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign mapping policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare mapping policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare mapping policy on blockchain"
goto terminate-scripts
