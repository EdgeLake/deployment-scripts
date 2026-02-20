#-----------------------------------------------------------------------------------------------------------------------
# Small test script - run manually via: process !local_scripts/policies/test.al
#-----------------------------------------------------------------------------------------------------------------------
##### Ubuntu Akave Video Streaming Demo ######
###### connect dbms customers where type = bucket and provider = akave and access_key = $AKAVE_ACCESS_KEY and secret_key = $AKAVE_SECRET_KEY and region = akave-network and endpoint = $AKAVE_ENDPOINT and network_id = xx01xx
#### Make sure to connect to a dbms named customers or change the dbms name
##### The last video_url is what will be used. also change the video_host ip
#### For now, connect to a mongodb container
video_table=video_table
video_url = "rtsp://192.168.1.203:8554/live.sdp"
video_url = "https://www.twitch.tv/livingbrasil"
video_url = "https://www.twitch.tv/truckersaw"
video_url = "https://cwwp2.dot.ca.gov/vm/loc/d5/sr1oceanstreet.htm"
video_url = "https://camstreamer.com/embed/fnRZFv4aEbT5kehuU8H5wFSLfOjDDqx39k4hTw3x?rel=0"
video_url = "https://www.twitch.tv/stopsigncam"
video_url = "https://camstreamer.com/embed/qjmkJiI8u6XjTJDZfZyRXCWExnqShE2SzV3udJmd?rel=0"
video_url = "https://cwwp2.dot.ca.gov/vm/loc/d12/i5112disneylanddr.htm"
video_url = "https://www.twitch.tv/stopsigncam"
video_url = "https://camstreamer.com/embed/qjmkJiI8u6XjTJDZfZyRXCWExnqShE2SzV3udJmd?rel=0"
video_url = "https://www.youtube.com/watch?v=rnXIjl_Rzy4"
video_url = "https://www.twitch.tv/stopsigncam"
video_host = 192.168.1.206
video_port = 8889
import function where import_name = imshow and lib = external_lib.video_processing.cv2_stream_imshow and method = init_class
set function params where import_name = imshow and param_name = port and param_type = int and param_value = !video_port
set function params where import_name = imshow and param_name = host and param_value = !video_host
<video connect where
    name = video-ai and
    protocol = https and
    interface = url and
    address = !video_url and
    video_dbms = customers and
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
run video stream where name = video-ai and import_display = imshow and grpc_name = yolov5
#### Query for all inference rows
sql customers info = (dest_type = rest) and extend=(+node_name, @ip, @port, @dbms_name, @table_name, +video_table) and format = json and timezone = utc  select file, timestamp, car, truck, bus, person from detection_table where timestamp > now() - 5 minutes order by timestamp --> selection (columns: ip using ip and port using port and dbms using dbms_name and table using video_table and file using file)
#### avg per video
sql customers info = (dest_type = rest) and extend=(+node_name, @ip, @port, @dbms_name, @table_name, +video_table) and format = json and timezone = utc  select file, COUNT(file) as num_infer, MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, AVG(car) as avg_car, AVG(truck) as avg_truck, AVG(bus) as avg_bus, AVG(person) as avg_person from detection_table where timestamp > now() - 10 minutes group by file order by max_ts --> selection (columns: ip using ip and port using port and dbms using dbms_name and table using video_table and file using file)
sql customers info = (dest_type = rest) and extend=(+node_name, @ip, @port, @dbms_name, @table_name, +video_table) and format = json and timezone = utc  SELECT DISTINCT file, insert_timestamp, timestamp, file_size, is_deleted FROM video_table  GROUP BY node_name, file, insert_timestamp, timestamp, file_size, is_deleted ORDER BY file --> selection (columns: ip using ip and port using port and dbms using dbms_name and table using table_name and file using file)
#### Install yt-dlp in container 
apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
 && chmod a+rx /usr/local/bin/yt-dlp
rm /app/AnyLog-Network/external_lib/video_processing/cookies/youtube.txt
yt-dlp --cookies-from-browser chrome --cookies /app/AnyLog-Network/external_lib/video_processing/cookies/youtube.txt "https://www.youtube.com/watch?v=rnXIjl_Rzy4"
yt-dlp --cookies-from-browser chrome --cookies youtube.txt "https://www.youtube.com/watch?v=rnXIjl_Rzy4"
yt-dlp \
  --cookies /app/AnyLog-Network/external_lib/video_processing/cookies/youtube.txt \
  --add-headers "User-Agent: Mozilla/5.0" \
  --add-headers "Accept-Language: en-US,en;q=0.9" \
  "https://www.youtube.com/"
