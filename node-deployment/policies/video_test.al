#-----------------------------------------------------------------------------------------------------------------------
# Minimal video streaming - Twitch only. No YOLO, no storage. Just display the stream.
# Run: process !local_scripts/policies/video_test.al
# View at: http://localhost:8888 (or your host:8888 if running in Docker)
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

video_url = "https://www.twitch.tv/stopsigncam"
video_host = 0.0.0.0
video_port = 8888
set default_dbms = test

import function where import_name = imshow and lib = external_lib.video_processing.cv2_stream_imshow and method = init_class
set function params where import_name = imshow and param_name = port and param_type = int and param_value = !video_port
set function params where import_name = imshow and param_name = host and param_value = !video_host

<video connect where
    name = twitch and
    protocol = https and
    interface = url and
    address = !video_url and
    video_dbms = !default_dbms and
    video_table = video_table
>
run video stream where name = twitch and import_display = imshow

end script
