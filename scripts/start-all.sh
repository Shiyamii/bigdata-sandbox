#!/bin/bash
/usr/local/bin/start-hdfs.sh
/usr/local/bin/start-hive.sh
/usr/local/bin/start-kafka.sh
/usr/local/bin/start-nosql.sh
/usr/local/bin/start-jupyter.sh
echo "All services started!"
