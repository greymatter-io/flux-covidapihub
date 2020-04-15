#!/bin/bash

API_NAME=$1

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "proxy_key": "$API_NAME.proxy",
    "domain_keys": [
        "$API_NAME.apis.domain"
    ],
    "listener_keys": [
        "$API_NAME.apis.listener"
    ],
    "name": "apis.$API_NAME",
    "listeners": null
}
EOF