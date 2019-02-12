FROM alpine

RUN apk update && \
  apk add bash curl zip jq

RUN \
  set -x && \
  apk update && \
  apk -Uuv add groff less python py2-pip bash jq curl wget ca-certificates openssl zip git && \
  pip install awscli yq && \
  apk --purge -v del py2-pip && \
  rm /var/cache/apk/*

WORKDIR /tmp

ENV BIN_CACHE_DIR=/bin-cache
ENV DEFAULT_KUBE_VERSION=1.10.12
ENV DEFAULT_KOPS_VERSION=1.10.0
ENV DEFAULT_VAULT_VERSION=1.0.0
ENV DEFAULT_HELM_VERSION=2.12.1
ENV AUTO_BUILD=false
ENV HELM_MATCH_SERVER=true
ENV KUBE_MATCH_SERVER=true
ENV VAULT_MATCH_SERVER=true

RUN mkdir ${BIN_CACHE_DIR}
RUN mkdir /bin-local
COPY helper /helper

# Install kubectl
RUN /helper/install_kube.sh

# Install kops
RUN /helper/install_kops.sh

# Install helm
RUN /helper/install_helm.sh

# Install vault client
RUN /helper/install_vault.sh

# Install vault-to-envs
RUN /helper/install_v2e.sh

RUN touch /vault-token && ln -s /vault-token /root/.vault-token

COPY entrypoint.sh /entrypoint.sh

VOLUME /scripts

ENTRYPOINT [ "/entrypoint.sh" ]
