#!/bin/bash

set -e
set -o pipefail

function main() {
    export GOPATH=~/go
    export KUBECONFIG=/etc/kubernetes/admin.conf

    cd $GOPATH/src/k8s.io/sample-controller
        kubectl create -f artifacts/examples/crd.yaml
        kubectl create -f artifacts/examples/example-foo.yaml
        go run *.go -kubeconfig=$KUBECONFIG
        kubectl get deployments
        kubectl delete -f artifacts/examples/example-foo.yaml
        kubectl delete -f artifacts/examples/crd.yaml
}

main
