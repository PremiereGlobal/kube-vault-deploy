#!/bin/bash

# exit when any command fails
set -e

source /installers/sha.sh

HELM_VERSION="${1:-$DEFAULT_HELM_VERSION}"
BIN_PATH="${2:-"/bin-local/"}"
TMP_PATH=$(mktemp -d -t ci-XXXXXXXXXX)

# Download
curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o ${TMP_PATH}/helm.tar.gz

# Verify download
SHA=$(curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz.sha256)
if [ $(verifysha256 ${TMP_PATH}/helm.tar.gz ${SHA}) -ne 0 ]; then
  echo "Error validating helm binary signature"
  exit 1
fi

# Move binary to it's home
tar -zxvf ${TMP_PATH}/helm.tar.gz > /dev/null \
&& rm ${TMP_PATH}/helm.tar.gz \
&& chmod +x linux-amd64/helm \
&& mv linux-amd64/helm ${BIN_PATH}/helm-v${HELM_VERSION} \
&& rm -rf ${TMP_PATH}

# Link binary
ln -sf ${BIN_PATH}/helm-v${HELM_VERSION} /usr/local/bin/helm

# Init local files and update repo
HELMV=${HELM_VERSION:0:1}
if [[ "${HELMV}" != "3" ]]; then 
  helm init --client-only
fi

# If we have repos, update them
helm repo update 2>/dev/null || true
