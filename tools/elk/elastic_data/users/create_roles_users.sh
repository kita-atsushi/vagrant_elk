#!/bin/bash
CWD=$(cd $(dirname $0); pwd)

unset http_proxy https_proxy
bash ${CWD}/create_logstash_writer_role.sh
bash ${CWD}/create_logstash_internal_user.sh
bash ${CWD}/create_logstash_reader_role.sh
bash ${CWD}/create_logstash_reader_user.sh
