#!/bin/bash
export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"
kubectl config use-context greymatter
kubectl config current-context