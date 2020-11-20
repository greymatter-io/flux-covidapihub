#!/bin/bash

NAME=$1

#define the template.
cat <<EOF
{
    "zone_key": "default.zone",
    "listener_key": "$NAME.apis.listener",
    "domain_keys": [
        "$NAME.apis.domain"
    ],
    "name": "ingress",
    "ip": "0.0.0.0",
    "port": 8443,
    "protocol": "http_auto",
    "secret": {
        "secret_key": "apis.identity",
        "secret_name": "spiffe://covidapihub.io/ns/apis/sa/apis-sa",
        "secret_validation_name": "spiffe://covidapihub.io",
        "subject_names": [
            "spiffe://covidapihub.io/ns/edge/sa/edge"
        ],
        "ecdh_curves": [
            "X25519:P-256:P-521:P-384"
        ]
    },
    "active_http_filters": [
        "gm.metrics",
        "gm.observables"
    ],
    "http_filters": {
        "gm_metrics": {
            "metrics_port": 8080,
            "metrics_host": "0.0.0.0",
            "metrics_dashboard_uri_path": "/metrics",
            "metrics_prometheus_uri_path": "/prometheus",
            "metrics_ring_buffer_size": 4096,
            "prometheus_system_metrics_interval_seconds": 15,
            "metrics_key_function": "depth",
            "metrics_key_depth": "3"
        },
        "gm_observables": {
            "topic": "apis.$NAME",
            "eventTopic": "observables",
            "useKafka": true,
            "kafkaServerConnection": "b-1.covidapihub-msk.6s1o6w.c9.kafka.us-east-1.amazonaws.com:9094,b-2.covidapihub-msk.6s1o6w.c9.kafka.us-east-1.amazonaws.com:9094",
            "useKafkaTLS": true
        }
    },
    "tracing_config": null
}
EOF
