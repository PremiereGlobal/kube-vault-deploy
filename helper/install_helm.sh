#!/bin/bash

source /helper/sha.sh

HELM_VERSION="${1:-$DEFAULT_HELM_VERSION}"
BIN_PATH="${2:-"/bin-local/"}"

# Download
curl -L https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz

# Verify download
SHA=$(curl -L https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz.sha256)
if [ $(verifysha256 helm.tar.gz ${SHA}) -ne 0 ]; then
  echo "Error validating helm binary signature"
  exit 1
fi

# Move binary to it's home
tar -zxvf helm.tar.gz > /dev/null \
&& rm helm.tar.gz \
&& chmod +x linux-amd64/helm \
&& mv linux-amd64/helm ${BIN_PATH}/helm-v${HELM_VERSION} \
&& rm -rf linux-amd64

# Link binary
ln -sf ${BIN_PATH}/helm-v${HELM_VERSION} /usr/local/bin/helm

# Init local files and update repo
helm init --client-only
helm repo update
