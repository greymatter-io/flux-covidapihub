#!/usr/bin/env bash

# PREREQS:
# - create all namespaces except for spire
# - apply kubeseal resources and grab private key from kubeseal logs on startup
# - create and apply all secrets using kubeseal private key
# - create kafka and update all mesh configs with the connection string
# - create postgres instance for slo and create objectives-postgres secret with creds

set -eux pipefail

cd ~/Decipher/helm-charts/spire
git checkout copy-covid && git pull
make spire

cd ~/Decipher/flux-covidapihub

for f in cert-manager/*.yaml; do kubectl apply -f $f; done

for f in fabric/*.yaml; do kubectl apply -f $f; done

for f in sense/*.yaml; do kubectl apply -f $f; done

for f in website/*.yaml; do kubectl apply -f $f; done

for f in data/*.yaml; do kubectl apply -f $f; done

for f in apis/*.yaml; do kubectl apply -f $f; done

for f in apis/*/*/*.yaml; do kubectl apply -f $f; done

for f in edge/*.yaml; do kubectl apply -f $f; done

./scripts/scripts/mesh-config.sh
./scripts/scripts/mesh-api.sh

bs update-kops-cluster-sgs --cluster-name covidhub.upgrade.k8s.local
