#!/bin/bash

# exit when any command fails
set -e

# No way to detect which KOPS version was used so only change if it is requested.
function install() {
  if [[ -f "/bin-local/kops-v${1}" ]]; then
    echo "kops version ${1} exists in container, linking."
    ln -sf /bin-local/kops-v${1} /usr/local/bin/kops
  elif [[ -f "/bin-cache/kops-v${1}" ]]; then
    echo "kops version ${1} exists in bin-cache, linking."
    ln -sf /bin-cache/kops-v${1} /usr/local/bin/kops
  else
    echo "Installing kops version ${1}"
    /helper/install_kops.sh ${1} ${BIN_CACHE_DIR}
  fi
}

if [[ "$KOPS_VERSION" != "" ]]; then
  echo "Installing custom kops version ${KOPS_VERSION}"
  install ${KOPS_VERSION}
fi
