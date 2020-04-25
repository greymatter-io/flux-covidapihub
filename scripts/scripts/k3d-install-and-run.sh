#!/bin/bash

if [ ! -f scripts/scripts/credentials.sh ]; then
    echo decipher email:
    read DockerProductionUsername
    echo docker production password:
    read -s DockerProductionPassword

    echo index.docker.io username:
    read IndexDockerUsername
    echo index.docker.io password:
    read -s IndexDockerPassword

    TEMPLATE=scripts/scripts/credentials.template
    cp $TEMPLATE scripts/scripts/credentials.sh
    sed -i '' "s/DPUsername/\"${DockerProductionUsername}\"/g" scripts/scripts/credentials.sh
    sed -i '' "s/DPPassword/\"${DockerProductionPassword}\"/g" scripts/scripts/credentials.sh
    sed -i '' "s/IDUsername/\"${IndexDockerUsername}\"/g" scripts/scripts/credentials.sh
    sed -i '' "s/IDPassword/\"${IndexDockerPassword}\"/g" scripts/scripts/credentials.sh
fi

# install k3d 1.7.0
curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | TAG=v1.7.0 bash

# Check if there's already a greymatter cluster, if so delete it
if [[ "$(k3d list 2>/dev/null)" == *"greymatter"* ]]; then
    k3d delete --name greymatter
fi

# Create 4 workers for a greymatter cluster
k3d create --workers 4 --name greymatter --publish 30000:8443 --publish 30001:9443

while [[ $(k3d get-kubeconfig --name='greymatter' 2>/dev/null) != *kubeconfig.yaml ]]; do
    echo "waiting for k3d cluster to start up" && sleep 10
done

echo "🌸 k3d cluster is up and running 🌸"