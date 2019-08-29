#!/bin/bash

# exit when any command fails
set -e

# We're authenticating using credentials passed in via environment variables (or v2e)
echo "Generating kube-config for $CLUSTER_SERVER based on environment variables credentials..."

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

USING_K8S="true"

exit 0
