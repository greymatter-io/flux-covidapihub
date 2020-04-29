#!/bin/bash

echo API Name:
read name
echo Host:
read host
echo Port:
read port
echo Path:
read route_path
echo Display Name:
read display_name
echo Owner:
read owner
echo "Capability (health, governance, etc.)":
read content_type
echo Docs link:
read docs

echo Description:
read description
echo "Updates (ex. Daily, Monthly, 5 Minutes)":
read updates
echo "Coverage (ex. US)":
read coverage
echo "Format (JSON, CSV, etc.)":
read format

if [[ $format == "" ]]; then
    format="JSON"
fi

# convert sort and group-by fields to lowercase
route_path=$(perl -e "print lc('$route_path');")
content_type=$(perl -e "print lc('$content_type');")
content_type="$(tr '[:lower:]' '[:upper:]' <<<${content_type:0:1})${content_type:1}"

capability=\"\\\"{\\\\\\\"name\\\\\\\":\\\\\\\"$display_name\\\\\\\",\\\\\\\"url\\\\\\\":\\\\\\\"$https://${host}${route_path}\\\\\\\",\\\\\\\"description\\\\\\\":\\\\\\\"${description}\\\\\\\",\\\\\\\"source\\\\\\\":\\\\\\\"$owner\\\\\\\",\\\\\\\"contentType\\\\\\\":[\\\\\\\"$content_type\\\\\\\"],\\\\\\\"homePage\\\\\\\":\\\\\\\"$docs\\\\\\\",\\\\\\\"thumbnail\\\\\\\":\\\\\\\"$thumbnail\\\\\\\",\\\\\\\"coverage\\\\\\\":[\\\\\\\"$coverage\\\\\\\"],\\\\\\\"format\\\\\\\":[\\\\\\\"$format\\\\\\\"],\\\\\\\"updates\\\\\\\":[\\\\\\\"$updates\\\\\\\"]}\\\"\"

mkdir apis/$name
mkdir apis/$name/mesh
mkdir apis/$name/mesh/clusters
mkdir apis/$name/mesh/domains
mkdir apis/$name/mesh/listeners
mkdir apis/$name/mesh/routes
mkdir apis/$name/mesh/proxies
mkdir apis/$name/mesh/rules
scripts/resources/api_files/deployment.sh $name >apis/$name/$name.deployment.yaml
scripts/resources/api_files/sidecar_configmap.sh $name >apis/$name/$name.sidecar.configmap.yaml
scripts/resources/api_files/domain.sh $name $host >apis/$name/mesh/domains/$name.domain.ingress.json
scripts/resources/api_files/listener.sh $name >apis/$name/mesh/listeners/$name.listener.ingress.json
scripts/resources/api_files/proxy.sh $name >apis/$name/mesh/proxies/$name.proxy.json
scripts/resources/api_files/edge.cluster.sh $name >apis/$name/mesh/clusters/edge.$name.cluster.json
scripts/resources/api_files/local.cluster.sh $name $host $port >apis/$name/mesh/clusters/local.cluster.json
scripts/resources/api_files/edge.rules.sh $name >apis/$name/mesh/rules/edge.$name.rules.json
scripts/resources/api_files/local.rules.sh $name >apis/$name/mesh/rules/local.rules.json
scripts/resources/api_files/edge.route.sh $name >apis/$name/mesh/routes/edge.$name.route.json
scripts/resources/api_files/local.route.sh $name $route_path >apis/$name/mesh/routes/local.route.json
scripts/resources/api_files/edge.route.slash.sh $name >apis/$name/mesh/routes/edge.$name.route.slash.json
scripts/resources/api_files/catalog.sh $name "$display_name" "$owner" "$capability" "$docs" >apis/$name/mesh/catalog.$name.json

echo ""
echo "Generating Catalog envvars, checking covidapihub for number of services"
count=$(curl -k https://covidapihub.io/catalog/latest/zones/default.zone | jq .clusterCount)
count=$((count + 1))
echo "The current service count is: $count, incrementing by 1"
count=$((count + 1))
scripts/resources/catalog.envvars.sh $name "$display_name" "$owner" "$capability" "$docs" "$count" >apis/$name/mesh/catalog.envvars.yaml
echo ""
echo "Copy the following envvars (theyre also stored in apis/$name/mesh/catalog.envvars.yaml) and paste them into the catalog container env"
echo ""
cat apis/$name/mesh/catalog.envvars.yaml
echo ""

read -r -p "Apply the configs now? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    read -r -p "Apply to prod? [y/N] " prod
    if [[ "$prod" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        scripts/scripts/apply-new-api.sh "N" $name
    else
        scripts/scripts/apply-new-api.sh "Y" $name
    fi
fi
