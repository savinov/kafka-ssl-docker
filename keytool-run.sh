#!/bin/bash

# kafka1, kafka2
KAFKA=$1
# client.keystore.jks, client.truststore.jks, server.keystore.jks, server.truststore.jks
JKS=$2

keytool -v -list -keystore "jks/${KAFKA}/${JKS}" -storepass "password"
