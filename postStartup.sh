#!/bin/bash

# Ensure all environment variables are properly configured.
: "${KAFKA_HOME=/kafka_2.12-2.5.0}"
: "${PLAINTEXT_PORT=9094}"

echo -e "KAFKA_HOME=$KAFKA_HOME\n\
PLAINTEXT_PORT=$PLAINTEXT_PORT"

# wait kafka server to start
while ! nc -z localhost $PLAINTEXT_PORT; do
  sleep 1
done

# create topics
"${KAFKA_HOME}/bin/kafka-topics.sh" --bootstrap-server "127.0.0.1:${PLAINTEXT_PORT}" --topic topic1 --create --partitions 3 --replication-factor 1
"${KAFKA_HOME}/bin/kafka-topics.sh" --bootstrap-server "127.0.0.1:${PLAINTEXT_PORT}" --topic topic2 --create --partitions 3 --replication-factor 1
"${KAFKA_HOME}/bin/kafka-topics.sh" --bootstrap-server "127.0.0.1:${PLAINTEXT_PORT}" --topic topic3 --create --partitions 3 --replication-factor 1
