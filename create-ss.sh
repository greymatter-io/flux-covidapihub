#!/bin/bash
DIR=$1
for f in $DIR/*.secret.yaml; do
    echo $f
    # spire/server.tls.secret.yaml --> spire/server.tls.sealedsecret.yaml
    sealedsecret=$(echo $f | awk '{
        gsub(".secret.yaml", ".sealedsecret.yaml")
        print $0
    }')
    kubeseal --cert ./.kubeseal.pem -o yaml <$f >$sealedsecret
done
