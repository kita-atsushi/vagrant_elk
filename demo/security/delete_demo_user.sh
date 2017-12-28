#!/bin/bash
echo "@@@ Delete a-service-developer"
curl -sSL -X DELETE -u elastic:changeme http://127.0.0.1:9200/_xpack/security/user/a-service-developer
echo ""

echo "@@@ Delete b-service-developer"
curl -sSL -X DELETE -u elastic:changeme http://127.0.0.1:9200/_xpack/security/user/b-service-developer
echo ""

echo "@@@ Delete a-service-role"
curl -sSL -X DELETE -u elastic:changeme http://127.0.0.1:9200/_xpack/security/role/a-service-role
echo ""

echo "@@@ Delete b-service-role"
curl -sSL -X DELETE -u elastic:changeme http://127.0.0.1:9200/_xpack/security/role/b-service-role
echo ""

echo "Done!"

exit 0
