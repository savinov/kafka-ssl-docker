#!/bin/bash
# Ensure all environment variables are properly configured.
: "${KAFKA_HOME=/kafka_2.12-2.5.0}"
: "${SERVER_KEY_STORE=$KAFKA_HOME/ssl/server.keystore.jks}"
: "${CLIENT_KEY_STORE=$KAFKA_HOME/ssl/client.keystore.jks}"
: "${SERVER_TRUST_STORE=$KAFKA_HOME/ssl/server.truststore.jks}"
: "${CLIENT_TRUST_STORE=$KAFKA_HOME/ssl/client.truststore.jks}"
: "${DOMAIN=www.mywebsite.com}"
: "${PASSWORD=abc123def}"
: "${SSL_PORT=9093}"
: "${PLAINTEXT_PORT=9094}"
: "${BROKER_ID=101}"

echo -e "prepStartup.sh:\n\
KAFKA_HOME=$KAFKA_HOME\n\
CLIENT_KEY_STORE=$CLIENT_KEY_STORE\n\
CLIENT_TRUST_STORE=$CLIENT_TRUST_STORE\n\
SERVER_KEY_STORE=$SERVER_KEY_STORE\n\
SERVER_TRUST_STORE=$SERVER_TRUST_STORE\n\
DOMAIN=$DOMAIN\n\
SSL_PORT=$SSL_PORT\n\
PLAINTEXT_PORT=$PLAINTEXT_PORT\n\
BROKER_ID=$BROKER_ID\n\
PASSWORD=$PASSWORD"


# Create keystore, if the file does not exist
if [[ ! -f ${SERVER_KEY_STORE} ]]; then
    echo "No keystore file is found; hence creating a new one at $KAFKA_HOME/ssl/"

    mkdir -p ${KAFKA_HOME}/ssl/
    cd ${KAFKA_HOME}/ssl/ || exitWithError "KAFKA_HOME/ssl directory does not exist"

    # Generate server keystore
    keytool -keystore server.keystore.jks -alias $DOMAIN -validity 365 -genkey -keyalg RSA -dname "CN=$DOMAIN, OU=orgunit, O=Organisation, L=bangalore, S=Karnataka, C=IN" -ext SAN=DNS:$DOMAIN -keypass $PASSWORD -storepass $PASSWORD
    # Generate CA certificate
    openssl req -new -x509 -keyout ca-key -out ca-cert -days 365 -passout pass:"$PASSWORD" -subj "/CN=$DOMAIN"
    # Import CA certificate into the server keystore
    keytool -keystore server.keystore.jks -alias CARoot -import -file ca-cert -storepass $PASSWORD -noprompt
    # Generate a server certificate and sign it using the CA
    keytool -keystore server.keystore.jks -alias $DOMAIN -certreq -file server-cert-file -storepass $PASSWORD
    openssl x509 -req -CA ca-cert -CAkey ca-key -in server-cert-file -out server-cert-signed -days 365 -CAcreateserial -passin pass:$PASSWORD
    # Import signed server certificate to the server keystore
    keytool -keystore server.keystore.jks -alias $DOMAIN -import -file server-cert-signed -storepass $PASSWORD
    echo "generated server keystore file is ${SERVER_KEY_STORE}"

    # Create server truststore and import CA certificate
    keytool -keystore server.truststore.jks -alias CARoot -import -file ca-cert -storepass $PASSWORD -noprompt
    echo "generated server truststore file is ${SERVER_TRUST_STORE}"
    # Create client truststore and import CA certificate
    keytool -keystore client.truststore.jks -alias CARoot -import -file ca-cert -storepass $PASSWORD -noprompt
    echo "generated client truststore file is ${CLIENT_TRUST_STORE}"

    # Generate a client keystore
    keytool -keystore client.keystore.jks -alias $DOMAIN -validity 365 -genkey -keyalg RSA -dname "CN=$DOMAIN, OU=orgunit, O=Organisation, L=bangalore, S=Karnataka, C=IN" -ext SAN=DNS:$DOMAIN -keypass $PASSWORD -storepass $PASSWORD
    # Generate a client certificate and sign it using the CA
    keytool -keystore client.keystore.jks -alias $DOMAIN -certreq -file client-cert-file -storepass $PASSWORD
    openssl x509 -req -CA ca-cert -CAkey ca-key -in client-cert-file -out client-cert-signed -days 365 -CAcreateserial -passin pass:$PASSWORD
    # Import CA Certificate into the Client keystore
    keytool -keystore client.keystore.jks -alias CARoot -import -file ca-cert -storepass $PASSWORD -noprompt
    # Import signed client certificate to the client keystore
    keytool -keystore client.keystore.jks -alias $DOMAIN -import -file client-cert-signed -storepass $PASSWORD
    echo "generated client keystore file is ${CLIENT_KEY_STORE}"

    cd /
fi

# setup certificates to run kafka-replicator with SSL
if [ -d /ssl-certs ]; then
  cp -r "${KAFKA_HOME}/ssl" "/ssl-certs/${DOMAIN}"
  keytool -importkeystore -srckeystore "/ssl-certs/${DOMAIN}/client.keystore.jks" \
  -destkeystore "/ssl-certs/${DOMAIN}/client.keystore.p12" -srcstoretype jks -deststoretype pkcs12 \
  -srcstorepass password -deststorepass password
fi

# Copy server.properties to the relevant config directory
if [[ ! -f ${KAFKA_HOME}/config/serverssl.properties ]]; then
    cd ${KAFKA_HOME} || exitWithError "KAFKA_HOME directory does not exist"
    cp /serverssl.properties ./config/
    sed -i "s|<WEBSITE>|${DOMAIN}|g" ./config/serverssl.properties
    sed -i "s|<SSL_PORT>|${SSL_PORT}|g" ./config/serverssl.properties
    sed -i "s|<PLAINTEXT_PORT>|${PLAINTEXT_PORT}|g" ./config/serverssl.properties
    sed -i "s|<PASSWORD>|${PASSWORD}|g" ./config/serverssl.properties
    sed -i "s|<KEYSTORELOCATION>|${SERVER_KEY_STORE}|g" ./config/serverssl.properties
    sed -i "s|<TRUSTSTORELOCATION>|${SERVER_TRUST_STORE}|g" ./config/serverssl.properties
    sed -i "s|<BROKER_ID>|${BROKER_ID}|g" ./config/serverssl.properties
fi
