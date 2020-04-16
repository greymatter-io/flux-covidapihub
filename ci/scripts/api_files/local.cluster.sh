#!/bin/bash

API_NAME=$1
API_ADDRESS=$2

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "cluster_key": "$API_NAME.local.cluster",
    "name": "local",
    "instances": [
        {
            "host": "$API_ADDRESS",
            "port": 443
        }
    ],
    "circuit_breakers": null,
    "outlier_detection": null,
    "health_checks": [],
    "require_tls": true
}
EOF
