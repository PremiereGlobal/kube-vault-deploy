FROM alpine

ENV VAULT_VERSION="0.9.0"
ENV KUBECTL_VERSION="1.8.4"
ENV HELM_VERSION="2.7.2"
ENV TERRAFORM_VERSION="0.11.1"

RUN apk update && \
  apk add bash curl zip jq kamailio-mysql mysql-client

WORKDIR /tmp

# Install Vault Client
RUN curl -o vault.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" && \
  unzip vault.zip && \
  mv vault /usr/bin && \
  rm vault.zip

# Install kubectl
RUN curl -o kubectl -LO "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
  chmod +x kubectl && \
  mv kubectl /usr/bin

# Install helm
RUN curl -o helm.tar.gz -L "https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
  tar -zxvf helm.tar.gz && \
  chmod +x linux-amd64/helm && \
  mv linux-amd64/helm /usr/bin && \
  rm -rf linux-amd64 helm.tar.gz

# Install terraform
RUN curl -o terraform.zip -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
  unzip terraform.zip && \
  chmod +x terraform && \
  mv terraform /usr/bin && \
  rm -rf terraform terraform.zip

# Install latest kops
RUN curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 \
    && chmod +x kops-linux-amd64 \
    && mv kops-linux-amd64 /usr/local/bin/kops \
    && kops version


VOLUME /vault-token
VOLUME /scripts

WORKDIR /scripts

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
