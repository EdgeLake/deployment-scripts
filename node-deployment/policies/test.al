#-----------------------------------------------------------------------------------------------------------------------
# Small test script - run manually via: process !local_scripts/policies/test.al
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

print "=== Test Script Started ==="
hostname = get hostname
print "Hostname: " + !hostname
print "Timestamp: " + now
print "=== Test Script Done ==="
end script
