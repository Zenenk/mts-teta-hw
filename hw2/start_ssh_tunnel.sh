#!/bin/bash

# Использование:
#   ./start_ssh_tunnel.sh [REMOTE_USER] [REMOTE_HOST]
#
# Пример:
#   ./start_ssh_tunnel.sh <USER> <EXTERNAL_IP>

REMOTE_USER=${1:-"<USER>"}
REMOTE_HOST=${2:-"<EXTERNAL_IP>"}

echo "Создание SSH-туннеля с пробросом портов:
  - 9870 (HDFS) -> 9870
  - 8088 (YARN) -> 8088
  - 19888 (HistoryServer) -> 19888"
ssh -L 9870:127.0.0.1:9870 -L 8088:127.0.0.1:8088 -L 19888:127.0.0.1:19888 ${REMOTE_USER}@${REMOTE_HOST}
