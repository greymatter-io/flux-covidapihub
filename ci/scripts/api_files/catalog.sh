#!/bin/bash

API_NAME=$1

#define the template.
cat  << EOF
{
 "clusterName": "$API_NAME",
 "zoneName": "default.zone",
 "name": "$API_NAME",
 "version": "1.0",
 "owner": "Decipher",
 "capability": "API",
 "runtime": "GO",
 "documentation": "/apis/$API_NAME/",
 "prometheusJob": "$API_NAME",
 "minInstances": 1,
 "maxInstances": 2,
 "authorized": true,
 "enableInstanceMetrics": true,
 "enableHistoricalMetrics": true,
 "metricsPort": 8080
 }
EOF