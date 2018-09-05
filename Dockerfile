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

ENV VAULT_VERSION=0.10.4
ENV HELM_VERSION=2.10.0

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
      && chmod +x ./kubectl \
      && mv ./kubectl /usr/local/bin/kubectl \
      && kubectl version --client

# Install kops
RUN curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 \
    && chmod +x kops-linux-amd64 \
    && mv kops-linux-amd64 /usr/local/bin/kops \
    && kops version

# Install helm
RUN curl -L https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz \
  && tar -zxvf helm.tar.gz \
  && rm helm.tar.gz \
  && chmod +x linux-amd64/helm \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && rm -rf linux-amd64 \
  && helm version -c

# Install vault client
RUN curl -L https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip \
  && unzip vault.zip \
  && rm vault.zip \
  && chmod +x vault \
  && mv vault /usr/local/bin/vault \
  && vault version

# Install vault-to-envs
RUN LATEST_V2E_RELEASE=$(curl -s https://api.github.com/repos/readytalk/vault-to-envs/releases/latest | grep tag_name | cut -d '"' -f 4) \
  && curl -LO https://github.com/readytalk/vault-to-envs/releases/download/${LATEST_V2E_RELEASE}/v2e.zip -o v2e.zip \
  && unzip v2e.zip \
  && rm v2e.zip \
  && chmod +x v2e \
  && mv v2e /usr/local/bin/v2e

RUN touch /vault-token && ln -s /vault-token /root/.vault-token

VOLUME /scripts

WORKDIR /scripts

ENV AUTO_BUILD=false
ENV HELM_MATCH_SERVER=true
ENV DEPLOY_SCRIPT=deploy.sh

COPY helper /helper
COPY entrypoint.sh /entrypoint.sh


ENTRYPOINT [ "/entrypoint.sh" ]
