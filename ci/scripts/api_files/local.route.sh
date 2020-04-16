#!/bin/bash

API_NAME=$1

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "domain_key": "$API_NAME.apis.domain",
    "route_key": "$API_NAME.local.route",
    "path": "/",
    "prefix_rewrite": "/covid",
    "redirects": null,
    "shared_rules_key": "$API_NAME.local.rules",
    "rules": null,
    "response_data": {},
    "cohort_seed": null,
    "retry_policy": null
}

EOF