#!/bin/bash

# Ensure all environment variables are properly configured.
: "${KAFKA_HOME=/kafka_2.12-2.5.0}"
: "${PLAINTEXT_PORT=9094}"

echo -e "healthCheck.sh:\n\
KAFKA_HOME=$KAFKA_HOME\n\
PLAINTEXT_PORT=$PLAINTEXT_PORT"

# wait kafka server to start
while ! nc -z localhost $PLAINTEXT_PORT; do
  sleep 1
done

# check topics
topics=$("${KAFKA_HOME}/bin/kafka-topics.sh" --bootstrap-server "127.0.0.1:${PLAINTEXT_PORT}" --list)
[[ "$topics" =~ "topic1" \
  && "$topics" =~ "topic2" \
  && "$topics" =~ "topic3" ]] \
  || exit 1
