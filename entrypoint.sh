#!/bin/bash

AUTO_BUILD=${AUTO_BUILD:-"false"}
DEPLOY_SCRIPT=${DEPLOY_SCRIPT:-"deploy.sh"}
VAULT_KUBE_FIELD=${VAULT_KUBE_FIELD:-"config"}

# Ensure required env variables are set
if [ -z "$VAULT_ADDR" ]; then
  >&2 echo "Error: VAULT_ADDR environment variable not set. See documentation."
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
  export VAULT_TOKEN=$(cat /root/.vault-token 2> /dev/null)
elif [ -z "$VAULT_TOKEN" -a "$AUTO_BUILD" == "true"]; then
  >&2 echo "Must set env VAULT_TOKEN if running as AUTO_BUILD=true."
  exit 1
fi

# Check if we're authenticated with vault, if not, and if not AUTO_BUILD, try LDAP
vault token lookup > /dev/null 2>&1
if [ $? -ne 0 -a $AUTO_BUILD == "false" ]; then
 unset VAULT_TOKEN
 >&2 echo -n "Enter LDAP Username: "
 read username
 vault login -method=ldap username=$username
 if [ $? -ne 0 ]; then
   >&2 echo "Invalid Vault Login"
   exit 1
 fi
 export VAULT_TOKEN=$(cat /root/.vault-token 2> /dev/null)
fi

# If the deploy needs additional secrets, get them using
# https://github.com/ReadyTalk/vault-to-envs
if [[ -n $SECRET_CONFIG ]]; then
  SECRET_VARS=$(v2e)
  eval "$SECRET_VARS"
fi

# We're authenticating using credentials passed in via environment variables (or v2e)
# CLUSTER_SERVER, CLUSTER_CA, and USER_TOKEN must be set
if [ "$CLUSTER_SERVER" -o "${CLUSTER_CA}" -o "${USER_TOKEN}" ]; then
  if [ "$CLUSTER_SERVER" -a "${CLUSTER_CA}" -a "${USER_TOKEN}" ]; then

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

  else
    echo "Error: Need to specify CLUSTER_SERVER, CLUSTER_CA and USER_TOKEN to authenticate with Kubernetes"
    exit 1
  fi

elif [ "$CLUSTER_NAME" -o "$ACCOUNT_NAME" ]; then

  # We're authenticating using Vault with cluster/account info passed in via environment variables
  if [ "$CLUSTER_NAME" -a "$ACCOUNT_NAME" ]; then
    echo "Generating kube-config for $CLUSTER_NAME based on Vault credentials..."

    SECRET_PATH=secret/kubernetes/$CLUSTER_NAME/$ACCOUNT_NAME/kube-config
    vault read -field=cluster-ca $SECRET_PATH > /ca.crt
    CLUSTER_CA_FILE=/ca.crt
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
  else
    echo "Error: Need to specify KUBE_CLUSTER and KUBE_ACCOUNT to authenticate with Kubernetes"
    exit 1
  fi
fi

# Install client version of helm that matches the remote server
if [ "$HELM_MATCH_SERVER" == "true" ]; then
  HELM_VERSION=$(kubectl get  deploy tiller-deploy  --namespace=kube-system -o='jsonpath={.spec.template.spec.containers[0].image}' | sed 's/.*v\([0-9\.]*\)/\1/g')
  if [ -z ${HELM_VERSION+x} ]; then
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
