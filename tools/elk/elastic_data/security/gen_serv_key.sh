#!/bin/bash
CWD=$(cd $(dirname $0); pwd)
OUTPUT_DIR=${CWD}/cert

rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

echo "@@@ Generate RSA key"
openssl genrsa -out ${OUTPUT_DIR}/server.key 1024
echo ""

echo "@@@ Publish CSR certification"
openssl req -new -key ${OUTPUT_DIR}/server.key <<EOF > ${OUTPUT_DIR}/cacert.pem
JP
Tokyo
Kamata
Fujitsu
BusinessPlatformServiceDepartment
127.0.0.1



EOF

echo ""
echo ""

echo "@@@ Publish Server certification"
openssl x509 -req -in ${OUTPUT_DIR}/cacert.pem -signkey ${OUTPUT_DIR}/server.key -out ${OUTPUT_DIR}/server.crt

echo ""
echo "@@@ Generate below"
echo "server key: ${OUTPUT_DIR}/server.key"
echo "csr cert: ${OUTPUT_DIR}/cacert.pem"
echo "server cert: ${OUTPUT_DIR}/server.crt"

echo "Done!"
echo ""

exit 0
