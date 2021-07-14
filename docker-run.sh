#!/bin/bash

docker run --init -d -p 2181:2181 -p 9093:9093 -p 9094:9094 --name=kafkassl kafka-ssl-local
