#!/bin/bash

echo API Name:
read api_name
echo API Address:
read api_addr


mkdir apis/$api_name
mkdir apis/$api_name/mesh
mkdir apis/$api_name/mesh/clusters
mkdir apis/$api_name/mesh/domains
mkdir apis/$api_name/mesh/listeners
mkdir apis/$api_name/mesh/routes
mkdir apis/$api_name/mesh/proxies
mkdir apis/$api_name/mesh/rules
ci/scripts/api_files/deployment.sh $api_name > apis/$api_name/$api_name.deployment.yaml
ci/scripts/api_files/sidecar_configmap.sh $api_name > apis/$api_name/$api_name.sidecar.configmap.yaml
ci/scripts/api_files/domain.sh $api_name $api_addr > apis/$api_name/mesh/domains/$api_name.domain.ingress.json
ci/scripts/api_files/listener.sh $api_name > apis/$api_name/mesh/listeners/$api_name.listener.ingress.json
ci/scripts/api_files/proxy.sh $api_name > apis/$api_name/mesh/proxies/$api_name.proxy.json
ci/scripts/api_files/edge.cluster.sh $api_name > apis/$api_name/mesh/clusters/edge.$api_name.cluster.json
ci/scripts/api_files/edge.rules.sh $api_name > apis/$api_name/mesh/rules/edge.$api_name.rules.json
ci/scripts/api_files/edge.route.sh $api_name > apis/$api_name/mesh/routes/edge.$api_name.route.json
ci/scripts/api_files/edge.route.slash.sh $api_name > apis/$api_name/mesh/routes/edge.$api_name.route.slash.json
ci/scripts/api_files/catalog.sh $api_name > apis/$api_name/mesh/catalog.$api_name.json