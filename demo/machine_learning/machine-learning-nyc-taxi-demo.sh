#!/bin/bash
# This script is demonstration for elk stack machine-learning function.
#   * Refer to https://www.elastic.co/jp/blog/experiencing-machine-learning-with-nyc-taxi-dataset
CWD="$(cd $(dirname $0) && pwd)"

# Put your environment parameter
WORK_DIR="/vagrant/tools"
ELASTIC_SEARCH_HOST="127.0.0.1"
ELASTIC_SEARCH_PORT="9200"
ELASTIC_USER="elastic"
ELASTIC_PASSWD="changeme"


echo "@@@ Intalling openjdk-8-jdk"
apt-get install -y openjdk-8-jdk
INSTALLED_JAVA_HOME="$(find / -name "java" |grep 'openjdk' | grep -v 'jre'|xargs -i dirname "{}"|xargs -i dirname "{}")"
export JAVA_HOME=${INSTALLED_JAVA_HOME}

echo "@@@ Installing logstash"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
apt-get install -y apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt-get update && apt-get install logstash

LOG_STASH_PATH="$(find / -name "logstash" |grep '/bin/logstash'|xargs -i dirname "{}")"
export PATH=$PATH:${LOG_STASH_PATH}

echo "@@@ Installing logstash plugin"
logstash-plugin install logstash-filter-translate

# entry .env
echo "export PATH=$PATH:${LOG_STASH_PATH}" >>${CWD}/.env
echo "export JAVA_HOME=${INSTALLED_JAVA_HOME}" >>${CWD}/.env

echo "@@@ Download sample data"
if [ ! -e "${CWD}/data/yellow_tripdata_2016-11.csv" ]; then
  wget https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2016-11.csv -P ${CWD}/data/
fi
if [ ! -e "${CWD}/data/taxi.csv" ]; then
  curl https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv | cut -d, -f 1,3 | tail +2 > ${CWD}/data/taxi.csv
fi

echo "@@@ Put config data"
cat << EOF >${CWD}/data/nyc-taxi-yellow-translate-logstash.conf
input {
  stdin { type => "tripdata" }
}
filter {
  csv {
    columns => ["VendorID","tpep_pickup_datetime","tpep_dropoff_datetime","passenger_count","trip_distance","RatecodeID","store_and_fwd_flag","PULocationID","DOLocationID","payment_type","fare_amount","extra","mta_tax","tip_amount","tolls_amount","improvement_surcharge","total_amount"]
    convert => {"extra" => "float"}
    convert => {"fare_amount" => "float"}
    convert => {"improvement_surcharge" => "float"}
    convert => {"mta_tax" => "float"}
    convert => {"tip_amount" => "float"}
    convert => {"tolls_amount" => "float"}
    convert => {"total_amount" => "float"}
    convert => {"trip_distance" => "float"}
    convert => {"passenger_count" => "integer"}
  }
  date {
    match => ["tpep_pickup_datetime", "yyyy-MM-dd HH:mm:ss", "ISO8601"]
    timezone => "EST"
  }
  date {
    match => ["tpep_pickup_datetime", "yyyy-MM-dd HH:mm:ss", "ISO8601"]
    target => ["@tpep_pickup_datetime"]
    remove_field => ["tpep_pickup_datetime"]
    timezone => "EST"
  }
  date {
    match => ["tpep_dropoff_datetime", "yyyy-MM-dd HH:mm:ss", "ISO8601"]
    target => ["@tpep_dropoff_datetime"]
    remove_field => ["tpep_dropoff_datetime"]
    timezone => "EST"
  }
  translate {
    field => "RatecodeID"
    destination => "RatecodeID"
    dictionary => [
      "1", "Standard rate",
      "2", "JFK",
      "3", "Newark",
      "4", "Nassau or Westchester",
      "5", "Negotiated fare",
      "6", "Group ride"
    ]
  }
  translate {
    field => "VendorID"
    destination => "VendorID_t"
    dictionary => [
      "1", "Creative Mobile Technologies",
      "2", "VeriFone Inc"
    ]
  }
  translate {
    field => "payment_type"
    destination => "payment_type_t"
    dictionary => [
      "1", "Credit card",
      "2", "Cash",
      "3", "No charge",
      "4", "Dispute",
      "5", "Unknown",
      "6", "Voided trip"
    ]
  }
  translate {
    field => "PULocationID"
    destination => "PULocationID_t"
    dictionary_path => "${CWD}/data/taxi.csv"
  }
  translate {
    field => "DOLocationID"
    destination => "DOLocationID_t"
    dictionary_path => "${CWD}/data/taxi.csv"
  }
  mutate {
    remove_field => ["message", "column18", "column19", "RatecodeID", "VendorID", "payment_type", "PULocationID", "DOLocationID"]
  }
}
output {
#  stdout { codec => dots }
  elasticsearch {
    hosts => "${ELASTIC_SEARCH_HOST}:${ELASTIC_SEARCH_PORT}"
    user => "${ELASTIC_USER}"
    password => "${ELASTIC_PASSWD}"
    index => "nyc-taxi-yellow-%{+YYYY.MM.dd}"
  }
}
EOF

echo "@@@"
echo "@@@ Insert bulk data"
echo "@@@ This operation takes a long time(abount 1 hour)."
echo "@@@"
tail +2 "${CWD}/data/yellow_tripdata_2016-11.csv" | logstash -f "${CWD}/data/nyc-taxi-yellow-translate-logstash.conf"

echo "Done."
