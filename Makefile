SHELL := /bin/bash

# This makefile provides a shortcut to creating a local k3d cluster

.PHONY: k3d
k3d:
	./scripts/scripts/k3d.sh

.PHONY: mesh-prod
mesh:
	./scripts/scripts/mesh-config.sh "N"

.PHONY: mesh
mesh-dev:
	./scripts/scripts/mesh-config.sh "Y"

.PHONY: new-api
new-api:
	./scripts/scripts/new-api.sh

.PHONY: apply-api-prod
apply-api:
	./scripts/scripts/apply-new-api.sh "N"

.PHONY: apply-api
apply-api-dev:
	./scripts/scripts/apply-new-api.sh "Y"

.PHONY: delete-api
delete-api:
	./scripts/scripts/delete-api.sh