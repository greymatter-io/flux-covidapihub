#!/bin/bash

API_NAME=$1
API_ADDRESS=$2

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "domain_key": "$API_NAME.apis.domain",
    "name": "*",
    "port": 8443,
    "gzip_enabled": false,
    "cors_config": null,
    "aliases": null,
    "force_https": true,
    "redirects": [
        {
          "name": "redirect-to-$API_NAME",
          "from": "/",
          "to": "$API_ADDRESS",
          "redirect_type": "temporary",
          "header_constraints": null
        }
      ]
}
EOF