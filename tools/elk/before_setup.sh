#!/bin/bash

# Fix https://github.com/docker-library/elasticsearch/issues/111
echo "vm.max_map_count=262144" >>/etc/sysctl.conf


