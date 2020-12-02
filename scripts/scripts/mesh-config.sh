#!/bin/bash
ENV=$1

greymatter version

source ./scripts/scripts/mesh-env.sh

# if [[ $ENV == "k3d" && "$(kubectl config current-context)" != "greymatter" ]]; then
#     echo "⛔️⛔️⛔️⛔️⛔ You are about to apply mesh configs to non-k3d environment ⛔️⛔️⛔️⛔️⛔️"
#     exit 1
# fi

# if [[ $ENV == "prod" && "$(kubectl config current-context)" = arn:aws:eks:* ]]; then
#     echo "🍀🍀🍀🍀🍀 Just so you know, you are changing production 🍀🍀🍀🍀🍀"
#     source ./scripts/scripts/credentials.sh
#     if [ -z "$ClientId" ] || [ -z "$ClientSecret" ]; then
#         echo "⛔️ You do not have OIDC client ID and secret set in your credentials.sh"
#         exit 1
#     fi
# fi

listener=$(lsof -t -i:10080)
if [ ! -z "$listener" ]; then
    echo "Killing a process (pid $listener) using port 10080"
    kill $listener
fi

echo "Waiting for Control API to start... ⏱"
kubectl -n fabric wait --for=condition=Ready pod/api-0 --timeout=300s

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
meshfolders=(mesh/fabric/control-api)
for meshfolder in "${meshfolders[@]}"; do
    cd $meshfolder
    for folder in $objects; do
        echo "Found folder: $meshfolder/$folder"
        for file in $folder/*; do
            object="${folder%?}"
            if [[ $object == "proxie" ]]; then object="proxy"; fi
            if [[ $object == "rule" ]]; then object="shared_rules"; fi
            if [[ $object == "listener" && $ENV == "k3d" ]]; then
                value=$(<$file)
                value=$(jq '.http_filters.gm_observables.useKafka = false' <<<"$value")
                echo "$value" >/tmp/listener.json
                create_or_update listener /tmp/listener.json
                sleep $delay
            else
                echo "applying $file"
                create_or_update $object $file
                sleep $delay
            fi
        done
    done
    cd -
done

# Overwrite
if [[ $ENV == "k3d" ]]; then
    create_or_update domain scripts/resources/mesh.edge.domains.login.json
    create_or_update listener scripts/resources/mesh.edge.listener.login.json
    create_or_update listener scripts/resources/mesh.edge.listener.ingress.json

fi

# if [[ $ENV == "prod" ]]; then
# cp mesh/edge/listeners/login.json /tmp/login.json
# sed -i '' "s/CLIENT_ID_REDACTED/${ClientId}/g" /tmp/login.json
# sed -i '' "s/CLIENT_SECRET_REDACTED/${ClientSecret}/g" /tmp/login.json
# create_or_update listener /tmp/login.json
# fi
