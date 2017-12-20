# Kubernetes Auth w/ Vault

Docker container for authenticting to Kubernetes using Vault.

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Prerequisites](#prerequisites)
- [Usage](#usage)
	- [Dev/Local Deployments](#devlocal-deployments)
	- [Pipeline Deployments](#pipeline-deployments)
	- [Environment Variables](#environment-variables)
	- [Volume Mounts](#volume-mounts)
- [Deployment Scripts](#deployment-scripts)
- [Example](#example)

<!-- /TOC -->

## Prerequisites

* Kubernetes cluster
* Vault instance
 * Pre-loaded secret w/ Kubernetes config
 * LDAP configured (optional)

## Usage

There are two primary use cases for using this container.

### Dev/Local Deployments

Manual deployments to Kubernetes (via `kubectl` or `helm`) from individual workstation.  This scenario can utilize LDAP or VAULT_TOKEN environment variable for authentication.

LDAP Method:
```
docker run --rm -it \
    --name=kube-vault-deploy \
    -e KUBE_CLUSTER=blue.my-domain.com \
    -e VAULT_ADDR=https://vault.my-domain.com:8200 \
    -e VAULT_KUBE_PATH=secret/kubernetes/blue.my-domain.com/kube-config \
    -v ~/.k8s-vault-token:/vault-token:rw \
    -v $(pwd)/deploy:/scripts:ro \
    readytalk/kube-vault-deploy
```

### Pipeline Deployments

Scripted/Automated deployments to Kubernetes (via `kubectl` or `helm`) from CI tools such as Jenkins/Travis.  This scenario will required that a VAULT_TOKEN be passed into the container for authentication.

```
docker run --rm \
    --name=kube-vault-deploy \
    -e AUTO_BUILD=true \
    -e KUBE_CLUSTER=blue.my-domain.com \
    -e VAULT_ADDR=https://vault.my-domain.com:8200 \
    -e VAULT_KUBE_PATH=secret/kubernetes/blue.my-domain.com/kube-config \
    -e VAULT_TOKEN=$VAULT_TOKEN \
    -v $(pwd)/deploy:/scripts:ro \
    readytalk/kube-vault-deploy
```

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default/Required |
|----------------|----------------------------------------------|---------|
|`KUBE_CLUSTER`| This is the name of the Kubernetes cluster you want to deploy to.  For example `blue.my-domain.com`. | required |
|`VAULT_ADDR`| The full address of the instance of vault to connect to. For example `https://vault.my-domain.com:8200` | required |
|`VAULT_KUBE_PATH`| Path within Vault that contains the kube config data. | required |
|`VAULT_KUBE_FIELD`| Field within `VAULT_KUBE_PATH` that contains the Kubernetes config. | `config` |
|`VAULT_TOKEN`| Vault token to use for authentication. If not set and AUTO_BUILD=false, will prompt for LDAP credentials. | (not set) |
|`AUTO_BUILD`| Flag that controls the behavior of the authentication mechanism.  If set to true, will not prompt for LDAP user/pass but instead will fail if `VAULT_TOKEN` is not provided. | `false` |
|`DEPLOY_SCRIPT`| Name of a script in the `/scripts` volume mount (see next section) to execute when the container is run. | `deploy.sh` |

Additional environment variables can be passed in to be used by the deployment files.

### Volume Mounts

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/scripts`| ro | This location contains deploy scripts from your host that need to be accessible by the application. |
|`/vault-token`| rw | This is an optional volume where the application stores the authenticated vault token. It is recommended this not be set for production/pipeline jobs.  For local development, it is recommended you mount this to something like `~/.k8s-vault-token` on the host so that you don't have to auth every time you run the container. |

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
docker run --rm -it \
    --name=kube-vault-deploy \
    -e VAULT_ADDR=https://vault.my-domain.com:8200 \
    -e KUBE_CLUSTER=blue.my-domain.com \
    -e VAULT_KUBE_PATH=secret/kubernetes/blue.my-domain.com/kube-config \
    -e HELM_ENV=dev \
    -v $(pwd)/deploy:/scripts:ro \
    readytalk/kube-vault-deploy
```

From there the following will happen:
* User will be prompted for a vault credentials (LDAP) since VAULT_TOKEN was not passed in.
* Container will read the Kubernetes config from Vault field `config` in the secret `secret/kubernetes/blue.my-domain.com/kube-config`
* Container will execute `deploy.sh` which was passed in from the volume mounted to `deploy/`
* `HELM_ENV` is a custom environment variable used by `deploy.sh`
* Within `deploy.sh` perform a helm upgrade
