# Big Data sandbox docker setup

## Overview

This repository contains a Docker image and a Docker Compose configuration to create a local Big Data sandbox. 
The provided image installs and prepares several common components of a Big Data ecosystem: 
SSH, Hadoop (HDFS + YARN), Mongodb, Hive, Sqoop, Kafka, Oracle NoSQL (KVStore) and a Jupyter server.

> For the moment only Hadoop, Mongodb & Oracle NoSQL (KVStore) have been verified to work correctly in this setup.

This README explains what is in the `Dockerfile` and the `docker-compose.yml`, which ports are exposed, 
which environment variables are available, and how to build / run the service on a local machine (Windows, cmd.exe shell).

## Fair Warning

This setup is intended for local development, learning and experimentation only. 
It is not suitable for production use. The configuration files, security settings, resource allocations and other 
parameters are simplified for ease of use and may not reflect best practices for a production environment.

Also, this project can easily break due to changes in the upstream software packages (mainly Oracle NoSQL database ;) ),
so please consider it a starting point for your own experiments rather than a stable solution.

## Main contents

`Dockerfile`: builds an image based on `ubuntu:22.04` and installs:
  - OpenJDK 11, basic utilities (wget, curl, net-tools, nano, python3, pip3)
  - OpenSSH server (with password authentication enabled for user `root`, password `root`)
  - Hadoop (version 3.3.6) — deployed under `/opt/hadoop` and added to PATH
  - Hive (version 4.0.1) — deployed under `/opt/hive` and added to PATH
  - Sqoop (version 1.4.7) — deployed under `/opt/sqoop`
  - Kafka (version 3.8.0, Scala 2.13) — deployed under `/opt/kafka`
  - Oracle NoSQL (KVStore) — deployed under `/opt/kvstore`
  - Jupyter Notebook (installed via pip)

## How to use this repository

### Prebuilt image
A prebuilt version of the Docker image is available on Docker Hub as `shiyamii/bigdata-sandbox:latest`.
You can use it with the `docker-compose.yml` in the `docker-composes` folder directly without building it yourself 
by pulling and running it via Docker Compose:
```bat
docker-compose pull
docker-compose up -d
```

### Connect to the container

#### SSH access
You can SSH into the container using the following command (from your host machine):

```bat
ssh -p 2222 sandbox@localhost
```

The default password for the `sandbox` user is `sandbox`.

#### Docker exec access
Alternatively, you can open a bash shell inside the running container using:
```bat
docker exec -it sandbox bash
```


### Examples to run

See the [EXAMPLES.md](EXAMPLES.md) file for some basic commands to run Hadoop jobs, start Hive, Kafka and Oracle NoSQL (KVStore).

## Exposed ports and expected usage

Here are the ports published in `docker-compose.yml` (host:container) and their expected usage:

- 2222:22 — SSH access to the container
- 9870:9870 — NameNode web UI (HDFS) ✓
- 9864:9864 — DataNode web UI (HDFS) ✓
- 8088:8088 — YARN ResourceManager web UI ✓
- 9000:9000 — HDFS RPC / client port (often used as fs.defaultFS) ✓
- 27017:27017 — MongoDB ✓
- 10000:10000 — HiveServer2 (JDBC/Beeline client connection ns)
- 10002:10002 — (likely used for an auxiliary or custom Hive/metastore service)
- 2181:2181 — Zookeeper (coordination for Kafka and KV store)
- 9092:9092 — Kafka broker
- 5000:5000 and 5001:5001 — ports used by Oracle NoSQL/KVStore in this image ✓
- 8888:8888 — Jupyter Notebook

Note: these usages correspond to the standard packages installed in the image; 
only those marked with a ✓ have been verified to work in this specific setup.


## Useful endpoints

- HDFS NameNode UI: http://localhost:9870 ✓
- DataNode UI: http://localhost:9864 ✓
- YARN ResourceManager UI: http://localhost:8088  ✓
- HiveServer2 (JDBC/Beeline): localhost:10000
- Kafka broker: localhost:9092
- Zookeeper: localhost:2181
- Jupyter: http://localhost:8888


## Detailed instructions for modification, build and run

### Configuration and scripts

- Hadoop configuration files (e.g. `yarn-site.xml` and `mapred-site.xml`) should be located in the project's `config/` directory. The `Dockerfile` attempts to copy files from `config/hadoop/yarn-site.xml` and `config/hadoop/mapred-site.xml` into the Hadoop configuration inside the image.

  Important: in this repository the `config/` root already contains `yarn-site.xml` and `mapred-site.xml` (without an `hadoop` subfolder). If you use the `Dockerfile` as-is, the copy step may fail during build if paths do not match. Two options:
  - move your local files into `config/hadoop/` (create the `config/hadoop/` folder and place `yarn-site.xml` and `mapred-site.xml` there), or
  - modify the `Dockerfile` to copy from `config/yarn-site.xml` and `config/mapred-site.xml` (a safer option if you don't want to create an extra folder).

- Startup scripts are located in the `scripts/` folder (for example `start-all.sh`, `start-dfs.sh`, `start-yarn.sh`, `start-hive.sh`, `start-kafka.sh`, `start-nosql.sh`, `start-jupyter.sh`). They are copied and made executable in the image under `/usr/local/startup-scripts/`.

  Because the Dockerfile's CMD leaves the container paused, the recommended way to use these scripts is:
  1) start the container (see next section)
  2) open a shell inside the container:

  ```bat
  docker exec -it bigdata cmd.exe /C bash
  ```

  or (more common on Linux/macOS):

  ```bash
  docker exec -it bigdata bash
  ```

  3) run the desired script, for example:

  ```bash
  /usr/local/startup-scripts/start-all.sh
  ```

  The included scripts start HDFS, YARN, Hive, Kafka, KVStore and Jupyter in the sequence provided by the repository authors.

---

###  Build and run (Windows - cmd.exe)

From the project root (`f:\.Dev\docker\bigdata-sandbox`):

1) Build the Docker image via Docker Compose:

```bat
docker-compose build
```

2) Start the service in the foreground (CTRL+C to stop):

```bat
docker-compose up
```

3) Start the service in the background (detached):

```bat
docker-compose up -d
```

4) View logs:

```bat
docker-compose logs -f
```

5) Enter the container to run the startup scripts:

```bat
docker exec -it bigdata cmd.exe /C bash
# then inside the container bash shell
/usr/local/startup-scripts/start-all.sh
```



## Contributing

This project isn't actively maintained, but feel free to fork and modify it for your own experiments.