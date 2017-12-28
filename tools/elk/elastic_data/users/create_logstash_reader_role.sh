#!/bin/bash
CWD=$(cd $(dirname $0); pwd)
source ${CWD}/../../config

DATA_FILE="${CWD}/data/elastic_reader_role.json"
cat << EOF >${DATA_FILE}
{
  "indices": [
    {
      "names": [ "logstash-*" ],
      "privileges": ["read","view_index_metadata"]
    }
  ]
}
EOF
curl -sSL -X POST -u "${USER}:${PASSWORD}" \
-H "Content-Type: application/json" \
"${ELASTIC_ENDPOINT}/_xpack/security/role/logstash_reader" \
-T "${DATA_FILE}" |python -mjson.tool
rm -f ${DATA_FILE}


