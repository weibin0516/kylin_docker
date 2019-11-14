# Docker image for apache kylin
FROM centos:6.9

MAINTAINER weibin0516 <codingforfun@126.com>

ENV HIVE_VERSION 1.2.1
ENV HADOOP_VERSION 2.7.0
ENV HBASE_VERSION 1.1.2
ENV SPARK_VERSION 2.3.1
ENV ZK_VERSION 3.4.6
ENV KAFKA_VERSION 1.1.1
ENV LIVY_VERSION 0.6.0
ENV KYLIN_VERSION 3.0.0-alpha2

ENV JAVA_HOME /home/admin/jdk1.8.0_141
ENV MVN_HOME /home/admin/apache-maven-3.6.1
ENV HADOOP_HOME /home/admin/hadoop-$HADOOP_VERSION
ENV HIVE_HOME /home/admin/apache-hive-$HIVE_VERSION-bin
ENV HADOOP_CONF $HADOOP_HOME/etc/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV HBASE_HOME /home/admin/hbase-$HBASE_VERSION
ENV SPARK_HOME /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6
ENV SPARK_CONF_DIR /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6/conf
ENV ZK_HOME /home/admin/zookeeper-$ZK_VERSION
ENV KAFKA_HOME /home/admin/kafka_2.11-$KAFKA_VERSION
ENV LIVY_HOME /home/admin/apache-livy-$LIVY_VERSION-incubating-bin
ENV KYLIN_HOME=/home/admin/apache-kylin-3.0.0-alpha2-bin-hbase1x
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$HBASE_HOME/bin:$MVN_HOME/bin:spark-$SPARK_VERSION-bin-hadoop2.6/bin:$KAFKA_HOME/bin:$KYLIN_HOME/bin

USER root

WORKDIR /home/admin

# install tools
RUN yum -y install lsof.x86_64 wget.x86_64 tar.x86_64 git.x86_64 mysql-server.x86_64 mysql.x86_64 unzip.x86_64

# install mvn
RUN wget http://mirrors.ocf.berkeley.edu/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz
RUN tar -zxvf apache-maven-3.6.1-bin.tar.gz
COPY conf/maven/settings.xml $MVN_HOME/conf/settings.xml
RUN rm -f apache-maven-3.6.1-bin.tar.gz

# install npm
RUN curl -sL https://rpm.nodesource.com/setup_8.x | bash -
RUN yum install -y nodejs

# setup jdk
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz"
RUN tar -zxvf /home/admin/jdk-8u141-linux-x64.tar.gz
RUN rm -f /home/admin/jdk-8u141-linux-x64.tar.gz

# setup hadoop
RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
RUN tar -zxvf /home/admin/hadoop-$HADOOP_VERSION.tar.gz
RUN rm -f /home/admin/hadoop-$HADOOP_VERSION.tar.gz

COPY conf/hadoop/* $HADOOP_CONF/
RUN mkdir -p /data/hadoop

# setup hbase
RUN wget https://archive.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz
RUN tar -zxvf /home/admin/hbase-$HBASE_VERSION-bin.tar.gz
RUN rm -f /home/admin/hbase-$HBASE_VERSION-bin.tar.gz
COPY conf/hbase/hbase-site.xml $HBASE_HOME/conf
RUN mkdir -p /data/hbase
RUN mkdir -p /data/zookeeper

# setup hive
RUN wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
RUN tar -zxvf /home/admin/apache-hive-$HIVE_VERSION-bin.tar.gz
RUN rm -f /home/admin/apache-hive-$HIVE_VERSION-bin.tar.gz
COPY conf/hive/hive-site.xml $HIVE_HOME/conf
RUN wget -P $HIVE_HOME/lib https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.24/mysql-connector-java-5.1.24.jar

# setup spark
RUN wget https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.6.tgz
RUN tar -zxvf /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6.tgz
RUN rm -f /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6.tgz
RUN cp $HIVE_HOME/conf/hive-site.xml $SPARK_HOME/conf
RUN cp $SPARK_HOME/yarn/*.jar $HADOOP_HOME/share/hadoop/yarn/lib
RUN cp $HIVE_HOME/lib/mysql-connector-java-5.1.24.jar $SPARK_HOME/jars
RUN echo spark.sql.catalogImplementation=hive > $SPARK_HOME/conf/spark-defaults.conf

# setup kafka
RUN wget https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz
RUN tar -zxvf /home/admin/kafka_2.11-$KAFKA_VERSION.tgz
RUN rm -f /home/admin/kafka_2.11-$KAFKA_VERSION.tgz

# setup livy
RUN wget https://www.apache.org/dist/incubator/livy/$LIVY_VERSION-incubating/apache-livy-$LIVY_VERSION-incubating-bin.zip \
    && unzip /home/admin/apache-livy-$LIVY_VERSION-incubating-bin.zip \
    && rm -f /home/admin/apache-livy-$LIVY_VERSION-incubating-bin.zip

# setup kylin
RUN wget https://www.apache.org/dist/kylin/apache-kylin-3.0.0-alpha2/apache-kylin-3.0.0-alpha2-bin-hbase1x.tar.gz
RUN tar -zxvf apache-kylin-3.0.0-alpha2-bin-hbase1x.tar.gz \
    && echo "kylin.engine.spark-conf.spark.executor.memory=1G" >> $KYLIN_HOME/conf/kylin.properties \
    && echo "kylin.engine.spark-conf-mergedict.spark.executor.memory=1.5G" >> $KYLIN_HOME/conf/kylin.properties \
    && echo "kylin.engine.livy-conf.livy-url=http://127.0.0.1:8998" >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.livy-conf.livy-key.file=hdfs://localhost:9000/kylin/livy/kylin-job-$KYLIN_VERSION.jar >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.livy-conf.livy-arr.jars=hdfs://localhost:9000/kylin/livy/hbase-client-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-common-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-hadoop-compat-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-hadoop2-compat-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-server-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/htrace-core-*-incubating.jar,hdfs://localhost:9000/kylin/livy/metrics-core-*.jar >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.source.hive.quote-enabled=false >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf.spark.eventLog.dir=hdfs://localhost:9000/kylin/spark-history >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf.spark.history.fs.logDirectory=hdfs://localhost:9000/kylin/spark-history >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.source.hive.redistribute-flat-table=false >> $KYLIN_HOME/conf/kylin.properties
RUN rm -f /home/admin/apache-kylin-3.0.0-alpha2-bin-hbase1x.tar.gz

COPY ./entrypoint.sh /home/admin/entrypoint.sh
RUN chmod u+x /home/admin/entrypoint.sh

ENTRYPOINT ["/home/admin/entrypoint.sh"]
