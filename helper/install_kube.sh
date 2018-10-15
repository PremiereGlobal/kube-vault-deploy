#!/bin/bash

KUBE_VERSION="${1:-$DEFAULT_KUBE_VERSION}"
BIN_PATH="${2:-"/usr/local/bin/"}"

curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv ./kubectl ${BIN_PATH}/kubectl \
  && kubectl version --client
