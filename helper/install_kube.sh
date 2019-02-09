#!/bin/bash

source /helper/sha.sh

KUBE_VERSION="${1:-$DEFAULT_KUBE_VERSION}"
BIN_PATH="${2:-"/bin-local/"}"

# Download
curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl

# Verify download
SHA=$(curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl.sha1)
if [ $(verifysha1 kubectl ${SHA}) -ne 0 ]; then
  echo "Error validating kubectl binary signature"
  exit 1
fi

# Move binary to it's home
chmod +x ./kubectl \
  && mv ./kubectl ${BIN_PATH}/kubectl-v${KUBE_VERSION}

# Link binary
ln -sf ${BIN_PATH}/kubectl-v${KUBE_VERSION} /usr/local/bin/kubectl
