#!/bin/bash

echo decipher email: 
read DockerProductionUsername
echo docker production password:
read -s DockerProductionPassword

echo index.docker.io username: 
read IndexDockerUsername
echo index.docker.io password:
read -s IndexDockerPassword

# install k3d 1.7.0
curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | TAG=v1.7.0 bash

# Check if there's already a greymatter cluster, if so delete it
if [[ "$(k3d list)" == *"greymatter"* ]]
then
    k3d delete --name greymatter
fi

# Create 4 workers for a greymatter cluster
k3d create --workers 4 --name greymatter --publish 30000:10808
while [[ $(k3d get-kubeconfig --name='greymatter') != *kubeconfig.yaml ]]; do echo "echo waiting for k3d cluster to start up" && sleep 10; done

export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"

echo "Cluster is connected"

# Apply kubernetes yaml files in order
for folder in kubeseal spire fabric sense
do
    kubectl apply -f $folder/namespace.yaml
    find $folder/*.yaml ! -name "namespace.yaml" ! -name "*sealedsecret.yaml" ! -name "registrar.validatingwebhookconfiguration.yaml" -exec kubectl apply -f {} \;
done

echo ""
echo "files applied"
echo ""

# Apply secrets

export AUTHORITY_FINGERPRINT="$(acert authorities create -n 'Quickstart' -o 'Grey Matter')"

ServerCaIntermediateCrt="$(acert authorities export ${AUTHORITY_FINGERPRINT} -t certificate -f pem)"
ServerCaIntermediateKey="$(acert authorities export ${AUTHORITY_FINGERPRINT} -t key -f pem)"
ServerCaRootCrt="$(acert authorities export ${AUTHORITY_FINGERPRINT} -t authority -f pem)"

export REGISTRAR_FINGERPRINT=$(acert authorities issue ${AUTHORITY_FINGERPRINT} -n 'registrar.spire.svc')

ServerTlsCaCrt="$(acert leaves export ${REGISTRAR_FINGERPRINT} -t authority -f pem)"
ServerTlsRegistrarSpireSvcCrt="$(acert leaves export ${REGISTRAR_FINGERPRINT} -t certificate -f pem)"
ServerTlsRegistrarSpireSvcKey="$(acert leaves export ${REGISTRAR_FINGERPRINT} -t key -f pem)"

ObjectivesPostgresDatabase="greymatter"
ObjectivesPostgresHost=""
ObjectivesPostgresUsername="greymatter"
ObjectivesPostgresPassword="greymatter"
ObjectivesPostgresPort="5432"


kubectl create secret generic server-ca --namespace "spire" --from-literal=intermediate.crt="$ServerCaIntermediateCrt" --from-literal=intermediate.key="$ServerCaIntermediateKey" --from-literal=root.crt="$ServerCaRootCrt"

kubectl create secret generic server-tls --namespace "spire" --from-literal=ca.crt="$ServerTlsCaCrt" --from-literal=registrar.spire.svc.crt="$ServerTlsRegistrarSpireSvcCrt" --from-literal=registrar.spire.svc.key="$ServerTlsRegistrarSpireSvcKey"

sed "s/caBundle: .*/caBundle: $(acert leaves export ${REGISTRAR_FINGERPRINT} -t authority -f pem | base64)/" spire/registrar.validatingwebhookconfiguration.yaml > spire/overlay.registrar.validatingwebhookconfiguration.yaml
kubectl apply  -f spire/overlay.registrar.validatingwebhookconfiguration.yaml
rm spire/overlay.registrar.validatingwebhookconfiguration.yaml


for folder in fabric sense
do
    kubectl create secret docker-registry docker.production.deciphernow.com --namespace $folder --docker-server=docker.production.deciphernow.com --docker-username=$DockerProductionUsername --docker-password=$DockerProductionPassword
    kubectl create secret docker-registry index.docker.io --namespace $folder --docker-server=index.docker.io --docker-username=$IndexDockerUsername --docker-password=$IndexDockerPassword --docker-email=$IndexDockerUsername
done

kubectl create secret generic objectives-postgres --namespace "sense" --from-literal=database=$ObjectivesPostgresDatabase --from-literal=host=$ObjectivesPostgresHost --from-literal=username=$ObjectivesPostgresUsername --from-literal=password=$ObjectivesPostgresPassword --from-literal=port=$ObjectivesPostgresPort

echo ""
echo "secrets applied"
echo ""
