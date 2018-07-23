#!/bin/bash

set -e
set -o pipefail

function main() {
    export GOPATH=~/go
    export KUBECONFIG=/etc/kubernetes/admin.conf

    cd $GOPATH/src/github.com/cclin81922/k8s-pod-monitor
        # just copy and paste the sample code
        # cp sample-code/skaffold.yaml .
        # then
        skaffold run
        git add -A
        git commit -m "pass try-skaffold"
}

main
