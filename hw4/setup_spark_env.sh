#!/bin/bash

SPARK_VERSION="spark-3.5.3-bin-hadoop3"
SPARK_TGZ="${SPARK_VERSION}.tgz"
INSTALL_DIR="/home/hadoop"
VENV_DIR="${INSTALL_DIR}/venv"

sudo apt update
sudo apt install -y python3-venv python3-pip

cd ${INSTALL_DIR}
if [ ! -f "${SPARK_TGZ}" ]; then
  wget https://archive.apache.org/dist/spark/spark-3.5.3/${SPARK_TGZ}
fi

if [ ! -d "${INSTALL_DIR}/${SPARK_VERSION}" ]; then
  tar -xzvf ${SPARK_TGZ}
fi

if [ ! -d "${VENV_DIR}" ]; then
  python3 -m venv ${VENV_DIR}
fi
source ${VENV_DIR}/bin/activate
pip install -U pip ipython onetl[files]
deactivate
