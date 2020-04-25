#!/bin/bash

echo API Name:
read name
echo URL:
read csv_url


fmt="${csv_url##*.}"
if [[ "$fmt" =~ ^(xls|xlsx|xlsm|xlsb|odf)$ ]]; then
    echo "Sheet Name: "
    read sheet_name
fi

echo Display Name:
read display_name
echo Owner:
read owner
echo Capability:
read capability
echo Docs link:
read docs

# convert sort and group-by fields to lowercase
capability=$(perl -e "print lc('$capability');")

mkdir apis/$name
mkdir apis/$name/mesh
mkdir apis/$name/mesh/clusters
mkdir apis/$name/mesh/domains
mkdir apis/$name/mesh/listeners
mkdir apis/$name/mesh/routes
mkdir apis/$name/mesh/proxies
mkdir apis/$name/mesh/rules
scripts/resources/api_files/csv.deployment.sh $name $csv_url $sheet_name >apis/$name/$name.deployment.yaml
scripts/resources/api_files/sidecar_configmap.sh $name >apis/$name/$name.sidecar.configmap.yaml
scripts/resources/api_files/domain.csv.sh $name "0.0.0.0" >apis/$name/mesh/domains/$name.domain.ingress.json
scripts/resources/api_files/listener.sh $name >apis/$name/mesh/listeners/$name.listener.ingress.json
scripts/resources/api_files/proxy.sh $name >apis/$name/mesh/proxies/$name.proxy.json
scripts/resources/api_files/edge.cluster.sh $name >apis/$name/mesh/clusters/edge.$name.cluster.json
scripts/resources/api_files/local.cluster.csv.sh $name "0.0.0.0" "80" >apis/$name/mesh/clusters/local.cluster.json
scripts/resources/api_files/edge.rules.sh $name >apis/$name/mesh/rules/edge.$name.rules.json
scripts/resources/api_files/local.rules.sh $name >apis/$name/mesh/rules/local.rules.json
scripts/resources/api_files/edge.route.sh $name >apis/$name/mesh/routes/edge.$name.route.json
scripts/resources/api_files/local.route.sh $name "" >apis/$name/mesh/routes/local.route.json
scripts/resources/api_files/edge.route.slash.sh $name >apis/$name/mesh/routes/edge.$name.route.slash.json
scripts/resources/api_files/catalog.sh $name "$display_name" "$owner" "$capability" "$docs" >apis/$name/mesh/catalog.$name.json

read -r -p "Apply the configs now? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    read -r -p "Apply to prod? [y/N] " prod
    if [[ "$prod" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        scripts/scripts/apply-new-api.sh "N" $name
    else
        scripts/scripts/apply-new-api.sh "Y" $name
    fi
fi
