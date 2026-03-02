on error ignore
set debug on
# Times Square - hardcoded stream (loaded by video_ai.al)
video_url = $VIDEO_URL
if not !video_url then video_url = "https://www.youtube.com/watch?v=rnXIjl_Rzy4"
video_name = $VIDEO_NAME
if not !video_name then video_name = timessquare
yolo_model_port = $YOLO_MODEL_PORT
if not !yolo_model_port then yolo_model_port = 50051
set enable_detections = false
if $ENABLE_DETECTIONS == true or $ENABLE_DETECTIONS == True or $ENABLE_DETECTIONS == TRUE then set enable_detections = true

if !enable_detections == true then
<do video connect where
    name = !video_name and
    protocol = https and
    interface = url and
    address = !video_url and
    video_dbms = !default_dbms and
    video_table = video_table and
    detection_dbms = customers and
    detection_table = detection_table and
    detection_column = person and
    detection_column = car and
    detection_column = truck and
    detection_column = bus and
    recording_segment_time = 1 and
    detection_ignore_time = 10
>
<do run grpc client where name=yolov5 and ip = !ip and port = !yolo_model_port and grpc_dir = !anylog_path/AnyLog-Network/external_lib/frame_modeling 
and proto = infer and function = PredictStream and request = "PredictRequest" and response = "PredictResponse" 
and service = InferenceService and debug = false and invoke = true>

#run video stream where name = timessquare and import_detect = initiate_yolo and import_display = imshow
do run video stream where name = !video_name and import_display = imshow and grpc_name = yolov5

else
<do video connect where
    name = !video_name and
    protocol = https and
    interface = url and
    address = !video_url and
    video_dbms = !default_dbms
>
do run video stream where name = !video_name and import_display = imshow

end script