#!/bin/bash

echo API Name:
read name
echo URL:
read csv_url

fmt="${csv_url##*.}"
if [[ "$fmt" =~ ^(xls|xlsx|xlsm|xlsb|odf)$ ]]; then
    echo "Sheet Name: "
    read sheet_name
elif [[ "$fmt" != "csv" ]]; then
    echo "Source format: "
    read source_format
    echo "Sheet Name: (leave empty if not applicable)"
    read sheet_name
fi

read -r -p "Skip rows? (Y/n):" skiprows
if [[ "$skiprows" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "list of rows to skip: (ex. 0,5,10)"
    read skip_rows
fi


echo Display Name:
read display_name
echo Owner:
read owner
echo Owner URL:
read owner_url
echo "Capability (health, governance, etc.)":
read content_type
echo "Docs link (default /apis/$name/docs/)":
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

content_type=$(perl -e "print lc('$content_type');")
content_type="$(tr '[:lower:]' '[:upper:]' <<<${content_type:0:1})${content_type:1}"

capability=\"\\\"{\\\\\\\"name\\\\\\\":\\\\\\\"$display_name\\\\\\\",\\\\\\\"url\\\\\\\":\\\\\\\"$csv_url\\\\\\\",\\\\\\\"description\\\\\\\":\\\\\\\"${description}\\\\\\\",\\\\\\\"source\\\\\\\":\\\\\\\"$owner\\\\\\\",\\\\\\\"contentType\\\\\\\":[\\\\\\\"$content_type\\\\\\\"],\\\\\\\"homePage\\\\\\\":\\\\\\\"$owner_url\\\\\\\",\\\\\\\"thumbnail\\\\\\\":\\\\\\\"$thumbnail\\\\\\\",\\\\\\\"coverage\\\\\\\":[\\\\\\\"$coverage\\\\\\\"],\\\\\\\"format\\\\\\\":[\\\\\\\"$format\\\\\\\"],\\\\\\\"updates\\\\\\\":[\\\\\\\"$updates\\\\\\\"]}\\\"\"

mkdir apis/$name
mkdir apis/$name/mesh
mkdir apis/$name/mesh/clusters
mkdir apis/$name/mesh/domains
mkdir apis/$name/mesh/listeners
mkdir apis/$name/mesh/routes
mkdir apis/$name/mesh/proxies
mkdir apis/$name/mesh/rules
scripts/resources/api_files/csv.deployment.sh $name $csv_url "$sheet_name" "$skip_rows" "$source_format" >apis/$name/$name.deployment.yaml
scripts/resources/api_files/swagger.configmap.sh $name "$display_name" $docs >apis/$name/$name.swagger.configmap.yaml
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
scripts/resources/api_files/catalog.sh $name "$display_name" "$owner" "$capability" "/apis/$name/docs/" >apis/$name/mesh/catalog.$name.json

echo ""
echo "Generating Catalog envvars, checking covidapihub for number of services"
count=$(curl -k https://covidapihub.io/catalog/latest/zones/default.zone | jq .clusterCount)
count=$((count + 1))
echo "The current service count is: $count, incrementing by 1"
count=$((count + 1))
scripts/resources/catalog.envvars.sh $name "$display_name" "$owner" "$capability" "/apis/$name/docs/" "$count" >apis/$name/mesh/catalog.envvars.yaml
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
