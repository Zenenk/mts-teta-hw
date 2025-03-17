#!/usr/bin/env python3
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from onetl.connection import SparkHDFS
from onetl.connection import Hive
from onetl.file import FileDFReader
from onetl.file.format import CSV
from onetl.db import DBWriter

spark = SparkSession.builder \
    .master("yarn") \
    .appName("spark-with-yarn") \
    .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
    .config("spark.hive.metastore.uris", "thrift://<NAMENODE_HOSTNAME>:<HS2_METASTORE_PORT>") \
    .enableHiveSupport() \
    .getOrCreate()

hdfs = SparkHDFS(host="<NAMENODE_HOSTNAME>", port=9000, spark=spark, cluster="test")
hdfs.check()

reader = FileDFReader(connection=hdfs, format=CSV(delimeter=",", header=True), source_path="/input")
df = reader.run(["for_spark.csv"])

df_transformed = df.withColumn("number", df["number"].cast("int")) \
                   .groupBy("colour").agg(F.sum("number").alias("total_number"))

print("Количество строк:", df_transformed.count())
df_transformed.printSchema()
print("Количество партиций:", df_transformed.rdd.getNumPartitions())

hive = Hive(spark=spark, cluster="test")
writer = DBWriter(connection=hive, table="test.spark_partitions", options={"if_exists": "replace_entire_table", "partitionBy": "colour"})
writer.run(df_transformed)

spark.stop()
