#!/bin/bash

echo API Name:
read api_name
echo API Address:
read api_addr


mkdir apis/$api_name
mkdir apis/$api_name/mesh
ci/scripts/api_files/deployment.sh $api_name > apis/$api_name/$api_name.deployment.yaml
ci/scripts/api_files/sidecar_configmap.sh $api_name > apis/$api_name/$api_name.sidecar.configmap.yaml
ci/scripts/api_files/domain.sh $api_name $api_addr > apis/$api_name/mesh/$api_name.domain.ingress.json
ci/scripts/api_files/listener.sh $api_name > apis/$api_name/mesh/$api_name.listener.ingress.json
ci/scripts/api_files/proxy.sh $api_name > apis/$api_name/mesh/$api_name.proxy.json
ci/scripts/api_files/edge.cluster.sh $api_name > apis/$api_name/mesh/edge.$api_name.cluster.json
ci/scripts/api_files/edge.rules.sh $api_name > apis/$api_name/mesh/edge.$api_name.rules.json
ci/scripts/api_files/edge.route.sh $api_name > apis/$api_name/mesh/edge.$api_name.route.json
ci/scripts/api_files/edge.route.slash.sh $api_name > apis/$api_name/mesh/edge.$api_name.route.slash.json
ci/scripts/api_files/catalog.sh $api_name > apis/$api_name/mesh/catalog.$api_name.json