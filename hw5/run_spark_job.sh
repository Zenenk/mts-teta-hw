#!/bin/bash

SPARK_HOME="/home/hadoop/spark-3.5.3-bin-hadoop3"
PY_SCRIPT="spark_pipeline.py"
VENV_DIR="/home/hadoop/venv"

source ${VENV_DIR}/bin/activate

export SPARK_HOME=${SPARK_HOME}
export PATH=${SPARK_HOME}/bin:$PATH
export PYTHONPATH=$(for z in "${SPARK_HOME}/python/lib/"*.zip; do echo -n "$z:"; done)$PYTHONPATH

spark-submit --master yarn ${PY_SCRIPT}
deactivate

