#!/bin/bash

docker-compose stop
docker-compose rm -f
rm -rf elastic_data/data
bash setup.sh 
