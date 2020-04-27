#!/bin/bash

# Check if there's already a greymatter cluster, if so delete it
if [[ "$(k3d list 2>/dev/null)" == *"greymatter"* ]]; then
    k3d delete --name greymatter
fi