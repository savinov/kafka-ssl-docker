#!/bin/bash

mkdir -p jks

docker cp kafkassl:/kafka_2.12-2.5.0/ssl/server.keystore.jks jks/server.keystore.jks
docker cp kafkassl:/kafka_2.12-2.5.0/ssl/server.truststore.jks jks/server.truststore.jks
docker cp kafkassl:/kafka_2.12-2.5.0/ssl/client.keystore.jks jks/client.keystore.jks
docker cp kafkassl:/kafka_2.12-2.5.0/ssl/client.truststore.jks jks/client.truststore.jks
