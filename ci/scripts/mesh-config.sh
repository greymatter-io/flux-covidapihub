#!/bin/bash

greymatter version

source ./ci/scripts/mesh-env.sh
kubectl cluster-info
listener=$(lsof -t -i:10080)

if [ ! -z "$listener" ]; then
    echo "Killing a process (pid $listener) using port 10080"
    kill $listener
fi

kubectl -n fabric wait --for=condition=Ready pod/api-0  --timeout=300s

kubectl port-forward api-0 -n fabric 10080:10080 &
sleep 10

echo "Starting mesh configuration ..."

echo "Creating service configuration objects..."

# Create or update takes an object type and an optional filename
create_or_update() {
    file=$2
    # If file is null, set to objecttype.json, eg route.json
    if [ -z "$file" ]; then
        file=$1.json
    fi

    echo "Creating object with $file"
    resp=$(greymatter create $1 <$file)
    echo "$resp"
    # If response from the api is null, try editing the object
    if [ -z "$resp" ]; then
        echo "Object already exists! Editing $file"
        greymatter edit $1 _ <$file
    fi

    echo "----------"
}

delay=0.01
objects="domains clusters listeners proxies rules routes"
meshfolders=(mesh/edge mesh/data/data mesh/data/jwt mesh/sense/catalog mesh/sense/dashboard mesh/sense/objectives mesh/sense/prometheus mesh/kibana mesh/website)
for meshfolder in "${meshfolders[@]}"
do
    cd $meshfolder
    for folder in $objects
    do
        echo "Found folder: $meshfolder/$folder"
        for file in $folder/*
        do
            object="${folder%?}"
            if [[ $object == "proxie" ]]; then object="proxy"; fi
            if [[ $object == "rule" ]]; then object="shared_rules"; fi
            echo "applying $file"
            create_or_update $object $file
            sleep $delay
        done
    done
    cd -
done

# Overwrite
create_or_update listener ci/resources/mesh.edge.listener.ingress.json
