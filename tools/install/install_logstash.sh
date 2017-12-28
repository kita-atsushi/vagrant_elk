#!/bin/bash
ENV_FILE="/vagrant/tools/.env"

echo "@@@ Installing openjdk-8-jdk"
apt-get install -y openjdk-8-jdk
INSTALLED_JAVA_HOME="$(find /usr/lib/jvm/ -name "java" |grep 'openjdk' | grep -v 'jre'|xargs -i dirname "{}"|xargs -i dirname "{}")"
export JAVA_HOME=${INSTALLED_JAVA_HOME}

echo "@@@ Installing logstash"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
apt-get install -y apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt-get update && apt-get install logstash

LOG_STASH_PATH="$(find / -name "logstash" |grep '/bin/logstash'|xargs -i dirname "{}")"
export PATH=$PATH:${LOG_STASH_PATH}

echo "@@@ Installing logstash plugin"
logstash-plugin install logstash-filter-translate

# entry .env
rm -f "${ENV_FILE}"
echo "export PATH=$PATH:${LOG_STASH_PATH}" >>${ENV_FILE}
echo "export JAVA_HOME=${INSTALLED_JAVA_HOME}" >>${ENV_FILE}
