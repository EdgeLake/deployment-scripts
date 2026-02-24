#-----------------------------------------------------------------------------------------------------------------------
# Hardcoded video AI - Times Square stream with YOLO detection (boxes overlay, no DB storage)
# Run: process !local_scripts/videostreaming/video_ai.al
# View: http://localhost:8888/stream/timessquare
#-----------------------------------------------------------------------------------------------------------------------
# Modeled after video_test.al: setup display + YOLO first, then process video_ai_streams.al (like video_test processes video_streams_generated.al)
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

print "video_ai.al: Starting..."

set debug on

:set-paths:
if not !anylog_path then anylog_path = /app
if not !local_scripts then local_scripts = !anylog_path + "/deployment-scripts/node-deployment"
streams_generated = !local_scripts + "/videostreaming/video_ai_streams.al"
print "video_ai.al: Paths set, streams script = " + !streams_generated

:setup-display:
on error goto setup-error
video_host = 0.0.0.0
video_port = 8888
set default_dbms = test
print "video_ai.al: Setting up video display (imshow)..."
import function where import_name = imshow and lib = external_lib.video_processing.cv2_stream_imshow and method = init_class
set function params where import_name = imshow and param_name = port and param_type = int and param_value = !video_port
set function params where import_name = imshow and param_name = host and param_value = !video_host
print "video_ai.al: Display setup complete"

:enable-detections:
on error goto enable-detections-error
print "video_ai.al: Setting up YOLO detection..."
import function where import_name = initiate_yolo and lib = external_lib.frame_modeling.yolo_detection and method = init_class
set function params where import_name = initiate_yolo and param_name = module_type and param_value = darknet
set function params where import_name = initiate_yolo and param_name = classes and param_type = list and param_value = []
set function params where import_name = initiate_yolo and param_name = module_path1 and param_value = https://github.com/AlexeyAB/darknet/releases/download/yolov4/yolov4-tiny.weights
set function params where import_name = initiate_yolo and param_name = module_path2 and param_value = https://raw.githubusercontent.com/AlexeyAB/darknet/refs/heads/master/cfg/yolov4-tiny.cfg
set function params where import_name = initiate_yolo and param_name = coco_path and param_value = https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names
print "video_ai.al: YOLO setup complete"

:load-streams:
on error goto load-error
print "video_ai.al: Processing streams script (video_ai_streams.al)..."
thread !local_scripts/videostreaming/video_ai_streams.al
print "video_ai.al: Done - view at http://localhost:8888/stream/timessquare"
goto end-script

:end-script:
end script

:setup-error:
print "video_ai.al: ERROR - Failed to setup video display (imshow)"
goto end-script
:enable-detections-error:
print "video_ai.al: ERROR - Failed to setup YOLO detection"
goto end-script
:load-error:
print "video_ai.al: ERROR - Failed to load streams"
goto end-script
