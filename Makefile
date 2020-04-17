SHELL := /bin/bash

# This makefile provides a shortcut to creating a local k3d cluster

.PHONY: k3d
k3d:
	./ci/scripts/k3d.sh

.PHONY: mesh
mesh:
	./ci/scripts/mesh-config.sh

.PHONY: new-api
new-api:
	./ci/scripts/new-api.sh

.PHONY: apply-api
apply-api:
	./ci/scripts/apply-new-api.sh

.PHONY: delete-api
delete-api:
	./ci/scripts/delete-api.sh