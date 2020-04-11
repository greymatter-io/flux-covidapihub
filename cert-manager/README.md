# cert-manager

## Version

The current version is `v.0.14.2` (for Kubernetes version 1.15+)

## Preparation

[cert-manager](htts://cert-manager.io) is a tool that automatically requests and renews certificates from LetsEncrypt

To upgrade cert-manager, download the single manifest file from their [Installation instructions](https://cert-manager.io/docs/installation/kubernetes/). Then run `ruby split.rb <file>` to decompose the manifest into multiple files.

## Installation

The cert-manager CRDs need to be installed with `--validate=false` flag.  Currently, Flux cannot support this, so the CRDs must be applied manually.

To ensure Flux does not attempt to modify the CRD files, add this line to the annotation field for the CRDs

```yaml
annotations:
  fluxcd.io/ignore: "true"
```