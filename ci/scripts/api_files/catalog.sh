#!/bin/bash

NAME=$1

#define the template.
cat  << EOF
{
 "clusterName": "$NAME",
 "zoneName": "default.zone",
 "name": "$NAME",
 "version": "1.0",
 "owner": "Decipher",
 "capability": "API",
 "runtime": "GO",
 "documentation": "/apis/$NAME/",
 "prometheusJob": "$NAME",
 "minInstances": 1,
 "maxInstances": 2,
 "authorized": true,
 "enableInstanceMetrics": true,
 "enableHistoricalMetrics": true,
 "metricsPort": 8080
 }
EOF