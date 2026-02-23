on error ignore

# Times Square - hardcoded stream (loaded by video_ai.al)
<video connect where
    name = timessquare and
    protocol = https and
    interface = url and
    address = "https://www.youtube.com/watch?v=rnXIjl_Rzy4" and
    video_dbms = !default_dbms and
    video_table = video_table
>
run video stream where name = timessquare and import_detect = initiate_yolo and import_display = imshow

end script
