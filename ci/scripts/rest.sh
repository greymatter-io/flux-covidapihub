#!/bin/bash
export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"

for f in ingress/private*.yaml; do kubectl apply -f $f; done
for f in ingress/public*.yaml; do kubectl apply -f $f; done

kubectl apply -f private.ingress.yaml

kubectl port-forward api-0 -n fabric 10080:10080 &