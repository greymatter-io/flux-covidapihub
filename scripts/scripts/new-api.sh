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
echo Capability:
read capability


mkdir apis/$name
mkdir apis/$name/mesh
mkdir apis/$name/mesh/clusters
mkdir apis/$name/mesh/domains
mkdir apis/$name/mesh/listeners
mkdir apis/$name/mesh/routes
mkdir apis/$name/mesh/proxies
mkdir apis/$name/mesh/rules
scripts/resources/api_files/deployment.sh $name > apis/$name/$name.deployment.yaml
scripts/resources/api_files/sidecar_configmap.sh $name > apis/$name/$name.sidecar.configmap.yaml
scripts/resources/api_files/domain.sh $name $host > apis/$name/mesh/domains/$name.domain.ingress.json
scripts/resources/api_files/listener.sh $name > apis/$name/mesh/listeners/$name.listener.ingress.json
scripts/resources/api_files/proxy.sh $name > apis/$name/mesh/proxies/$name.proxy.json
scripts/resources/api_files/edge.cluster.sh $name > apis/$name/mesh/clusters/edge.$name.cluster.json
scripts/resources/api_files/local.cluster.sh $name $host $port > apis/$name/mesh/clusters/local.cluster.json
scripts/resources/api_files/edge.rules.sh $name > apis/$name/mesh/rules/edge.$name.rules.json
scripts/resources/api_files/local.rules.sh $name > apis/$name/mesh/rules/local.rules.json
scripts/resources/api_files/edge.route.sh $name > apis/$name/mesh/routes/edge.$name.route.json
scripts/resources/api_files/local.route.sh $name $route_path > apis/$name/mesh/routes/local.route.json
scripts/resources/api_files/edge.route.slash.sh $name > apis/$name/mesh/routes/edge.$name.route.slash.json
scripts/resources/api_files/catalog.sh $name "$display_name" "$owner" "$capability" > apis/$name/mesh/catalog.$name.json

read -r -p "Apply the configs now? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    scripts/scripts/apply-new-api.sh $name
fi