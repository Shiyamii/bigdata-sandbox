DIR="/opt/hadoop/data/dfs/namenode"

if [ ! -d "$DIR" ] || [ -z "$(ls -A "$DIR" 2>/dev/null)" ]; then
  echo 'Formatting namenode...'
    su -s /bin/bash sandbox -c "/opt/hadoop/bin/hdfs namenode -format -force -nonInteractive"
    echo "Namenode formatted."
fi

exit 0