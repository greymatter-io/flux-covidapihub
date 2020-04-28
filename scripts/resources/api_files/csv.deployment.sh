#!/bin/bash

NAME=$1
CSV_URL=$2
SHEET_NAME=$3

#define the template.
cat  << EOF
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
        - name: SHEET_NAME
          value: $SHEET_NAME
        - name: FLASK_APP
          value: app/main.py
        - name: FLASK_DEBUG
          value: "0"
        - name: RUN
          value: flask run --host=0.0.0.0 --port=80
        - name: SOURCE_URL
          value: $CSV_URL
        image: covidapihub/apier:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 80
        volumeMounts:
          - name: swagger-static
            mountPath: /app/static
            readOnly: true
      - name: sidecar
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
        - name: swagger-static
          configMap:
            name: $NAME-swagger
EOF