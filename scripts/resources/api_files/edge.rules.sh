#!/bin/bash

NAME=$1

#define the template.
cat <<EOF
{
    "zone_key": "default.zone",
    "shared_rules_key": "edge.$NAME.rules",
    "name": "edge.$NAME",
    "default": {
        "light": [
            {
                "constraint_key": "",
                "cluster_key": "edge.$NAME.cluster",
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
    "properties": null
}
EOF
