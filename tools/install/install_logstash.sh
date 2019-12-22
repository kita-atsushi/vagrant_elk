#!/bin/bash
CWD="$(cd $(dirname $0) && pwd)"
HOME_DIR="/home/vagrant"
mkdir -p "${HOME_DIR}"
LS_VERSION="7.2.1"
LS_DOWNLOAD_URL="https://artifacts.elastic.co/downloads/logstash/logstash-${LS_VERSION}.tar.gz"
LS_BASENAME=`basename "${LS_DOWNLOAD_URL}"`

echo "@@@ Installing openjdk-8-jdk"
apt-get install -y openjdk-8-jdk
INSTALLED_JAVA_HOME="$(find /usr/lib/jvm/ -name "java" |grep 'openjdk' | grep -v 'jre'|xargs -i dirname "{}"|xargs -i dirname "{}")"
export JAVA_HOME=${INSTALLED_JAVA_HOME}

wget "${LS_DOWNLOAD_URL}" -P /tmp

tar -zxvf "/tmp/${LS_BASENAME}" -C "${HOME_DIR}"

LOGSTASH_DIR="${HOME_DIR}/logstash-${LS_VERSION}"
cp ${CWD}/files/azureblob_ai_messages.conf "${LOGSTASH_DIR}/config/"
cp ${CWD}/files/azureblob_weblog.conf "${LOGSTASH_DIR}/config/"
${LOGSTASH_DIR}/bin/logstash-plugin install logstash-filter-translate
${LOGSTASH_DIR}/bin/logstash-plugin install logstash-input-azureblob
cp ${CWD}/files/pipelines.yml "${LOGSTASH_DIR}/config/"

echo "Done!"

exit 0

