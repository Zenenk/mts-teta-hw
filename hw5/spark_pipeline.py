#!/usr/bin/env python3
from pyspark.sql import SparkSession
from pyspark.sql import functions as F

def main():
    spark = SparkSession.builder \
        .appName("SparkPipelineUnderYARN") \
        .master("yarn") \
        .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
        .config("spark.hive.metastore.uris", "thrift://<NAMENODE_HOSTNAME>:<HS2_METASTORE_PORT>") \
        .enableHiveSupport() \
        .getOrCreate()

    df = spark.read.format("csv") \
           .option("header", "true") \
           .option("inferSchema", "true") \
           .load("hdfs://<NAMENODE_HOSTNAME>:<HDFS_PORT>/input/data.csv")

    df_transformed = df.withColumn("number", df["number"].cast("int")) \
                        .groupBy("category").agg(F.sum("number").alias("total_number"))

    df_transformed.write.mode("overwrite").saveAsTable("default.transformed_data")

    spark.stop()

if __name__ == "__main__":
    main()
