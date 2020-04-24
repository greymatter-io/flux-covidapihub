#!/bin/bash

NAME=$1
HOST=$2
PORT=$3

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "cluster_key": "$NAME.local.cluster",
    "name": "local",
    "instances": [
        {
            "host": "$HOST",
            "port": $PORT
        }
    ],
    "circuit_breakers": null,
    "outlier_detection": null,
    "health_checks": []
}
EOF
