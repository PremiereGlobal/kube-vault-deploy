#!/bin/bash

HELM_MATCH_VERSION=$(kubectl get  deploy tiller-deploy  --namespace=kube-system -o='jsonpath={.spec.template.spec.containers[0].image}' | sed 's/.*v\([0-9\.]*\)/\1/g')
if [ -z ${HELM_MATCH_VERSION} ]; then
  echo "Error: Getting Helm Tiller version from remote K8s server"
  exit 1
else
  echo "Switching Helm version to ${HELM_MATCH_VERSION} to match server"
  cd /tmp
  curl -L https://kubernetes-helm.storage.googleapis.com/helm-v${HELM_MATCH_VERSION}-linux-amd64.tar.gz -o helm.tar.gz
  tar -zxvf helm.tar.gz
  rm helm.tar.gz
  chmod +x linux-amd64/helm
  mv linux-amd64/helm /usr/local/bin/helm
  rm -rf linux-amd64
fi
