#!/bin/bash

# Fail if any command fails
# Dealing w/ secrets, don't output any commands
set -e
set +x

USING_K8S="false"

# Ensure that we're authenticated with vault
/helper/vault.sh

# If the deploy needs additional secrets, get them using
# https://github.com/ReadyTalk/vault-to-envs
if [[ -n $SECRET_CONFIG ]]; then
  SECRET_VARS=$(v2e)
  eval "$SECRET_VARS"
fi

# Set up Kubernetes context (if applicable)
/helper/kubernetes.sh

cd /scripts

exec "$@"
