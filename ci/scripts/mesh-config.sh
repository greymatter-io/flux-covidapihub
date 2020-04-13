#!/bin/bash

greymatter version

sh ./ci/scripts/mesh-env.sh

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
meshfolders=(mesh/private mesh/public mesh/kibana mesh/website mesh/data/data mesh/data/jwt mesh/sense/catalog mesh/sense/dashboard mesh/sense/objectives mesh/sense/promtheus) 
for meshfolder in "${meshfolders[@]}"
do
    cd $meshfolder
    for folder in $objects
    do
	echo "Found folder: $folder"
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
done


