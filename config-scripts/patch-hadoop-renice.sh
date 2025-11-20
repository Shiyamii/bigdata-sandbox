#!/bin/bash

# Chemin vers Hadoop
HADOOP_HOME=${HADOOP_HOME:-/opt/hadoop}
HADOOP_FUNCTIONS="$HADOOP_HOME/libexec/hadoop-functions.sh"

if [ ! -f "$HADOOP_FUNCTIONS" ]; then
    echo "ERROR: $HADOOP_FUNCTIONS not found. Please set HADOOP_HOME correctly."
    exit 1
fi

echo "Patching $HADOOP_FUNCTIONS to ignore renice errors..."

# Backup original file
cp "$HADOOP_FUNCTIONS" "$HADOOP_FUNCTIONS.bak"

# Patch : ajoute '|| true' aux lignes qui contiennent 'renice'
sed -i '/renice/s/$/ || true/' "$HADOOP_FUNCTIONS"

echo "Patch applied. Backup saved as $HADOOP_FUNCTIONS.bak"
echo "You can now run start-dfs.sh and start-yarn.sh without renice errors."
