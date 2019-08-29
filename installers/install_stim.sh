#!/bin/bash

# exit when any command fails
set -e

curl -L https://github.com/PremiereGlobal/stim/releases/download/v${STIM_VERSION}/stim-linux-v${STIM_VERSION}.tar.gz -o stim.tar.gz \
  && tar -zxvf stim.tar.gz \
  && rm stim.tar.gz \
  && chmod +x stim \
  && mv stim /usr/local/bin/stim
