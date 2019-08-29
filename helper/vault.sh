#!/bin/bash

# Ensure Vault is reachable
vault status > /dev/null 2>&1
if [ $? -ne 0 ]; then
  >&2 echo "Error reaching vault (VAULT_ADDR=${VAULT_ADDR})"
  exit 1
fi

# Ensure VAULT_TOKEN is set (either by file or VAULT_TOKEN env var)
if [ -z "${VAULT_TOKEN}" ] && [ -f /vault-token ]; then
  export VAULT_TOKEN=$(cat /vault-token)
elif [ -z "${VAULT_TOKEN}" ]; then
  >&2 echo "Vault token is not set"
  exit 1
fi

# Ensure we're authenticated with Vault
vault token lookup > /dev/null 2>&1
if [ $? -ne 0 ]; then
  >&2 echo "Vault token is not valid."
  exit 1
fi

echo $VAULT_TOKEN
