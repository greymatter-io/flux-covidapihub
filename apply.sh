#!/usr/bin/env bash

# cd ~/Decipher/helm-charts/spire
# git checkout -b copy-covid && git pull
# make spire

# kubectl create namespace cert-manager
# for f in cert-manager/*.yaml; do kubectl apply -f $f; done

# kubectl create namespace fabric
# for f in fabric/*.yaml; do kubectl apply -f $f; done

# kubectl create namespace sense
# for f in sense/*.yaml; do kubectl apply -f $f; done

# kubectl create namespace website
# for f in website/*.yaml; do kubectl apply -f $f; done

# kubectl create namespace data
# for f in data/*.yaml; do kubectl apply -f $f; done

# kubectl create namespace edge
# for f in edge/*.yaml; do kubectl apply -f $f; done

kubectl create namespace apis
for f in apis/*.yaml; do kubectl apply -f $f; done
for f in apis/*/*.yaml; do kubectl apply -f $f; done
