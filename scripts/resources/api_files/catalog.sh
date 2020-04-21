#!/bin/bash

NAME=$1
DISPLAY=$2
OWNER=$3
CAPABILITY=$4
DOCS=$5

#define the template.
cat  << EOF
{
 "clusterName": "apis.$NAME",
 "zoneName": "default.zone",
 "name": "$DISPLAY",
 "version": "1.0",
 "owner": "$OWNER",
 "capability": "$CAPABILITY",
 "runtime": "GO",
 "documentation": "$DOCS",
 "prometheusJob": "apis.$NAME",
 "minInstances": 1,
 "maxInstances": 2,
 "authorized": true,
 "enableInstanceMetrics": true,
 "enableHistoricalMetrics": true,
 "metricsPort": 8080
 }
EOF