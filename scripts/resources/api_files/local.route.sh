#!/bin/bash

NAME=$1
ROUTE_PATH=$2

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "domain_key": "$NAME.apis.domain",
    "route_key": "$NAME.local.route",
    "path": "/",
    "prefix_rewrite": "$ROUTE_PATH",
    "redirects": null,
    "shared_rules_key": "$NAME.local.rules",
    "rules": null,
    "response_data": {},
    "cohort_seed": null,
    "retry_policy": null
}
EOF
