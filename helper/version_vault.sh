#!/bin/bash

# exit when any command fails
set -e

function install() {
  if [[ -f "/bin-local/vault-v${1}" ]]; then
    echo "vault version ${1} exists in container, linking."
    ln -sf /bin-local/vault-v${1} /usr/local/bin/vault
  elif [[ -f "/bin-cache/vault-v${1}" ]]; then
    echo "vault version ${1} exists in bin-cache, linking."
    ln -sf /bin-cache/vault-v${1} /usr/local/bin/vault
  else
    echo "Installing Vault version ${1}"
    /helper/install_vault.sh ${1} ${BIN_CACHE_DIR}
  fi
}

if [[ "$VAULT_VERSION" != "" ]]; then
  echo "Installing custom Vault version ${VAULT_VERSION}"
  install ${VAULT_VERSION}
elif [[ "$VAULT_MATCH_SERVER" == "true" ]]; then
  VAULT_MATCH_VERSION=$(vault status -format=json | jq -r '.version')
  if [ -z ${VAULT_MATCH_VERSION} ]; then
    echo "Error: Getting Vault version from remote server"
    exit 1
  else
    echo "Installing Vault version ${VAULT_MATCH_VERSION} to match server"
    install ${VAULT_MATCH_VERSION}
  fi
fi
