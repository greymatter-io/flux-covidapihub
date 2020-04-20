# Access Control

This documentation explains what we did to allow POST/DELETE request to Catalog service while keeping the main site publically accessible. Also have a step-by-step instruction on how we can run this locally.

## Overview

In production, there is a path:
https://covidhubapi.io/login

This path contains a filter chain which checks whether a user has a valid access token in the cookie. Otherwise, a user gets redirected to Google authentication page.

The other filter chain which is accessible https://covidhubapi.io checks whether a request has a valid access token in the header (`access_token`). It will not do anything if it does not exist; remove it if it is invalid. The RBAC filter will allow GET request whether the requestr header contains access token or not, and it allows other requests (POST, PUT, DELETE, etc) if and only if the request has an access token header.

## Running this locally

Make sure you have k3d installed and run the following:

```
export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"
make k3d mesh
```

## The "login" route locally is:
https://localhost:30001

If you do not have a cookie "access_token", it will redirect you to a login page.
Otherwise, it is actually redirecting you to https://localhost:30000 - but redirect process chops off the port at the time of writing (https://github.com/DecipherNow/greymatter/issues/326), so you will end up in https://localhost and it will give you 443 error page. I think this will look okay when we are redirecting to https://covidapihub.io in prod. If you open up https://localhost:30000, you will see the access_token it acquired.

This route has validation filter that removes stale access_token cookie if found.

## The "public" route is:
https://localhost:30000

This route has a validation filter that will remove access_token header if it is not valid, and RBAC filter will only allow non-GET request when it has access_token header. This route does not care about the cookie that gets passed around (whether it's missing, invalid, or expired).

## How to access Catalog:
```
curl -k -L --location --request POST 'https://localhost:30000/catalog/latest/clusters' \
--header 'access_token: ya29.a0Ae4lvC31rtfO-qvnRTQEqmygsawSspEgsZp1tLTAvPLI7SztU2gJ7uoAAWZnCNd8NNFdravJDz25ATctbtxAq4NFWIO-LzyrpaGeDldcViBc7SCGTnmV9YgBi9GrVwmE1cnV2cSg4EehyXkpOatP2-AZ9fkQ3rmHCZs' \
--header 'Content-Type: application/json' \
--data-raw '{
  "clusterName": "example-service",
  "zoneName": "default.zone",
  "name": "Example Service",
  "version": "1.0",
  "owner": "Decipher",
  "capability": "Example",
  "runtime": "GO",
  "documentation": "/services/example-service/1.0/",
  "prometheusJob": "example-service",
  "minInstances": 1,
  "maxInstances": 1,
  "authorized": true,
  "enableInstanceMetrics": true,
  "enableHistoricalMetrics": false,
  "metricsPort": 8081
}'
```
Replace the access_token with what you have in your cookie. If successful, it will either create a cluster for you, or complain that "Cluster already exists in Zone".

Now if you send `made-up-token-that-should-not-be-allowed` like so :

```
curl -k -L --location --request POST 'https://localhost:30000/catalog/latest/clusters' \
--header 'access_token: made-up-token-that-should-not-be-allowed' \
--header 'Content-Type: application/json' \
--data-raw '{
  "clusterName": "example-service",
  "zoneName": "default.zone",
  "name": "Example Service",
  "version": "1.0",
  "owner": "Decipher",
  "capability": "Example",
  "runtime": "GO",
  "documentation": "/services/example-service/1.0/",
  "prometheusJob": "example-service",
  "minInstances": 1,
  "maxInstances": 1,
  "authorized": true,
  "enableInstanceMetrics": true,
  "enableHistoricalMetrics": false,
  "metricsPort": 8081
}'
```

It will return `RBAC: access denied`