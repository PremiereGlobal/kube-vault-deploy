#!/bin/bash

# exit when any command fails
set -e

function install() {
  if [[ -f "/bin-local/helm-v${1}" ]]; then
    echo "helm version ${1} exists in container, linking."
    ln -sf /bin-local/helm-v${1} /usr/local/bin/helm
  elif [[ -f "/bin-cache/helm-v${1}" ]]; then
    echo "helm version ${1} exists in bin-cache, linking."
    ln -sf /bin-cache/helm-v${1} /usr/local/bin/helm
  else
    echo "Installing Helm version ${1}"
    /installers/install_helm.sh ${1} ${BIN_CACHE_DIR}
  fi
}

if [[ "$HELM_VERSION" != "" ]]; then
  echo "Installing custom Helm version ${HELM_VERSION}"
  install ${HELM_VERSION}
elif [[ "$HELM_MATCH_SERVER" == "true" ]]; then
  HELM_MATCH_VERSION=$(helm version -s | sed 's/.*v\([0-9\.]\+\).*/\1/')
  if [ -z ${HELM_MATCH_VERSION} ]; then
    echo "Error: Getting Helm Tiller version from remote K8s server"
    exit 1
  else
    echo "Installing Helm version ${HELM_MATCH_VERSION} to match server"
    install ${HELM_MATCH_VERSION}
  fi
fi
