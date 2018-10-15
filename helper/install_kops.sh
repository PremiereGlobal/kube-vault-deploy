#!/bin/bash

KOPS_VERSION="${1:-$DEFAULT_KOPS_VERSION}"
BIN_PATH="${2:-"/usr/local/bin/"}"

curl -LO https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 \
  && chmod +x kops-linux-amd64 \
  && mv kops-linux-amd64 ${BIN_PATH}/kops \
  && kops version
