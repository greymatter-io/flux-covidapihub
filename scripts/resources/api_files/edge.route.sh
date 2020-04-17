#!/bin/bash

NAME=$1

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "domain_key": "edge.ingress.domain",
    "route_key": "edge.$NAME.route",
    "path": "/apis/$NAME/",
    "prefix_rewrite": "/",
    "redirects": null,
    "shared_rules_key": "edge.$NAME.rules",
    "rules": null,
    "response_data": {},
    "cohort_seed": null,
    "retry_policy": null
}
EOF