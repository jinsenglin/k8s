#!/bin/bash

set -e

git clone https://github.com/stefanprodan/k8s-prom-hpa.git

kubectl apply -f k8s-prom-hpa/metrics-server

kubectl apply -f k8s-prom-hpa/namespaces.yaml
kubectl apply -f k8s-prom-hpa/prometheus
kubectl apply -f k8s-prom-hpa/custom-metrics-api
