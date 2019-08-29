FROM alpine

RUN \
  set -x && \
  apk update && \
  apk -Uuv add bash curl zip jq groff less python py2-pip bash jq curl wget ca-certificates openssl zip git apache2-utils && \
  pip install awscli yq && \
  apk --purge -v del py2-pip && \
  rm /var/cache/apk/*

WORKDIR /tmp

ENV BIN_CACHE_DIR=/bin-cache \
  DEFAULT_KUBE_VERSION=1.11.9 \
  DEFAULT_KOPS_VERSION=1.11.1 \
  DEFAULT_VAULT_VERSION=1.1.2 \
  DEFAULT_HELM_VERSION=2.14.2 \
  V2E_VERSION=0.2.0 \
  STIM_VERSION=0.0.6 \
  HELM_MATCH_SERVER=true \
  KUBE_MATCH_SERVER=true \
  VAULT_MATCH_SERVER=true

RUN mkdir ${BIN_CACHE_DIR} && mkdir /bin-local

# Install kubectl, kops, helm, vault, v2e
COPY installers /installers
RUN /installers/install_kube.sh && \
  /installers/install_kops.sh && \
  /installers/install_helm.sh && \
  /installers/install_vault.sh && \
  /installers/install_v2e.sh && \
  /installers/install_stim.sh

COPY helper /helper

COPY entrypoint.sh /entrypoint.sh

VOLUME /scripts

CMD [ "deploy.sh" ]
ENTRYPOINT [ "/entrypoint.sh" ]
