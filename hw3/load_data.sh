#!/bin/bash

HIVE_HOME=${HIVE_HOME:-"/home/hadoop/apache-hive-4.0.0-alpha-2-bin"}
HS2_LOG="/tmp/hs2.log"
BEELINE_URL="jdbc:hive2://<NAMENODE_HOSTNAME>:<HS2_PORT>"

tmux new-session -d -s hive_server2 "$HIVE_HOME/sbin/hiveserver2 1>> ${HS2_LOG} 2>> ${HS2_LOG}"
echo "HiveServer2 запустить, лог: ${HS2_LOG}"

sleep 30

beeline -u "${BEELINE_URL}" -n <USER> -p <PASSWORD> <<EOF
-- Создать базу данных (если не создана)
CREATE DATABASE IF NOT EXISTS test;
USE test;
-- Создать партиционированную таблицу (например, по дате)
CREATE TABLE IF NOT EXISTS colours (
    colour STRING,
    number INT
)
PARTITIONED BY (dt STRING)
COMMENT 'Партиционированная таблица с данными о цветах'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;
SHOW TABLES;
-- Загрузить данные в таблицу в раздел (например, dt='2025-02-18')
LOAD DATA INPATH '/test/colours.tsv' INTO TABLE colours PARTITION (dt='2025-02-18');
EOF

echo "Данные загрузить в таблицу."
