# Quickly try Kylin


We have pushed the Kylin image for the user to the docker hub. Users do not need to build the image locally, just execute the following command to pull the image from the docker hub: 

```
docker pull apachekylin/apache-kylin-standalone:3.0.0-alpha2
```

After the pull is successful, execute the following command to start the container: 

```
docker run -d \
-m 8G \
-p 7070:7070 \
-p 8088:8088 \
-p 50070:50070 \
-p 8032:8032 \
-p 8042:8042 \
-p 60010:60010 \
apachekylin/apache-kylin-standalone:3.0.0-alpha2
```

The following services are automatically started when the container starts: 

- NameNode, DataNode
- ResourceManager, NodeManager
- HBase
- Kafka
- Kylin

and run automatically `$KYLIN_HOME/bin/sample.sh `, create a kylin_streaming_topic topic in Kafka and continue to send data to this topic. This is to let the users start the container and then experience the batch and streaming way to build the cube and query.

After the container is started, we can enter the container through the `docker exec` command. Of course, since we have mapped the specified port in the container to the local port, we can open the pages of each service directly in the native browser, such as: 

- Kylin Web UI: [http://127.0.0.1:7070/kylin/login](http://127.0.0.1:7070/kylin/login)
- Hdfs NameNode Web UI: [http://127.0.0.1:50070](http://127.0.0.1:50070/)
- Yarn ResourceManager Web UI: [http://127.0.0.1:8088](http://127.0.0.1:8088/)
- HBase Web UI: [http://127.0.0.1:60010](http://127.0.0.1:60010/)

In the container, the relevant environment variables are as follows: 

```
JAVA_HOME=/home/admin/jdk1.8.0_141
HADOOP_HOME=/home/admin/hadoop-2.7.0
KAFKA_HOME=/home/admin/kafka_2.11-1.1.1
SPARK_HOME=/home/admin/spark-2.3.1-bin-hadoop2.6
HBASE_HOME=/home/admin/hbase-1.1.2
HIVE_HOME=/home/admin/apache-hive-1.2.1-bin
KYLIN_HOME=/home/admin/apache-kylin-3.0.0-alpha2-bin-hbase1x
```
