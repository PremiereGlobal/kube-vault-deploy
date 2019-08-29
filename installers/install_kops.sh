#!/bin/bash

# exit when any command fails
set -e

source /installers/sha.sh

KOPS_VERSION="${1:-$DEFAULT_KOPS_VERSION}"
BIN_PATH="${2:-"/bin-local/"}"

# Download
curl -LO https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64

# Verify download
SHA=$(curl -L https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64-sha1)
if [ $(verifysha1 kops-linux-amd64 ${SHA}) -ne 0 ]; then
  echo "Error validating kops binary signature"
  exit 1
fi

# Move binary to it's home
chmod +x kops-linux-amd64 \
  && mv kops-linux-amd64 ${BIN_PATH}/kops-v${KOPS_VERSION}

# Link binary
ln -sf ${BIN_PATH}/kops-v${KOPS_VERSION} /usr/local/bin/kops
