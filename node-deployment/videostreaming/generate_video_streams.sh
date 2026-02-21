#!/bin/sh
# Read stream list from videostreams.txt (format: name,url per line) and generate
# video_streams_generated.al with video connect + run video stream blocks.
#
# Usage: ./generate_video_streams.sh <input_txt> <output_al>

if [ $# -lt 2 ]; then
  echo "Usage: generate_video_streams.sh <input_txt> <output_al>" >&2
  exit 1
fi

INPUT="$1"
OUTPUT="$2"

{
  echo "on error ignore"
  echo ""
  while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$line" ] && continue
    name=$(echo "$line" | cut -d',' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    url=$(echo "$line" | cut -d',' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$name" ] || [ -z "$url" ] && continue
    url_escaped=$(echo "$url" | sed 's/"/\\"/g')
    echo "# $name"
    echo "<video connect where"
    echo "    name = $name and"
    echo "    protocol = https and"
    echo "    interface = url and"
    echo "    address = \"$url_escaped\" and"
    echo "    video_dbms = !default_dbms and"
    echo "    video_table = video_table"
    echo ">"
    echo "run video stream where name = $name and import_display = imshow"
    echo ""
  done < "$INPUT"
  echo "end script"
} > "$OUTPUT"

count=$(grep -c "^# " "$OUTPUT" 2>/dev/null || echo 0)
echo "Generated $count stream(s) -> $OUTPUT"
