#!/bin/bash
DOWNLOAD_URL="https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m`"

curl -L ${DOWNLOAD_URL} -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

