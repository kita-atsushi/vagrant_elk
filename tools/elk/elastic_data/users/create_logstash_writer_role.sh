#!/bin/bash
CWD=$(cd $(dirname $0); pwd)
source ${CWD}/../../config

DATA_FILE="${CWD}/data/elastic_role.json"
cat << EOF >${DATA_FILE}
{
  "cluster": ["manage_index_templates", "monitor"],
  "indices": [
    {
      "names": [ "logstash-*" ],
      "privileges": ["write","delete","create_index"]
    }
  ]
}
EOF
curl -sSL -X POST -u "${USER}:${PASSWORD}" \
-H "Content-Type: application/json" \
"${ELASTIC_ENDPOINT}/_xpack/security/role/logstash_writer" \
-T "${DATA_FILE}"|python -mjson.tool
rm -f "${DATA_FILE}"

