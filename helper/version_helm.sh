#!/bin/bash

function install() {
  if [[ "${1}" == "${HELM_INSTALLED_VERSION}" ]]; then
    echo "Helm already matches version ${1}"
  else
    echo "Installing Helm version ${1}"
    /helper/install_helm.sh ${1} ${BIN_CACHE_DIR}
  fi
}

if [[ "$HELM_VERSION" != "" ]]; then
  echo "Installing custom Helm version ${HELM_VERSION}"
  install ${HELM_VERSION}
elif [[ "$HELM_MATCH_SERVER" == "true" ]]; then
  HELM_MATCH_VERSION=$(kubectl get  deploy tiller-deploy  --namespace=kube-system -o='jsonpath={.spec.template.spec.containers[0].image}' | sed 's/.*v\([0-9\.]*\)/\1/g')
  if [ -z ${HELM_MATCH_VERSION} ]; then
    echo "Error: Getting Helm Tiller version from remote K8s server"
    exit 1
  else
    echo "Installing Helm version ${HELM_MATCH_VERSION} to match server"
    install ${HELM_MATCH_VERSION}
  fi
fi
