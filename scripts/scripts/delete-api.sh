#!/bin/bash

echo API Name:
read API_NAME
echo "Delete API in dev? [y/N]":
read DEV

source ./scripts/scripts/mesh-env.sh
if [[ "$DEV" =~ ^([yY])$ ]]; then
    source ./scripts/scripts/kubeconfig-k3d.sh
else
    source ./scripts/scripts/kubeconfig-aws.sh
fi

echo "Removing $API_NAME"

kubectl delete -f apis/$API_NAME/$API_NAME.sidecar.configmap.yaml
kubectl delete -f apis/$API_NAME/$API_NAME.deployment.yaml

echo "Deleting mesh config for api: $API_NAME"

greymatter version

kubectl cluster-info

listener=$(lsof -t -i:10080)

if [ ! -z "$listener" ]; then
    echo "Killing a process (pid $listener) using port 10080"
    kill $listener
fi

kubectl -n fabric wait --for=condition=Ready pod/api-0  --timeout=300s

kubectl port-forward api-0 -n fabric 10080:10080 &
sleep 10

echo "Deleting service configuration objects..."


delay=0.01

greymatter delete cluster edge.$API_NAME.cluster
greymatter delete cluster $API_NAME.local.cluster
greymatter delete domain $API_NAME.apis.domain
greymatter delete listener $API_NAME.apis.listener
greymatter delete proxy $API_NAME.proxy
greymatter delete shared_rules edge.$API_NAME.rules
greymatter delete shared_rules $API_NAME.local.rules
greymatter delete route edge.$API_NAME.route
greymatter delete route edge.$API_NAME.slash.route
greymatter delete route $API_NAME.local.route