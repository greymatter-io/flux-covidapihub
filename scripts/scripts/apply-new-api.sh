#!/bin/bash

DEV=$1
API_NAME=$2

if [ "$API_NAME" == "" ]; then
    echo API Name
    read API_NAME
fi

source ./scripts/scripts/mesh-env.sh

if [[ "$DEV" =~ ^([yY])$ ]]; then
    source ./scripts/scripts/kubeconfig-k3d.sh
    find apis/*.yaml ! -name "namespace.yaml" ! -name "*secret.yaml" ! -name "registrar.validatingwebhookconfiguration.yaml" -exec kubectl apply -f {} \;
else
    source ./scripts/scripts/kubeconfig-aws.sh
fi


echo "Applying new api: $API_NAME"

if [[ "$DEV" =~ ^([yY])$ ]]; then
    kubectl apply -f apis/$API_NAME
fi

echo "Applying mesh config for api: $API_NAME"

greymatter version

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

echo "Creating (or updating) service configuration objects..."

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


for cl in apis/$API_NAME/mesh/clusters/*.json; do create_or_update cluster $cl; done
for cl in apis/$API_NAME/mesh/domains/*.json; do create_or_update domain $cl; done

if [[ "$DEV" =~ ^([yY])$ ]]; then
    for cl in apis/$API_NAME/mesh/listeners/*.json; do
        value=$(<$cl)
        value=$(jq '.http_filters.gm_observables.useKafka = false' <<<"$value")
        echo "$value" > /tmp/listener.json
        create_or_update listener /tmp/listener.json
    done
else
    for cl in apis/$API_NAME/mesh/listeners/*.json; do create_or_update listener $cl; done
fi

for cl in apis/$API_NAME/mesh/proxies/*.json; do create_or_update proxy $cl; done
for cl in apis/$API_NAME/mesh/rules/*.json; do create_or_update shared_rules $cl; done
for cl in apis/$API_NAME/mesh/routes/*.json; do create_or_update route $cl; done