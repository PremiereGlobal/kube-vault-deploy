# Kubernetes Auth w/ Vault

Docker container for create Kubernetes config from data stored in Vault.

## Usage

```
docker run -it \
  -e VAULT_ADDR=https://my-vault-domain:8200 \
  -e CLUSTER_NAME=cluster.my-domain.com \
  -e ACCOUNT_NAME=sre \
  -v ${HOME}/.kube/config:/kube-config/config \
  readytalk/kube-vault-deploy:kube-auth
```
