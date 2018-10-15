#!/bin/bash

# Fail if any command fails
# Dealing w/ secrets, don't output any commands
# set -e
set +x
export PATH="${BIN_CACHE_DIR}:${PATH}"
source /helper/get_versions.sh
get_versions

USING_K8S="false"
USING_VAULT="false"

# Set up Vault (if applicable)
/helper/vault.sh
if [[ $? -eq 0 ]]; then
  USING_VAULT=true
fi

if [[ "$USING_VAULT" == "true" ]]; then
  /helper/version_vault.sh

  # If the deploy needs additional secrets, get them using
  # https://github.com/ReadyTalk/vault-to-envs
  if [[ -n $SECRET_CONFIG ]]; then
    SECRET_VARS=$(v2e)
    eval "$SECRET_VARS"
  fi
fi

# Set up Kubernetes context (if applicable)
/helper/kubernetes.sh
if [[ $? -eq 0 ]]; then
  USING_K8S=true
fi

if [[ "$USING_K8S" == "true" ]]; then
  /helper/version_kube.sh
  /helper/version_helm.sh
  /helper/version_kops.sh
fi

if [[ "$@" == "version" ]]; then
  get_versions
  echo ""
  echo "  Client Versions:"
  echo "  kubectl: ${KUBE_INSTALLED_VERSION}"
  echo "  helm: ${HELM_INSTALLED_VERSION}"
  echo "  kops: ${KOPS_INSTALLED_VERSION}"
  echo "  vault: ${VAULT_INSTALLED_VERSION}"
  echo "  aws: ${AWS_INSTALLED_VERSION}"
  exit 0
fi

cd /scripts

$@
