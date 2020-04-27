#!/bin/bash

if [[ "$(kubectl config current-context)" != "greymatter" ]]; then
    echo "⛔️⛔️⛔️⛔️⛔ You are about to apply yaml file to non-k3d environment ⛔️⛔️⛔️⛔️⛔️"
    exit 1
fi

# A little forceful but killing dashboard pod
control_pod=$(kubectl get pod -l app=control -o jsonpath="{.items[0].metadata.name}" -n fabric)

kubectl delete pod api-0 -n fabric
kubectl delete pod $control_pod -n fabric
