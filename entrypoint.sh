#!/bin/bash

# Ensure required env variables are set
if [ -z "$VAULT_ADDR" ]; then
  >&2 echo "Error: VAULT_ADDR environment variable not set. See documentation."
  exit 1
fi

if [ -z "$CLUSTER_NAME" ]; then
  >&2 echo "Error: CLUSTER_NAME environment variable not set. See documentation."
  exit 1
fi

if [ -z "$ACCOUNT_NAME" ]; then
  >&2 echo "Error: ACCOUNT_NAME environment variable not set. See documentation."
  exit 1
fi

# Check if vault is available
vault status > /dev/null 2>&1
if [ $? -ne 0 ]; then
  >&2 echo "Error reaching vault ($VAULT_ADDR)"
  exit 1
fi

# Check if we're authenticated with vault, if not, and if not AUTO_BUILD, try LDAP
vault token-lookup > /dev/null 2>&1
if [ $? -ne 0 ]; then
 unset VAULT_TOKEN
 >&2 echo -n "Enter LDAP Username: "
 read username
 vault auth -method=ldap username=$username 2> /dev/null

 if [ $? -ne 0 ]; then
   >&2 echo "Invalid Vault Login"
   exit 1
 else
   cp ~/.vault-token /vault-token/.vault-token
 fi
fi

SECRET_PATH=secret/kubernetes/$CLUSTER_NAME/$ACCOUNT_NAME/kube-config
vault read -field=cluster-ca $SECRET_PATH > ./ca.crt
CLUSTER_CA_FILE=./ca.crt
CLUSTER_SERVER=$(vault read -field=cluster-server $SECRET_PATH)
CLUSTER_NAME=$(vault read -field=cluster-name $SECRET_PATH)
USER_NAME=$(vault read -field=user-name $SECRET_PATH)
USER_TOKEN=$(vault read -field=user-token $SECRET_PATH)
DEFAULT_NAMESPACE=$(vault read -field=default-namespace $SECRET_PATH)
CONTEXT_NAME=${CONTEXT_NAME:-$CLUSTER_NAME-$USER_NAME}
AUTHINFO_NAME=${AUTHINFO_NAME:-$USER_NAME-$CLUSTER_NAME}

# Create/Update kubectl cluster entry
kubectl config set-cluster $CLUSTER_NAME \
  --embed-certs=true \
  --server=$CLUSTER_SERVER \
  --certificate-authority=$CLUSTER_CA_FILE

# Create/Update kubectl user credentials
kubectl config set-credentials $AUTHINFO_NAME --token=$USER_TOKEN

# Create/Update kubectl context
kubectl config set-context $CONTEXT_NAME \
--cluster=$CLUSTER_NAME \
--user=$AUTHINFO_NAME \
--namespace=$DEFAULT_NAMESPACE

# Use the newly updated context
kubectl config use-context $CONTEXT_NAME
