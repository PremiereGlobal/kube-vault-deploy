#!/bin/bash

# exit when any command fails
set -e

function install() {
  if [[ -f "/bin-local/kubectl-v${1}" ]]; then
    echo "kubectl version ${1} exists in container, linking."
    ln -sf /bin-local/kubectl-v${1} /usr/local/bin/kubectl
  elif [[ -f "/bin-cache/kubectl-v${1}" ]]; then
    echo "kubectl version ${1} exists in bin-cache, linking."
    ln -sf /bin-cache/kubectl-v${1} /usr/local/bin/kubectl
  else
    echo "Installing kubectl version ${1}"
    /installers/install_kube.sh ${1} ${BIN_CACHE_DIR}
  fi
}

if [[ "$KUBE_VERSION" != "" ]]; then
  echo "Installing custom Kubernetes (kubectl) version ${KUBE_VERSION}"
  install ${KUBE_VERSION}
elif [[ "$KUBE_MATCH_SERVER" == "true" ]]; then
  KUBE_MATCH_VERSION=$(kubectl version -o json | jq -r '.serverVersion.gitVersion | ltrimstr("v")')
  if [ -z ${KUBE_MATCH_VERSION} ]; then
    echo "Error: Getting Kubernetes version from remoteserver"
    exit 1
  else
    echo "Installing kubectl version ${KUBE_MATCH_VERSION} to match server"
    install ${KUBE_MATCH_VERSION}
  fi
fi
