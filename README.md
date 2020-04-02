# flux-covidapihub
This repository contains the Kuberenetes resources deployed to [Covid API Hub](https://covidapihub.io). The resources within this repository are periodically checked and deployed, updated or deleted by [Flux](https://docs.fluxcd.io/en/1.18.0/).

## Secrets
The respository ignores any files that match the pattern `*.secret.yaml`. This is done in a meager attempt to prevent sensitive data from being checked into the repository unencrypted. Instead, secrets should be encrypted using the `kubeseal` utility for [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets). There are a number of ways to produce a sealed secret but the simplest is to create a regular Kuberenetes secret locally with the desired content.  For example:

```
kubectl create secret generic word -n dictionary -o yaml --from-literal=value=bird --dry-run > ./word.secret.yaml
```

Then generate a sealed secret from this secret using the public key in the root of this repository:

```
kubeseal --cert ./.kubeseal.pem < ./word.secret.yaml > ./word.sealedsecret.yaml
```

The content of `./word.sealedsecret.yaml` is suitable for commiting into the repository and will be decrypted to match the content of `./word.secret.yaml` in the cluster.
