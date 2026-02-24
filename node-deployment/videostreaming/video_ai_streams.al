on error ignore
set debug interactive
# Times Square - hardcoded stream (loaded by video_ai.al)
<video connect where
    name = timessquare and
    protocol = https and
    interface = url and
    address = "https://www.youtube.com/watch?v=rnXIjl_Rzy4" and
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
<run grpc client where name=yolov5 and ip = 127.0.0.1 and port = 50051 and grpc_dir = /app/AnyLog-Network/external_lib/frame_modeling/ 
and proto = infer and function = PredictStream and request = "PredictRequest" and response = "PredictResponse" 
and service = InferenceService and debug = false and invoke = true>

#run video stream where name = timessquare and import_detect = initiate_yolo and import_display = imshow
run video stream where name = timessquare and import_display = imshow and grpc_name = yolov5

end script
