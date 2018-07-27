#!/bin/bash

set -e
set -o pipefail

function main() {
    export GOPATH=~/go
    export KUBECONFIG=/etc/kubernetes/admin.conf

    cd $GOPATH/src/k8s.io/sample-controller
        go run *.go -kubeconfig=$KUBECONFIG
}

main
