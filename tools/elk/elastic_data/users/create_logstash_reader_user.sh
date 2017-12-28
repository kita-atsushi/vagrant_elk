#!/bin/bash
CWD=$(cd $(dirname $0); pwd)
source ${CWD}/../../config

DATA_FILE="${CWD}/data/elastic_reader_user.json"
cat << EOF >${DATA_FILE}
{
  "password" : "changeme",
  "roles" : [ "logstash_reader"],
  "full_name" : "Kibana User"
}
EOF
curl -sSL -X POST -u "${USER}:${PASSWORD}" \
-H "Content-Type: application/json" \
"${ELASTIC_ENDPOINT}/_xpack/security/user/logstash_user" \
-T "${DATA_FILE}" |python -mjson.tool
rm -f ${DATA_FILE}


