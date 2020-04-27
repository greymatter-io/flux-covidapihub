#!/bin/bash

if [[ "$(kubectl config current-context)" != "greymatter" ]]; then
    echo "⛔️⛔️⛔️⛔️⛔ You are about to apply yaml file to non-k3d environment ⛔️⛔️⛔️⛔️⛔️"
    exit 1
fi

# A little forceful but killing dashboard pod
dashboard_pod=$(kubectl get pod -l app=dashboard -o jsonpath="{.items[0].metadata.name}" -n sense)
kubectl delete pod $dashboard_pod -n sense