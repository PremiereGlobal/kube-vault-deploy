#!/bin/bash

# exit when any command fails
# set -e

# Get location of this script
TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $TEST_DIR/..

docker build -t kube-vault-deploy:dev ./

echo ""; echo "#######################"; echo ""

TEST="No Vault address set"
echo "TEST: "${TEST}
docker run \
  -e VAULT_TOKEN=$(cat ~/.vault-token) \
  -e SECRET_CONFIG="$(cat $TEST_DIR/secrets.json)" \
  kube-vault-deploy:dev sh -c 'exit 0'
if [ $? -eq 0 ]; then echo "PASS: ${TEST}"; else echo "Failed - ${TEST}"; exit 1; fi

echo ""; echo "#######################"; echo ""

TEST="Vault not reachable"
echo "TEST: "${TEST}
docker run \
  -e VAULT_ADDR=https://foo \
  -e VAULT_TOKEN=$(cat ~/.vault-token) \
  -e SECRET_CONFIG="$(cat $TEST_DIR/secrets.json)" \
  kube-vault-deploy:dev sh -c 'exit 0'
if [ $? -ne 0 ]; then echo "PASS: ${TEST}"; else echo "Failed - ${TEST}"; exit 1; fi

echo ""; echo "#######################"; echo ""

TEST="No Vault token set"
echo "TEST: "${TEST}
docker run \
  -e VAULT_ADDR=${VAULT_ADDR} \
  -e SECRET_CONFIG="$(cat $TEST_DIR/secrets.json)" \
  kube-vault-deploy:dev sh -c 'exit 0'
if [ $? -ne 0 ]; then echo "PASS: ${TEST}"; else echo "Failed - ${TEST}"; exit 1; fi

echo ""; echo "#######################"; echo ""

TEST="Vault token set via env var"
echo "TEST: "${TEST}
docker run \
  -e VAULT_ADDR=${VAULT_ADDR} \
  -e VAULT_TOKEN=$(cat ~/.vault-token) \
  -e SECRET_CONFIG="$(cat $TEST_DIR/secrets.json)" \
  kube-vault-deploy:dev sh -c 'exit 0'
if [ $? -eq 0 ]; then echo "PASS: ${TEST}"; else echo "Failed - ${TEST}"; exit 1; fi

echo ""; echo "#######################"; echo ""

TEST="Vault token set via path"
echo "TEST: "${TEST}
docker run \
  -e VAULT_ADDR=${VAULT_ADDR} \
  -v ${HOME}/.vault-token:/vault-token \
  -e SECRET_CONFIG="$(cat $TEST_DIR/secrets.json)" \
  kube-vault-deploy:dev sh -c 'exit 0'
if [ $? -eq 0 ]; then echo "PASS: ${TEST}"; else echo "Failed - ${TEST}"; exit 1; fi

echo ""; echo "#######################"; echo ""

TEST="Secret config set via path"
echo "TEST: "${TEST}
docker run \
  -e VAULT_ADDR=${VAULT_ADDR} \
  -v ${HOME}/.vault-token:/vault-token \
  -v $TEST_DIR/secrets.json:/secrets/config.json \
  -e SECRET_CONFIG_PATH=/secrets/config.json \
  kube-vault-deploy:dev sh -c 'exit 0'
if [ $? -eq 0 ]; then echo "PASS: ${TEST}"; else echo "Failed - ${TEST}"; exit 1; fi

exit 0
