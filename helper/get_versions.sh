function get_versions() {
  export KUBE_INSTALLED_VERSION=$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion | gsub("[v]"; "")')
  export HELM_INSTALLED_VERSION=$(helm version --client --template '{{.Client.SemVer}}' | sed 's/^v//')
  export KOPS_INSTALLED_VERSION=$(kops version | sed 's/^Version *//' | sed 's/[[:blank:]].*//')
  export VAULT_INSTALLED_VERSION=$(vault version | sed 's/Vault v//' | sed 's/[[:blank:]].*//')
  export AWS_INSTALLED_VERSION=$(aws --version 2>&1 | sed 's/aws-cli\///' | sed 's/[[:blank:]].*//')
}
