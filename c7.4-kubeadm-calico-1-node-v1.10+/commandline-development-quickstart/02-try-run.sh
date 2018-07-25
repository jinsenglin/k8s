#!/bin/bash

set -e
set -o pipefail

function main() {
    export GOPATH=~/go
    export KUBECONFIG=/etc/kubernetes/admin.conf

    cd $GOPATH/src/github.com/cclin81922/k8s-image-changer
        # just copy and paste the sample code
        # cp sample-code/-gitignore .gitignore
        # cp sample-code/Makefile .
        # cp sample-code/v1.11.x-Gopkg.toml Gopkg.toml
        # cp sample-code/cmd/image-changer/* cmd/image-changer/
        # then 
        $GOPATH/bin/dep ensure
        go build -o out/image-changer github.com/cclin81922/k8s-image-changer/cmd/image-changer
        make
        kubectl run nginx --image=nginx:1.14.0
        ./out/image-changer -kubeconfig=$KUBECONFIG -deploy=nginx -container=nginx -image=nginx:1.15.0
        kubectl delete deploy nginx
        git add -A
        git commit -m "pass try-run"
}

main
