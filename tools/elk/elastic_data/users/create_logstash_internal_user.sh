#!/bin/bash
CWD=$(cd $(dirname $0); pwd)
source ${CWD}/../../config

DATA_FILE="${CWD}/data/elastic_internal_role.json"
cat << EOF >${DATA_FILE}
{
  "password" : "changeme",
  "roles" : [ "logstash_writer"],
  "full_name" : "Internal Logstash User"
}
EOF
curl -sSL -X POST -u "${USER}:${PASSWORD}" \
-H "Content-Type: application/json" \
"${ELASTIC_ENDPOINT}/_xpack/security/user/logstash_internal" \
-T "${DATA_FILE}" |python -mjson.tool
rm -f ${DATA_FILE}

