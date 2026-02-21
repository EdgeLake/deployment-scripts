#-----------------------------------------------------------------------------------------------------------------------
# Video streaming from readtest.txt. Format: name,url per line (e.g. bobross,https://www.twitch.tv/bobross)
# Parses Twitch/YouTube/etc from URL automatically. View at: http://localhost:8888/stream/{name}
# Run: process !local_scripts/policies/video_test.al
# Docker: port 8888 must be exposed (-p 8888:8888)
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

if not !anylog_path then anylog_path = /app
if not !local_scripts then local_scripts = !anylog_path + "/deployment-scripts/node-deployment"

# Generate video_streams_generated.al from readtest.txt
streams_txt = !local_scripts + "/policies/readtest.txt"
streams_generated = !local_scripts + "/policies/video_streams_generated.al"
script_path = !local_scripts + "/policies/generate_video_streams.py"
gen_cmd = "python3 " + !script_path + " " + !streams_txt + " " + !streams_generated
system !gen_cmd

video_host = 0.0.0.0
video_port = 8888
set default_dbms = test

import function where import_name = imshow and lib = external_lib.video_processing.cv2_stream_imshow and method = init_class
set function params where import_name = imshow and param_name = port and param_type = int and param_value = !video_port
set function params where import_name = imshow and param_name = host and param_value = !video_host

# Load and run all streams from generated script
process !streams_generated
print "Streams loaded from readtest.txt - view at http://localhost:8888/stream/{name}"

end script
