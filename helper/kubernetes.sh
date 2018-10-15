#!/bin/bash

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

    USING_K8S="true"

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

    USING_K8S="true"

  else
    echo "Error: Need to specify KUBE_CLUSTER and KUBE_ACCOUNT to authenticate with Kubernetes"
    exit 1
  fi
else
  echo "Kubernetes not configured, continuing..."
  exit 1
fi

exit 0
