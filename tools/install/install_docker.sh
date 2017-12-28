#!/bin/bash
SCRIPT_DIR="$(cd $(dirname $0) && pwd)"

function install_docker {
  echo "@@@ Install docker"
  apt install -y apt-transport-https ca-certificates curl software-properties-common
  DOCKER_GPG_KEY_URL="https://download.docker.com/linux/ubuntu/gpg"
  FINGER_PRINT="0EBFCD88"
  DOCKER_REPO_URL="https://download.docker.com/linux/ubuntu"
  DOCKER_VERSION="17.09.0~ce-0~ubuntu"

  curl -fsSL ${DOCKER_GPG_KEY_URL} | apt-key add -
  apt-key fingerprint "${FINGER_PRINT}"
  add-apt-repository "deb [arch=amd64] ${DOCKER_REPO_URL} \
     $(lsb_release -cs) \
        stable"
  apt update
  apt install -y "docker-ce=${DOCKER_VERSION}"
}

function setup_local_registry {
  echo "@@@ Setting local registry"
  DOCKER_SERVICE_FILE="/lib/systemd/system/docker.service"
  sed -i -e "s#ExecStart=/usr/bin/dockerd.*#ExecStart=/usr/bin/dockerd -H fd:// --insecure-registry ${LOCAL_DOCKER_REGISTRY_IP}:5000#" "${DOCKER_SERVICE_FILE}"
}

function setup_proxy {
  local HTTP_PROXY=$1

  echo "@@@ Setting proxy docker process"
  KEY_STRING='Type=notify'
  DOCKER_SERVICE_FILE="/lib/systemd/system/docker.service"
  INSERT_LINE_NUM_1=`cat -n ${DOCKER_SERVICE_FILE}|grep "${KEY_STRING}"|awk '{print $1}'`
  INSERT_LINE_NUM_2=`expr ${INSERT_LINE_NUM_1} + 1`
  INSERT_LINE_NUM_3=`expr ${INSERT_LINE_NUM_2} + 1`

  HTTP_PROXY_SETTING="Environment='http_proxy=${HTTP_PROXY}'"
  HTTPS_PROXY_SETTING="Environment='https_proxy=${HTTP_PROXY}'"
  NO_PROXY_SETTING="Environment='no_proxy=${MASTER_HOSTNAME},${NODE_HOSTNAME},${LOCAL_DOCKER_REGISTRY_IP}'"

  sed -i -e "${INSERT_LINE_NUM_1}i ${HTTP_PROXY_SETTING}" ${DOCKER_SERVICE_FILE}
  sed -i -e "${INSERT_LINE_NUM_2}i ${HTTPS_PROXY_SETTING}" ${DOCKER_SERVICE_FILE}
  sed -i -e "${INSERT_LINE_NUM_3}i ${NO_PROXY_SETTING}" ${DOCKER_SERVICE_FILE}
}

### Main
install_docker
setup_local_registry
if [ ! -z "${http_proxy}" ]; then
  setup_proxy ${http_proxy}
fi

echo "@@@ Restarting docker"
systemctl daemon-reload
systemctl restart docker

echo "@@@ Enable docker service"
systemctl enable docker

echo "Done!"

