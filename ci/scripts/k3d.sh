#!/bin/bash

if [ ! -f ci/scripts/credentials.sh ]
then
    echo decipher email:
    read DockerProductionUsername
    echo docker production password:
    read -s DockerProductionPassword

    echo index.docker.io username:
    read IndexDockerUsername
    echo index.docker.io password:
    read -s IndexDockerPassword

    TEMPLATE=ci/scripts/credentials.template
    cp $TEMPLATE ci/scripts/credentials.sh
    sed -i '' "s/DPUsername/\"${DockerProductionUsername}\"/g" ci/scripts/credentials.sh
    sed -i '' "s/DPPassword/\"${DockerProductionPassword}\"/g"  ci/scripts/credentials.sh
    sed -i '' "s/IDUsername/\"${IndexDockerUsername}\"/g"  ci/scripts/credentials.sh
    sed -i '' "s/IDPassword/\"${IndexDockerPassword}\"/g"  ci/scripts/credentials.sh
fi

source ./ci/scripts/credentials.sh

# install k3d 1.7.0
curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | TAG=v1.7.0 bash

# Check if there's already a greymatter cluster, if so delete it
if [[ "$(k3d list)" == *"greymatter"* ]]; then
    k3d delete --name greymatter
fi

# Create 4 workers for a greymatter cluster
k3d create --workers 4 --name greymatter --publish 30000:8443
while [[ $(k3d get-kubeconfig --name='greymatter') != *kubeconfig.yaml ]]; do echo "echo waiting for k3d cluster to start up" && sleep 10; done

export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"

echo "Cluster is connected"

folders=(edge fabric sense data website)

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
    kubectl create secret docker-registry docker.production.deciphernow.com --namespace $folder --docker-server=docker.production.deciphernow.com --docker-username=$DockerProductionUsername --docker-password=$DockerProductionPassword
    kubectl create secret docker-registry index.docker.io --namespace $folder --docker-server=index.docker.io --docker-username=$IndexDockerUsername --docker-password=$IndexDockerPassword --docker-email=$IndexDockerUsername
done

kubectl create secret generic objectives-postgres --namespace "sense" --from-literal=database=$ObjectivesPostgresDatabase --from-literal=host=$ObjectivesPostgresHost --from-literal=username=$ObjectivesPostgresUsername --from-literal=password=$ObjectivesPostgresPassword --from-literal=port=$ObjectivesPostgresPort

echo ""
echo "secrets applied"
echo ""

kubectl apply -f spire/server.dev.yaml
sleep 60
kubectl apply -f spire/agent.dev.yaml

echo ""
echo "spire applied"
echo ""


for folder in "${folders[@]}"; do
    echo "================================== $folder"
    if [[ $folder == "edge" ]]
    then
        kubectl apply -f ci/resources/edge.service.yaml
        kubectl apply -f edge/edge.serviceaccount.yaml
        kubectl apply -f edge/edge.sidecar.configmap.yaml
        kubectl apply -f edge/edge.deployment.yaml
    else
        find $folder/*.yaml ! -name "namespace.yaml" ! -name "*secret.yaml" ! -name "registrar.validatingwebhookconfiguration.yaml" -exec kubectl apply -f {} \;
    fi
done


kubectl apply -f ci/resources/dashboard.deployment.yaml

echo ""
echo "files applied"
echo ""


kubectl apply -f ci/resources/edge.ingress.yaml

echo ""
echo "ingress applied"
echo ""
