#!/bin/bash

# Fail if any command fails
set -e

# Dealing w/ secrets, don't output any commands
set +x

# If the deploy needs additional secrets, get them using
# https://github.com/ReadyTalk/vault-to-envs
if [[ -n $SECRET_CONFIG ]]; then
  SECRET_VARS=$(v2e)
  eval "$SECRET_VARS"
fi

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

# Install client version of helm that matches the remote server
if [ "$HELM_MATCH_SERVER" == "true" ]; then
  HELM_VERSION=$(kubectl get  deploy tiller-deploy  --namespace=kube-system -o='jsonpath={.spec.template.spec.containers[0].image}' | sed 's/.*v\([0-9\.]*\)/\1/g')
  if [ -z "${HELM_VERSION}" ]; then
    echo "Error: Getting Helm Tiller version from remote K8s server"
  else
    cd /tmp
    curl -L https://kubernetes-helm.storage.googleapis.com/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz
    tar -zxvf helm.tar.gz
    rm helm.tar.gz
    chmod +x linux-amd64/helm
    mv linux-amd64/helm /usr/local/bin/helm
    rm -rf linux-amd64
  fi
fi

cd /scripts

exec "$@"
