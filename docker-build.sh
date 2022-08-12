#!/bin/bash

# Build kafka-ssl-local
docker rmi kafka-ssl-local
docker build -t kafka-ssl-local .

# Prune dangling images after build
docker image prune --filter="dangling=true" -f
