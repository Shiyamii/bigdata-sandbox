FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-8-jdk wget curl net-tools nano python3 python3-pip \
    supervisor zookeeperd \
    && apt-get clean

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
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
ENV HIVE_VERSION=3.1.3

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

RUN wget https://downloads.apache.org/sqoop/${SQOOP_VERSION}/sqoop-${SQOOP_VERSION}.bin__hadoop-3.2.0.tar.gz \
 && tar -xzf sqoop-${SQOOP_VERSION}.bin__hadoop-3.2.0.tar.gz -C /opt \
 && mv /opt/sqoop-${SQOOP_VERSION}.bin__hadoop-3.2.0 /opt/sqoop \
 && rm sqoop-${SQOOP_VERSION}.bin__hadoop-3.2.0.tar.gz

ENV SQOOP_HOME=/opt/sqoop
ENV PATH=$PATH:$SQOOP_HOME/bin

# -----------------------
# Kafka
# -----------------------
ENV KAFKA_VERSION=3.7.0
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
ENV KV_VERSION=12.2.5

RUN wget https://download.oracle.com/otn-pub/otn_software/nosql-database/kv-${KV_VERSION}.tar.gz \
 && tar -xzf kv-${KV_VERSION}.tar.gz -C /opt \
 && mv /opt/kv-${KV_VERSION} /opt/kvstore \
 && rm kv-${KV_VERSION}.tar.gz

ENV KV_HOME=/opt/kvstore

# -----------------------
# Jupyter Notebook
# -----------------------
RUN pip3 install notebook pyhive

# -----------------------
# Supervisord
# -----------------------
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# -----------------------
# Init scripts
# -----------------------
COPY start-all.sh /usr/local/bin/start-all.sh
RUN chmod +x /usr/local/bin/start-all.sh

EXPOSE 9870 9864 9000 \
       10000 10002 \
       2181 9092 \
       5000 5001 \
       8888

CMD ["/usr/bin/supervisord"]
