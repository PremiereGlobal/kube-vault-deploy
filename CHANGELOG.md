### 0.3.2
* Added support for helm3 downloading

### 0.3.1
* Fixing bug with version matching path

### 0.3.0
* Now using [vault-to-env](https://github.com/PremiereGlobal/vault-to-envs) `v0.2.0` which supports Vault's key-value version 2 datastore
* Fixed issue with `deploy.sh` not running by default
* Removed Vault prompt to log in
  *  This was due to increased difficulty providing enough options to
* Removed `AUTO_BUILD` env var
  * Wasn't doing much to begin with
* Removed support for `CLUSTER_NAME` and `ACCOUNT_NAME` env vars for Kubernetes
* Fixed and clarified README
* Added `apacheutils` to the container
* Bumped default versions
  * Kubernetes to `1.11.9`
  * Helm to `2.14.2`
  * Vault to `1.1.2`
  * Kops to `1.11.1`

### 0.2.9
* Fixing issue with volume mounting read-only to `/scripts`

### 0.2.8
* Bumped Kubernetes (1.10.12), Helm (2.12.1) and Vault (1.0.0) versions
* `/bin-cache` volume will now version binaries instead of overwrite them - this provides a more robust caching mechanism
* Added Helm init and repo update on install
* Added signature validation for downloaded binaries (kubectl, helm, kops, vault)
* Download binaries if version set (even if it doesn't appear you're using it)

### 0.2.7
* Bumped Kubernetes default version to 1.10.8
* Change helm version detection logic

### 0.2.6
* Fixed bug with Helm match version path
* Bumped Helm default version to 2.11

### 0.2.5
* Added default file location for reading secret config.  In working directory, if file `secret_config.json` is found, it will be evaluated.
* Added environment var `SECRET_CONFIG_PATH` for setting custom secret config path.
* Fixed path issue with custom working directories

### 0.2.4
* Fix error message when not mounting `/bin-cache`
* Upped Vault default version to 0.11.1
* Updating kops even if not using Kubernetes
* Fixed execution of custom script

### 0.2.3
* Fix read-only `/scripts` mount issue

### 0.2.2
* Fixed `HELM_MATCH_SERVER` to only download new version if it differs the existing one
* Added additional options for custom versioning of tools
  * `HELM_VERSION`
  * `KUBE_MATCH_SERVER`
  * `KUBE_VERSION`
  * `KOPS_VERSION`
  * `VAULT_MATCH_SERVER`
  * `VAULT_VERSION`
* Added VOLUME `/bin-cache` for binaries so they can be cached locally if repeatedly using custom version

### 0.2.1
* Fixed issue with script failing when not using Kubernetes

### 0.2.0
* Locked `helm` version to `2.10.0`
* Locked `vault` version to `0.10.4`
* Added `HELM_MATCH_SERVER` environment variable (see [README.md](README.md))
