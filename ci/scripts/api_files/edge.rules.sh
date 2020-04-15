#!/bin/bash

API_NAME=$1

#define the template.
cat  << EOF
{
    "zone_key": "default.zone",
    "shared_rules_key": "edge.$API_NAME.rules",
    "name": "edge.$API_NAME",
    "default": {
        "light": [
            {
                "constraint_key": "",
                "cluster_key": "edge.$API_NAME.cluster",
                "metadata": null,
                "properties": null,
                "response_data": {},
                "weight": 1
            }
        ],
        "dark": null,
        "tap": null
    },
    "rules": null,
    "response_data": {},
    "cohort_seed": null,
    "properties": null,
    "retry_policy": null
}
EOF