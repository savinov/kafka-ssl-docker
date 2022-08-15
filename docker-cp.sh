#!/bin/bash

# kafka1, kafka2
KAFKA=$1
# kafka-replicator-replicator_kafka_1-1, kafka-replicator-replicator_kafka_2-1
CONTAINER=$2

mkdir -p "jks/${KAFKA}"

docker cp "${CONTAINER}:/kafka_2.12-2.5.0/ssl/server.keystore.jks" "jks/${KAFKA}/server.keystore.jks"
docker cp "${CONTAINER}:/kafka_2.12-2.5.0/ssl/server.truststore.jks" "jks/${KAFKA}/server.truststore.jks"
docker cp "${CONTAINER}:/kafka_2.12-2.5.0/ssl/client.keystore.jks" "jks/${KAFKA}/client.keystore.jks"
docker cp "${CONTAINER}:/kafka_2.12-2.5.0/ssl/client.truststore.jks" "jks/${KAFKA}/client.truststore.jks"
