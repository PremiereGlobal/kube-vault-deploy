#!/bin/bash

VAULT_VERSION="${1:-$DEFAULT_VAULT_VERSION}"
BIN_PATH="${2:-"/usr/local/bin/"}"

curl -L https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip \
  && unzip vault.zip \
  && rm vault.zip \
  && chmod +x vault \
  && mv vault ${BIN_PATH}/vault \
  && vault version
