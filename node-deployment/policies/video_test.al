#-----------------------------------------------------------------------------------------------------------------------
# Minimal video streaming - Twitch and YouTube. No YOLO, no storage. Just display the streams.
# Run: process !local_scripts/policies/video_test.al
#
# View at: http://localhost:8888/stream/twitch   or   http://localhost:8888/stream/youtube
# If in Docker: port 8888 must be exposed (-p 8888:8888)
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

video_host = 0.0.0.0
video_port = 8888
set default_dbms = test

import function where import_name = imshow and lib = external_lib.video_processing.cv2_stream_imshow and method = init_class
set function params where import_name = imshow and param_name = port and param_type = int and param_value = !video_port
set function params where import_name = imshow and param_name = host and param_value = !video_host

# Twitch stream
<video connect where
    name = twitch and
    protocol = https and
    interface = url and
    address = "https://www.twitch.tv/stopsigncam" and
    video_dbms = !default_dbms and
    video_table = video_table
>
run video stream where name = twitch and import_display = imshow

# YouTube stream
<video connect where
    name = youtube and
    protocol = https and
    interface = url and
    address = "https://www.youtube.com/watch?v=rnXIjl_Rzy4" and
    video_dbms = !default_dbms and
    video_table = video_table
>
run video stream where name = youtube and import_display = imshow

end script
