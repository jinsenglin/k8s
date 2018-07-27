#!/bin/bash

set -e
set -o pipefail

function main() {
    export GOPATH=~/go
    export KUBECONFIG=/etc/kubernetes/admin.conf

    cd $GOPATH/src/k8s.io/sample-controller
        # Terminal 1
        kubectl create -f artifacts/examples/crd.yaml
        go run *.go -kubeconfig=$KUBECONFIG
        kubectl delete -f artifacts/examples/crd.yaml

        # Terminal 2
        kubectl create -f artifacts/examples/example-foo.yaml
        kubectl get foo
        kubectl get deployments example-foo
        kubectl delete -f artifacts/examples/example-foo.yaml
        kubectl get foo
        kubectl get deployments example-foo
}

main
