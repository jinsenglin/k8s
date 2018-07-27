#!/bin/bash

set -e
set -o pipefail

function main() {
    export GOPATH=~/go
    mkdir -p $GOPATH/src/github.com/k8s.io
    cp -r sample-controller-kubernetes-1.11.1 $GOPATH/src/github.com/k8s.io/sample-controller
}

main
