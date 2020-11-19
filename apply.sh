#!/usr/bin/env bash

# kubectl create namespace spire
# for f in spire/registrar.*.yaml; do kubectl apply -f $f; done
# for f in spire/server.*.yaml; do kubectl apply -f $f; done
# kubectl create namespace fabric
# for f in fabric/*.yaml; do kubectl apply -f $f; done

# kubectl create namespace sense
# for f in sense/*.yaml; do kubectl apply -f $f; done

# kubectl create namespace website
# for f in website/*.yaml; do kubectl apply -f $f; done

kubectl create namespace data
for f in data/*.yaml; do kubectl apply -f $f; done
