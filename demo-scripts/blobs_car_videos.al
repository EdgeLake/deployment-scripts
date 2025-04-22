#-----------------------------------------------------------------------------------------------------------------------
# The following provides an example for accepting video data into MongoDB. The example uses REST broker process, but the
# same can be applied with MQTT, and the policy is similar to what EdgeX generates. When deploying script on a publisher
# node, make sure the default logical database (!default_dbms) is set to an existing logical database.
#
# :AnyLog process:
#   0. Connect to (NoSQL) logical database
#   1. Set parameters
#   2. declare mapping policy
#   3. execute `run msg client`
#   4. From the outside deploy data generator
#       python3 $HOME/Sample-Data-Generator/data_generator_file_processing.py ~/Downloads/sample_data/videos/ ${REST_CONN_INFO} post \
#           --topic video-mapping \
#           --dbms test \
#           --table videos \
#           --enable-timezone-range \
#           --exception
#
# :sample data coming in:
# {
#   "apiVersion": "v2",
#   "id": "6b055b44-6eae-4f5d-b2fc-f9df19bf42cf",
#   "deviceName": "anylog-data-generator",
#   "origin": 1660163909,
#   "profileName": "anylog-video-generator",
#   "readings": [{
#       "start_ts": "2022-01-01 00:00:00",
#       "end_ts": "2022-01-01 00:00:05",
#       "binaryValue": "AAAAHGZ0eXBtcDQyAAAAAWlzb21tcDQxbXA0MgADWChtb292AAAAbG12aGQAAAAA3xnEUt8ZxFMAAHUwAANvyQABAA",
#       "mediaType": "video/mp4",
#       "origin": 1660163909,
#       "profileName": "traffic_data",
#       "resourceName": "OnvifSnapshot",
#       "valueType": "Binary",
#       "num_cars": 5,
#       "speed": 65.3
#   }],
#   "sourceName": "OnvifSnapshot"
# }
#
# :sample policy:
# {
#     "mapping": {
#        "id": !policy_id,
#        "dbms": "bring [dbName]",
#        "table": "bring [deviceName]",
#        "source": {
#            "bring": "[deviceName]",
#            "default": "car_data"
#        },
#        "readings": "readings",
#        "schema": {
#            "timestamp": {
#                "type": "timestamp",
#                "bring": "[timestamp]"
#           },
#            "start_ts": {
#                "type": "timestamp",
#                "bring": "[start_ts]"
#            },
#            "end_ts": {
#                "type": "timestamp",
#               "bring": "[end_ts]"
#            },
#            "file": {
#                "blob": true,
#                "bring": "[binaryValue]",
#                "extension": "mp4",
#                "apply": "base64decoding",
#                "hash": "md5",
#                "type": "varchar"
#            },
#            "file_type": {
#                "bring": "[mediaType]",
#                "type": "string"
#            },
#            "num_cars": {
#                "bring": "[num_cars]",
#                "type": "int"
#            },
#            "speed": {
#                "bring": "[speed]",
#                "type": "float"
#            }
#        }
#    }
# }
#
# :documents:
#   - Generic MQTT script: !local_scripts/deployment_scripts/mqtt.al
#   - Documentation: https://github.com/AnyLog-co/documentation/blob/master/image%20mapping.md
#-----------------------------------------------------------------------------------------------------------------------
# process !anylog_path/deployment-scripts/demo-scripts/blobs_car_videos.al

# declare policy
:prepare-policy:
policy_id = car-videos # used also as the mqtt topic name
policy = blockchain get mapping where id = !policy_id
if !policy then goto msg-call

:create-policy:
on error ignore
set new_policy = ""
set policy new_policy [mapping] = {}
set policy new_policy [mapping][id] = !policy_id
set policy new_policy [mapping][dbms] = "bring [dbName]"
set policy new_policy [mapping][table] = "bring [deviceName]"

set policy new_policy [mapping][source] = {}
set policy new_policy [mapping][source][bring] = "[deviceName]"
set policy new_policy [mapping][source][default] = "car_videos"

set policy new_policy [mapping][readings] = "readings"

set policy new_policy [mapping][schema] = {}
set policy new_policy [mapping][schema][timestamp] = {}
set policy new_policy [mapping][schema][timestamp][type] = "timestamp"
set policy new_policy [mapping][schema][timestamp][bring] = "[timestamp]"

set policy new_policy [mapping][schema][start_ts] = {}
set policy new_policy [mapping][schema][start_ts][type] = "timestamp"
set policy new_policy [mapping][schema][start_ts][bring] = "[start_ts]"

set policy new_policy [mapping][schema][end_ts] = {}
set policy new_policy [mapping][schema][end_ts][type] = "timestamp"
set policy new_policy [mapping][schema][end_ts][bring] = "[end_ts]"

set policy new_policy [mapping][schema][file] = {}
set policy new_policy [mapping][schema][file][blob] = true.bool
set policy new_policy [mapping][schema][file][bring] = "[binaryValue]"
set policy new_policy [mapping][schema][file][extension] = "mp4"
set policy new_policy [mapping][schema][file][hash] = "md5"
set policy new_policy [mapping][schema][file][type] = "varchar"

set policy new_policy [mapping][schema][file][apply] = "base64decoding"
# --- Sample Code for using opencv ---
# set policy new_policy [mapping][schema][file][apply] = "opencv"
# --- Sample Code for using opencv ---


set policy new_policy [mapping][schema][file_type] = {}
set policy new_policy [mapping][schema][file_type][type] = "string"
set policy new_policy [mapping][schema][file_type][bring] = "[mediaType]"

set policy new_policy [mapping][schema][num_cars] = {}
set policy new_policy [mapping][schema][num_cars][type] = "int"
set policy new_policy [mapping][schema][num_cars][bring] = "[num_cars]"

set policy new_policy [mapping][schema][speed] = {}
set policy new_policy [mapping][schema][speed][type] = "float"
set policy new_policy [mapping][schema][speed][bring] = "[speed]"


:test-policy:
test_policy = json !new_policy test
if !test_policy == false then goto test-policy-error

:publish-policy:
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error

:msg-call:
if !is_demo == true then goto end-script
on error goto msg-error
if !anylog_broker_port then
<do run msg client where broker=local and port=!anylog_broker_port and log=false and topic=(
    name=!policy_id and
    policy=!policy_id
)>
else if not !anylog_broker_port and !user_name and !user_password then
<do run msg client where broker=rest and port=!anylog_rest_port and user=!user_name and password=!user_password and user-agent=anylog and log=false and topic=(
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

:test-policy-error:
echo "Invalid JSON format, cannot declare policy"
goto end-script

:sign-policy-error:
print "Failed to sign cluster policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member cluster policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare cluster policy on blockchain"
goto terminate-scripts

:policy-error:
print "Failed to publish policy for an unknown reason"
goto terminate-scripts


:msg-error:
echo "Failed to deploy MQTT process"
goto end-script