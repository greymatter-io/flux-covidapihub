#!/bin/bash

NAME=$1

#define the template.
cat  << EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: $NAME
    cluster: apis.$NAME
  name: $NAME
  namespace: apis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $NAME
      cluster: apis.$NAME
  template:
    metadata:
      labels:
        app: $NAME
        cluster: apis.$NAME
    spec:
      serviceAccountName: apis-sa
      containers:
        - name: $NAME-proxy
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
            name: $NAME-sidecar
EOF