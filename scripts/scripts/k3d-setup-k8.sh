#!/bin/bash

source ./scripts/scripts/credentials.sh

if [[ "$(kubectl config current-context)" != "greymatter" ]]; then
    echo "⛔️⛔️⛔️⛔️⛔ You are about to apply yaml file to non-k3d environment ⛔️⛔️⛔️⛔️⛔️"
    exit 1
fi

deployments=(edge fabric sense data website)
folders=("${deployments[@]}" "apis") # we just want to create namespace and secrets for apis.

# Apply kubernetes yaml files in order
for folder in "${folders[@]}"; do
    kubectl apply -f $folder/namespace.yaml
done

echo ""
echo "namespaces applied"
echo ""

# Apply secrets
export AUTHORITY_FINGERPRINT=$(acert authorities create -n "Covid API Hub" -o "Decipher Technology Studios" -c "US")
export FINGERPRINT=$(acert authorities issue ${AUTHORITY_FINGERPRINT} -n 'edge.svc')

EdgeCaCrt="$(acert leaves export ${FINGERPRINT} -t authority -f pem)"
EdgeCrt="$(acert leaves export ${FINGERPRINT} -t certificate -f pem)"
EdgeKey="$(acert leaves export ${FINGERPRINT} -t key -f pem)"

kubectl create secret generic edge.svc \
    --namespace "edge" \
    --from-literal=ca.crt="$EdgeCaCrt" \
    --from-literal=edge.svc.crt="$EdgeCrt" \
    --from-literal=edge.svc.key="$EdgeKey"

ObjectivesPostgresDatabase="greymatter"
ObjectivesPostgresHost=""
ObjectivesPostgresUsername="greymatter"
ObjectivesPostgresPassword="greymatter"
ObjectivesPostgresPort="5432"

for folder in "${folders[@]}"; do
    kubectl create secret docker-registry docker-dev.production.deciphernow.com --namespace $folder --docker-server=docker-dev.production.deciphernow.com --docker-username=$DockerProductionUsername --docker-password=$DockerProductionPassword
    kubectl create secret docker-registry index.docker.io --namespace $folder --docker-server=index.docker.io --docker-username=$IndexDockerUsername --docker-password=$IndexDockerPassword --docker-email=$IndexDockerUsername
done

kubectl create secret generic objectives-postgres --namespace "sense" --from-literal=database=$ObjectivesPostgresDatabase --from-literal=host=$ObjectivesPostgresHost --from-literal=username=$ObjectivesPostgresUsername --from-literal=password=$ObjectivesPostgresPassword --from-literal=port=$ObjectivesPostgresPort

echo ""
echo "secrets applied"
echo ""

kubectl apply -f spire/server.dev.yaml
echo "Waiting for Spire server to start... ⏱"
sleep 60
kubectl apply -f spire/agent.dev.yaml

echo ""
echo "spire applied"
echo ""

for folder in "${deployments[@]}"; do
    echo "================================== $folder"
    if [[ $folder == "edge" ]]; then
        kubectl apply -f scripts/resources/edge.service.yaml
        kubectl apply -f edge/edge.serviceaccount.yaml
        kubectl apply -f edge/edge.sidecar.configmap.yaml
        kubectl apply -f edge/edge.deployment.yaml
    else
        find $folder/*.yaml ! -name "namespace.yaml" ! -name "*secret.yaml" ! -name "registrar.validatingwebhookconfiguration.yaml" -exec kubectl apply -f {} \;
    fi
done

# Overwrite with development only configs
kubectl apply -f scripts/resources/dashboard.deployment.yaml
kubectl apply -f scripts/resources/data.statefulset.yaml
kubectl apply -f scripts/resources/local.secrets.yaml

echo ""
echo "files applied"
echo ""

kubectl apply -f scripts/resources/edge.ingress.yaml

echo ""
echo "ingress applied"
echo ""
