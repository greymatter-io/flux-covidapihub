#!/bin/bash

NAME=$1
CSV_URL=$2
SHEETS=$3
SKIP_ROWS=$4
SOURCE_FORMAT=$5

#define the template.
cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    kompose.cmd: kompose convert -f docker-compose.yml
    kompose.version: 1.21.0 ()
  creationTimestamp: null
  labels:
    io.kompose.service: apier
    app: $NAME
    cluster: apis.$NAME
  name: $NAME
  namespace: apis
spec:
  replicas: 1
  selector:
    matchLabels:
      io.kompose.service: apier
      app: $NAME
      cluster: apis.$NAME
  strategy: {}
  template:
    metadata:
      annotations:
        kompose.cmd: kompose convert -f docker-compose.yml
        kompose.version: 1.21.0 ()
      creationTimestamp: null
      labels:
        io.kompose.service: apier
        app: $NAME
        cluster: apis.$NAME
    spec:
      serviceAccountName: apis-sa
      containers:
      - name: apier
        env:
        - name: SHEETS
          value: $SHEETS

        - name: SHEET_SKIP_ROWS
          value: $SKIP_ROWS
        - name: SOURCE_FORMAT
          value: $SOURCE_FORMAT


        - name: SOURCE_URL
          value: $CSV_URL
        image: docker.greymatter.io/development/gm-apier:2.0.0
        imagePullPolicy: Always
        ports:
        - containerPort: 8000
        volumeMounts:
          - name: swagger-static
            mountPath: /app/static
            readOnly: true
      - name: sidecar
        image: "docker-dev.production.deciphernow.com/deciphernow/gm-proxy:1.5.1"
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
        volumeMounts:
          - name: sidecar-config
            mountPath: /etc/greymatter
            readOnly: true
          - name: spire-socket
            mountPath: /run/spire/sockets
            readOnly: false
      imagePullSecrets:
        - name: docker-dev.production.deciphernow.com
      volumes:
        - name: spire-socket
          hostPath:
            path: /run/spire/sockets
            type: DirectoryOrCreate
        - name: sidecar-config
          configMap:
            name: $NAME-sidecar
        - name: swagger-static
          configMap:
            name: $NAME-swagger
EOF
