#!/bin/bash
docker ps -a |grep 'Exited'|awk '{print $1}'|xargs -i docker rm -f {}
docker images |grep '<none>'|awk '{print $3}'|xargs -i docker rmi -f {}
