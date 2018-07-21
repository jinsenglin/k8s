#!/bin/bash

set -e
set -o pipefail

function main() {
    # just copy and paste the sample code
    # then 
    dep ensure
    go build -o out/pod-monitor github.com/cclin81922/k8s-pod-monitor/cmd/pod-monitor
    make
    docker build -t k8s-pod-monitor:latest .
    kubectl apply -f k8s-pod.yaml
    kubectl delete -f k8s-pod.yaml
}

main
