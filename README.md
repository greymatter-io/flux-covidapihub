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

If you would like to deploy all the APIs to your local k3d, you can run:

```
make k3d-api
```

## Adding an API

To add an api to the mesh by proxy, run the following:

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
- Owner URL: relevant link back to the source. This could be the owner's homepage or a landing page for the specific api if available
- Capability: catability for catalog entry - corresponds to contentType [here](https://github.com/greymatter-io/covidapihub-site/blob/master/public/mock.json)
- Documentation: Docs link

Example:

For example, to create a deployment and configs for [this api](https://api.census.gov/data/2019/pep/population) from [this entry](https://github.com/greymatter-io/covidapihub-site/blob/7f1eb7fff72f77ccf9389bfac5c2bded889b9d55/public/mock.json#L203-L224) - these are the entries:

1. API Name: `us-census-population`
2. Host: `api.census.gov`
3. Port: `443`
4. Path: `/data/2019/pep/population`
5. Display Name: `US Census Bureau - Population`
6. Owner: `Census Bureau`
7. Owner URL: `https://www.census.gov`
8. Capability: `governance`
9. Documentation URL: `https://www.census.gov/data/developers/data-sets/popest-popproj.html`

### Troubleshooting


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

## Adding a CSV

To add a csv, run the following:

```bash
make new-csv
```

It will prompt you for the following information:

- API Name: an all lowercase, no spaces or special characters name for the deployment. This will dictate the route to this api - it will be `https://covidapihub.io/apis/<api_name>`
- URL: this is the url to the csv file online
- Source format: if the url to the csv/xslx did not have a file extension, you need to specify it here
- Skip rows: If the spreadsheet is irregular, you can specify specific rows to skip. They don't need to be sequential. This is a comma delimted list of row numbers, 1-indexed. e.g., if the data in the sheet starts at row 5, you would enter '1,2,3,4'.
- Sheet Name: if the dataset is xlsx, you must specify the name of the sheet that the API will serve up.
- Display Name: display name for catalog entry
- Owner: owner for catalog entry
- Owner URL: Relevant link back to the source. This could be the owner's homepage or documentation for the specific dataset if available
- Capability: capability for catalog entry - corresponds to contentType [here](https://github.com/greymatter-io/covidapihub-site/blob/master/public/mock.json)
- Docs link: link to docs, for csv's we want to point to apier's docs, so just use the default which is `/apis/{api_name}/docs/`
- Description: Description of the API used in dashboard service view
- Updates: Frequency of updates to the dataset ex. Daily, Monthly, 5 Minutes, Not Specified
- Coverage: geographic coverage of the data e.g. World, US, Italy
- Format: format of the data. This should be "JSON" plus the original format (CSV, XSLX, etc.)
  
Example:

1. API Name: `nyt-us-csv`
2. URL: `https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv`
3. Source format:
4. Skip rows: n
5. Sheet Name: 
6. Display Name: `NYT US Data`
7. Owner: `New York Times`
8. Owner URL: `https://github.com/nytimes/covid-19-data`
9. Capability: `health`
10. Docs link: `/apis/nyt-us-csv/docs/`
11. Description: `An ongoing repository of data on coronavirus cases and deaths in the U.S.`
12. Updates: `Daily`
13. Coverage: `US`
14. Format: `JSON, CSV`
  
Once this is done, you will need to copy the resulting catalog configs and paste them into the catalog container env. These variables are also saved in a gitignore'd file located at `apis/{service}/mesh/catalog.envvars.yaml`.

If you're deploying locally, you can type `Y` to apply GM configs and the service's k8s deployment files, or `N` if you want to inspect the configuration before applying - it will be stored in `apis/<api_name>` directory. If applying, it will prompt you with `Apply to prod? [y/N]`, if you want to apply the api immediately to prod type Y, otherwise type N to apply to your local dev environment.

If you want to delete an api deployment and mesh configs, run `make delete-api` and type the `api_name` when prompted. If you want to delete the api from your local dev environment, type `Y` when it prompts `Delete API in dev? [y/N]`.

If you want to apply an api from a set of already generated configs in your local dev environment, run `make apply-api` and type the `api_name` when prompted.  To apply an api from a set of already generated configs in prod, run `make apply-api-prod`.
