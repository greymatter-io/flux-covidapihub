#!/bin/bash
export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"

kubectl create namespace ingress

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