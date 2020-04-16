#!/bin/bash

echo API Name:
read name
echo Host:
read host
echo Port:
read port
echo Path:
read route_path
echo Apply API?:
read apply


mkdir apis/$name
mkdir apis/$name/mesh
mkdir apis/$name/mesh/clusters
mkdir apis/$name/mesh/domains
mkdir apis/$name/mesh/listeners
mkdir apis/$name/mesh/routes
mkdir apis/$name/mesh/proxies
mkdir apis/$name/mesh/rules
ci/scripts/api_files/deployment.sh $name > apis/$name/$name.deployment.yaml
ci/scripts/api_files/sidecar_configmap.sh $name > apis/$name/$name.sidecar.configmap.yaml
ci/scripts/api_files/domain.sh $name $host > apis/$name/mesh/domains/$name.domain.ingress.json
ci/scripts/api_files/listener.sh $name > apis/$name/mesh/listeners/$name.listener.ingress.json
ci/scripts/api_files/proxy.sh $name > apis/$name/mesh/proxies/$name.proxy.json
ci/scripts/api_files/edge.cluster.sh $name > apis/$name/mesh/clusters/edge.$name.cluster.json
ci/scripts/api_files/local.cluster.sh $name $host $port > apis/$name/mesh/clusters/local.cluster.json
ci/scripts/api_files/edge.rules.sh $name > apis/$name/mesh/rules/edge.$name.rules.json
ci/scripts/api_files/local.rules.sh $name > apis/$name/mesh/rules/local.rules.json
ci/scripts/api_files/edge.route.sh $name > apis/$name/mesh/routes/edge.$name.route.json
ci/scripts/api_files/local.route.sh $name $route_path > apis/$name/mesh/routes/local.route.json
ci/scripts/api_files/edge.route.slash.sh $name > apis/$name/mesh/routes/edge.$name.route.slash.json
ci/scripts/api_files/catalog.sh $name > apis/$name/mesh/catalog.$name.json

if [[ "$apply" == "True" ]]; then
    ci/scripts/apply-new-api.sh $name
fi