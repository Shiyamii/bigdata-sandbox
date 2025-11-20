#!/bin/bash
# Démarrer MySQL
service mysql start

# Créer la base Hive Metastore et l'utilisateur
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS hive_metastore;
CREATE USER IF NOT EXISTS 'hiveuser'@'%' IDENTIFIED BY 'hivepass';
GRANT ALL PRIVILEGES ON hive_metastore.* TO 'hiveuser'@'%';
FLUSH PRIVILEGES;
EOF

# Initialiser le metastore
$HIVE_HOME/bin/schematool -dbType mysql -initSchema
