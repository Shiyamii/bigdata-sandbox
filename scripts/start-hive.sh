#!/bin/bash
echo "Starting Hive Metastore..."
schematool -dbType derby -initSchema --verbose || true
nohup $HIVE_HOME/bin/hive --service metastore > /tmp/hive-metastore.log 2>&1 &
echo "Starting HiveServer2..."
nohup $HIVE_HOME/bin/hive --service hiveserver2 > /tmp/hive-server2.log 2>&1 &
echo "Hive started."
