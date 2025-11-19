#!/bin/bash
echo "Starting HDFS..."
if [ ! -d "/tmp/hadoop-root/dfs/name" ]; then
    hdfs namenode -format
fi
$HADOOP_HOME/sbin/start-dfs.sh
echo "HDFS started."
