#!/bin/bash

NAME=$1
HOST=$2

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "domain_key": "$NAME.apis.domain",
    "name": "*",
    "port": 8443,
    "gzip_enabled": false,
    "cors_config": null,
    "aliases": null,
    "force_https": true,
    "custom_headers": [
      {
        "key": "Host",
        "value": "$HOST"
      }
  ]
}
EOF