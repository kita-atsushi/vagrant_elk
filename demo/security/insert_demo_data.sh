#!/bin/bash
CWD="$(cd $(dirname $0) && pwd)"
ENV_FILE="/vagrant/tools/.env"
source "${ENV_FILE}"

SERVICE_NAME=("a-service" "b-service")
for NAME in ${SERVICE_NAME[@]}; do
  echo "@@@"
  echo "@@@ Insert bulk ${NAME} data by logstash"
  echo "@@@"

  echo "tail +2 \"${CWD}/data/minimum_${NAME}_yellow_tripdata.csv\" | logstash -f \"${CWD}/data/${NAME}-log-translate-logstash.conf\""
  tail +2 "${CWD}/data/minimum_${NAME}_yellow_tripdata.csv" | logstash -f "${CWD}/data/${NAME}-log-translate-logstash.conf"
  echo "@@@ Done."
done

echo "Finish."
