on error ignore

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
run video stream where name = timessquare and import_detect = initiate_yolo and import_display = imshow

end script
