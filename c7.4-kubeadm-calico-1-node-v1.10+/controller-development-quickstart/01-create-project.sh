#!/bin/bash

set -e
set -o pipefail

function main() {
    export GOPATH=~/go
    mkdir -p $GOPATH/src/github.com/cclin81922/k8s-pod-monitor

    cd $GOPATH/src/github.com/cclin81922/k8s-pod-monitor
        mkdir -p cmd/pod-monitor pkg internal out
        $GOPATH/bin/dep init
        touch Makefile
        touch Dockerfile
        touch skaffold.yaml
        touch cmd/pod-monitor/main.go
        touch .gitignore
        git init
        git add -A
        git commit -m "init"
}

main
