FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk wget curl net-tools nano python3 python3-pip \
    supervisor zookeeperd \
    && apt-get clean

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

## add sandbox user
RUN apt-get install -y sudo && \
    useradd -ms /bin/bash sandbox && \
    echo "sandbox:sandbox" | chpasswd && \
    adduser sandbox sudo && \
    usermod -aG sudo sandbox && \
    echo "sandbox ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# -----------------------
# SSH Setup
# -----------------------

RUN apt-get update && apt-get install -y openssh-server openssh-client sudo \
    && mkdir /var/run/sshd \

RUN echo "root:root" | chpasswd

RUN su - sandbox -c "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa" && \
    su - sandbox -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys" && \
    chmod 600 /home/sandbox/.ssh/authorized_keys

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's@PermitEmptyPasswords no@PermitEmptyPasswords no@' /etc/ssh/sshd_config


# -----------------------
# Hadoop (with YARN)
# -----------------------
ENV HADOOP_VERSION=3.3.6

RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
 && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt \
 && mv /opt/hadoop-${HADOOP_VERSION} /opt/hadoop \
 && rm hadoop-${HADOOP_VERSION}.tar.gz

ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV YARN_LOG_DIR=/var/log/yarn
ENV LOG_DIR=/var/log/hadoop
ENV HDFS_NAMENODE_USER=sandbox
ENV HDFS_SECONDARYNAMENODE_USER=sandbox
ENV HDFS_DATANODE_USER=sandbox

COPY config/hadoop/* $HADOOP_CONF_DIR/

RUN mkdir -p $YARN_LOG_DIR && \
    mkdir -p /var/run/hadoop-yarn && \
    mkdir -p /var/bigdata/data/dfs/namenode && \
    mkdir -p /var/bigdata/data/dfs/datanode && \
    chown -R sandbox:sandbox /var/bigdata/data/dfs && \
    chmod -R 755 /var/bigdata/data/dfs


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
ENV PATH=$PATH:$KVHOME/bin
ENV KVROOT=/var/bigdata/data/kvstore

RUN chmod 755 $KVHOME/*


# -----------------------
# MongoDB
# -----------------------

ENV MONGO_LOG_DIR=/var/bigdata/log/mongodb
ENV MONGO_DATA_DIR=/var/bigdata/data/mongodb

RUN wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add - && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update && \
    apt-get install -y mongodb-org && \
    apt-get clean && \
    mkdir -p $MONGO_LOG_DIR && \
    mkdir -p $MONGO_DATA_DIR && \
    chown -R sandbox:sandbox /var/bigdata/data/mongodb && \
    chmod -R 755 /var/bigdata/data/mongodb

ENV PATH=$PATH:/usr/bin/mongod:/usr/bin/mongo

# -----------------------
# Jupyter Notebook
# -----------------------
RUN pip3 install notebook pyhive

# -----------------------
# Pass all environment variables to sandbox user
# -----------------------

RUN printenv | grep -v "no_proxy" | grep -v "HTTP_PROXY" | grep -v "http_proxy" | grep -v "HTTPS_PROXY" | grep -v "https_proxy" | awk '{print "export " $0}'  >> /home/sandbox/.bashrc


# -----------------------
# Modify hadoop-fonctions.sh
# -----------------------
COPY config-scripts/patch-hadoop-renice.sh /tmp/patch-hadoop-renice.sh
RUN bash /tmp/patch-hadoop-renice.sh && rm /tmp/patch-hadoop-renice.sh

# -----------------------
# Expose ports
# -----------------------

EXPOSE 9870 9864 9000 \
       10000 10002 \
       2181 9092 27017\
       5000 5001 8888\
       8088 8042 22

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config-scripts/startup.sh /startup.sh
RUN chmod 755 /startup.sh
CMD ["/usr/bin/supervisord", "-n"]