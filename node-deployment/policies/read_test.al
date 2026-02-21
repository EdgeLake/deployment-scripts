#-----------------------------------------------------------------------------------------------------------------------
# Read readtest.txt and print its contents.
# Run: process !local_scripts/policies/read_test.al
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

if not !anylog_path then anylog_path = /app
if not !local_scripts then local_scripts = !anylog_path + "/deployment-scripts/node-deployment"

file_path = !local_scripts + "/policies/readtest.txt"
content = python "open('" + !file_path + "').read()"
print !content

end script
