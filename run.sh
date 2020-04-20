#!/bin/bash

export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"
make k3d mesh