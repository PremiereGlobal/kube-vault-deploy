#!/bin/bash

source /helper/sha.sh

VAULT_VERSION="${1:-$DEFAULT_VAULT_VERSION}"
BIN_PATH="${2:-"/bin-local/"}"

# Download
curl -LO https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

# Verify download
SHA=$(curl -L https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS | grep vault_${VAULT_VERSION}_linux_amd64.zip)
if [ "$(sha256sum vault_${VAULT_VERSION}_linux_amd64.zip)" != "${SHA}" ]; then
  echo "Error validating vault binary signature"
  exit 1
fi

# Move binary to it's home
unzip vault_${VAULT_VERSION}_linux_amd64.zip \
  && rm vault_${VAULT_VERSION}_linux_amd64.zip \
  && chmod +x vault \
  && mv vault ${BIN_PATH}/vault-v${VAULT_VERSION}

# Link binary
ln -sf ${BIN_PATH}/vault-v${VAULT_VERSION} /usr/local/bin/vault
