#!/bin/bash

LATEST_V2E_RELEASE=$(curl -s https://api.github.com/repos/readytalk/vault-to-envs/releases/latest | grep tag_name | cut -d '"' -f 4) \
  && curl -LO https://github.com/readytalk/vault-to-envs/releases/download/${LATEST_V2E_RELEASE}/v2e.zip -o v2e.zip \
  && unzip v2e.zip \
  && rm v2e.zip \
  && chmod +x v2e \
  && mv v2e /usr/local/bin/v2e
