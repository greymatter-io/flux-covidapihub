#!/bin/bash

API_NAME=$1

#define the template.
cat  << EOF
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: $API_NAME-sidecar
  namespace: apis
data:
  config.yaml: |-
    node:
      id: "default"
      cluster: "apis.$API_NAME"
      locality:
        zone: default.zone
        region: default.region
    dynamic_resources:
      ads_config:
        api_type: GRPC
        grpc_services:
          envoy_grpc:
            cluster_name: xds_cluster
      cds_config:
        ads: {}
      lds_config:
        ads: {}
    static_resources:
      clusters:
        - name: xds_cluster
          connect_timeout: 0.25s
          http2_protocol_options: {}
          type: STRICT_DNS
          lb_policy: ROUND_ROBIN
          load_assignment:
            cluster_name: xds_cluster
            endpoints:
              - lb_endpoints:
                - endpoint:
                    address:
                      socket_address:
                        address: control.fabric.svc.cluster.local
                        port_value: 8443
          tls_context:
            common_tls_context:
              tls_certificate_sds_secret_configs:
                - name: "spiffe://covidapihub.io/ns/apis/sa/apis-sa"
                  sds_config:
                    api_config_source:
                      api_type: GRPC
                      grpc_services:
                        envoy_grpc:
                          cluster_name: spire_agent
              tls_params:
                ecdh_curves:
                  - X25519:P-256:P-521:P-384
              combined_validation_context:
                default_validation_context:
                  verify_subject_alt_name:
                    - "spiffe://covidapihub.io/ns/fabric/sa/control"
                validation_context_sds_secret_config:
                  name: "spiffe://covidapihub.io"
                  sds_config:
                    api_config_source:
                      api_type: GRPC
                      grpc_services:
                        envoy_grpc:
                          cluster_name: spire_agent
        - name: spire_agent
          connect_timeout: 0.25s
          http2_protocol_options: {}
          type: STATIC
          lb_policy: ROUND_ROBIN
          load_assignment:
            cluster_name: spire_agent
            endpoints:
              - lb_endpoints:
                - endpoint:
                    address:
                      pipe:
                        path: /run/spire/sockets/agent.sock
    admin:
      access_log_path: /dev/stdout
      address:
        socket_address:
          address: 127.0.0.1
          port_value: 8001
EOF