#!/bin/bash
echo "Starting Oracle NoSQL KVStore..."
nohup java -jar $KVHOME/lib/kvstore.jar kvlite -secure-config disable -port 5000 > /tmp/kvstore.log 2>&1 &
echo "KVStore started."