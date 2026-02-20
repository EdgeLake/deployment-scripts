#-----------------------------------------------------------------------------------------------------------------------
# Small test script - run manually via: process !local_scripts/policies/test2.al
#-----------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------#
# The following demonstrates connecting to a live video stream (via Youtube or Twitch) and getting insights from it
#
# The sample code uses YOLO4 (darknet), but the code provided in (external_lib/frame_modeling/yolo_detection) is able to
# support up to version 9 of Yolo and preemptive Pytorch support
#
# :sample-urls:
#   - Abbey Road London: https://www.youtube.com/watch?v=57w2gYXjRic
#   - Times Square: https://www.youtube.com/watch?v=rnXIjl_Rzy4
#   - twitch : https://www.twitch.tv/citywalking4k
#----------------------------------------------------------------------------------------------------------------------#
on error ignore
:set-params:
if not $VIDEO_URL and not !video_url then goto missing-url

if $VIDEO_URL then video_url = $VIDEO_URL
video_url = "https://www.youtube.com/watch?v=rnXIjl_Rzy4"
video_host = 0.0.0.0
video_port = 8888
set enable_detections = false
set default_dbms=test

if $VIDEO_HOST then video_host = $VIDEO_HOST
if $VIDEO_PORT then video_port = $VIDEO_PORT

if $ENABLE_DETECTIONS == true or $ENABLE_DETECTIONS == True or $ENABLE_DETECTIONS == TRUE then set enable_detections = true


:browser-configs:
on error goto browser-configs-error

# python3 code to use from external library
import function where import_name = imshow and lib = external_lib.video_processing.cv2_stream_imshow and method = init_class

# declare params for init_class method
set function params where import_name = imshow and param_name = port and param_type = int and param_value = !video_port
set function params where import_name = imshow and param_name = host and param_value = !video_host

if !enable_ai == false then goto start-feed

:enable-detections:
on error goto enable-detections-error

# python3 code to use from external library
import function where import_name = initiate_yolo and lib = external_lib.frame_modeling.yolo_detection and method = init_class

# declare params for init_class method
set function params where import_name = initiate_yolo and param_name = module_type and param_value = darknet
set function params where import_name = initiate_yolo and param_name = classes and param_type = list and param_value = []
set function params where import_name = initiate_yolo and param_name = module_path1 and param_value = https://github.com/AlexeyAB/darknet/releases/download/yolov4/yolov4-tiny.weights
set function params where import_name = initiate_yolo and param_name = module_path2 and param_value = https://raw.githubusercontent.com/AlexeyAB/darknet/refs/heads/master/cfg/yolov4-tiny.cfg
set function params where import_name = initiate_yolo and param_name = coco_path and param_value = https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names

:start-feed:
on error goto start-feed-error
if !enable_detections == true then
<do video connect where
    name = youtube and
    protocol = https and
    interface = url and
    address = !video_url and
    video_dbms = !default_dbms and
    video_table = video_table and
    detection_dbms = video_dbms and
    detection_table = detection_table and
    detection_column = person and
    detection_column = car and
    detection_column = truck and
    detection_column = bus and
    recording_segment_time = 1 and
    detection_ignore_time = 10
>
do run video stream where name=youtube and import_detect = initiate_yolo and import_display = imshow
else
<do video connect where
    name = youtube and
    protocol = https and
    interface = url and
    address = !video_url and
    video_dbms = !default_dbms and
    video_table = video_table
>
do run video stream where name=youtube and import_display = imshow

# video connect where name = youtube and protocol = https and interface = url and address = !video_url and video_dbms = !default_dbms and video_table = video_table


:end-script:
end script

:missing-url:
echo "Missing live feed URL, cannot continue"
goto end-script

:browser-configs-error:
echo "Failed to init ImShow for browser"
goto end-script

:enable-detections-error:
echo "Failed to define detection information for live feed"
goto end-script

:start-feed-error:
echo "Failed to start video feed"
goto end-script
