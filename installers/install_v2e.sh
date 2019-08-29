#!/bin/bash

# exit when any command fails
set -e

curl -L https://github.com/PremiereGlobal/vault-to-envs/releases/download/v${V2E_VERSION}/vault-to-envs-linux-v${V2E_VERSION}.tar.gz -o v2e.tar.gz \
  && tar -zxvf v2e.tar.gz \
  && rm v2e.tar.gz \
  && chmod +x v2e \
  && mv v2e /usr/local/bin/v2e
