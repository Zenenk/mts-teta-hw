#!/bin/bash

# Изменить переменные в зависимости от среды

MASTER_NODE=${MASTER_NODE:-"<NAMENODE_HOSTNAME>"}
DATANODES=${DATANODES:-"<HOST_1> <HOST_2>"}
HADOOP_HOME=${HADOOP_HOME:-"/home/hadoop/<HADOOP_VERSION>"}
SSH_USER=${SSH_USER:-"hadoop"}
CONFIG_DIR="$HADOOP_HOME/etc/hadoop"

echo "Настройка $CONFIG_DIR/yarn-site.xml..."
cat > "$CONFIG_DIR/yarn-site.xml" <<EOF
<configuration>
  <property>
      <name>yarn.nodemanager.aux-services</name>
      <value>mapreduce_shuffle</value>
  </property>
  <property>
      <name>yarn.nodemanager.env-whitelist</name>
      <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value>
  </property>
  <property>
      <name>yarn.resourcemanager.hostname</name>
      <value>${MASTER_NODE}</value>
  </property>
  <property>
      <name>yarn.resourcemanager.address</name>
      <value>${MASTER_NODE}:8032</value>
  </property>
  <property>
      <name>yarn.resourcemanager.resource-tracker.address</name>
      <value>${MASTER_NODE}:8031</value>
  </property>
</configuration>
EOF

echo "Настройка $CONFIG_DIR/mapred-site.xml..."
cat > "$CONFIG_DIR/mapred-site.xml" <<EOF
<configuration>
  <property>
      <name>mapreduce.framework.name</name>
      <value>yarn</value>
  </property>
  <property>
      <name>mapreduce.application.classpath</name>
      <value>\$HADOOP_HOME/share/hadoop/mapreduce/*:\$HADOOP_HOME/share/hadoop/mapreduce/lib/*</value>
  </property>
</configuration>
EOF

echo "Копирование файлов конфигурации на узлы..."
for node in ${MASTER_NODE} ${DATANODES}; do
  scp "$CONFIG_DIR/yarn-site.xml" "$SSH_USER@$node:$CONFIG_DIR/"
  scp "$CONFIG_DIR/mapred-site.xml" "$SSH_USER@$node:$CONFIG_DIR/"
  echo "Файлы скопировать на $node"
done

echo "Запук YARN на узле ${MASTER_NODE}..."
ssh "$SSH_USER@$MASTER_NODE" "$HADOOP_HOME/sbin/start-yarn.sh"
echo "YARN запустить."

if [ -n "$1" ]; then
  CSV_FILE="$1"
  echo "Загрузка файла $CSV_FILE в HDFS /test..."
  ssh "$SSH_USER@$MASTER_NODE" "hdfs dfs -mkdir -p /test && hdfs dfs -put -f $CSV_FILE /test"
  ssh "$SSH_USER@$MASTER_NODE" "hdfs dfs -ls /test"
fi

echo "Развертка YARN завершена."
