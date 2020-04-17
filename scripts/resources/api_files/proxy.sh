#!/bin/bash

NAME=$1

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "proxy_key": "$NAME.proxy",
    "domain_keys": [
        "$NAME.apis.domain"
    ],
    "listener_keys": [
        "$NAME.apis.listener"
    ],
    "name": "apis.$NAME",
    "listeners": null
}
EOF