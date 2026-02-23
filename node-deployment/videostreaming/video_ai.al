#-----------------------------------------------------------------------------------------------------------------------
# Hardcoded video AI - Times Square stream with YOLO detection (boxes overlay, no DB storage)
# Run: process !local_scripts/videostreaming/video_ai.al
# View: http://localhost:8888/stream/timessquare
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

:setup:
video_url = "https://www.youtube.com/watch?v=rnXIjl_Rzy4"
video_host = 0.0.0.0
video_port = 8888
set default_dbms = test

:display:
import function where import_name = imshow and lib = external_lib.video_processing.cv2_stream_imshow and method = init_class
set function params where import_name = imshow and param_name = port and param_type = int and param_value = !video_port
set function params where import_name = imshow and param_name = host and param_value = !video_host

:yolo:
import function where import_name = initiate_yolo and lib = external_lib.frame_modeling.yolo_detection and method = init_class
set function params where import_name = initiate_yolo and param_name = module_type and param_value = darknet
set function params where import_name = initiate_yolo and param_name = classes and param_type = list and param_value = []
set function params where import_name = initiate_yolo and param_name = module_path1 and param_value = https://github.com/AlexeyAB/darknet/releases/download/yolov4/yolov4-tiny.weights
set function params where import_name = initiate_yolo and param_name = module_path2 and param_value = https://raw.githubusercontent.com/AlexeyAB/darknet/refs/heads/master/cfg/yolov4-tiny.cfg
set function params where import_name = initiate_yolo and param_name = coco_path and param_value = https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names

:stream:
<do video connect where
    name = timessquare and
    protocol = https and
    interface = url and
    address = !video_url and
    video_dbms = !default_dbms and
    video_table = video_table
>
do run video stream where name = timessquare and import_detect = initiate_yolo and import_display = imshow

:end-script:
echo "Times Square stream with YOLO - view at http://localhost:8888/stream/timessquare"
end script
