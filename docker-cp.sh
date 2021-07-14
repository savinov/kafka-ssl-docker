#!/bin/bash

docker cp kafkassl:/kafka_2.12-2.5.0/ssl/server.keystore.jks server.keystore.jks
docker cp kafkassl:/kafka_2.12-2.5.0/ssl/server.truststore.jks server.truststore.jks
docker cp kafkassl:/kafka_2.12-2.5.0/ssl/client.keystore.jks client.keystore.jks
docker cp kafkassl:/kafka_2.12-2.5.0/ssl/client.truststore.jks client.truststore.jks
