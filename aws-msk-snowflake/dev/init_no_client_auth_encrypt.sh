#!/bin/bash
cd /home/ec2-user

echo "Installing java-11"

sudo yum -y install java-11

echo "Download Kafka application"

wget https://archive.apache.org/dist/kafka/3.2.0/kafka_2.12-3.2.0.tgz

echo "Uncompress Kafka application"

tar -xzf kafka_2.12-3.2.0.tgz
