#!/bin/bash
CWD=$(cd $(dirname $0); pwd)
source ${CWD}/config
CONFIG_FILE="${CWD}/elastic_data/config/elasticsearch.yml"

function uncomment_es_config_section {
    local SECTION_FLAG_NAME=$1
    SECTON_START_NUM=`cat -n "${CONFIG_FILE}" |grep ${SECTION_FLAG_NAME}_START|awk '{print $1}'`
    SECTON_END_NUM=`cat -n "${CONFIG_FILE}" |grep ${SECTION_FLAG_NAME}_END|awk '{print $1}'`
    EDIT_START_LINE=`expr ${SECTON_START_NUM} + 1`
    EDIT_END_LINE=`expr ${SECTON_END_NUM} - 1`

    sed -i "${EDIT_START_LINE},${EDIT_END_LINE} s/^# //g" "${CONFIG_FILE}"
}

function replace_es_config_param {
	local PARAM_NAME="$1"
	local PARAM_VALUE="$2"
    sed -i "s/@@${PARAM_NAME}@@/${PARAM_VALUE}/g" "${CONFIG_FILE}"
}

cd ${CWD}
source ${CWD}/config
bash ${CWD}/before_setup.sh

### Email Action
if [ "${IS_EMAIL_ACTION}" == "True" ]; then
    uncomment_es_config_section "IS_EMAIL_ACTION"
    replace_es_config_param "EXCHANGE_MAIL_FROM" "${EXCHANGE_MAIL_FROM}"
    replace_es_config_param "EXCHANGE_MAIL_USER" "${EXCHANGE_MAIL_USER}"
    replace_es_config_param "EXCHANGE_MAIL_PASSWORD" "${EXCHANGE_MAIL_PASSWORD}"
fi

echo "@@@ Generate server cert for Kibana https connection."
bash ${CWD}/elastic_data/security/gen_serv_key.sh

# echo "@@@ Configure logstash.conf"
# sed -i -e "s/@@KAFKA_SERVERS@@/${KAFKA_SERVERS}/g" \
# -e "s/@@KAFKA_TOPICS@@/${KAFKA_TOPICS}/g" \
# "${CWD}/elastic_data/pipeline/logstash-simple.conf"

docker-compose up -d

echo "@@@ Waiting for starting elasticsearch..."
sleep 120s

bash ${CWD}/elastic_data/users/create_roles_users.sh
