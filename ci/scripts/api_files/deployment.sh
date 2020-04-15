#!/bin/bash

API_NAME=$1

#define the template.
cat  << EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: $API_NAME
    cluster: apis.$API_NAME
  name: $API_NAME
  namespace: apis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $API_NAME
      cluster: apis.$API_NAME
  template:
    metadata:
      labels:
        app: $API_NAME
        cluster: apis.$API_NAME
    spec:
      serviceAccountName: apis-sa
      containers:
        - name: $API_NAME-proxy
          image: "docker.production.deciphernow.com/deciphernow/gm-proxy:1.2.2"
          imagePullPolicy: IfNotPresent
          args:
            - -c
            - /etc/greymatter/config.yaml
          command:
            - /app/gm-proxy
          ports:
            - name: metrics
              containerPort: 8080
            - name: sidecar
              containerPort: 8443
          env:
            - name: ENVOY_LOG_LEVEL
              value: "debug"
          volumeMounts:
            - name: sidecar-config
              mountPath: /etc/greymatter
              readOnly: true
            - name: spire-socket
              mountPath: /run/spire/sockets
              readOnly: false
      imagePullSecrets:
        - name: docker.production.deciphernow.com
      volumes:
        - name: spire-socket
          hostPath:
            path: /run/spire/sockets
            type: DirectoryOrCreate
        - name: sidecar-config
          configMap:
            name: $API_NAME-sidecar
EOF