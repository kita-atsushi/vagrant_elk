#!/bin/sh
KAFKA_VERSION=1.0.0
SCALA_VERSION=2.12

mirror=$(curl --stderr /dev/null https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred')
url="${mirror}kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
wget "${url}" -O "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
