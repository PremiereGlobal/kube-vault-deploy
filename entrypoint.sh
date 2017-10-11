#!/bin/bash

AUTO_BUILD=${AUTO_BUILD:-"false"}
DEPLOY_SCRIPT=${DEPLOY_SCRIPT:-"deploy.sh"}
VAULT_KUBE_FIELD=${VAULT_KUBE_FIELD:-"config"}

# Ensure required env variables are set
if [ -z "$VAULT_ADDR" ]; then
  >&2 echo "VAULT_ADDR environment variable not set. See documentation."
  exit 1
fi

if [ -z "$KUBE_CLUSTER" ]; then
  >&2 echo "KUBE_CLUSTER environment variable not set. See documentation."
  exit 1
fi

if [ -z "$VAULT_KUBE_PATH" ]; then
  >&2 echo "VAULT_KUBE_PATH environment variable not set. See documentation."
  exit 1
fi

# Check if vault is available
vault status > /dev/null 2>&1
if [ $? -ne 0 ]; then
  >&2 echo "Error reaching vault ($VAULT_ADDR)"
  exit 1
fi

# Ensure VAULT_TOKEN is set (either by file or VAULT_TOKEN env var)
if [ -z "$VAULT_TOKEN" -a "$AUTO_BUILD" == "false" ]; then
  export VAULT_TOKEN=$(cat /vault-token/.vault-token 2> /dev/null)
elif [ -z "$VAULT_TOKEN" -a "$AUTO_BUILD" == "true"]; then
  >&2 echo "Must set env VAULT_TOKEN if running as AUTO_BUILD=true."
  exit 1
fi

# Check if we're authenticated with vault, if not, and if not AUTO_BUILD, try LDAP
vault token-lookup > /dev/null 2>&1
if [ $? -ne 0 -a $AUTO_BUILD == "false" ]; then
 unset VAULT_TOKEN
 >&2 echo -n "Enter LDAP Username: "
 read username
 vault auth -method=ldap username=$username 2> /dev/null

 if [ $? -ne 0 ]; then
   >&2 echo "Invalid Vault Login"
   exit 1
 else
   mkdir -p /k8s-vault-token
   cp ~/.vault-token /vault-token/.vault-token
 fi
fi

echo "Fetching Kubernetes config..."
CONFIG=$(vault read -field=$VAULT_KUBE_FIELD $VAULT_KUBE_PATH)

if [ $? -ne 0 ]; then
  >&2 echo "Error reading kube config from vault"
  exit 1
fi

mkdir ~/.kube
echo "$CONFIG" >> ~/.kube/config

if [ -e "/scripts/$DEPLOY_SCRIPT" ]; then
  /scripts/$DEPLOY_SCRIPT
else
  >&2 echo "No deploy script found.  See documentation on DEPLOY_SCRIPT environment variable."
  exit 1
fi
