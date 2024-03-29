#!/bin/bash

if [[ "$(kubectl config current-context)" != "greymatter" ]]; then
    echo "⛔️⛔️⛔️⛔️⛔ You are about to apply yaml file to non-k3d environment ⛔️⛔️⛔️⛔️⛔️"
    exit 1
fi

 find apis/*.yaml ! -name "namespace.yaml" ! -name "*secret.yaml" ! -name "registrar.validatingwebhookconfiguration.yaml" -exec kubectl apply -f {} \;


for folder in apis/*; do
    if [ -d "$folder" ]; then
        echo "================================== $folder"
        find $folder/*.yaml -exec kubectl apply -f {} \;
    fi
done

echo ""
echo "apis applied"
echo ""
