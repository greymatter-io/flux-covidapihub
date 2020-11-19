#!/bin/bash

set -e

namespaces=$(kubectl get ns | grep -v NAME | awk '{print $1}')

list_resources () {
    local ns=$1
    local resource=$2
    local resources=$(kubectl get $resource -n $ns 2> /dev/null | grep -v NAME | awk '{print $1}')
    echo "-------------------------"
    echo "RESOURCE: $resource"
    echo ""
    echo $resources | awk '{    
        if ($0 ~/^$/) {
            print "No resources"
        } else {
            gsub(" ", "\n")
            print $0
        }
    }'
}

# analyze namespaces

for ns in $namespaces
do
    echo ""
    echo "========================="
    echo "NAMESPACE: $ns"
    echo ""

    list_resources $ns deployment 
    # list_resources $ns svc 
    # list_resources $ns pvc
    list_resources $ns sts 
    # list_resources $ns role
    # list_resources $ns clusterrolebinding
    # list_resources $ns sa
    # list_resources $ns ingress
    # list_resources $ns cm 
    # list_resources $ns sealedsecret
    # list_resources $ns secret 
done
