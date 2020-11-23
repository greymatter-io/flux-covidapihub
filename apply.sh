#!/usr/bin/env bash

# PREREQS:
# - create all namespaces
# - apply kubeseal resources
# - create and apply all secrets using kubeseal private key
# - create kafka and update all mesh configs

set -eux pipefail

cd ~/Decipher/helm-charts/spire
git checkout copy-covid && git pull
make spire

for f in cert-manager/*.yaml; do kubectl apply -f $f; done

for f in fabric/*.yaml; do kubectl apply -f $f; done

for f in sense/*.yaml; do kubectl apply -f $f; done

for f in website/*.yaml; do kubectl apply -f $f; done

for f in data/*.yaml; do kubectl apply -f $f; done

for f in edge/*.yaml; do kubectl apply -f $f; done

for f in apis/*.yaml; do kubectl apply -f $f; done

for f in apis/*/*.yaml; do kubectl apply -f $f; done

./mesh-config.sh
./mesh-api.sh
