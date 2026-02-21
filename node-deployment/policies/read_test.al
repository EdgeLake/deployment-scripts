#-----------------------------------------------------------------------------------------------------------------------
# Read readtest.txt and print its contents.
# Run: process !local_scripts/policies/read_test.al
#-----------------------------------------------------------------------------------------------------------------------
on error ignore


file_path = !local_scripts/policies/readtest.txt
content = python "open('" + !file_path + "').read()"
print !content

end script
