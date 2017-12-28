#!/bin/bash
CWD=$(cd $(dirname $0); pwd)
TO_EMAIL_ADDRESS="${1}"
HOST="${2:-127.0.0.1:9200}"
CREDENTIAL="${3:-elastic:changeme}"
WATCH_ID="sample_action_email"

echo "@@@ Delete ${WATCH_ID} (if exists)"
curl -X DELETE "http://${HOST}/_xpack/watcher/watch/${WATCH_ID}" \
--user "${CREDENTIAL}"
echo ""
echo ""

echo "@@@ Create watch item"
sed -i.org "s/@@TO_EMAIL_ADDRESS@@/${TO_EMAIL_ADDRESS}/g" ${CWD}/watch_body.json
curl -X PUT "http://${HOST}/_xpack/watcher/watch/${WATCH_ID}" \
--user "${CREDENTIAL}" \
-H "Content-type: application/json" \
-T ${CWD}/watch_body.json

mv ${CWD}/watch_body.json.org ${CWD}/watch_body.json

echo ""
echo "Done!"
