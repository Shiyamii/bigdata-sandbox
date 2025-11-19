#!/bin/bash

# Format HDFS only the first time
if [ ! -d "/tmp/hadoop-root/dfs/name" ]; then
  hdfs namenode -format
fi

# Start HDFS
$HADOOP_HOME/sbin/start-dfs.sh

# init Hive metastore schema
schematool -dbType derby -initSchema --verbose || true

exec "$@"
