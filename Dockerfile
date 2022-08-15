FROM ubuntu
WORKDIR /
RUN apt-get update > /dev/null && apt-get install runit -y > /dev/null
RUN apt-get update > /dev/null && apt-get install libssl-dev openssl -y > /dev/null
RUN apt-get update > /dev/null && apt-get install openjdk-8-jdk -y > /dev/null
RUN apt-get update > /dev/null && apt-get install netcat -y > /dev/null


#ADD https://mirrors.estointernet.in/apache/kafka/2.5.0/kafka_2.12-2.5.0.tgz .
ADD https://archive.apache.org/dist/kafka/2.5.0/kafka_2.12-2.5.0.tgz .
RUN tar xzf kafka_2.12-2.5.0.tgz && rm kafka_2.12-2.5.0.tgz

RUN mkdir -p /etc/service/zookeeper/
RUN mkdir -p /etc/service/kafka/

COPY serverssl.properties .
COPY prepStartup.sh .
COPY postStartup.sh .
COPY healthCheck.sh .

RUN /bin/bash -c "echo -e '#!/bin/bash\nexec /kafka_2.12-2.5.0/bin/zookeeper-server-start.sh /kafka_2.12-2.5.0/config/zookeeper.properties\n' > /etc/service/zookeeper/run"
RUN /bin/bash -c "echo -e '#!/bin/bash\n/prepStartup.sh\n/postStartup.sh&\nexec /kafka_2.12-2.5.0/bin/kafka-server-start.sh /kafka_2.12-2.5.0/config/serverssl.properties\n' > /etc/service/kafka/run"

RUN chmod +x /etc/service/zookeeper/run
RUN chmod +x /etc/service/kafka/run

ENV KAFKA_HOME=/kafka_2.12-2.5.0
ENV PASSWORD=password
ENV DOMAIN=localhost
ENV SSL_PORT=9093
ENV PLAINTEXT_PORT=9094
ENV BROKER_ID=101

EXPOSE 2181/tcp
EXPOSE $SSL_PORT/tcp
EXPOSE $PLAINTEXT_PORT/tcp

#HEALTHCHECK --interval=60s --timeout=5s --start-period=30s \
#CMD [[ $(sv status kafka) =~ "run" ]] || exit 1

HEALTHCHECK --interval=5s --timeout=10s --start-period=30s --retries=10 \
CMD ./healthCheck.sh || exit 1

CMD ["runsvdir", "/etc/service"]
