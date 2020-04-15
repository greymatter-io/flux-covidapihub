#!/bin/bash

API_NAME=$1

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "domain_key": "edge.ingress.domain",
    "route_key": "edge.$API_NAME.slash.route",
    "path": "/apis/$API_NAME",
    "prefix_rewrite": "/apis/$API_NAME/",
    "redirects": null,
    "shared_rules_key": "edge.$API_NAME.rules",
    "rules": null,
    "response_data": {},
    "cohort_seed": null,
    "retry_policy": null
}
EOF