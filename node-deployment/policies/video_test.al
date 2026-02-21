#-----------------------------------------------------------------------------------------------------------------------
# Video streaming from readtest.txt. Format: name,url per line (e.g. bobross,https://www.twitch.tv/bobross)
# Parses Twitch/YouTube/etc from URL automatically. View at: http://localhost:8888/stream/{name}
# Run: process !local_scripts/policies/video_test.al
# Docker: port 8888 must be exposed (-p 8888:8888)
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

:set-paths:
if not !anylog_path then anylog_path = /app
if not !local_scripts then local_scripts = !anylog_path + "/deployment-scripts/node-deployment"

streams_txt = !local_scripts + "/policies/readtest.txt"
streams_generated = !local_scripts + "/policies/video_streams_generated.al"

:generate-script:
on error goto generate-error
# Run shell script to generate video_streams_generated.al from readtest.txt
script_path = !local_scripts + "/policies/generate_video_streams.sh"
gen_cmd = "sh " + !script_path + " " + !streams_txt + " " + !streams_generated
system !gen_cmd
goto setup-display

:setup-display:
on error goto setup-error
video_host = 0.0.0.0
video_port = 8888
set default_dbms = test

import function where import_name = imshow and lib = external_lib.video_processing.cv2_stream_imshow and method = init_class
set function params where import_name = imshow and param_name = port and param_type = int and param_value = !video_port
set function params where import_name = imshow and param_name = host and param_value = !video_host

:load-streams:
on error goto load-error
process !streams_generated
print "Streams loaded from readtest.txt - view at http://localhost:8888/stream/{name}"
goto end-script

:end-script:
end script

:generate-error:
echo "Failed to generate video streams from readtest.txt"
goto end-script

:setup-error:
echo "Failed to setup video display (imshow)"
goto end-script

:load-error:
echo "Failed to load streams from generated script"
goto end-script
