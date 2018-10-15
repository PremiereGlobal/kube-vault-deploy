#!/bin/bash

# Ensure that $VAULT_ADDR is set
if [ -z "${VAULT_ADDR}" ]; then
  >&2 echo "Vault not configured, continuing..."
  exit 1
fi

# Ensure Vault is reachable
vault status > /dev/null 2>&1
if [ $? -ne 0 ]; then
  >&2 echo "Error reaching vault (VAULT_ADDR=${VAULT_ADDR})"
  exit 1
fi

# Ensure VAULT_TOKEN is set (either by file or VAULT_TOKEN env var)
if [ -z "${VAULT_TOKEN}" ] && [ "${AUTO_BUILD}" == "false" ]; then
  export VAULT_TOKEN=$(cat /root/.vault-token 2> /dev/null)
elif [ -z "${VAULT_TOKEN}" ] && [ "${AUTO_BUILD}" == "true" ]; then
  >&2 echo "Must set env VAULT_TOKEN if running as AUTO_BUILD=true."
  exit 1
fi

# Ensure we're authenticated with Vault
vault token lookup > /dev/null 2>&1
if [ $? -ne 0 -a $AUTO_BUILD == "false" ]; then

  # Ensure we're running in an interactive shell if we're going to prompt credentials
  if [ -t 0 ] ; then
    unset VAULT_TOKEN
    >&2 echo -n "Enter LDAP Username: "
    read username
    vault login -method=ldap username=$username
    if [ $? -ne 0 ]; then
     >&2 echo "Invalid Vault Login"
     exit 1
    fi
    export VAULT_TOKEN=$(cat /root/.vault-token 2> /dev/null)
  else
    >&2 echo "Must run Docker in interactive shell mode to prompt for Vault credentials."
    >&2 echo "Use the '-it' flag in your 'docker run' command to enable this feature."
    exit 1
  fi

fi
