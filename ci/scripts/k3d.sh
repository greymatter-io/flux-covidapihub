#!/bin/bash

# install k3d 1.7.0
curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | TAG=v1.7.0 bash

# Check if there's already a greymatter cluster, if so delete it
if [[ "$(k3d list)" == *"greymatter"* ]]
then
    k3d delete --name greymatter
fi

# Create 4 workers for a greymatter cluster
k3d create --workers 4 --name greymatter --publish 30000:10808
while [[ $(k3d get-kubeconfig --name='greymatter') != *kubeconfig.yaml ]]; do echo "echo waiting for k3d cluster to start up" && sleep 10; done

export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"

echo "Cluster is connected"

# Apply kubernetes yaml files in order
kubectl apply -f kubeseal/namespace.yaml
find kubeseal/*.yaml ! -name "kubeseal/namespace.yaml" -exec kubectl apply -f {} \;

kubectl apply -f spire/namespace.yaml
find spire/*.yaml ! -name "spire/namespace.yaml" -exec kubectl apply -f {} \;

kubectl apply -f fabric/namespace.yaml
find fabric/*.yaml ! -name "fabic/namespace.yaml" -exec kubectl apply -f {} \;

kubectl apply -f sense/namespace.yaml
find sense/*.yaml ! -name "sense/namespace.yaml" -exec kubectl apply -f {} \;

kubectl apply -f data/namespace.yaml
find data/*.yaml ! -name "data/namespace.yaml" -exec kubectl apply -f {} \;

echo "files applied"






