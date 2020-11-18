#!/usr/bin/env bash

kubectl create namespace spire
for f in spire/registrar.*.yaml; do kubectl apply -f $f; done
for f in spire/server.*.yaml; do kubectl apply -f $f; done
