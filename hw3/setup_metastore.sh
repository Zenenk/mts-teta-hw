#!/bin/bash

POSTGRES_VERSION=${POSTGRES_VERSION:-"16"}
PG_CONF="/etc/postgresql/${POSTGRES_VERSION}/main"
NAMENODE_HOST=${NAMENODE_HOST:-"<NAMENODE_HOSTNAME>"}
NEW_PORT=${NEW_PORT:-5433}
ALLOWED_IPS=("<ALLOWED_IP1>" "<ALLOWED_IP2>")

sudo apt update
sudo apt install -y postgresql postgresql-client

sudo -i -u postgres psql <<EOF
CREATE DATABASE metastore;
CREATE USER hive WITH PASSWORD 'hiveMegaPass';
GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;
ALTER DATABASE metastore OWNER TO hive;
EOF

sudo sed -i "s/# listen_addresses = 'localhost'/listen_addresses = '${NAMENODE_HOST}'/" "$PG_CONF/postgresql.conf"
sudo sed -i "s/port = 5432/port = ${NEW_PORT}/" "$PG_CONF/postgresql.conf"

for ip in "${ALLOWED_IPS[@]}"; do
  echo "host metastore hive ${ip}/32 password" | sudo tee -a "$PG_CONF/pg_hba.conf"
done

sudo systemctl restart postgresql

echo "Metastore настроить. Проверить подключение:"
psql -h 127.0.0.1 -p ${NEW_PORT} -U hive -W -d metastore
