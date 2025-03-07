#!/bin/bash

HIVE_VERSION="apache-hive-4.0.0-alpha-2-bin"
HIVE_TAR="${HIVE_VERSION}.tar.gz"
HIVE_HOME="/home/hadoop/${HIVE_VERSION}"
POSTGRES_PORT=${POSTGRES_PORT:-5433}
NAMENODE_HOST=${NAMENODE_HOST:-"<NAMENODE_HOSTNAME>"}

cd /home/hadoop

if [ ! -f "$HIVE_TAR" ]; then
  wget https://archive.apache.org/dist/hive/hive-4.0.0-alpha-2/${HIVE_TAR}
fi

if [ ! -d "$HIVE_HOME" ]; then
  tar -xzvf "$HIVE_TAR"
fi

cd "$HIVE_HOME/lib"
if [ ! -f "postgresql-42.7.4.jar" ]; then
  wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar
fi

cd "$HIVE_HOME/conf"
cat > hive-site.xml <<EOF
<configuration>
    <property>
        <name>hive.server2.authentication</name>
        <value>NONE</value>
    </property>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
    </property>
    <property>
        <name>hive.server2.thrift.port</name>
        <value>5433</value>
        <description>TCP порт для HiveServer2</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://${NAMENODE_HOST}:${POSTGRES_PORT}/metastore</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.postgresql.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>hive</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>hiveMegaPass</value>
    </property>
</configuration>
EOF

grep -q "HIVE_HOME" ~/.profile || cat >> ~/.profile <<EOF
export HIVE_HOME=/home/hadoop/${HIVE_VERSION}
export HIVE_CONF_DIR=\$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=\$HIVE_HOME/lib/*
export PATH=\$PATH:\$HIVE_HOME/bin
EOF

source ~/.profile

hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod g+w /user/hive/warehouse

"$HIVE_HOME/bin/schematool" -dbType postgres -initSchema

echo "Hive настроить."
