#!/bin/bash

API_NAME=$1

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "cluster_key": "edge.$API_NAME.cluster",
    "name": "apis.$API_NAME",
    "instances": [],
    "circuit_breakers": null,
    "outlier_detection": null,
    "health_checks": [],
    "require_tls": true,
    "secret": {
        "secret_key": "edge.identity",
        "secret_name": "spiffe://covidapihub.io/ns/edge/sa/edge",
        "secret_validation_name": "spiffe://covidapihub.io",
        "subject_names": [
            "spiffe://covidapihub.io/ns/apis/sa/apis-sa"
        ],
        "ecdh_curves": [
            "X25519:P-256:P-521:P-384"
        ]
    }
}
EOF