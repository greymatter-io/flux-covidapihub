#!/bin/bash

API_NAME=$1

echo "Applying new api: $API_NAME"

kubectl apply -f apis/$API_NAME/$API_NAME.sidecar.configmap.yaml
kubectl apply -f apis/$API_NAME/$API_NAME.deployment.yaml

echo "Applying mesh config for api: $API_NAME"

greymatter version

source ./ci/scripts/mesh-env.sh
kubectl cluster-info

listener=$(lsof -t -i:10080)

if [ ! -z "$listener" ]; then
    echo "Killing a process (pid $listener) using port 10080"
    kill $listener
fi

kubectl -n fabric wait --for=condition=Ready pod/api-0  --timeout=300s

kubectl port-forward api-0 -n fabric 10080:10080 &
sleep 10

echo "Starting mesh configuration ..."

echo "Creating service configuration objects..."

delay=0.01

for cl in apis/$API_NAME/mesh/clusters/*.json; do greymatter create cluster < $cl; done
for cl in apis/$API_NAME/mesh/domains/*.json; do greymatter create domain < $cl; done
for cl in apis/$API_NAME/mesh/listeners/*.json; do greymatter create listener < $cl; done
for cl in apis/$API_NAME/mesh/proxies/*.json; do greymatter create proxy < $cl; done
for cl in apis/$API_NAME/mesh/rules/*.json; do greymatter create shared_rules < $cl; done
for cl in apis/$API_NAME/mesh/routes/*.json; do greymatter create route < $cl; done