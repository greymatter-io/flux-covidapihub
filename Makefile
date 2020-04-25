SHELL := /bin/bash


.PHONY: k3d
k3d: run-k3d k3d-setup-k8

.PHONY: k3d-all
k3d-all: k3d mesh k3d-api

# Instrall and run k3d
.PHONY: run-k3d
run-k3d:
	./scripts/scripts/k3d-install-and-run.sh

# Apply yaml files to k3d
.PHONY: k3d-setup-k8
k3d-setup-k8:
	source ./scripts/scripts/kubeconfig-k3d.sh; \
	./scripts/scripts/k3d-setup-k8.sh

# Apply mesh configs to k3d
.PHONY: mesh
mesh:
	source ./scripts/scripts/kubeconfig-k3d.sh; \
	./scripts/scripts/mesh-config.sh "k3d"

# Apply API related yaml files and json files to k3d
.PHONY: k3d-api
k3d-api:
	source ./scripts/scripts/kubeconfig-k3d.sh; \
    ./scripts/scripts/k3d-setup-k8-api.sh; \
	./scripts/scripts/mesh-api.sh "k3d"

# Clean ports, delete k3d cluster, and empty acert folder.
.PHONY: clean
clean:
	./scripts/scripts/clean-ports.sh; \
	./scripts/scripts/clean-k3d.sh; \
	./scripts/scripts/clean-acert.sh

# Deploy meshconfig to prod. You must have OIDC client ID and secret in your credential.sh file.
.PHONY: mesh-prod
mesh-prod:
	source ./scripts/scripts/kubeconfig-aws.sh; \
	./scripts/scripts/mesh-config.sh "prod"
	./scripts/scripts/mesh-api.sh "prod"

.PHONY: new-api
new-api:
	./scripts/scripts/new-api.sh

.PHONY: apply-api-prod
apply-api-prod:
	./scripts/scripts/apply-new-api.sh "N"

.PHONY: apply-api
apply-api:
	./scripts/scripts/apply-new-api.sh "Y"

.PHONY: delete-api
delete-api:
	./scripts/scripts/delete-api.sh

.PHONY: new-csv
new-csv:
	./scripts/scripts/new-csv.sh