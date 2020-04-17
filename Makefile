SHELL := /bin/bash

# This makefile provides a shortcut to creating a local k3d cluster

.PHONY: k3d
k3d:
	./scripts/scripts/k3d.sh

.PHONY: mesh
mesh:
	./scripts/scripts/mesh-config.sh

.PHONY: new-api
new-api:
	./scripts/scripts/new-api.sh

.PHONY: apply-api
apply-api:
	./scripts/scripts/apply-new-api.sh

.PHONY: delete-api
delete-api:
	./scripts/scripts/delete-api.sh