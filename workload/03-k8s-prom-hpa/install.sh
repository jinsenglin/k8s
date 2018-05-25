#!/bin/bash

set -e

git clone https://github.com/stefanprodan/k8s-prom-hpa.git

kubectl apply -f k8s-prom-hpa/metrics-server

kubectl apply -f k8s-prom-hpa/namespaces.yaml
kubectl apply -f k8s-prom-hpa/prometheus

<<OPT1
yum install golang
    wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
    chmod +x cfssl_linux-amd64
    mv cfssl_linux-amd64 /usr/local/bin/cfssl

    wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
    chmod +x cfssljson_linux-amd64
    mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

    export PATH=$PATH:/usr/local/bin
make certs

cd k8s-prom-hpa
kubectl apply -f ./custom-metrics-api
OPT1

# OPT2
cp cm-adapter-serving-certs.yaml k8s-prom-hpa/custom-metrics-api
kubectl apply -f k8s-prom-hpa/custom-metrics-api
