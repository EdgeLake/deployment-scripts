#-----------------------------------------------------------------------------------------------------------------------
# Hardcoded video AI - Times Square stream with YOLO detection (boxes overlay, no DB storage)
# Run: process !local_scripts/videostreaming/video_ai.al
# View: http://localhost:8888/stream/timessquare
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

print "video_ai.al: Starting..."
:setup:
video_url = "https://www.youtube.com/watch?v=rnXIjl_Rzy4"
video_host = 0.0.0.0
video_port = 8888
set default_dbms = test
print "video_ai.al: Setup complete - url = " + !video_url + " host = " + !video_host + " port = " + !video_port

:display:
print "video_ai.al: Setting up video display (imshow)..."
on error goto display-error
import function where import_name = imshow and lib = external_lib.video_processing.cv2_stream_imshow and method = init_class
set function params where import_name = imshow and param_name = port and param_type = int and param_value = !video_port
set function params where import_name = imshow and param_name = host and param_value = !video_host
print "video_ai.al: Display (imshow) setup complete"

:yolo:
print "video_ai.al: Setting up YOLO detection..."
on error goto yolo-error
import function where import_name = initiate_yolo and lib = external_lib.frame_modeling.yolo_detection and method = init_class
set function params where import_name = initiate_yolo and param_name = module_type and param_value = darknet
set function params where import_name = initiate_yolo and param_name = classes and param_type = list and param_value = []
set function params where import_name = initiate_yolo and param_name = module_path1 and param_value = https://github.com/AlexeyAB/darknet/releases/download/yolov4/yolov4-tiny.weights
set function params where import_name = initiate_yolo and param_name = module_path2 and param_value = https://raw.githubusercontent.com/AlexeyAB/darknet/refs/heads/master/cfg/yolov4-tiny.cfg
set function params where import_name = initiate_yolo and param_name = coco_path and param_value = https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names
print "video_ai.al: YOLO setup complete"

:stream:
print "video_ai.al: Connecting to Times Square stream..."
on error goto stream-error
<do video connect where
    name = timessquare and
    protocol = https and
    interface = url and
    address = !video_url and
    video_dbms = !default_dbms and
    video_table = video_table
>
print "video_ai.al: Video connect done, starting stream with YOLO..."
do run video stream where name = timessquare and import_detect = initiate_yolo and import_display = imshow
print "video_ai.al: Stream started"
goto end-script

:end-script:
print "video_ai.al: Done - view at http://localhost:8888/stream/timessquare"
end script

:display-error:
print "video_ai.al: ERROR - Failed to setup video display (imshow)"
goto end-script
:yolo-error:
print "video_ai.al: ERROR - Failed to setup YOLO detection"
goto end-script
:stream-error:
print "video_ai.al: ERROR - Failed to connect or start Times Square stream"
goto end-script
