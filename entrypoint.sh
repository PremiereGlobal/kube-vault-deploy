#!/bin/bash

# DEPLOY_SCRIPT=${DEPLOY_SCRIPT:-"deploy.sh"}
# VAULT_KUBE_FIELD=${VAULT_KUBE_FIELD:-"config"}
#
# SECRET_PATH=secret/kubernetes/$CLUSTER_NAME/$ACCOUNT_NAME/kube-config
# vault read -field=cluster-ca $SECRET_PATH > ./ca.crt
# CLUSTER_CA_FILE=./ca.crt
# CLUSTER_SERVER=$(vault read -field=cluster-server $SECRET_PATH)
# CLUSTER_NAME=$(vault read -field=cluster-name $SECRET_PATH)
# USER_NAME=$(vault read -field=user-name $SECRET_PATH)
# USER_TOKEN=$(vault read -field=user-token $SECRET_PATH)
# DEFAULT_NAMESPACE=$(vault read -field=default-namespace $SECRET_PATH)
# CONTEXT_NAME=${CONTEXT_NAME:-$CLUSTER_NAME-$USER_NAME}
# AUTHINFO_NAME=${AUTHINFO_NAME:-$USER_NAME-$CLUSTER_NAME}

CONTEXT_NAME=default
CLUSTER_NAME=default
AUTHINFO_NAME=default
DEFAULT_NAMESPACE=${DEFAULT_NAMESPACE:-default}

echo "$CLUSTER_CA" > /cluster.ca

# Create/Update kubectl cluster entry
kubectl config set-cluster $CLUSTER_NAME \
  --embed-certs=true \
  --server=$CLUSTER_SERVER \
  --certificate-authority=/cluster.ca

# Create/Update kubectl user credentials
kubectl config set-credentials $AUTHINFO_NAME --token="$USER_TOKEN"

# Create/Update kubectl context
kubectl config set-context $CONTEXT_NAME \
--cluster=$CLUSTER_NAME \
--user=$AUTHINFO_NAME \
--namespace=$DEFAULT_NAMESPACE

# Use the newly updated context
kubectl config use-context $CONTEXT_NAME

cd /scripts

exec "$@"
