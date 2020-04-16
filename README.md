# flux-covidapihub
This repository contains the Kuberenetes resources deployed to [Covid API Hub](https://covidapihub.io). The resources within this repository are periodically checked and deployed, updated or deleted by [Flux](https://docs.fluxcd.io/en/1.18.0/).

## Secrets
The respository ignores any files that match the pattern `*.secret.yaml`. This is done in a meager attempt to prevent sensitive data from being checked into the repository unencrypted. Instead, secrets should be encrypted using the `kubeseal` utility for [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets). There are a number of ways to produce a sealed secret but the simplest is to create a regular Kuberenetes secret locally with the desired content.  For example:

```
kubectl create secret generic word -n dictionary -o yaml --from-literal=value=bird --dry-run > ./word.secret.yaml
```

Then generate a sealed secret from this secret using the public key in the root of this repository:

```
kubeseal -o yaml --cert ./.kubeseal.pem < ./word.secret.yaml > ./word.sealedsecret.yaml
```

The content of `./word.sealedsecret.yaml` is suitable for commiting into the repository and will be decrypted to match the content of `./word.secret.yaml` in the cluster.

## Running Locally with K3D

### With Makefile

Run `make k3d mesh` in order to start up a four-worker [k3d](https://github.com/rancher/k3d) cluster locally on port 30000.  It will apply the various yamls and create secrets for local development.  Part of the secret creation includes using [acert](https://github.com/deciphernow/acert) so that needs to be installed before running the script.

Note that this will not change which environment your `kubectl` is pointing to. Make sure to run `export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"` to use the kubeconfig for that cluster and be able to use `kubectl` commands.

When using Chrome, you will get a security warning which can be bypassed by typing `thisisunsafe`.

### With run script
At the root of this repo, it has run.sh script. By running this like so:
```
. ./run.sh
```

It will run `make k3d mesh` as described above, but also change your `KUBECONFIG` environment variable.
