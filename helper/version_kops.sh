#!/bin/bash

# No way to detect which KOPS version was used so only change if it is requested.

function install() {
  if [[ "${1}" == "${KOPS_INSTALLED_VERSION}" ]]; then
    echo "kops already matches version ${1}"
  else
    echo "Installing kops version ${1}"
    /helper/install_kops.sh ${1} ${BIN_CACHE_DIR}
  fi
}

if [[ "$KOPS_VERSION" != "" ]]; then
  echo "Installing custom kops version ${KOPS_VERSION}"
  install ${KOPS_VERSION}
fi
