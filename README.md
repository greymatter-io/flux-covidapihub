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
source ./run.sh
```

It will run `make k3d mesh` as described above, but also change your `KUBECONFIG` environment variable.

## Adding an API

To add an api to the mesh, run the following:

```bash
make new-api
```

It will prompt you for the following information:

- API Name: an all lowercase, no spaces or special characters name for the deployment. This will dictate the route to this api - it will be `https://covidapihub.io/apis/<api_name>`
- Host: hostname of the api
- Port: port of the api
- Path: path to the api, it should being with `/`.
- Display Name: display name for catalog entry
- Owner: owner for catalog entry
- Capability: catability for catalog entry - corresponds to contentType [here](https://github.com/greymatter-io/covidapihub-site/blob/master/public/mock.json)
- Documentation: API doc/spec if available
Example:

For example, to create a deployment and configs for [this api](https://api.census.gov/data/2019/pep/population) from [this entry](https://github.com/greymatter-io/covidapihub-site/blob/7f1eb7fff72f77ccf9389bfac5c2bded889b9d55/public/mock.json#L203-L224) - these are the entries:

1. API NAME: `us-census-population`
2. Host: `api.census.gov`
3. Port: `443`
4. Path: `/data/2019/pep/population`
5. Display Name: `US Census Bureau - Population`
6. Owner: `Census Bureau`
7. Capability: `Governance`
8. Documentation URL: `https://www.census.gov/data/developers/data-sets/popest-popproj.html`

Once this is done, if you're deploying locally, you can type `Y` to apply configs, or `N` if you want to inspect the configuration before applying - it will be stored in `apis/<api_name>` directory. If applying, it will prompt you with `Apply to prod? [y/N]`, if you want to apply the api immediately to prod type Y, otherwise type N to apply to your local dev environment.

Some API's sit behind load balancers and will need to add an SNI field. This will let the request know which backend server to go to. If you are having trouble proxying, try adding this field to the local cluster object:

```json
  "ssl_config": {
    "cipher_filter": "",
    "protocols": null,
    "sni": "api.census.gov"
  }
```

**NOTE**: If an API is returning an html response in a browser for an endpoing when it should be returning json, try adding a custom `Accept` header to it's domain object to tell it to accept content-type application/json:

```json
    {
      "key": "Accept",
      "value": "application/json"
    }
```

If you want to delete an api deployment and mesh configs, run `make delete-api` and type the `api_name` when prompted. If you want to delete the api from your local dev environment, type `Y` when it prompts `Delete API in dev? [y/N]`.

If you want to apply an api from a set of already generated configs in your local dev environment, run `make apply-api` and type the `api_name` when prompted.  To apply an api from a set of already generated configs in prod, run `make apply-api-prod`.
