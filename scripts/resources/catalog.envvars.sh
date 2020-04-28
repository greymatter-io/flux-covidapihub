#!/bin/bash

NAME=$1
DISPLAY=$2
OWNER=$3
CAPABILITY=$4
DOCS=$5
NUMBER=$6

#define the template.
cat  << EOF
            - name: SERVICE_${NUMBER}_CLUSTER_NAME
              value: apis.$NAME
            - name: SERVICE_${NUMBER}_ZONE_NAME
              value: default.zone
            - name: SERVICE_${NUMBER}_NAME
              value: $DISPLAY
            - name: SERVICE_${NUMBER}_OWNER
              value: $OWNER
            - name: SERVICE_${NUMBER}_RUNTIME
              value: "Node"
            - name: SERVICE_${NUMBER}_DOCUMENTATION
              value: "$DOCS"
            - name: SERVICE_${NUMBER}_VERSION
              value: "latest"
            - name: SERVICE_${NUMBER}_CAPABILITY
              value: $CAPABILITY
            - name: SERVICE_${NUMBER}_PROMETHEUS_JOB
              value: apis.$NAME
            - name: SERVICE_${NUMBER}_MAX_INSTANCES
              value: "2"
            - name: SERVICE_${NUMBER}_MIN_INSTANCES
              value: "1"
            - name: SERVICE_${NUMBER}_ENABLE_INSTANCE_METRICS
              value: "true"
            - name: SERVICE_${NUMBER}_ENABLE_HISTORICAL_METRICS
              value: "true"
            - name: SERVICE_${NUMBER}_METRICS_TEMPLATE
              value: ""
            - name: SERVICE_${NUMBER}_METRICS_PORT
              value: "8080"
EOF