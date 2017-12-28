#!/bin/bash
CWD=$(cd $(dirname $0); pwd)
source "${CWD}/../../tools/elk/config"
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

function post_user {
  local ACTION=${1:-Create}
  local USER_NAME=$2
  local ROLE_NAMES=$3

  echo "@@@ ${ACTION} user. ${USER_NAME}"
  TEMPLATE_FILE="${CWD}/data/user-template.json"
  DATA_FILE="/tmp/${USER_NAME}.json"
  cat "${TEMPLATE_FILE}" | \
  sed -e "s/@@FULL_NAME@@/${USER_NAME}/g" \
      -e "s/@@ROLE_NAMES@@/${ROLE_NAMES}/g" >${DATA_FILE}

  curl -sSL -X POST -u "${USER}:${PASSWORD}" -H "Content-Type: application/json" \
  "${ELASTIC_ENDPOINT}/_xpack/security/user/${USER_NAME}" \
  -T "${DATA_FILE}" |python -mjson.tool
  rm -f ${DATA_FILE}
  if [ "${ACTION}" == "Update" ]; then
    echo "@@@ NOTE: Result false is OK."
  fi
  echo "Done!"
}

function create_role {
  local ROLE_NAME=$1
  local INDEX_NAME=$2
  local RUN_AS_USER_NAME=$3

  echo "@@@ Create role. ${ROLE_NAME}"
  TEMPLATE_FILE="${CWD}/data/role-template.json"
  DATA_FILE="/tmp/${ROLE_NAME}.json"
  cat "${TEMPLATE_FILE}" | \
  sed -e "s/@@ROLE_NAME@@/${ROLE_NAME}/g" \
      -e "s/@@INDEX_NAME@@/${INDEX_NAME}/g" \
      -e "s/@@RUN_AS_USER_NAME@@/${RUN_AS_USER_NAME}/g" >${DATA_FILE}

  curl -sSL -X POST -u "${USER}:${PASSWORD}" -H "Content-Type: application/json" \
  "${ELASTIC_ENDPOINT}/_xpack/security/role/${ROLE_NAME}" \
  -T "${DATA_FILE}" |python -mjson.tool
  rm -f ${DATA_FILE}
  echo "Done!"
}

### Main
post_user Create a-service-developer
post_user Create b-service-developer
post_user Create other

create_role a-service-role a-service a-service-developer
create_role b-service-role b-service b-service-developer

post_user Update a-service-developer '"kibana_user", "a-service-role"'
post_user Update b-service-developer '"kibana_user", "b-service-role"'
post_user Update other '"kibana_user"'

exit 0
