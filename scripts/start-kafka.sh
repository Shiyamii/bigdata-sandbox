#!/bin/bash
echo "Starting Zookeeper..."
nohup /usr/share/zookeeper/bin/zkServer.sh start-foreground > /tmp/zookeeper.log 2>&1 &
echo "Starting Kafka broker..."
nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /tmp/kafka.log 2>&1 &
echo "Kafka started."
