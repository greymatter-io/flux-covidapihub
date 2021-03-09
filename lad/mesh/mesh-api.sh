#!/bin/bash

greymatter version

if [[ "$(kubectl config current-context)" = arn:aws:eks:*  ]]; then
    echo "🍀🍀🍀🍀🍀 Just so you know, you are changing production 🍀🍀🍀🍀🍀"
fi

listener=$(lsof -t -i:10080)
if [ ! -z "$listener" ]; then
    echo "Killing a process (pid $listener) using port 10080"
    kill $listener
fi

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

kubectl port-forward api-0 -n fabric 10080:10080 &
sleep 15

delay=0.01

objects="domains clusters listeners proxies rules routes"

for folder in $objects; do
    echo "Found folder: $folder"
    for file in $folder/*; do
        object="${folder%?}"
        if [[ $object == "proxie" ]]; then object="proxy"; fi
        if [[ $object == "rule" ]]; then object="shared_rules"; fi

        echo "applying $file"
        create_or_update $object $file
        sleep $delay

    done
done

