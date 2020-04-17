#!/bin/bash

export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"
export GREYMATTER_API_HOST='localhost:10080'
export GREYMATTER_API_SSL='false'
export GREYMATTER_API_INSECURE='true'
export GREYMATTER_API_SSLCERT=''
export GREYMATTER_API_SSLKEY=''
export GREYMATTER_CONTROL_PREFIX=''
export GREYMATTER_API_PREFIX=''
