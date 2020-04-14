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

folders=(ingress fabric sense data website)

# Apply kubernetes yaml files in order
for folder in "${folders[@]}"; do
    kubectl apply -f $folder/namespace.yaml
done

echo ""
echo "namespaces applied"
echo ""

# Apply secrets

export AUTHORITY_FINGERPRINT=$(acert authorities create -n "Covid API Hub" -o "Decipher Technology Studios" -c "US")
export PUBLIC_FINGERPRINT=$(acert authorities issue ${AUTHORITY_FINGERPRINT} -n 'public.ingress.svc')
export PRIVATE_FINGERPRINT=$(acert authorities issue ${AUTHORITY_FINGERPRINT} -n 'private.ingress.svc')

PublicCaCrt="$(acert leaves export ${PUBLIC_FINGERPRINT} -t authority -f pem)"
PublicCrt="$(acert leaves export ${PUBLIC_FINGERPRINT} -t certificate -f pem)"
PublicKey="$(acert leaves export ${PUBLIC_FINGERPRINT} -t key -f pem)"
PrivateCaCrt="$(acert leaves export ${PRIVATE_FINGERPRINT} -t authority -f pem)"
PrivateCrt="$(acert leaves export ${PRIVATE_FINGERPRINT} -t certificate -f pem)"
PrivateKey="$(acert leaves export ${PRIVATE_FINGERPRINT} -t key -f pem)"

kubectl create secret generic public.ingress.svc \
    --namespace "ingress" \
    --from-literal=ca.crt="$PublicCaCrt" \
    --from-literal=public.ingress.svc.crt="$PublicCrt" \
    --from-literal=public.ingress.svc.key="$PublicKey"

kubectl create secret generic private.ingress.svc \
    --namespace "ingress" \
    --from-literal=ca.crt="$PrivateCaCrt" \
    --from-literal=private.ingress.svc.crt="$PrivateCrt" \
    --from-literal=private.ingress.svc.key="$PrivateKey"

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

kubectl apply -f ci/resources/dev.ingress.yaml
echo ""
echo "ingress applied"
echo ""

for folder in "${folders[@]}"; do
    echo "==================================$folder"
    if [[ $folder == "ingress" ]]
    then
        for f in ingress/private*.yaml; do kubectl apply -f $f; done
    else
        find $folder/*.yaml ! -name "namespace.yaml" ! -name "*sealedsecret.yaml" ! -name "registrar.validatingwebhookconfiguration.yaml" -exec kubectl apply -f {} \;
    fi
done


kubectl apply -f ci/resources/dashboard.deployment.yaml
echo ""
echo "files applied"
echo ""
