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
