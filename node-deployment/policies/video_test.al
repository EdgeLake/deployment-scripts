#-----------------------------------------------------------------------------------------------------------------------
# Video streaming from readtest.txt. Format: name,url per line (e.g. bobross,https://www.twitch.tv/bobross)
# Parses Twitch/YouTube/etc from URL automatically. View at: http://localhost:8888/stream/{name}
# Run: process !local_scripts/policies/video_test.al
# Docker: port 8888 must be exposed (-p 8888:8888)
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

if not !anylog_path then anylog_path = /app
if not !local_scripts then local_scripts = !anylog_path + "/deployment-scripts/node-deployment"

# Generate video_streams_generated.al from readtest.txt using inline Python
streams_txt = !local_scripts + "/policies/readtest.txt"
streams_generated = !local_scripts + "/policies/video_streams_generated.al"
python "(lambda fp,gp:(lambda c:[open(gp,'w').write('on error ignore'+chr(10)+chr(10)+chr(10).join([(lambda p:chr(60)+'video connect where'+chr(10)+'    name = '+p[0].strip()+' and'+chr(10)+'    protocol = https and'+chr(10)+'    interface = url and'+chr(10)+'    address = '+chr(34)+p[1].strip().replace(chr(34),chr(92)+chr(34))+chr(34)+' and'+chr(10)+'    video_dbms = !default_dbms and'+chr(10)+'    video_table = video_table'+chr(10)+chr(62)+chr(10)+'run video stream where name = '+p[0].strip()+' and import_display = imshow')(l.split(',',1)) for l in c.split(chr(10)) if l.strip() and ',' in l])+chr(10)+'end script'+chr(10))][0])(open(fp).read().replace(chr(13),'')))(r'" + !streams_txt + "',r'" + !streams_generated + "')"

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
