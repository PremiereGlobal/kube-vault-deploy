#!/bin/bash

HELM_VERSION="${1:-$DEFAULT_HELM_VERSION}"
BIN_PATH="${2:-"/usr/local/bin/"}"

curl -L https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz \
  && tar -zxvf helm.tar.gz > /dev/null \
  && rm helm.tar.gz \
  && chmod +x linux-amd64/helm \
  && mv linux-amd64/helm ${BIN_PATH}helm \
  && rm -rf linux-amd64 \
  && helm version -c
