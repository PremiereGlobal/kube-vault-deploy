# Kubernetes Deployments w/ Vault

Docker container for deploying to Kubernetes (via `kubectl` or `helm`) using Vault to to retrieve secrets.

## Prerequisites

* Kubernetes cluster
* Vault instance

### Secret Config
This container uses a secret config file which defines secret values to pull from Vault.  For more detail on the config file format, see [vault-to-envs tool](https://github.com/PremiereGlobal/vault-to-envs). There are several ways to get the config into this container:
* Include an environment variable `SECRET_CONFIG` which contains the config text (json).
* Mount a `secret_config` file into the working directory of the container and specify it's location with the `SECRET_CONFIG_PATH` env var

## Usage / Examples

### Basic usage
```
docker run --rm \
  -e VAULT_ADDR=https://vault.my-domain.com:8200 \
	-e VAULT_TOKEN=${VAULT_TOKEN} \
  -e SECRET_CONFIG="$(cat secret_config.json)" \
  -v $(pwd)/deploy:/scripts:ro \
  PremiereGlobal/kube-vault-deploy
```

### Passing Vault token and secret config in as files
```
docker run --rm \
  -e VAULT_ADDR=https://vault.my-domain.com:8200 \
	-v ${HOME}/.vault-token=/vault-token \
  -v $(pwd)/secret_config.json:/secrets/config.json \
  -e SECRET_CONFIG_PATH=/secrets/config.json \
  -v $(pwd)/deploy:/scripts:ro \
  PremiereGlobal/kube-vault-deploy
```

### Custom script name
```
docker run --rm \
  -e VAULT_ADDR=https://vault.my-domain.com:8200 \
  -e VAULT_TOKEN=${VAULT_TOKEN} \
  -e SECRET_CONFIG="$(cat secret_config.json)" \
  -v $(pwd)/deploy:/scripts:ro \
  PremiereGlobal/kube-vault-deploy
```

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default/Required |
|----------------|----------------------------------------------|---------|
|`VAULT_ADDR`| The full address of the instance of vault to connect to. For example `https://vault.my-domain.com:8200` | required |
|`VAULT_TOKEN`| Vault token to use for authentication. | `` |
|`SECRET_CONFIG`| JSON text representing secrets to pull from Vault. See [Secret Config](#secret-config) section below. | `` |
|`SECRET_CONFIG_PATH`| Path for secret config file. See [Secret Config](#secret-config) section below. Will only be used if `SECRET_CONFIG` is not set. | `` |
|`HELM_MATCH_SERVER`| If set to `true`, downloads the helm version to match the version of the Tiller installed on the cluster. | `true` |
|`HELM_VERSION`| If set, overrides the container version of helm with the specified version. | ` ` |
|`KUBE_MATCH_SERVER`| If set to `true`, downloads the kubectl version to match the version of the cluster. | `true` |
|`KUBE_VERSION`| If set, overrides the container version of kubectl with the specified version. | ` ` |
|`KOPS_VERSION`| If set, overrides the container version of kops with the specified version. | ` ` |
|`VAULT_MATCH_SERVER`| If set to `true`, downloads the vault version to match the version of the cluster. | `true` |
|`VAULT_VERSION`| If set, overrides the container version of Vault with the specified version. | ` ` |

Additional environment variables can be passed in to be used by the deployment files.

### Volume Mounts

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/scripts`| ro | This location contains deploy scripts from your host that need to be accessible by the application. |
|`/vault-token`| rw | This is an optional volume where the application stores the authenticated vault token. It is recommended this not be set for production/pipeline jobs.  For local development, it is recommended you mount this to  `~/.vault-token` (be sure to create that file first or Docker will create it as a directory and it will fail) on the host so that you don't have to auth every time you run the container. |
|`/bin-cache`| rw | This is an optional volume where custom binary versions (kubectl, vault, etc) will be stored.  This can be mounted locally to cache these binaries so they don't have to be downloaded every run. |

## Deployment Scripts

Scripts should be mounted from a local directory to `/scripts` inside the container (see Volume Mounts section above).  By default, the container will run the `deploy.sh` file in this directory to kick off the build.  This script can anything you want with `kubectl` or `helm` and can be augmented with additional environment variables you pass in.

## Example

As an example, say we have a project with the following structure

```
deploy/
│   deploy.sh
│
└── helm_chart/
│   │   Chart.yaml
│   │   values.yaml
│   │   values-dev.yaml
│   │   values-prod.yaml
│   │
│   └───templates/
│       │   deployment.yaml
│       │   service.yaml
│       │   ...
src/
│   ...
lib/
│   ...
README.md
...
```

deploy/deploy.sh:
```
#!/bin/bash

helm upgrade --values helm_chart/values-$HELM_ENV.yaml $HELM_ENV-release helm_chart/
```

From the project root we can run
```
docker run --rm \
    -e VAULT_ADDR=https://vault.my-domain.com:8200 \
		-e VAULT_TOKEN=$(cat ~/.vault-token)
		-e SECRET_CONFIG=${SECRET_CONFIG} \
    -e HELM_ENV=dev \
    -v $(pwd)/deploy:/scripts:ro \
    PremiereGlobal/kube-vault-deploy
```

From there the following will happen:
* User will be prompted for a vault credentials (LDAP) since VAULT_TOKEN was not passed in.
* Container will read the Kubernetes config from Vault field `config` in the secret `secret/kubernetes/blue.my-domain.com/kube-config`
* Container will execute `deploy.sh` which was passed in from the volume mounted to `deploy/`
* `HELM_ENV` is a custom environment variable used by `deploy.sh`
* Within `deploy.sh` perform a helm upgrade
