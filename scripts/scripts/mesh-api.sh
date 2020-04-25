#!/bin/bash
ENV=$1

greymatter version

source ./scripts/scripts/mesh-env.sh

if [[ $ENV == "k3d" && "$(kubectl config current-context)" != "greymatter" ]]; then
    echo "⛔️⛔️⛔️⛔️⛔ You are about to apply mesh configs to non-k3d environment ⛔️⛔️⛔️⛔️⛔️"
    exit 1
fi

if [[ $ENV == "prod" && "$(kubectl config current-context)" = arn:aws:eks:*  ]]; then
    echo "🍀🍀🍀🍀🍀 Just so you know, you are changing production 🍀🍀🍀🍀🍀"
fi

listener=$(lsof -t -i:10081)
if [ ! -z "$listener" ]; then
    echo "Killing a process (pid $listener) using port 10081"
    kill $listener
fi

kubectl port-forward deployment/catalog -n sense 10081:10080 &
sleep 15

for meshfolder in apis/*; do
    if [ -d "$meshfolder" ]; then
        for folder in $objects; do
            echo "Found folder: $meshfolder/mesh/$folder"
            for file in $meshfolder/mesh/$folder/*; do
                object="${folder%?}"
                if [[ $object == "proxie" ]]; then object="proxy"; fi
                if [[ $object == "rule" ]]; then object="shared_rules"; fi
                if [[ $object == "listener" && "$ENV" == "k3d" ]]; then
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
        curl -XPOST http://localhost:10081/clusters -d "@$meshfolder/mesh/catalog.${meshfolder##*/}.json"
    fi
done
