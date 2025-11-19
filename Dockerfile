FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk wget curl net-tools nano python3 python3-pip \
    supervisor zookeeperd \
    && apt-get clean

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# -----------------------
# Hadoop
# -----------------------
ENV HADOOP_VERSION=3.3.6

RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
 && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt \
 && mv /opt/hadoop-${HADOOP_VERSION} /opt/hadoop \
 && rm hadoop-${HADOOP_VERSION}.tar.gz

ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# -----------------------
# Hive
# -----------------------
ENV HIVE_VERSION=4.0.1

RUN wget https://downloads.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
 && tar -xzf apache-hive-${HIVE_VERSION}-bin.tar.gz -C /opt \
 && mv /opt/apache-hive-${HIVE_VERSION}-bin /opt/hive \
 && rm apache-hive-${HIVE_VERSION}-bin.tar.gz

ENV HIVE_HOME=/opt/hive
ENV PATH=$PATH:$HIVE_HOME/bin

# -----------------------
# Sqoop
# -----------------------
ENV SQOOP_VERSION=1.4.7

RUN wget https://archive.apache.org/dist/sqoop/${SQOOP_VERSION}/sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0.tar.gz  \
 && tar -xzf sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0.tar.gz -C /opt \
 && mv /opt/sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0 /opt/sqoop \
 && rm sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0.tar.gz

ENV SQOOP_HOME=/opt/sqoop
ENV PATH=$PATH:$SQOOP_HOME/bin

# -----------------------
# Kafka
# -----------------------
ENV KAFKA_VERSION=3.8.0
ENV SCALA_VERSION=2.13

RUN wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
 && mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
 && rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

# -----------------------
# Oracle NoSQL (KVStore)
# -----------------------
ENV KV_VERSION=25.1.13

RUN wget https://github.com/oracle/nosql/releases/download/v25.1.13/kv-ce-25.1.13.tar.gz \
 && tar -xzf kv-ce-25.1.13.tar.gz -C /opt \
 && mv /opt/kv-25.1.13 /opt/kvstore \
 && rm kv-ce-25.1.13.tar.gz

ENV KVHOME=/opt/kvstore

RUN chmod 777 $KVHOME/*

# -----------------------
# Jupyter Notebook
# -----------------------
RUN pip3 install notebook pyhive

# -----------------------
# Scripts pour démarrer chaque service
# -----------------------
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

EXPOSE 9870 9864 9000 \
       10000 10002 \
       2181 9092 \
       5000 5001 \
       8888

CMD ["tail", "-f", "/dev/null"]
