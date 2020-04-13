#!/bin/bash

export GREYMATTER_API_HOST='localhost:10080'
export GREYMATTER_API_SSL='false'
export GREYMATTER_API_INSECURE='true'
export GREYMATTER_API_SSLCERT=''
export GREYMATTER_API_SSLKEY=''
export GREYMATTER_CONTROL_PREFIX=''
export GREYMATTER_API_PREFIX=''

kubectl port-forward api-0 -n fabric 10080:10080 &

sleep 5
