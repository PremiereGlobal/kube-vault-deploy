#!/bin/bash

# Fail if any command fails
# Dealing w/ secrets, don't output any commands
# set -e
set +x

source /helper/get_versions.sh

USING_K8S="false"
USING_VAULT="false"

# Set up Vault (if applicable)
/helper/vault.sh
if [[ $? -eq 0 ]]; then
  USING_VAULT=true
fi

if [[ "$USING_VAULT" == "true" || "${VAULT_VERSION}" != "" ]]; then
  /helper/version_vault.sh
fi

if [[ "$USING_VAULT" == "true" ]]; then

  # If the deploy needs additional secrets, get them using
  # https://github.com/ReadyTalk/vault-to-envs
  if [[ -n $SECRET_CONFIG ]]; then
    SECRET_VARS=$(v2e)
    eval "$SECRET_VARS"
  elif [[ $SECRET_CONFIG_PATH && -f "${SECRET_CONFIG_PATH}" ]]; then
    echo "Secret config set at ${SECRET_CONFIG_PATH}"
    export SECRET_CONFIG=$(cat "${SECRET_CONFIG_PATH}")
    SECRET_VARS=$(v2e)
    eval "$SECRET_VARS"
    # Implement custom path for config file
  elif [[ -f "${WORK_DIR}/secret_config.json" ]]; then
    echo "Secret config found at ${WORK_DIR}/secret_config.json"
    export SECRET_CONFIG=$(cat ${WORK_DIR}/secret_config.json)
    SECRET_VARS=$(v2e)
    eval "$SECRET_VARS"
  fi
fi

# Set up Kubernetes context (if applicable)
/helper/kubernetes.sh
if [[ $? -eq 0 ]]; then
  USING_K8S=true
fi

if [[ "$USING_K8S" == "true" || ${KUBE_VERSION} != "" ]]; then
  /helper/version_kube.sh
fi

if [[ "$USING_K8S" == "true" || ${HELM_VERSION} != "" ]]; then
  /helper/version_helm.sh
fi

/helper/version_kops.sh

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

exec "$@"
