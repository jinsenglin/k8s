#!/bin/bash

set -e
set -o pipefail

function main() {
    export GOPATH=~/go
    export KUBECONFIG=/etc/kubernetes/admin.conf

    cd $GOPATH/src/github.com/cclin81922/k8s-pod-monitor
        # just copy and paste the sample code
        # cp sample-code/Dockerfile .
        # cp sample-code/-gitignore .gitignore
        # cp sample-code/k8s-namespace.yaml .
        # cp sample-code/k8s-pod.yaml .
        # cp sample-code/k8s-clusterrolebinding.yaml .
        # cp sample-code/Makefile .
        # cp sample-code/v1.11.x-Gopkg.toml Gopkg.toml
        # cp sample-code/cmd/pod-monitor/* cmd/pod-monitor/
        # cp sample-code/internal/controller/* internal/controller/
        # then 
        $GOPATH/bin/dep ensure
        go build -o out/pod-monitor github.com/cclin81922/k8s-pod-monitor/cmd/pod-monitor
        make
        docker build -t k8s-pod-monitor:latest .
        kubectl apply -f k8s-namespace.yaml -f k8s-clusterrolebinding.yaml -f k8s-pod.yaml
        kubectl -n dev get po
        kubectl -n dev logs pod-monitor
        kubectl delete -f k8s-namespace.yaml -f k8s-clusterrolebinding.yaml -f k8s-pod.yaml
        docker rmi k8s-pod-monitor:latest # also need manually remove the builder stage image
        git add -A
        git commit -m "pass try-run"
}

main
