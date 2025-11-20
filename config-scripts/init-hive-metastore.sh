#!/bin/bash
# Start MySQL
service mysql start

# Create Hive metastore database and user
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS hive_metastore;
CREATE USER IF NOT EXISTS 'sandbox'@'%' IDENTIFIED BY 'sandbox_password';
GRANT ALL PRIVILEGES ON hive_metastore.* TO 'sandbox'@'%';
FLUSH PRIVILEGES;
EOF

# Disable conflicting logging library
mkdir -p /opt/hive/disabled-libs
mv /opt/hive/lib/log4j-slf4j-impl-2.18.0.jar /opt/hive/disabled-libs/
chmod 777 /opt/hive/conf

# Initialize Hive metastore schema
/opt/hive/bin/schematool -dbType mysql -initSchema
